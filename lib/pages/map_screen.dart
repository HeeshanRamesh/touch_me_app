import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final LatLng salonLocation;
  final String salonName;

  const MapScreen({
    super.key,
    required this.salonLocation,
    required this.salonName,
  });

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('salon_marker'),
        position: salonLocation,
        infoWindow: InfoWindow(title: salonName),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(salonName, style: const TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 1,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: salonLocation, zoom: 16),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
