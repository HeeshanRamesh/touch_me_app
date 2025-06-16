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
      id: json['_id'],
      customerName: json['customerId']?['firstName'] ?? 'N/A',
      serviceName: json['saloonServiceId']?['serviceName'] ?? 'N/A',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
