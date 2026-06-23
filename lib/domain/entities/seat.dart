class Seat {
  final String id;
  final String busId;
  final int seatNumber;
  final String status;
  final String? lastTouchedBy;
  final DateTime updatedAt;

  Seat({
    required this.id,
    required this.busId,
    required this.seatNumber,
    required this.status,
    this.lastTouchedBy,
    required this.updatedAt,
  });
}
