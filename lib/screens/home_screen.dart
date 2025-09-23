import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/action_button.dart';
import '../providers/event_provider.dart';
import '../providers/feeding_timer_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedingTimerState = ref.watch(feedingTimerProvider);
    final eventActions = ref.watch(eventActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BabyCare 🍼💖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status display
            _buildStatusCard(context, feedingTimerState),
            const SizedBox(height: AppConstants.spacing * 2),

            // Main action buttons
            FeedingButton(
              isFeeding: feedingTimerState.isFeeding,
              duration: feedingTimerState.isFeeding
                  ? feedingTimerState.formattedDuration
                  : null,
              onPressed: () =>
                  _handleFeedingButton(context, ref, feedingTimerState),
            ),
            const SizedBox(height: AppConstants.spacing),

            ActionButton(
              text: 'Urination',
              icon: Icons.water_drop,
              onPressed: () => _handleUrinationButton(context, eventActions),
            ),
            const SizedBox(height: AppConstants.spacing),

            ActionButton(
              text: 'Stool',
              icon: Icons.circle,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () => _handleStoolButton(context, eventActions),
            ),
            const SizedBox(height: AppConstants.spacing * 2),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    icon: const Icon(Icons.history),
                    label: const Text('View History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.notifications),
                    label: const Text('Reminders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, FeedingTimerState timerState) {
    if (timerState.isFeeding) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing),
          child: Row(
            children: [
              const Icon(Icons.baby_changing_station, size: 32),
              const SizedBox(width: AppConstants.spacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feeding in Progress',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Duration: ${timerState.formattedDuration}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (timerState.startTime != null)
                    Text(
                      'Started: ${_formatTime(timerState.startTime!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing),
        child: Row(
          children: [
            const Icon(Icons.favorite, size: 32, color: Colors.pink),
            const SizedBox(width: AppConstants.spacing),
            Text(
              'Ready to track baby\'s needs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleFeedingButton(
    BuildContext context,
    WidgetRef ref,
    FeedingTimerState timerState,
  ) {
    final timerNotifier = ref.read(feedingTimerProvider.notifier);

    if (timerState.isFeeding) {
      // Show stop feeding dialog
      _showStopFeedingDialog(context, timerNotifier);
    } else {
      // Start feeding
      timerNotifier.startFeeding();

      // Navigate to timer screen
      Navigator.pushNamed(context, '/feeding-timer');
    }
  }

  void _showStopFeedingDialog(
    BuildContext context,
    FeedingTimerNotifier timerNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Feeding?'),
        content: const Text('Add any notes about this feeding session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              timerNotifier.stopFeeding();
              _showSuccessSnackBar(context, 'Feeding recorded successfully!');
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _handleUrinationButton(
    BuildContext context,
    EventActions eventActions,
  ) async {
    try {
      await eventActions.logUrine();
      _showSuccessSnackBar(context, 'Urination logged!');
    } catch (e) {
      _showErrorSnackBar(context, 'Error logging urination: $e');
    }
  }

  void _handleStoolButton(
    BuildContext context,
    EventActions eventActions,
  ) async {
    try {
      await eventActions.logStool();
      _showSuccessSnackBar(context, 'Stool logged!');
    } catch (e) {
      _showErrorSnackBar(context, 'Error logging stool: $e');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
