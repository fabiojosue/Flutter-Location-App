import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/geo_fence.dart';
import '../../../providers/geofence_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../widgets/map_view.dart';
import 'summary_screen.dart';

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
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      final geofenceProvider =
          Provider.of<GeofenceProvider>(context, listen: false);

      await locationProvider.init();
      geofenceProvider.startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
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
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  locationProvider.currentLocation != null
                      ? 'Lat: ${locationProvider.currentLocation!.latitude!.toStringAsFixed(5)} | Lng: ${locationProvider.currentLocation!.longitude!.toStringAsFixed(5)}'
                      : 'Location loading...',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tracking started')),
                  );
                },
                child: const Text('Clock In'),
              ),
              ElevatedButton(
                onPressed: () {
                  geofenceProvider.stopTracking();
                  geofenceProvider.stopGeofenceMonitoring();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tracking stopped')),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SummaryScreen()),
                  );
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
