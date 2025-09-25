import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import '../services/storage_service.dart';
import '../services/storage_service_mobile.dart';
import '../services/storage_service_web.dart';
import '../services/export_service.dart';
import '../services/export_service_mobile.dart';
import '../services/export_service_web.dart';
import '../utils/constants.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return kIsWeb ? StorageServiceWeb() : StorageServiceMobile();
});

// Export service provider
final exportServiceProvider = Provider<ExportService>((ref) {
  return kIsWeb
      ? ExportServiceWeb(ref.watch(storageServiceProvider))
      : ExportServiceMobile(ref.watch(storageServiceProvider));
});

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
  ExportService get _export => ref.read(exportServiceProvider);

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
    ref.read(selectedDateProvider.notifier).state =
        DateTime(date.year, date.month, date.day);
  }

  // Export day's history
  Future<bool> exportDay(DateTime date) async {
    return await _export.exportDay(date);
  }

  Future<bool> exportDateRange(DateTime startDate, DateTime endDate) async {
    return await _export.exportDateRange(startDate, endDate);
  }

  Future<void> exportAsCSV(DateTime startDate, DateTime endDate) async {
    await _export.exportAsCSV(startDate, endDate);
  }

  Future<void> exportMedicalReport(DateTime startDate, DateTime endDate) async {
    await _export.exportMedicalReport(startDate, endDate);
  }

  Future<bool> exportAllData() async {
    return await _export.exportAllData();
  }

  Future<void> exportWeeklySummary(DateTime weekStart) async {
    await _export.exportWeeklySummary(weekStart);
  }

  Future<void> exportMonthlySummary(DateTime month) async {
    await _export.exportMonthlySummary(month);
  }

  Future<void> clearAllData() async {
    await _storage.clearAllData();
    ref.invalidate(dayHistoryProvider);
    ref.invalidate(availableDatesProvider);
  }
}
