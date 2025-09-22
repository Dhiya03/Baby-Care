import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import '../utils/constants.dart';

class StorageService {
  static const String _dateFormat = 'yyyy-MM-dd';

  // Get history directory
  Future<Directory> _getHistoryDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final historyDir =
        Directory('${dir.path}/${AppConstants.historyFolderName}');
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    return historyDir;
  }

  // Get application directory (for temp files)
  Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Get file for specific date
  Future<File> _getFileForDate(DateTime date) async {
    final historyDir = await _getHistoryDir();
    final filename =
        DateFormat(_dateFormat).format(date) + AppConstants.fileExtension;
    return File('${historyDir.path}/$filename');
  }

  // Create file header
  String _createFileHeader(DateTime date) {
    final dateStr = DateFormat(_dateFormat).format(date);
    return '${AppConstants.fileHeader} $dateStr\n${AppConstants.formatComment}\n';
  }

  // Save event to file
  Future<void> saveEvent(Event event) async {
    final file = await _getFileForDate(event.start);

    // Check if file exists, create with header if not
    if (!await file.exists()) {
      await file.writeAsString(_createFileHeader(event.start));
    }

    // Append event
    final line = '${event.toFileLine()}\n';
    await file.writeAsString(line, mode: FileMode.append);
  }

  // Load day history
  Future<DayHistory> loadDayHistory(DateTime date) async {
    final file = await _getFileForDate(date);

    if (!await file.exists()) {
      return DayHistory(date: date, events: []);
    }

    final content = await file.readAsString();
    final lines = content
        .split('\n')
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();

    final events = <Event>[];
    for (int i = 0; i < lines.length; i++) {
      try {
        final event = Event.fromFileLine(
            lines[i], 'event_${date.millisecondsSinceEpoch}_$i');
        events.add(event);
      } catch (e) {
        // Skip malformed lines
        print('Error parsing line: ${lines[i]} - $e');
      }
    }

    return DayHistory(date: date, events: events);
  }

  // Update day history (rewrite entire file)
  Future<void> updateDayHistory(DayHistory dayHistory) async {
    final file = await _getFileForDate(dayHistory.date);

    // Create content
    final buffer = StringBuffer();
    buffer.writeln(_createFileHeader(dayHistory.date).trim());

    for (final event in dayHistory.sortedEvents) {
      buffer.writeln(event.toFileLine());
    }

    // Write atomically
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(buffer.toString());
    await tempFile.rename(file.path);
  }

  // Delete event from day
  Future<void> deleteEvent(DateTime date, String eventId) async {
    final dayHistory = await loadDayHistory(date);
    final updatedHistory = dayHistory.removeEvent(eventId);
    await updateDayHistory(updatedHistory);
  }

  // Update existing event
  Future<void> updateEvent(DateTime originalDate, Event updatedEvent) async {
    final originalDayHistory = await loadDayHistory(originalDate);
    final newDate = DateTime(updatedEvent.start.year, updatedEvent.start.month,
        updatedEvent.start.day);

    // If date changed, move event to new file
    if (originalDate != newDate) {
      // Remove from original file
      final updatedOriginalHistory =
          originalDayHistory.removeEvent(updatedEvent.id);
      await updateDayHistory(updatedOriginalHistory);

      // Add to new file
      final newDayHistory = await loadDayHistory(newDate);
      final updatedNewHistory = newDayHistory.addEvent(updatedEvent);
      await updateDayHistory(updatedNewHistory);
    } else {
      // Update in same file
      final updatedHistory = originalDayHistory.updateEvent(updatedEvent);
      await updateDayHistory(updatedHistory);
    }
  }

  // Get available history dates
  Future<List<DateTime>> getAvailableDates() async {
    try {
      final historyDir = await _getHistoryDir();
      final files = await historyDir
          .list()
          .where((entity) =>
              entity is File &&
              entity.path.endsWith(AppConstants.fileExtension))
          .cast<File>()
          .toList();

      final dates = <DateTime>[];
      final dateFormat = DateFormat(_dateFormat);

      for (final file in files) {
        final filename = file.uri.pathSegments.last;
        final dateStr = filename.replaceAll(AppConstants.fileExtension, '');
        try {
          final date = dateFormat.parse(dateStr);
          dates.add(date);
        } catch (e) {
          // Skip invalid date files
        }
      }

      dates.sort((a, b) => b.compareTo(a)); // Most recent first
      return dates;
    } catch (e) {
      return [];
    }
  }

  // Export file path for sharing
  Future<String?> getFilePathForDate(DateTime date) async {
    final file = await _getFileForDate(date);
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  // Get storage directory path (for debugging)
  Future<String> getStorageDirectoryPath() async {
    final dir = await _getHistoryDir();
    return dir.path;
  }

  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final dir = await _getHistoryDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
