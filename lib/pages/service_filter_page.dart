import 'package:flutter/material.dart';

class Service {
  final int id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final double price;
  final String type;
  final String discount;

  Service({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.type,
    required this.discount,
  });
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String searchTerm = '';
  String selectedLocation = '';
  String selectedDate = '';
  String priceRange = '';
  String serviceType = '';
  String sortBy = '';
  bool showFilters = false;

  final List<Service> services = [
    Service(
      id: 1,
      name: "Artistic Painting",
      location: "77 Paintwork Rd, Galle",
      rating: 4.7,
      reviews: 150,
      price: 2500,
      type: "Beauty & Wellness",
      discount: "Save up to 20% off",
    ),
    Service(
      id: 2,
      name: "Brows & Lashes",
      location: "123 Beauty St, Colombo",
      rating: 4.8,
      reviews: 200,
      price: 3500,
      type: "Beauty & Wellness",
      discount: "Save up to 15% off",
    ),
    Service(
      id: 3,
      name: "Spa Relaxation",
      location: "45 Wellness Ave, Kandy",
      rating: 4.6,
      reviews: 89,
      price: 5000,
      type: "Spa & Massage",
      discount: "Save up to 25% off",
    ),
    Service(
      id: 4,
      name: "Hair Styling Pro",
      location: "78 Style Rd, Negombo",
      rating: 4.9,
      reviews: 312,
      price: 2000,
      type: "Hair & Beauty",
      discount: "Save up to 30% off",
    ),
    Service(
      id: 5,
      name: "Nail Art Studio",
      location: "12 Fashion St, Colombo",
      rating: 4.5,
      reviews: 167,
      price: 1500,
      type: "Beauty & Wellness",
      discount: "Save up to 10% off",
    ),
    Service(
      id: 6,
      name: "Massage Therapy",
      location: "34 Relax Ave, Galle",
      rating: 4.8,
      reviews: 245,
      price: 4000,
      type: "Spa & Massage",
      discount: "Save up to 20% off",
    ),
  ];

  final List<String> locations = [
    "All Locations",
    "Colombo",
    "Galle",
    "Kandy",
    "Negombo"
  ];

  final List<Map<String, String>> priceRanges = [
    {"label": "All Prices", "value": ""},
    {"label": "Under Rs. 2000", "value": "0-2000"},
    {"label": "Rs. 2000 - Rs. 3000", "value": "2000-3000"},
    {"label": "Rs. 3000 - Rs. 4000", "value": "3000-4000"},
    {"label": "Above Rs. 4000", "value": "4000+"},
  ];

  final List<String> serviceTypes = [
    "Everyone",
    "Female",
    "Male",
    "Kids",
    "Door Step Service"
  ];

  final List<String> sortOptions = [
    "Popular",
    "Price: Low to High",
    "Price: High to Low",
    "Rating",
    "Newest"
  ];

  List<Service> get filteredServices {
    List<Service> filtered = services.where((service) {
      bool matchesSearch = service.name
          .toLowerCase()
          .contains(searchTerm.toLowerCase());
      
      bool matchesLocation = selectedLocation.isEmpty ||
          selectedLocation == "All Locations" ||
          service.location.contains(selectedLocation);
      
      bool matchesPrice = true;
      if (priceRange.isNotEmpty) {
        switch (priceRange) {
          case "0-2000":
            matchesPrice = service.price < 2000;
            break;
          case "2000-3000":
            matchesPrice = service.price >= 2000 && service.price <= 3000;
            break;
          case "3000-4000":
            matchesPrice = service.price >= 3000 && service.price <= 4000;
            break;
          case "4000+":
            matchesPrice = service.price > 4000;
            break;
        }
      }
      
      bool matchesType = serviceType.isEmpty ||
          serviceType == "Everyone" ||
          service.type == serviceType;
      
      return matchesSearch && matchesLocation && matchesPrice && matchesType;
    }).toList();

    if (sortBy.isNotEmpty) {
      switch (sortBy) {
        case "Price: Low to High":
          filtered.sort((a, b) => a.price.compareTo(b.price));
          break;
        case "Price: High to Low":
          filtered.sort((a, b) => b.price.compareTo(a.price));
          break;
        case "Rating":
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case "Popular":
          filtered.sort((a, b) => b.reviews.compareTo(a.reviews));
          break;
        case "Newest":
          filtered.sort((a, b) => b.id.compareTo(a.id));
          break;
      }
    }

    return filtered;
  }

  List<Service> get specialOffers {
    List<Service> offers = List.from(services);
    offers.sort((a, b) {
      String aDiscount = a.discount.replaceAll(RegExp(r'[^0-9]'), '');
      String bDiscount = b.discount.replaceAll(RegExp(r'[^0-9]'), '');
      int aPercent = int.tryParse(aDiscount) ?? 0;
      int bPercent = int.tryParse(bDiscount) ?? 0;
      return bPercent.compareTo(aPercent);
    });
    return offers.take(4).toList();
  }

  void _clearFilters() {
    setState(() {
      searchTerm = '';
      selectedLocation = '';
      selectedDate = '';
      priceRange = '';
      serviceType = '';
      sortBy = '';
      showFilters = false;
    });
  }

  void _showServiceTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Service Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose the type of service you\'re looking for:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ...serviceTypes.map((value) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(value),
                      leading: Radio<String>(
                        value: value,
                        groupValue: serviceType.isEmpty ? "Everyone" : serviceType,
                        onChanged: (String? newValue) {
                          setState(() {
                            serviceType = newValue ?? '';
                          });
                          Navigator.of(context).pop();
                        },
                        activeColor: Colors.purple[600],
                      ),
                      onTap: () {
                        setState(() {
                          serviceType = value;
                        });
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: serviceType == value ? Colors.purple[50] : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Sort Option',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose how to sort services:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ...sortOptions.map((value) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(value),
                      leading: Radio<String>(
                        value: value,
                        groupValue: sortBy.isEmpty ? "Popular" : sortBy,
                        onChanged: (String? newValue) {
                          setState(() {
                            sortBy = newValue ?? '';
                          });
                          Navigator.of(context).pop();
                        },
                        activeColor: Colors.purple[600],
                      ),
                      onTap: () {
                        setState(() {
                          sortBy = value;
                        });
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: sortBy == value ? Colors.purple[50] : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showPriceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Price Range',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose your price range:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                ...priceRanges.map((range) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(range['label']!),
                      leading: Radio<String>(
                        value: range['value']!,
                        groupValue: priceRange.isEmpty ? "" : priceRange,
                        onChanged: (String? newValue) {
                          setState(() {
                            priceRange = newValue ?? '';
                          });
                          Navigator.of(context).pop();
                        },
                        activeColor: Colors.purple[600],
                      ),
                      onTap: () {
                        setState(() {
                          priceRange = range['value']!;
                        });
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: priceRange == range['value'] ? Colors.purple[50] : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9D1E96),
                    Color(0xFF7E1878)
                  ],
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Services',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _clearFilters,
                              child: Text(
                                'Clear Filters',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchTerm = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by Business Name...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('Where...'),
                                  ],
                                ),
                                value: selectedLocation.isEmpty ? null : selectedLocation,
                                isExpanded: true,
                                items: locations.map((String location) {
                                  return DropdownMenuItem<String>(
                                    value: location,
                                    child: Text(
                                      location,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedLocation = newValue ?? '';
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'When...',
                                prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              onTap: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2026),
                                );
                                if (date != null) {
                                  setState(() {
                                    selectedDate = "${date.day}/${date.month}/${date.year}";
                                  });
                                }
                              },
                              readOnly: true,
                              controller: TextEditingController(text: selectedDate),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 45,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  showFilters = !showFilters;
                                });
                              },
                              borderRadius: BorderRadius.circular(25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.tune, color: Colors.purple[900], size: 20),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 90,
                            height: 45,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: InkWell(
                              onTap: _showSortDialog,
                              borderRadius: BorderRadius.circular(25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sortBy.isEmpty ? 'Sort' : sortBy,
                                      style: TextStyle(
                                        color: Colors.purple[900],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.purple[900], size: 16),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 90,
                            height: 45,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: InkWell(
                              onTap: _showPriceDialog,
                              borderRadius: BorderRadius.circular(25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      priceRange.isEmpty ? 'Price' : priceRanges.firstWhere(
                                        (range) => range['value'] == priceRange,
                                        orElse: () => {'label': 'Price'},
                                      )['label']!,
                                      style: TextStyle(
                                        color: Colors.purple[900],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.purple[900], size: 16),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 90,
                            height: 45,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: InkWell(
                              onTap: _showServiceTypeDialog,
                              borderRadius: BorderRadius.circular(25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      serviceType.isEmpty ? 'Type' : serviceType,
                                      style: TextStyle(
                                        color: Colors.purple[900],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.purple[900], size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showFilters)
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter Options',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Location', style: TextStyle(fontWeight: FontWeight.w500)),
                                      SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: selectedLocation.isEmpty ? null : selectedLocation,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        items: locations.map((String location) {
                                          return DropdownMenuItem<String>(
                                            value: location,
                                            child: Text(
                                              location,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedLocation = newValue ?? '';
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Price Range', style: TextStyle(fontWeight: FontWeight.w500)),
                                      SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: priceRange.isEmpty ? null : priceRanges.firstWhere(
                                          (range) => range['value'] == priceRange,
                                          orElse: () => {'label': ''},
                                        )['label'],
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        items: priceRanges.map((range) {
                                          return DropdownMenuItem<String>(
                                            value: range['label'],
                                            child: Text(
                                              range['label']!,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            priceRange = priceRanges.firstWhere(
                                              (range) => range['label'] == newValue,
                                              orElse: () => {'value': ''},
                                            )['value']!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (searchTerm.isEmpty &&
                        selectedLocation.isEmpty &&
                        priceRange.isEmpty &&
                        serviceType.isEmpty &&
                        sortBy.isEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Special Offers',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 290,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.hardEdge,
                          itemCount: specialOffers.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 200,
                              margin: EdgeInsets.only(right: 16),
                              child: SpecialOfferCard(service: specialOffers[index]),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    if (searchTerm.isNotEmpty ||
                        selectedLocation.isNotEmpty ||
                        priceRange.isNotEmpty ||
                        serviceType.isNotEmpty ||
                        sortBy.isNotEmpty) ...[
                      Text(
                        'All Services (${filteredServices.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: filteredServices.isEmpty
                            ? Center(
                                child: Text(
                                  'No services found matching your criteria.',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredServices.length,
                                itemBuilder: (context, index) {
                                  return ServiceCard(service: filteredServices[index]);
                                },
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpecialOfferCard extends StatelessWidget {
  final Service service;

  const SpecialOfferCard({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Colors.purple[200]!, Colors.pink[200]!],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.local_offer,
                    size: 40,
                    color: Colors.purple[600],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SPECIAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 226),
                  child: Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(maxWidth: 226),
                  child: Text(
                    service.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      service.rating.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(${service.reviews})',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs. ${service.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          constraints: BoxConstraints(maxWidth: 150),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service.discount,
                            style: TextStyle(
                              color: Colors.purple[600],
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.favorite_border,
                      color: Colors.purple[600],
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [Colors.purple[200]!, Colors.pink[200]!],
              ),
            ),
            child: Center(
              child: Text(
                'Service Image',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 64),
                  child: Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 64),
                  child: Text(
                    service.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      service.rating.toString(),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '|',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${service.reviews} reviews',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. ${service.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[600],
                            ),
                          ), 
                          SizedBox(height: 4),
                          Container(
                            constraints: BoxConstraints(maxWidth: 150),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service.discount,
                              style: TextStyle(
                                color: Colors.purple[600],
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.purple[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}