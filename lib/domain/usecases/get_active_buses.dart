import '../entities/bus.dart';
import '../repositories/i_bus_repository.dart';

class GetActiveBuses {
  final IBusRepository repository;

  GetActiveBuses(this.repository);

  Future<List<Bus>> call() async {
    return await repository.getActiveBuses();
  }
}
