import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../services/supabase_service.dart';

class BookingProvider extends ChangeNotifier {
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<bool> createBooking(BookingModel booking) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // 1. Double check seat availability before final booking (Concurrency Control)
      final seatsResponse = await SupabaseService.client
          .from('seats')
          .select('status')
          .eq('bus_id', booking.busId)
          .inFilter('seat_number', booking.seatNumbers);
      
      final anyNotSelecting = (seatsResponse as List).any((s) => s['status'] != 'selecting');
      if (anyNotSelecting) {
        throw Exception('Some seats were taken while you were paying.');
      }

      // 2. Create Booking record
      await SupabaseService.client.from('bookings').insert(booking.toJson());

      // 3. Update Seats to 'booked'
      await SupabaseService.client
          .from('seats')
          .update({'status': 'booked'})
          .eq('bus_id', booking.busId)
          .inFilter('seat_number', booking.seatNumbers);

      return true;
    } catch (e) {
      debugPrint('Booking Error: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
