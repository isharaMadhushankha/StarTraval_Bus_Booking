import 'package:flutter/material.dart';
import '../../../data/models/bus_model.dart';
import '../../../services/supabase_service.dart';

class AdminBusProvider extends ChangeNotifier {
  List<BusModel> _allBuses = [];
  List<BusModel> _filteredBuses = [];
  bool _isLoading = false;

  // Filter fields
  String _searchFrom = '';
  String _searchTo = '';
  DateTime? _searchDate;

  List<BusModel> get buses =>
      _filteredBuses.isEmpty &&
          _searchFrom.isEmpty &&
          _searchTo.isEmpty &&
          _searchDate == null
      ? _allBuses
      : _filteredBuses;
  bool get isLoading => _isLoading;
  String get searchFrom => _searchFrom;
  String get searchTo => _searchTo;
  DateTime? get searchDate => _searchDate;

  void _applyFilters() {
    _filteredBuses = _allBuses.where((bus) {
      // Filter by From location (departure location)
      if (_searchFrom.isNotEmpty) {
        final busRoute = bus.route.toLowerCase();
        final departureLocation = bus.departureLocation?.toLowerCase() ?? '';
        final fromFilter = _searchFrom.toLowerCase();
        if (!busRoute.contains(fromFilter) &&
            !departureLocation.contains(fromFilter)) {
          return false;
        }
      }

      // Filter by To location (arrival location)
      if (_searchTo.isNotEmpty) {
        final busRoute = bus.route.toLowerCase();
        final arrivalLocation = bus.arrivalLocation?.toLowerCase() ?? '';
        final toFilter = _searchTo.toLowerCase();
        if (!busRoute.contains(toFilter) &&
            !arrivalLocation.contains(toFilter)) {
          return false;
        }
      }

      // Filter by Date
      if (_searchDate != null) {
        final departureDate = DateTime(
          bus.departureTime.year,
          bus.departureTime.month,
          bus.departureTime.day,
        );
        final selectedDateOnly = DateTime(
          _searchDate!.year,
          _searchDate!.month,
          _searchDate!.day,
        );
        if (departureDate != selectedDateOnly) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  Future<void> fetchAllBuses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await SupabaseService.client
          .from('buses')
          .select()
          .order('departure_time', ascending: true);
      _allBuses = (response as List)
          .map((json) => BusModel.fromJson(json))
          .toList();
      _filteredBuses = _allBuses;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBus(BusModel bus) async {
    try {
      await SupabaseService.client.from('buses').insert(bus.toJson());
      await fetchAllBuses();
    } catch (e) {
      debugPrint('Error adding bus: $e');
    }
  }

  Future<void> updateBus(BusModel bus) async {
    try {
      await SupabaseService.client
          .from('buses')
          .update(bus.toJson())
          .eq('id', bus.id);
      await fetchAllBuses();
    } catch (e) {
      debugPrint('Error updating bus: $e');
      rethrow;
    }
  }

  Future<void> toggleBusStatus(String busId, bool isActive) async {
    try {
      debugPrint('=== TOGGLE START ===');
      debugPrint('Updating bus: $busId to isActive: $isActive');
      debugPrint('Current user ID: ${SupabaseService.currentUserId}');

      // Update local state immediately
      final busIndex = _allBuses.indexWhere((bus) => bus.id == busId);
      if (busIndex != -1) {
        final oldBus = _allBuses[busIndex];
        _allBuses[busIndex] = BusModel(
          id: oldBus.id,
          busNo: oldBus.busNo,
          route: oldBus.route,
          departureTime: oldBus.departureTime,
          totalSeats: oldBus.totalSeats,
          pricePerSeat: oldBus.pricePerSeat,
          isActive: isActive,
          statusNote: oldBus.statusNote,
          tripDate: oldBus.tripDate,
          arrivalTime: oldBus.arrivalTime,
          arrivalStatus: oldBus.arrivalStatus,
          estimatedArrivalTime: oldBus.estimatedArrivalTime,
        );
        notifyListeners();
        debugPrint('Local state updated');
      }

      // Update database - try different approaches
      debugPrint('Executing database update with RPC...');
      try {
        // Try using RPC if available
        final result = await SupabaseService.client.rpc(
          'update_bus_status',
          params: {'bus_id': busId, 'is_active': isActive},
        );
        debugPrint('RPC update result: $result');
      } catch (rpcError) {
        debugPrint('RPC failed, trying direct update: $rpcError');
        final result = await SupabaseService.client
            .from('buses')
            .update({'is_active': isActive})
            .eq('id', busId);
        debugPrint('Direct update result: $result');
      }

      // Fetch fresh data
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Fetching all buses...');
      await fetchAllBuses();

      final updatedBus = _allBuses.cast<BusModel?>().firstWhere(
        (b) => b?.id == busId,
        orElse: () => null,
      );
      if (updatedBus != null) {
        debugPrint(
          'After fetch, bus id=$busId isActive=${updatedBus.isActive}',
        );
        if (updatedBus.isActive != isActive) {
          debugPrint(
            'WARNING: Update did not persist! Expected $isActive but got ${updatedBus.isActive}',
          );
          debugPrint(
            'This is likely a Supabase RLS policy issue. Check your Row Level Security settings.',
          );
        }
      }
      debugPrint('=== TOGGLE END ===');
    } catch (e) {
      debugPrint('Error toggling status: $e');
      rethrow;
    }
  }

  Future<void> deleteBus(String busId) async {
    try {
      await SupabaseService.client.from('buses').delete().eq('id', busId);
      await fetchAllBuses();
    } catch (e) {
      debugPrint('Error deleting bus: $e');
    }
  }

  Future<void> clearSeatsForBus(String busId) async {
    try {
      final now = DateTime.now();

      // Archive all active bookings for this bus
      await SupabaseService.client
          .from('bookings')
          .update({'is_archived': true, 'trip_date': now.toIso8601String()})
          .eq('bus_id', busId)
          .eq('is_archived', false);

      // Reset all seats to available
      await SupabaseService.client
          .from('seats')
          .update({'status': 'available', 'last_touched_by': null})
          .eq('bus_id', busId);

      // Mark bus as arrived and completed
      await SupabaseService.client
          .from('buses')
          .update({
            'arrival_time': now.toIso8601String(),
            'arrival_status': 'completed',
            'trip_date': DateTime(
              now.year,
              now.month,
              now.day,
            ).toIso8601String(),
          })
          .eq('id', busId);

      await fetchAllBuses();
    } catch (e) {
      debugPrint('Error clearing seats: $e');
      rethrow;
    }
  }

  void setSearchFrom(String value) {
    _searchFrom = value;
    _applyFilters();
  }

  void setSearchTo(String value) {
    _searchTo = value;
    _applyFilters();
  }

  void setSearchDate(DateTime? date) {
    _searchDate = date;
    _applyFilters();
  }

  void clearFilters() {
    _searchFrom = '';
    _searchTo = '';
    _searchDate = null;
    _filteredBuses = _allBuses;
    notifyListeners();
  }
}