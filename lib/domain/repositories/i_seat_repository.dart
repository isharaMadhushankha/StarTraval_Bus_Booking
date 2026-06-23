import '../entities/seat.dart';

abstract class ISeatRepository {
  Future<List<Seat>> getSeatsByBusId(String busId);
  Future<void> updateSeatStatus(String seatId, String status, String? userId);
  Stream<List<Seat>> watchSeats(String busId);
  Future<void> resetAllSeatsByBusId(String busId);
}
