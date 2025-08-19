import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import 'dart:convert';
import '../services/services.dart';

class ServicesScreen extends StatefulWidget {
  final String token;

  const ServicesScreen({super.key, required this.token});

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
  List<Service> services = [];
  bool isLoading = true;
  String? errorMessage;

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
    "Haircut & Styling - Ladies",
    "Haircut & Styling - Gents",
    "Haircut & Styling - Kids",
    "Haircut & Styling - Adults",
    "Massage",
    "Bridal",
    "Tattoo & Piercing",
    "Facials & Skincare",
    "Hair Removal",
    "Nails",
    "Eyebrow & EyeLashes",
    "Injectable & Fillers",
    "Makeup",
    "Dressing",
    "Pedicure & Manicure",
    "Door Step Service",
    "Custom Service"
  ];

  final List<String> sortOptions = [
    "Popular",
    "Price: Low to High",
    "Price: High to Low",
    "Newest"
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedServices = await fetchServices(widget.token);
      setState(() {
        services = fetchedServices;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load services: $e';
      });
    }
  }

  List<Service> get filteredServices {
    List<Service> filtered = services.where((service) {
      bool matchesSearch = service.serviceName
          .toLowerCase()
          .contains(searchTerm.toLowerCase());

      bool matchesLocation = selectedLocation.isEmpty ||
          selectedLocation == "All Locations" ||
          (service.serviceDescription?.contains(selectedLocation) ?? false);

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
          (service.serviceDescription?.toLowerCase().contains(serviceType.toLowerCase()) ?? false);

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
        case "Newest":
          filtered.sort((a, b) => b.id.compareTo(a.id));
          break;
        case "Popular":
          filtered.sort((a, b) => b.id.compareTo(a.id)); // Assuming ID reflects popularity
          break;
      }
    }

    return filtered;
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
            height: 400, // Set a fixed height to limit dialog size
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: serviceTypes.map((value) {
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
                    ),
                  ),
                ),
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
                          hintText: 'Search by Service Name...',
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
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : errorMessage != null
                              ? Center(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              : filteredServices.isEmpty
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
                ),
              ),
            ),
          ],
        ),
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
            child: service.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      service.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  )
                : Center(
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
                    service.serviceName,
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
                    service.serviceDescription,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                 SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 64),
                  child: Text(
                    service.serviceDescription,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                          if (service.specialOffer != null && service.specialOffer!.isNotEmpty)
                            SizedBox(height: 4),
                          if (service.specialOffer != null && service.specialOffer!.isNotEmpty)
                            Container(
                              constraints: BoxConstraints(maxWidth: 150),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                service.specialOffer!,
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
                    // Flexible(
                    //   flex: 1,
                    //   child: IconButton(
                    //     onPressed: () {},
                    //     icon: Icon(
                    //       Icons.favorite_border,
                    //       color: Colors.purple[600],
                    //     ),
                    //   ),
                    // ),
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