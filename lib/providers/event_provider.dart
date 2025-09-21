import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

// Current selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Day history provider for selected date
final dayHistoryProvider = FutureProvider<DayHistory>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final storageService = ref.watch(storageServiceProvider);
  return storageService.loadDayHistory(selectedDate);
});

// Available dates provider
final availableDatesProvider = FutureProvider<List<DateTime>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return storageService.getAvailableDates();
});

// Event actions provider
final eventActionsProvider = Provider<EventActions>((ref) {
  return EventActions(ref);
});

class EventActions {
  final Ref ref;
  
  EventActions(this.ref);
  
  StorageService get _storage => ref.read(storageServiceProvider);
  
  // Add new event
  Future<void> addEvent(Event event) async {
    await _storage.saveEvent(event);
    
    // Refresh day history
    ref.invalidate(dayHistoryProvider);
    ref.invalidate(availableDatesProvider);
  }
  
  // Quick log urine
  Future<void> logUrine({String notes = AppConstants.defaultNotes}) async {
    final now = DateTime.now();
    final event = Event.instant(
      id: 'urine_${now.millisecondsSinceEpoch}',
      type: AppConstants.urinationType,
      timestamp: now,
      notes: notes,
    );
    
    await addEvent(event);
  }
  
  // Quick log stool
  Future<void> logStool({String notes = AppConstants.defaultNotes}) async {
    final now = DateTime.now();
    final event = Event.instant(
      id: 'stool_${now.millisecondsSinceEpoch}',
      type: AppConstants.stoolType,
      timestamp: now,
      notes: notes,
    );
    
    await addEvent(event);
  }
  
  // Update existing event
  Future<void> updateEvent(DateTime originalDate, Event updatedEvent) async {
    await _storage.updateEvent(originalDate, updatedEvent);
    
    // Refresh providers
    ref.invalidate(dayHistoryProvider);
    ref.invalidate(availableDatesProvider);
  }
  
  // Delete event
  Future<void> deleteEvent(DateTime date, String eventId) async {
    await _storage.deleteEvent(date, eventId);
    
    // Refresh day history
    ref.invalidate(dayHistoryProvider);
    ref.invalidate(availableDatesProvider);
  }
  
  // Change selected date
  void selectDate(DateTime date) {
    ref.read(selectedDateProvider.notifier).state = DateTime(date.year, date.month, date.day);
  }
  
  // Get export file path
  Future<String?> getExportFilePath(DateTime date) async {
    return await _storage.getFilePathForDate(date);
  }
}