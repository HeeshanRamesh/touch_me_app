class Merchant {
  final String id;
  final String outletName;
  final String outletPhone;
  final String logoUrl;
  final String location;
  final String ownerName;

  Merchant({
    required this.id,
    required this.outletName,
    required this.outletPhone,
    required this.logoUrl,
    required this.location,
    required this.ownerName,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    // Debug print to inspect the incoming JSON
    print('ℹ️ Raw merchant JSON: ${json.toString()}');

    // Handle ID extraction with multiple fallbacks
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    if (id.isEmpty) {
      print('⚠️ Critical: Merchant ID is empty in JSON!');
    }

    return Merchant(
      id: id,
      outletName: json['outlet']?['name'] ?? 'Unknown Outlet',
      outletPhone: json['outlet']?['phone'] ?? 'N/A',
      logoUrl: json['businessRegistration']?['logo'] ?? '',
      location: json['outlet']?['location'] ?? 'Unknown Location',
      ownerName: json['owner']?['name'] ?? 'Unknown Owner',
    );
  }

}
