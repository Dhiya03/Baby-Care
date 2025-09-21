import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../utils/constants.dart';
import '../widgets/event_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dayHistoryAsync = ref.watch(dayHistoryProvider);
    final eventActions = ref.watch(eventActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _exportDay(context, eventActions, selectedDate),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          _buildDateSelector(context, ref, selectedDate),
          
          // History content
          Expanded(
            child: dayHistoryAsync.when(
              data: (dayHistory) => _buildHistoryContent(context, ref, dayHistory),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: AppConstants.spacing),
                    Text('Error loading history: $error'),
                    const SizedBox(height: AppConstants.spacing),
                    ElevatedButton(
                      onPressed: () => ref.refresh(dayHistoryProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing,
            vertical: AppConstants.spacing / 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeDate(ref, selectedDate, -1),
                icon: const Icon(Icons.chevron_left),
              ),
              GestureDetector(
                onTap: () => _showDatePicker(context, ref, selectedDate),
                child: Column(
                  children: [
                    Text(
                      _formatDateHeader(selectedDate),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d, y').format(selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isToday(selectedDate) ? null : () => _changeDate(ref, selectedDate, 1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, WidgetRef ref, dayHistory) {
    if (!dayHistory.hasEvents) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppConstants.spacing),
            Text(
              'No events recorded for this day',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppConstants.spacing),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back to Home'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(dayHistoryProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing),
        children: [
          // Summary card
          _buildSummaryCard(context, dayHistory),
          const SizedBox(height: AppConstants.spacing),
          
          // Events by type
          if (dayHistory.feedingEvents.isNotEmpty) ...[
            _buildSectionHeader(context, 'Feeding Sessions', dayHistory.feedingCount),
            ...dayHistory.feedingEvents.map((event) => EventCard(
              event: event,
              onTap: () => _editEvent(context, ref, event),
              onDelete: () => _deleteEvent(context, ref, event),
            )),
            const SizedBox(height: AppConstants.spacing),
          ],
          
          if (dayHistory.urinationEvents.isNotEmpty) ...[
            _buildSectionHeader(context, 'Urination', dayHistory.urinationCount),
            ...dayHistory.urinationEvents.map((event) => EventCard(
              event: event,
              onTap: () => _editEvent(context, ref, event),
              onDelete: () => _deleteEvent(context, ref, event),
            )),
            const SizedBox(height: AppConstants.spacing),
          ],
          
          if (dayHistory.stoolEvents.isNotEmpty) ...[
            _buildSectionHeader(context, 'Stool', dayHistory.stoolCount),
            ...dayHistory.stoolEvents.map((event) => EventCard(
              event: event,
              onTap: () => _editEvent(context, ref, event),
              onDelete: () => _deleteEvent(context, ref, event),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, dayHistory) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacing / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(context, 'Feeding', '${dayHistory.feedingCount}', 
                    '${dayHistory.totalFeedingMinutes}m total'),
                _buildSummaryItem(context, 'Urine', '${dayHistory.urinationCount}', ''),
                _buildSummaryItem(context, 'Stool', '${dayHistory.stoolCount}', ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String count, String detail) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        if (detail.isNotEmpty)
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing / 2),
      child: Row(
        children: [
          Icon(
            _getIconForEventType(title),
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: AppConstants.spacing / 2),
          Text(
            '$title ($count)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEventType(String type) {
    switch (type.toLowerCase()) {
      case 'feeding':
        return Icons.baby_changing_station;
      case 'urination':
        return Icons.water_drop;
      case 'stool':
        return Icons.circle;
      default:
        return Icons.event;
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly == today;
  }

  void _changeDate(WidgetRef ref, DateTime currentDate, int days) {
    final newDate = currentDate.add(Duration(days: days));
    ref.read(selectedDateProvider.notifier).state = newDate;
  }

  void _showDatePicker(BuildContext context, WidgetRef ref, DateTime selectedDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  void _editEvent(BuildContext context, WidgetRef ref, Event event) {
    Navigator.pushNamed(
      context,
      '/edit-entry',
      arguments: {
        'event': event,
        'originalDate': ref.read(selectedDateProvider),
      },
    );
  }

  void _deleteEvent(BuildContext context, WidgetRef ref, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Are you sure you want to delete this ${event.type.toLowerCase()} event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(eventActionsProvider).deleteEvent(
                  ref.read(selectedDateProvider),
                  event.id,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting event: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportDay(BuildContext context, eventActions, DateTime date) async {
    try {
      final filePath = await eventActions.getExportFilePath(date);
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Baby history for ${DateFormat('yyyy-MM-dd').format(date)}',
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No data to export for this date'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }