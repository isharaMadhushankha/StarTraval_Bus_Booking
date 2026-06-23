class Bus {
  final String id;
  final String busNo;
  final String route;
  final DateTime departureTime;
  final int totalSeats;
  final double pricePerSeat;
  final bool isActive;
  final String? statusNote;

  Bus({
    required this.id,
    required this.busNo,
    required this.route,
    required this.departureTime,
    required this.totalSeats,
    required this.pricePerSeat,
    this.isActive = true,
    this.statusNote,
  });
}
