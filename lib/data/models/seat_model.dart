class SeatModel {
  final String id;
  final String busId;
  final int seatNumber;
  final String status; // 'available', 'selecting', 'booked'
  final String? lastTouchedBy;
  final DateTime updatedAt;

  SeatModel({
    required this.id,
    required this.busId,
    required this.seatNumber,
    required this.status,
    this.lastTouchedBy,
    required this.updatedAt,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['id'],
      busId: json['bus_id'],
      seatNumber: json['seat_number'],
      status: json['status'],
      lastTouchedBy: json['last_touched_by'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'last_touched_by': lastTouchedBy,
    };
  }
}
