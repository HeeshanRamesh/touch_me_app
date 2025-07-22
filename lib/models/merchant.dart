class Merchant {
  final String id;
  final String outletName;
  final String outletPhone;
  final String logoUrl;
  final String outletPictureUrl; // NEW
  final String ownerName;
  final String address;
  final double? rating;
  final int? reviews;
  final double latitude; // NEW
  final double longitude; // NEW

  Merchant({
    required this.id,
    required this.outletName,
    required this.outletPhone,
    required this.logoUrl,
    required this.outletPictureUrl, // NEW
    required this.ownerName,
    required this.address,
    this.rating,
    this.reviews,
    required this.latitude, // NEW
    required this.longitude, // NEW
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    print('ℹ Raw merchant JSON: ${json.toString()}');

    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    if (id.isEmpty) {
      print('⚠ Critical: Merchant ID is empty in JSON!');
    }

    final outlet = json['outlet'] ?? {};
    final businessRegistration = json['businessRegistration'] ?? {};
    final owner = json['owner'] ?? {};

    return Merchant(
      id: id,
      outletName: outlet['name'] ?? 'Unknown Outlet',
      outletPhone: outlet['phone'] ?? 'N/A',
      logoUrl: businessRegistration['logo'] ?? '',
      outletPictureUrl: outlet['picture'] ?? '', // <-- NEW
      ownerName: owner['name'] ?? 'Unknown Owner',
      address: outlet['address'] ?? '',
      rating:
          (json['rating'] is int)
              ? (json['rating'] as int).toDouble()
              : (json['rating'] as double?) ?? 5.0,
      reviews: json['reviews'] as int?,
      latitude: outlet['latitude']?.toDouble() ?? 0.0, // NEW
      longitude: outlet['longitude']?.toDouble() ?? 0.0, // NEW
    );
  }
}