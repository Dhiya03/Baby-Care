import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/date_helper.dart';

class TimerDisplay extends StatelessWidget {
  final Duration duration;
  final DateTime? startTime;
  final bool isRunning;
  final VoidCallback? onTap;
  final bool showStartTime;
  final bool compact;

  const TimerDisplay({
    super.key,
    required this.duration,
    this.startTime,
    this.isRunning = false,
    this.onTap,
    this.showStartTime = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompactTimer(context) : _buildFullTimer(context);
  }

  Widget _buildFullTimer(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isRunning ? 8 : 2,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing * 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            gradient: isRunning
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withAlpha(26), // 10% opacity
                      Theme.of(context).colorScheme.secondary.withAlpha(26), // 10% opacity
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer icon with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isRunning ? Icons.baby_changing_station : Icons.timer,
                  size: compact ? 32 : 64,
                  color: isRunning
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400],
                ),
              ),

              const SizedBox(height: AppConstants.spacing),

              // Status text
              Text(
                isRunning ? 'Feeding in Progress' : 'Timer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isRunning
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.spacing),

              // Duration display
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 32 : 48,
                          color: isRunning
                              ? Theme.of(context).primaryColor
                              : Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.color,
                        ) ??
                    const TextStyle(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing,
                    vertical: AppConstants.spacing / 2,
                  ),
                  child: Text(
                    DateHelper.formatTimerDuration(duration),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Start time display
              if (showStartTime && startTime != null) ...[
                const SizedBox(height: AppConstants.spacing),
                Text(
                  'Started at ${DateHelper.formatTime(startTime!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
              ],

              // Pulse animation when running
              if (isRunning) ...[
                const SizedBox(height: AppConstants.spacing),
                _buildPulseIndicator(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing,
        vertical: AppConstants.spacing / 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRunning ? Icons.baby_changing_station : Icons.timer,
            size: 20,
            color:
                isRunning ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            DateHelper.formatTimerDuration(duration),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isRunning
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.titleMedium?.color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 1),
      tween: Tween(begin: 0.3, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
      onEnd: () {
        // This will restart the animation
      },
    );
  }
}

// Specialized timer for notifications and lock screen
class LockScreenTimerDisplay extends StatelessWidget {
  final Duration duration;
  final bool isRunning;

  const LockScreenTimerDisplay({
    super.key,
    required this.duration,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.baby_changing_station,
            size: 24,
            color: isRunning ? Colors.pink : Colors.grey,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feeding',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateHelper.formatTimerDuration(duration),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Timer with milestone indicators
class MilestoneTimerDisplay extends StatelessWidget {
  final Duration duration;
  final bool isRunning;
  final List<int> milestones; // Minutes

  const MilestoneTimerDisplay({
    super.key,
    required this.duration,
    required this.isRunning,
    this.milestones = const [5, 10, 15, 20, 30],
  });

  @override
  Widget build(BuildContext context) {
    final currentMinutes = duration.inMinutes;

    return Column(
      children: [
        // Main timer
        TimerDisplay(duration: duration, isRunning: isRunning, compact: true),

        const SizedBox(height: AppConstants.spacing),

        // Milestone indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: milestones.map((milestone) {
            final isReached = currentMinutes >= milestone;
            final isCurrent = currentMinutes >= milestone - 1 &&
                currentMinutes < milestone + 1;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isReached
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      border: isCurrent && isRunning
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${milestone}m',
                    style: TextStyle(
                      fontSize: 10,
                      color: isReached
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                      fontWeight:
                          isReached ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
