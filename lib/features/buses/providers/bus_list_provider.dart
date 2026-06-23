import 'package:flutter/material.dart';
import '../../../data/models/bus_model.dart';
import '../../../services/supabase_service.dart';

class BusListProvider extends ChangeNotifier {
  List<BusModel> _allBuses = [];
  List<BusModel> _filteredBuses = [];
  bool _isLoading = false;
  String? _error;
  List<String> _bookedBusIds = [];
  Map<String, String> _bookedBusLocations = {}; // busId -> locationName

  // Filter fields
  String? _fromLocation;
  String? _toLocation;
  DateTime? _selectedDate;

  List<BusModel> get buses =>
      _filteredBuses.isEmpty &&
          _fromLocation == null &&
          _toLocation == null &&
          _selectedDate == null
      ? _allBuses
      : _filteredBuses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get bookedBusIds => _bookedBusIds;
  Map<String, String> get bookedBusLocations => _bookedBusLocations;

  String? get fromLocation => _fromLocation;
  String? get toLocation => _toLocation;
  DateTime? get selectedDate => _selectedDate;

  Future<void> fetchBuses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('buses')
          .select()
          .eq('is_active', true)
          .order('departure_time', ascending: true);

      _allBuses = (response as List)
          .map((json) => BusModel.fromJson(json))
          .toList();
      _filteredBuses = _allBuses;

      // Fetch active user bookings
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        final bookingsResponse = await SupabaseService.client
            .from('bookings')
            .select('bus_id')
            .eq('user_id', userId)
            .eq('payment_status', 'completed');
        
        _bookedBusIds = (bookingsResponse as List)
            .map((b) => b['bus_id'].toString())
            .toList();

        if (_bookedBusIds.isNotEmpty) {
          final locationsResponse = await SupabaseService.client
              .from('bus_locations')
              .select('bus_id, location_name')
              .inFilter('bus_id', _bookedBusIds);

          _bookedBusLocations = {
            for (var loc in (locationsResponse as List))
              loc['bus_id'].toString(): loc['location_name'] as String? ?? 'Location not available yet'
          };
        } else {
          _bookedBusLocations = {};
        }
      } else {
        _bookedBusIds = [];
        _bookedBusLocations = {};
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFromLocation(String? from) {
    _fromLocation = from;
    _applyFilters();
  }

  void setToLocation(String? to) {
    _toLocation = to;
    _applyFilters();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredBuses = _allBuses.where((bus) {
      // Filter by From location
      if (_fromLocation != null && _fromLocation!.isNotEmpty) {
        final busRoute = bus.route.toLowerCase();
        final fromFilter = _fromLocation!.toLowerCase();
        if (!busRoute.contains(fromFilter)) {
          return false;
        }
      }

      // Filter by To location
      if (_toLocation != null && _toLocation!.isNotEmpty) {
        final busRoute = bus.route.toLowerCase();
        final toFilter = _toLocation!.toLowerCase();
        if (!busRoute.contains(toFilter)) {
          return false;
        }
      }

      // Filter by Date
      if (_selectedDate != null) {
        final departureDate = DateTime(
          bus.departureTime.year,
          bus.departureTime.month,
          bus.departureTime.day,
        );
        final selectedDateOnly = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        if (departureDate != selectedDateOnly) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _fromLocation = null;
    _toLocation = null;
    _selectedDate = null;
    _filteredBuses = _allBuses;
    notifyListeners();
  }
}
