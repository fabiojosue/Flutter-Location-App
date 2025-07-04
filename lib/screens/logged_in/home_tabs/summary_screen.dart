import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, Duration> durations;

  const SummaryScreen({required this.durations, super.key});

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = durations.values.fold(Duration.zero, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Summary'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Spent in Geofences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (durations.isEmpty)
              const Text('No data recorded.')
            else
              ...durations.entries.map(
                (entry) => ListTile(
                  title: Text(entry.key),
                  trailing: Text(_formatDuration(entry.value)),
                ),
              ),
            const Divider(height: 32),
            Text(
              'Total Time: ${_formatDuration(totalDuration)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
