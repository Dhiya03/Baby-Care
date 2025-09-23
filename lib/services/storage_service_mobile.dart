import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// Mobile implementation of StorageService using dart:io.
class StorageServiceMobile implements StorageService {
  static const String _dateFormat = 'yyyy-MM-dd';

  // Get history directory
  Future<Directory> _getHistoryDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final historyDir = Directory(
      '${dir.path}/${AppConstants.historyFolderName}',
    );
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    return historyDir;
  }

  @override
  Future<String> getAppDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
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

  @override
  Future<void> saveEvent(Event event) async {
    final file = await _getFileForDate(event.start);

    if (!await file.exists()) {
      await file.writeAsString(_createFileHeader(event.start));
    }

    final line = '${event.toFileLine()}\n';
    await file.writeAsString(line, mode: FileMode.append);
  }

  @override
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
    final file = await _getFileForDate(dayHistory.date);

    final buffer = StringBuffer();
    buffer.writeln(_createFileHeader(dayHistory.date).trim());

    for (final event in dayHistory.sortedEvents) {
      buffer.writeln(event.toFileLine());
    }

    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(buffer.toString());
    await tempFile.rename(file.path);
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
      final originalDayHistory = await loadDayHistory(originalDate);
      final updatedOriginalHistory = originalDayHistory.removeEvent(
        updatedEvent.id,
      );
      await updateDayHistory(updatedOriginalHistory);

      final newDayHistory = await loadDayHistory(newDate);
      final updatedNewHistory = newDayHistory.addEvent(updatedEvent);
      await updateDayHistory(updatedNewHistory);
    } else {
      final originalDayHistory = await loadDayHistory(originalDate);
      final updatedHistory = originalDayHistory.updateEvent(updatedEvent);
      await updateDayHistory(updatedHistory);
    }
  }

  @override
  Future<List<DateTime>> getAvailableDates() async {
    try {
      final historyDir = await _getHistoryDir();
      final files = await historyDir
          .list()
          .where(
            (entity) =>
                entity is File &&
                entity.path.endsWith(AppConstants.fileExtension),
          )
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

      dates.sort((a, b) => b.compareTo(a));
      return dates;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String?> getFilePathForDate(DateTime date) async {
    final file = await _getFileForDate(date);
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  @override
  Future<String?> getDayHistoryContent(DateTime date) async {
    final file = await _getFileForDate(date);
    if (await file.exists()) {
      return file.readAsString();
    }
    return null;
  }

  @override
  Future<void> clearAllData() async {
    final dir = await _getHistoryDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
