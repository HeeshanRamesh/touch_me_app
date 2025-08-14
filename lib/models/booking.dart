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
    // Extract customer name: prefer customerName field, fallback to first_name + last_name
    String customerName = json['customerName'] ??
        ((json['customerId'] != null)
            ? '${json['customerId']['first_name'] ?? ''} ${json['customerId']['last_name'] ?? ''}'.trim()
            : 'N/A');

    // Extract service name: handle nested saloonServiceId
    String serviceName = json['saloonServiceId']?['serviceName'] ??
        'N/A';

    return Booking(
      id: json['_id'] ?? json['id'] ?? '',
      customerName: customerName,
      serviceName: serviceName,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
