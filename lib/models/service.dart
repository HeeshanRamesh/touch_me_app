class Service {
  final String id;
  final String serviceName;
  final String serviceDescription;
  final int price;
  final String image;
  final bool isActive;
  final String? duration; 
  final String? specialOffer;
  

  Service({
    required this.id,
    required this.serviceName,
    required this.serviceDescription,
    required this.price,
    required this.image,
    this.isActive = true,
    this.duration,
    this.specialOffer,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    print('ℹ️ Parsing service JSON: $json');
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    if (id.isEmpty) {
      print('⚠️ Warning: Service ID is empty in JSON');
    }
    return Service(
      id: id,
      serviceName: json['serviceName']?.toString() ?? 'Unknown Service',
      serviceDescription:
          json['serviceDescription']?.toString() ?? 'No description',
      price: (json['price'] is num) ? json['price'].toInt() : 0,
      image: json['image']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      duration: json['duration']?.toString() ?? '',
      specialOffer: json['specialOffer']?.toString() ?? '',
    );
  }
}
