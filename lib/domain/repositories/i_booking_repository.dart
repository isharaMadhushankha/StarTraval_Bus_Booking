import '../entities/booking.dart';

abstract class IBookingRepository {
  Future<void> createBooking(Booking booking);
  Future<List<Booking>> getUserBookings(String userId);
  Future<void> archiveBookingsByBusId(String busId);
}
