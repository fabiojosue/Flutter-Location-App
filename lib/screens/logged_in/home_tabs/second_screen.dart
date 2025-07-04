import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/geofence_provider.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final geofenceProvider = Provider.of<GeofenceProvider>(context);
    final durations = geofenceProvider.locationDurations;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: durations.isEmpty
              ? const Text(
                  'Nothing tracked yet.',
                  style: TextStyle(color: Colors.white54),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: durations.entries.map((entry) {
                    final name = entry.key;
                    final duration = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '$name: ${_formatDuration(duration)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
  }
}
