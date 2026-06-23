import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConductorProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  String? _conductorId;
  String? _conductorName;
  String? _conductorPhone;
  String? _assignedBusId;
  String? _busNumber;
  String? _busRoute;
  bool _isShareingLocation = false;
  bool _isLoading = true;
  String _statusMessage = 'Initializing...';
  Timer? _locationTimer;
  double? _lastLatitude;
  double? _lastLongitude;
  String? _currentLocationName;

  // Getters
  String? get conductorId => _conductorId;
  String? get conductorName => _conductorName;
  String? get conductorPhone => _conductorPhone;
  String? get assignedBusId => _assignedBusId;
  String? get busNumber => _busNumber;
  String? get busRoute => _busRoute;
  bool get isShareingLocation => _isShareingLocation;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;
  String? get currentLocationName => _currentLocationName;

  ConductorProvider() {
    _initializeConductor();
  }

  Future<void> _initializeConductor() async {
    try {
      _isLoading = true;
      _statusMessage = 'Loading conductor data...';
      notifyListeners();

      // Get current user
      final user = supabase.auth.currentUser;
      if (user == null) {
        _statusMessage = 'Not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _conductorId = user.id;

      // Fetch conductor details and assigned bus
      final response = await supabase
          .from('conductors')
          .select('name, phone, assigned_bus_id')
          .eq('id', _conductorId!)
          .single();

      _conductorName = response['name'];
      _conductorPhone = response['phone'];
      _assignedBusId = response['assigned_bus_id'];

      if (_assignedBusId != null) {
        // Fetch bus details including route
        final busResponse = await supabase
            .from('buses')
            .select('bus_no, route')
            .eq('id', _assignedBusId!)
            .single();

        _busNumber = busResponse['bus_no'];
        _busRoute = busResponse['route'];
        _statusMessage = 'Ready to share location';
      } else {
        _statusMessage = 'No bus assigned';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing conductor: $e');
      _statusMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> toggleLocationSharing() async {
    if (_assignedBusId == null) {
      _statusMessage = 'No bus assigned to you';
      notifyListeners();
      return;
    }

    if (_isShareingLocation) {
      // Stop sharing
      _stopLocationSharing();
    } else {
      // Start sharing
      _startLocationSharing();
    }
  }

  void _startLocationSharing() async {
    try {
      _statusMessage = 'Checking location services...';
      notifyListeners();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _statusMessage = 'Location services are disabled. Please enable location on your device.';
        notifyListeners();
        return;
      }

      _statusMessage = 'Requesting location permissions...';
      notifyListeners();

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _statusMessage = 'Location permission denied';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _statusMessage = 'Location permission permanently denied';
        notifyListeners();
        return;
      }

      _isShareingLocation = true;
      _statusMessage = '🔴 LIVE - Sharing location';
      notifyListeners();

      // First location update
      await _updateLocationToDatabase();

      // Start periodic updates every 10 seconds
      _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _updateLocationToDatabase();
      });
    } catch (e) {
      debugPrint('Error starting location sharing: $e');
      _statusMessage = 'Error: ${e.toString()}';
      _isShareingLocation = false;
      notifyListeners();
    }
  }

  void _stopLocationSharing() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _isShareingLocation = false;
    _statusMessage = '⚫ Offline - Not sharing';
    notifyListeners();
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=16'
      );
      final request = await client.getUrl(uri);
      request.headers.set('user-agent', 'StarTravalBusBooking/1.0 (contact: support@startraval.com)');
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        final address = data['address'];
        if (address != null) {
          final road = address['road'];
          final suburb = address['suburb'] ?? address['neighbourhood'] ?? address['suburb_district'];
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['city_district'] ?? address['county'];
          
          List<String> parts = [];
          if (road != null) parts.add(road);
          if (suburb != null) parts.add(suburb);
          if (city != null) parts.add(city);
          
          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
        return data['display_name'] ?? 'Unknown Location';
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
    return 'Unknown Location';
  }

  Future<void> _updateLocationToDatabase() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;

      // Reverse geocode position to name
      String locationName = 'Unknown Location';
      try {
        locationName = await _getAddressFromLatLng(position.latitude, position.longitude);
      } catch (e) {
        debugPrint('Error geocoding: $e');
      }
      _currentLocationName = locationName;

      // Check if a location record already exists for this bus
      final response = await supabase
          .from('bus_locations')
          .select('id')
          .eq('bus_id', _assignedBusId!)
          .maybeSingle();

      if (response != null) {
        // Update the existing record
        await supabase
            .from('bus_locations')
            .update({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'location_name': locationName,
              'timestamp': DateTime.now().toIso8601String(),
            })
            .eq('id', response['id']);
      } else {
        // Insert a new record
        await supabase.from('bus_locations').insert({
          'bus_id': _assignedBusId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'location_name': locationName,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      // Update status with latest location
      _statusMessage =
          '🔴 LIVE - ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      notifyListeners();

      debugPrint(
        'Location updated: ${position.latitude}, ${position.longitude}, Name: $locationName',
      );
    } catch (e) {
      debugPrint('Error updating location: $e');
      _statusMessage = 'Error updating location: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
