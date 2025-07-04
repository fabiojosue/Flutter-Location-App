import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../util/notifications_helper.dart';
import '../models/location.dart';
import '../models/geo_fence.dart';

class LocationProvider with ChangeNotifier {
  static final LocationProvider _singleton = LocationProvider._internal();

  factory LocationProvider() => _singleton;

  LocationProvider._internal();

  final location = loc.Location();
  loc.LocationData? _currentLocationData;
  Location? _currentLocation;

  bool _acceptedPermission = false;

  StreamSubscription<loc.LocationData>? _locationSubscription;
  GeoFence? _currentFence;
  final Map<String, DateTime> _entryTimes = {};
  final Map<String, Duration> _durations = {};

  bool get initialized => _currentLocation != null;
  bool get hasPermission => _acceptedPermission;
  Location? get currentLocation => _currentLocation;
  Map<String, Duration> get timeSpent => _durations;

  Future<void> init() async {
    await geocoding.setLocaleIdentifier('en');
    _acceptedPermission = await requestPermission();
    if (_acceptedPermission) {
      await fetchCurrentLocation();
      startTracking();
    }
    notifyListeners();
  }

  Future<bool> requestPermission() async {
    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        NotificationsHelper().showError(
          'Location permission denied. Please enable location services.',
        );
        return false;
      }
    }
    return true;
  }

  Future<void> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }
      _currentLocationData =
          await location.getLocation().timeout(const Duration(seconds: 6));
      _currentLocation = await _getUserLocation();
    } catch (e) {
      NotificationsHelper().printIfDebugMode('Location fetching failed: $e');
    }
  }

  Future<void> updateLocationOnMap(double lat, double lng) async {}

  Future<Location?> _getUserLocation() async {
    final locationPlaceMark = await _getLocationPlaceMark();

    if (locationPlaceMark == null) return null;

    return Location(
      country: locationPlaceMark.country ?? '',
      displayName: locationPlaceMark.locality ?? '',
      latitude: _currentLocationData!.latitude!,
      longitude: _currentLocationData!.longitude!,
      lastUpdated: DateTime.now(),
    );
  }

  Future<geocoding.Placemark?> _getLocationPlaceMark() async {
    if (_currentLocationData?.latitude == null ||
        _currentLocationData?.longitude == null) return null;
    final List<geocoding.Placemark> placeMarks =
        await geocoding.placemarkFromCoordinates(
      _currentLocationData!.latitude!,
      _currentLocationData!.longitude!,
    );

    return placeMarks[0];
  }

  bool _isInsideFence(loc.LocationData pos, GeoFence fence) {
    final distance = Geolocator.distanceBetween(
      pos.latitude!,
      pos.longitude!,
      fence.latitude,
      fence.longitude,
    );
    return distance <= fence.radius;
  }

  void startTracking() {
    _locationSubscription?.cancel();

    _locationSubscription = location.onLocationChanged.listen((pos) {
      for (final fence in predefinedGeoFences) {
        if (_isInsideFence(pos, fence)) {
          if (_currentFence?.name != fence.name) {
            _onEnterFence(fence);
          }
          return;
        }
      }

      if (_currentFence != null) {
        _onExitFence();
      }
    });
  }

  void _onEnterFence(GeoFence fence) {
    _onExitFence();
    _currentFence = fence;
    _entryTimes[fence.name] = DateTime.now();
    notifyListeners();
  }

  void _onExitFence() {
    if (_currentFence == null) return;

    final entryTime = _entryTimes[_currentFence!.name];
    if (entryTime != null) {
      final duration = DateTime.now().difference(entryTime);
      _durations[_currentFence!.name] =
          (_durations[_currentFence!.name] ?? Duration.zero) + duration;
    }

    _entryTimes.remove(_currentFence!.name);
    _currentFence = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
