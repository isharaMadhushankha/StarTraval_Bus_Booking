class BusModel {
  final String id;
  final String busNo;
  final String route;
  final DateTime departureTime;
  final int totalSeats;
  final double pricePerSeat;
  final bool isActive;
  final String? statusNote;
  final DateTime? tripDate;
  final DateTime? arrivalTime;
  final String? arrivalStatus;
  final DateTime? estimatedArrivalTime;
  final String? departureLocation;
  final String? arrivalLocation;
  final Duration? duration;
  final String? busType;
  final String? busModel;
  final String? busScheduleId;
  final DateTime? bookingClosingDateTime;
  final String? depotName;

  BusModel({
    required this.id,
    required this.busNo,
    required this.route,
    required this.departureTime,
    required this.totalSeats,
    required this.pricePerSeat,
    this.isActive = true,
    this.statusNote,
    this.tripDate,
    this.arrivalTime,
    this.arrivalStatus,
    this.estimatedArrivalTime,
    this.departureLocation,
    this.arrivalLocation,
    this.duration,
    this.busType,
    this.busModel,
    this.busScheduleId,
    this.bookingClosingDateTime,
    this.depotName,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'],
      busNo: json['bus_no'],
      route: json['route'],
      departureTime: DateTime.parse(json['departure_time']),
      totalSeats: json['total_seats'],
      pricePerSeat: (json['price_per_seat'] as num).toDouble(),
      isActive: json['is_active'] ?? true,
      statusNote: json['status_note'],
      tripDate: json['trip_date'] != null
          ? DateTime.parse(json['trip_date'])
          : null,
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'])
          : null,
      arrivalStatus: json['arrival_status'],
      estimatedArrivalTime: json['estimated_arrival_time'] != null
          ? DateTime.parse(json['estimated_arrival_time'])
          : null,
      departureLocation: json['departure_location'],
      arrivalLocation: json['arrival_location'],
      duration: json['duration'] != null ? Duration(minutes: json['duration'] as int) : null,
      busType: json['bus_type'],
      busModel: json['bus_model'],
      busScheduleId: json['bus_schedule_id'],
      bookingClosingDateTime: json['booking_closing_datetime'] != null
          ? DateTime.parse(json['booking_closing_datetime'])
          : null,
      depotName: json['depot_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bus_no': busNo,
      'route': route,
      'departure_time': departureTime.toIso8601String(),
      'total_seats': totalSeats,
      'price_per_seat': pricePerSeat,
      'is_active': isActive,
      'status_note': statusNote,
      'trip_date': tripDate?.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'arrival_status': arrivalStatus,
      'estimated_arrival_time': estimatedArrivalTime?.toIso8601String(),
      'departure_location': departureLocation,
      'arrival_location': arrivalLocation,
      'duration': duration?.inMinutes,
      'bus_type': busType,
      'bus_model': busModel,
      'bus_schedule_id': busScheduleId,
      'booking_closing_datetime': bookingClosingDateTime?.toIso8601String(),
      'depot_name': depotName,
    };
  }
}
