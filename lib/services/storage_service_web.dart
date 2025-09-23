import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// Web implementation of StorageService using SharedPreferences.
class StorageServiceWeb implements StorageService {
  static const String _prefix = 'history_';
  static const String _dateFormat = 'yyyy-MM-dd';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  String _getKeyForDate(DateTime date) {
    return '$_prefix${DateFormat(_dateFormat).format(date)}';
  }

  @override
  Future<void> saveEvent(Event event) async {
    final prefs = await _getPrefs();
    final key = _getKeyForDate(event.start);
    final existingContent = prefs.getString(key) ?? '';
    final newContent = existingContent.isEmpty
        ? _createFileHeader(event.start)
        : existingContent;

    final line = '${event.toFileLine()}\n';
    await prefs.setString(key, newContent + line);
  }

  @override
  Future<DayHistory> loadDayHistory(DateTime date) async {
    final prefs = await _getPrefs();
    final key = _getKeyForDate(date);
    final content = prefs.getString(key);

    if (content == null || content.isEmpty) {
      return DayHistory(date: date, events: []);
    }

    final lines = content
        .split('\n')
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();

    final events = <Event>[];
    for (int i = 0; i < lines.length; i++) {
      try {
        final event = Event.fromFileLine(
          lines[i],
          'event_${date.millisecondsSinceEpoch}_$i',
        );
        events.add(event);
      } catch (e) {
        // Skip malformed lines
      }
    }

    return DayHistory(date: date, events: events);
  }

  @override
  Future<void> updateDayHistory(DayHistory dayHistory) async {
    final prefs = await _getPrefs();
    final key = _getKeyForDate(dayHistory.date);

    final buffer = StringBuffer();
    buffer.writeln(_createFileHeader(dayHistory.date).trim());

    for (final event in dayHistory.sortedEvents) {
      buffer.writeln(event.toFileLine());
    }

    await prefs.setString(key, buffer.toString());
  }

  @override
  Future<void> deleteEvent(DateTime date, String eventId) async {
    final dayHistory = await loadDayHistory(date);
    final updatedHistory = dayHistory.removeEvent(eventId);
    await updateDayHistory(updatedHistory);
  }

  @override
  Future<void> updateEvent(DateTime originalDate, Event updatedEvent) async {
    final newDate = DateTime(
      updatedEvent.start.year,
      updatedEvent.start.month,
      updatedEvent.start.day,
    );

    if (originalDate != newDate) {
      await deleteEvent(originalDate, updatedEvent.id);
      await saveEvent(updatedEvent);
    } else {
      final dayHistory = await loadDayHistory(newDate);
      final updatedHistory = dayHistory.updateEvent(updatedEvent);
      await updateDayHistory(updatedHistory);
    }
  }

  @override
  Future<List<DateTime>> getAvailableDates() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    final dates = <DateTime>[];
    final dateFormat = DateFormat(_dateFormat);

    for (final key in keys) {
      final dateStr = key.replaceAll(_prefix, '');
      try {
        dates.add(dateFormat.parse(dateStr));
      } catch (e) {
        // ignore invalid keys
      }
    }
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  @override
  Future<String?> getFilePathForDate(DateTime date) async {
    // This method is not applicable for web, but we need to provide the content
    // for the export service. A better refactor would be to have a getContentForDate method.
    // For now, returning null will cause the export to show "no data".
    return null;
  }

  @override
  Future<String?> getDayHistoryContent(DateTime date) async {
    final prefs = await _getPrefs();
    final key = _getKeyForDate(date);
    return prefs.getString(key);
  }

  @override
  Future<String> getAppDirectoryPath() async {
    // This is not applicable for web storage.
    return '';
  }

  @override
  Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  String _createFileHeader(DateTime date) {
    final dateStr = DateFormat(_dateFormat).format(date);
    return '${AppConstants.fileHeader} $dateStr\n${AppConstants.formatComment}\n';
  }
}
