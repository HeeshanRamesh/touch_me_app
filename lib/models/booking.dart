class Booking {
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String saloonName;
  final String outletPhone; // New field for outlet phone
  final String outletAddress; // New field for outlet address
  final String date;
  final String time;
  final String status;
  final String price;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.saloonName,
    required this.outletPhone, // New required parameter
    required this.outletAddress, // New required parameter
    required this.date,
    required this.time,
    required this.status,
    required this.price,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Extract customer name: prefer customerName field, fallback to first_name + last_name
    String customerName = json['customerName'] ??
        ((json['customerId'] != null)
            ? '${json['customerId']['first_name'] ?? ''} ${json['customerId']['last_name'] ?? ''}'.trim()
            : 'N/A');

    // Extract customer phone: prefer customerPhone field, fallback to phone_number
    String customerPhone = json['customerPhone'] ??
        (json['customerId']?['phone_number'] ?? 'N/A');

    // Extract service name: handle nested saloonServiceId
    String serviceName = json['saloonServiceId']?['serviceName'] ?? 'N/A';

    // Extract service price: handle nested saloonServiceId
    String price = json['saloonServiceId']?['price']?.toString() ?? 'N/A';

    // Extract saloon name from nested merchant (prefer outlet.name, fallback to businessName or merchant name)
    String saloonName = 'N/A';
    String outletPhone = 'N/A';
    String outletAddress = 'N/A';
    final merchant = json['saloonServiceId']?['merchant'];
    if (merchant != null) {
      saloonName = merchant['outlet']?['name'] ?? // Primary: outlet name
                   merchant['businessName'] ??    // Fallback: business name
                   '${merchant['first_name'] ?? ''} ${merchant['last_name'] ?? ''}'.trim(); // Last fallback: merchant full name
      
      // New: Extract outlet phone and address
      outletPhone = merchant['outlet']?['phone'] ?? 'N/A';
      outletAddress = merchant['outlet']?['address'] ?? 'N/A';
    }

    return Booking(
      id: json['_id'] ?? json['id'] ?? '',
      customerName: customerName,
      customerPhone: customerPhone,
      serviceName: serviceName,
      saloonName: saloonName,
      outletPhone: outletPhone, // New field
      outletAddress: outletAddress, // New field
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      price: price,
    );
  }
}