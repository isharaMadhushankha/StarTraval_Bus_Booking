import '../entities/bus.dart';

abstract class IBusRepository {
  Future<List<Bus>> getActiveBuses();
  Future<void> addBus(Bus bus);
  Future<void> updateBusStatus(String id, bool isActive);
  Future<void> deleteBus(String id);
  Future<void> markBusArrived(String busId, DateTime arrivalTime);
  Future<void> clearSeatsForBus(String busId);
}
