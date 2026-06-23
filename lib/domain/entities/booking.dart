class Booking {
  final String id;
  final String userId;
  final String busId;
  final List<int> seatNumbers;
  final double totalAmount;
  final String paymentStatus;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.busId,
    required this.seatNumbers,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
  });
}
