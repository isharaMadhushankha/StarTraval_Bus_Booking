class BookingModel {
  final String id;
  final String userId;
  final String busId;
  final List<int> seatNumbers;
  final double totalAmount;
  final String paymentStatus; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final bool isArchived;
  final DateTime? tripDate;

  BookingModel({
    required this.id,
    required this.userId,
    required this.busId,
    required this.seatNumbers,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    this.isArchived = false,
    this.tripDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['user_id'],
      busId: json['bus_id'],
      seatNumbers: List<int>.from(json['seat_numbers']),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
      isArchived: json['is_archived'] ?? false,
      tripDate: json['trip_date'] != null ? DateTime.parse(json['trip_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bus_id': busId,
      'seat_numbers': seatNumbers,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'is_archived': isArchived,
      'trip_date': tripDate?.toIso8601String(),
    };
  }
}
