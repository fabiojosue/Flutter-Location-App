import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/geo_fence.dart';

class MapView extends StatelessWidget {
  final List<GeoFence> geoFences;

  const MapView({required this.geoFences, super.key});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(geoFences[0].latitude, geoFences[0].longitude),
        zoom: 14,
      ),
      markers: geoFences.map((fence) {
        return Marker(
          markerId: MarkerId(fence.name),
          position: LatLng(fence.latitude, fence.longitude),
          infoWindow: InfoWindow(title: fence.name),
        );
      }).toSet(),
      circles: geoFences.map((fence) {
        return Circle(
          circleId: CircleId(fence.name),
          center: LatLng(fence.latitude, fence.longitude),
          radius: fence.radius,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeWidth: 2,
        );
      }).toSet(),
      myLocationEnabled: true,
    );
  }
}
