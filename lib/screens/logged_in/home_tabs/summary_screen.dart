import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/geo_fence.dart';
import '../../../providers/geofence_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final geoProvider = Provider.of<GeofenceProvider>(context);
    final durations = geoProvider.locationDurations;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Summary'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: durations.isEmpty
            ? const Center(
                child: Text(
                  'No location data tracked yet.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView.separated(
                itemCount: durations.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final fenceName = durations.keys.elementAt(index);
                  final duration = durations[fenceName]!;

                  return ListTile(
                    title: Text(
                      fenceName,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}h '
        '${minutes.toString().padLeft(2, '0')}m '
        '${seconds.toString().padLeft(2, '0')}s';
  }
}
