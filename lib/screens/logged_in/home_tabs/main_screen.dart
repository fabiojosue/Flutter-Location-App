import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/geo_fence.dart';
import '../../../providers/geofence_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../widgets/map_view.dart';
import '../../../widgets/custom_dialogs.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      final geofenceProvider = Provider.of<GeofenceProvider>(
        context,
        listen: false,
      );

      await locationProvider.init();
      geofenceProvider.init(locationProvider);
      geofenceProvider.startTracking();
      geofenceProvider.startGeofenceMonitoring();

      final loc = locationProvider.currentLocation;
      debugPrint(
        'INIT COMPLETE — Location: lat: ${loc?.latitude}, lng: ${loc?.longitude}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final geofenceProvider = Provider.of<GeofenceProvider>(context);

    return Stack(
      children: [
        const MapView(geoFences: predefinedGeoFences),
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  geofenceProvider.currentFence != null
                      ? 'Inside: ${geofenceProvider.currentFence!.name}'
                      : 'Not in any geofence',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<LocationProvider>(
                  builder: (context, locationProvider, _) {
                    final location = locationProvider.currentLocation;
                    if (location != null) {
                      debugPrint(
                        'UI RENDER — Location loaded: lat: ${location.latitude}, lng: ${location.longitude}',
                      );
                    }
                    return Text(
                      location != null
                          ? 'Lat: ${location.latitude!.toStringAsFixed(5)} | Lng: ${location.longitude!.toStringAsFixed(5)}'
                          : 'Location loading...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  geofenceProvider.startTracking();
                  geofenceProvider.startGeofenceMonitoring();
                  showClockInDialog(context);
                },
                child: const Text('Clock In'),
              ),
              ElevatedButton(
                onPressed: () {
                  geofenceProvider.stopTracking();
                  geofenceProvider.stopGeofenceMonitoring();
                  final durations = geofenceProvider.locationDurations;

                  if (durations.isEmpty) {
                    showNoTimeTrackedDialog(context);
                  } else {
                    showSummaryDialog(context: context, durations: durations);
                  }
                },
                child: const Text('Clock Out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
