import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';



class LocationSelectScreen extends StatefulWidget {
  const LocationSelectScreen({super.key});

  @override
  State<LocationSelectScreen> createState() => _LocationSelectScreenState();
}

class _LocationSelectScreenState extends State<LocationSelectScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _currentPosition = position;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _searchController.clear();
      _searchResults.clear();
    });

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  Future<void> _searchLocations(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (query.isEmpty) {
        setState(() => _searchResults.clear());
        return;
      }

      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=lk',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'FlutterApp/1.0 (your@email.com)'},
        );

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          setState(() {
            _searchResults =
                data
                    .map(
                      (item) => {
                        'display_name': item['display_name'],
                        'lat': double.parse(item['lat']),
                        'lon': double.parse(item['lon']),
                      },
                    )
                    .toList();
          });
        }
      } catch (e) {
        debugPrint('Search failed: $e');
        setState(() => _searchResults.clear());
      }
    });
  }

  void _onSearchResultSelected(Map<String, dynamic> result) {
    final LatLng selected = LatLng(result['lat'], result['lon']);
    setState(() {
      _selectedLocation = selected;
      _searchResults.clear();
      _searchController.clear();
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(selected, 16));
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a location")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  _currentPosition != null
                      ? LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                      : const LatLng(7.8731, 80.7718),
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            onTap: _onMapTapped,
            markers:
                _selectedLocation != null
                    ? {
                      Marker(
                        markerId: const MarkerId("selectedLocation"),
                        position: _selectedLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                      ),
                    }
                    : {},
          ),

          // Search bar
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchLocations,
                  decoration: InputDecoration(
                    hintText: "Search location",
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults.clear());
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Search results dropdown
          if (_searchResults.isNotEmpty)
            Positioned(
              top: 100,
              left: 15,
              right: 15,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      title: Text(result['display_name']),
                      onTap: () => _onSearchResultSelected(result),
                    );
                  },
                ),
              ),
            ),

          // OSM attribution
          const Positioned(
            bottom: 60,
            left: 15,
            child: Text(
              "Search powered by OpenStreetMap",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),

      // Confirm button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5, right: 50),
        child: FloatingActionButton.extended(
          onPressed: _confirmLocation,
          backgroundColor: Colors.blue,
          icon: const Icon(Icons.location_on_outlined, color: Colors.white),
          label: const Text(
            "Set Location",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
