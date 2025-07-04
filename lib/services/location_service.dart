import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/geo_fence.dart';

class LocationService {
  final StreamController<Position> _locationController =
      StreamController.broadcast();

  Stream<Position> get locationStream => _locationController.stream;

  Future<void> startLocationUpdates() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      _locationController.add(position);
    });
  }

  static bool isInsideFence(Position position, GeoFence fence) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      fence.latitude,
      fence.longitude,
    );
    return distance <= fence.radius;
  }

  void dispose() {
    _locationController.close();
  }
}
