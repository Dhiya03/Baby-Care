import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feeding_timer_provider.dart';
import '../utils/constants.dart';

class FeedingTimerScreen extends ConsumerStatefulWidget {
  const FeedingTimerScreen({super.key});

  @override
  ConsumerState<FeedingTimerScreen> createState() => _FeedingTimerScreenState();
}

class _FeedingTimerScreenState extends ConsumerState<FeedingTimerScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(feedingTimerProvider);
    final timerNotifier = ref.read(feedingTimerProvider.notifier);

    // If not feeding, redirect back
    if (!timerState.isFeeding) {
      // The user has stopped the feeding, and the pop is handled in the _stopFeeding method.
      // This guard prevents a double-pop issue by simply showing a loader for a frame.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Timer'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display card
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing * 2),
                child: Column(
                  children: [
                    Icon(
                      Icons.baby_changing_station,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: AppConstants.spacing),

                    Text(
                      'Feeding in Progress',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacing),

                    // Duration display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        timerState.formattedDuration,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing),

                    if (timerState.startTime != null)
                      Text(
                        'Started at ${_formatTime(timerState.startTime!)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing * 2),

            // Notes input
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g., Baby seemed hungry, spit up after...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.spacing * 2),

            // Stop feeding button
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeight,
              child: ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _stopFeeding(timerNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.buttonRadius,
                    ),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stop, size: 32),
                          const SizedBox(width: AppConstants.spacing),
                          Text(
                            'End Feeding',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing),

            // Cancel button
            TextButton(
              onPressed: _isLoading ? null : () => _showCancelDialog(),
              child: const Text('Cancel Feeding'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _stopFeeding(FeedingTimerNotifier timerNotifier) async {
    setState(() {
      _isLoading = true;
    });

    final notes = _notesController.text.trim().isEmpty
        ? AppConstants.defaultNotes
        : _notesController.text.trim();

    try {
      await timerNotifier.stopFeeding(notes: notes);

      if (mounted) {
        // Show success and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feeding recorded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording feeding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Feeding?'),
        content: const Text(
          'This will stop the timer without saving the feeding session. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ref.read(feedingTimerProvider.notifier).reset();
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
