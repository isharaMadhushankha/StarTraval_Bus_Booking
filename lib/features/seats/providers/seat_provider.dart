// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/seat_model.dart';
import '../../../services/supabase_service.dart';

class SeatProvider extends ChangeNotifier {
  List<SeatModel> _seats = [];
  bool _isLoading = false;
  String? _busId;
  RealtimeChannel? _channel;

  List<SeatModel> get seats => _seats;
  bool get isLoading => _isLoading;

  Future<void> fetchAndWatchSeats(String busId) async {
    _busId = busId;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Initial Fetch
      final response = await SupabaseService.client
          .from('seats')
          .select()
          .eq('bus_id', busId)
          .order('seat_number', ascending: true);

      _seats = (response as List)
          .map((json) => SeatModel.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();

      // 2. Subscribe to Realtime Updates
      _channel?.unsubscribe();
      _channel = SupabaseService.client
          .channel('seats:bus_id=eq.$busId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'seats',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'bus_id',
              value: busId,
            ),
            callback: (payload) {
              final newSeat = SeatModel.fromJson(payload.newRecord);
              final index = _seats.indexWhere((s) => s.id == newSeat.id);
              if (index != -1) {
                _seats[index] = newSeat;
              } else {
                _seats.add(newSeat);
              }
              notifyListeners();
            },
          )
          .subscribe();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSeatSelection(String seatId, String currentStatus) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    String newStatus;
    if (currentStatus == 'available') {
      newStatus = 'selecting';
    } else if (currentStatus == 'selecting') {
      // Check if it's the same user who is selecting
      final seat = _seats.firstWhere((s) => s.id == seatId);
      if (seat.lastTouchedBy == userId) {
        newStatus = 'available';
      } else {
        return; // Someone else is selecting
      }
    } else {
      return; // Already booked
    }

    // Update UI immediately (optimistic update)
    final seatIndex = _seats.indexWhere((s) => s.id == seatId);
    if (seatIndex != -1) {
      final updatedSeat = SeatModel(
        id: _seats[seatIndex].id,
        busId: _seats[seatIndex].busId,
        seatNumber: _seats[seatIndex].seatNumber,
        status: newStatus,
        lastTouchedBy: newStatus == 'selecting' ? userId : null,
        updatedAt: DateTime.now(),
      );
      _seats[seatIndex] = updatedSeat;
      notifyListeners(); // Immediate visual feedback
    }

    try {
      await SupabaseService.client
          .from('seats')
          .update({
            'status': newStatus,
            'last_touched_by': newStatus == 'selecting' ? userId : null,
          })
          .eq('id', seatId);
    } catch (e) {
      debugPrint('Error toggling seat: $e');
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
