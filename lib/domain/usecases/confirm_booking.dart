import '../entities/booking.dart';
import '../repositories/i_booking_repository.dart';

class ConfirmBooking {
  final IBookingRepository repository;

  ConfirmBooking(this.repository);

  Future<void> call(Booking booking) async {
    await repository.createBooking(booking);
  }
}
