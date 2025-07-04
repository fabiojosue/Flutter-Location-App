import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/geo_fence.dart';
import 'location_provider.dart';

class GeofenceProvider with ChangeNotifier {
  final List<GeoFence> _geoFences = predefinedGeoFences;
  final Map<String, Duration> _locationDurations = {};
  final Map<String, DateTime> _entryTimes = {};

  Timer? _trackingTimer;
  Timer? _geofenceCheckTimer;

  GeoFence? _currentFence;
  GeoFence? get currentFence => _currentFence;
  Map<String, Duration> get locationDurations => _locationDurations;

  LocationProvider? _locationProvider;

  void init(LocationProvider provider) {
    _locationProvider = provider;
  }

  void startTracking() {
    if (_locationProvider == null) return;

    _trackingTimer?.cancel();
    _checkAndTrack();
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      _checkAndTrack();
    });
  }

  void _checkAndTrack() {
    final current = _locationProvider?.currentLocation;
    if (current == null) return;

    for (final fence in _geoFences) {
      final inside = _isInsideFence(
        current.latitude!,
        current.longitude!,
        fence.latitude,
        fence.longitude,
        fence.radius,
      );

      final now = DateTime.now();
      final alreadyInside = _entryTimes.containsKey(fence.name);

      if (inside && !alreadyInside) {
        _entryTimes[fence.name] = now;
      } else if (!inside && alreadyInside) {
        final entry = _entryTimes.remove(fence.name)!;
        final duration = now.difference(entry);
        _locationDurations[fence.name] =
            (_locationDurations[fence.name] ?? Duration.zero) + duration;
        notifyListeners();
      }
    }
  }

  void startGeofenceMonitoring() {
    if (_locationProvider == null) return;

    _geofenceCheckTimer?.cancel();

    _checkFenceStatus();

    _geofenceCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkFenceStatus();
    });
  }

  void _checkFenceStatus() {
    final current = _locationProvider?.currentLocation;
    if (current == null) return;

    for (final fence in _geoFences) {
      final inside = _isInsideFence(
        current.latitude!,
        current.longitude!,
        fence.latitude,
        fence.longitude,
        fence.radius,
      );

      if (inside && _currentFence?.name != fence.name) {
        _currentFence = fence;
        notifyListeners();
        break;
      } else if (!inside && _currentFence?.name == fence.name) {
        _currentFence = null;
        notifyListeners();
      }
    }
  }

  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;

    final now = DateTime.now();
    _entryTimes.forEach((fenceName, entryTime) {
      final duration = now.difference(entryTime);
      _locationDurations[fenceName] =
          (_locationDurations[fenceName] ?? Duration.zero) + duration;
    });

    _entryTimes.clear();
    notifyListeners();
  }

  void stopGeofenceMonitoring() {
    _geofenceCheckTimer?.cancel();
    _geofenceCheckTimer = null;
  }

  void resetTracking() {
    _trackingTimer?.cancel();
    _entryTimes.clear();
    _locationDurations.clear();
    _currentFence = null;
    notifyListeners();
  }

  bool _isInsideFence(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radius,
  ) {
    const earthRadius = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;
    return distance <= radius;
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);

  @override
  void dispose() {
    stopTracking();
    stopGeofenceMonitoring();
    super.dispose();
  }
}
