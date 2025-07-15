// models/booking.dart
class Booking {
  final String id;
  final String customerName;
  final String serviceName;
  final String date;
  final String time;
  final String status;

  Booking({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? json['id'] ?? '',
      customerName:
          json['customerId']?['name'] ??
          'N/A', // Changed from firstName to name
      serviceName: json['saloonServiceId']?['serviceName'] ?? 'N/A',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
