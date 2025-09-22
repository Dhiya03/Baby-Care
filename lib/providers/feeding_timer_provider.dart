import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../utils/constants.dart';
import 'event_provider.dart';

// Feeding timer state
class FeedingTimerState {
  final bool isFeeding;
  final DateTime? startTime;
  final Duration duration;
  final String? currentFeedingId;

  const FeedingTimerState({
    this.isFeeding = false,
    this.startTime,
    this.duration = Duration.zero,
    this.currentFeedingId,
  });

  FeedingTimerState copyWith({
    bool? isFeeding,
    DateTime? startTime,
    Duration? duration,
    String? currentFeedingId,
  }) {
    return FeedingTimerState(
      isFeeding: isFeeding ?? this.isFeeding,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      currentFeedingId: currentFeedingId ?? this.currentFeedingId,
    );
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Feeding timer notifier
class FeedingTimerNotifier extends StateNotifier<FeedingTimerState> {
  Timer? _timer;
  final Ref ref;

  FeedingTimerNotifier(this.ref) : super(const FeedingTimerState());

  // Start feeding
  void startFeeding() {
    if (state.isFeeding) return;

    final now = DateTime.now();
    final feedingId = 'feeding_${now.millisecondsSinceEpoch}';

    state = state.copyWith(
      isFeeding: true,
      startTime: now,
      duration: Duration.zero,
      currentFeedingId: feedingId,
    );

    // Start timer
    _startTimer();
  }

  // Stop feeding
  Future<void> stopFeeding({String notes = AppConstants.defaultNotes}) async {
    if (!state.isFeeding ||
        state.startTime == null ||
        state.currentFeedingId == null) {
      return;
    }

    _stopTimer();

    final endTime = DateTime.now();
    final durationMinutes = state.duration.inMinutes;

    // Create feeding event
    final event = Event.feeding(
      id: state.currentFeedingId!,
      start: state.startTime!,
      end: endTime,
      durationMinutes: durationMinutes,
      notes: notes,
    );

    // Save event
    await ref.read(eventActionsProvider).addEvent(event);

    // Reset state
    state = const FeedingTimerState();

    // Schedule reminder (will be implemented in notification service)
    _scheduleReminder(endTime);
  }

  // Reset timer state
  void reset() {
    _stopTimer();
    state = const FeedingTimerState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startTime != null) {
        final newDuration = DateTime.now().difference(state.startTime!);
        state = state.copyWith(duration: newDuration);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleReminder(DateTime lastFeedingEnd) {
    // TODO: Implement with notification service
    // Schedule reminders at lastFeedingEnd + 2h and + 3h
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

// Provider
final feedingTimerProvider =
    StateNotifierProvider<FeedingTimerNotifier, FeedingTimerState>((ref) {
  return FeedingTimerNotifier(ref);
});
