import 'package:flutter/material.dart';
import '../screens/logged_in/home_tabs/summary_screen.dart';

void showClockInDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Tracking Started'),
      content: const Text('You are now clocked in. Time will be tracked.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void showNoTimeTrackedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('No time tracked'),
      content: const Text('You did not spend time inside any geofence.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void showSummaryDialog({
  required BuildContext context,
  required Map<String, Duration> durations,
}) {
  final summary = durations.entries.map((entry) {
    final mins = entry.value.inMinutes;
    return "• ${entry.key}: ${mins > 0 ? '$mins min' : '${entry.value.inSeconds} sec'}";
  }).join('\n');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Time Tracked'),
      content: Text('You were in:\n\n$summary'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SummaryScreen(durations: durations),
              ),
            );
          },
          child: const Text('View Summary'),
        ),
      ],
    ),
  );
}
