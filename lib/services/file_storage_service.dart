import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import 'storage_service.dart';

class FileStorageService implements StorageService {
  static const _folderName = "BabyHistory";

  Future<Directory> _getFolder() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$_folderName');
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    return folder;
  }

  String _fileNameForDate(DateTime date) =>
      "${date.year}-${date.month}-${date.day}.txt";

  @override
  Future<void> saveEvent(Event event) async {
    final history = await loadDayHistory(event.timestamp);
    history.events.add(event);
    await updateDayHistory(history);
  }

  @override
  Future<DayHistory> loadDayHistory(DateTime date) async {
    final folder = await _getFolder();
    final file = File('${folder.path}/${_fileNameForDate(date)}');
    if (!await file.exists()) {
      return DayHistory(date: date, events: []);
    }
    final content = await file.readAsString();
    return DayHistory.fromJson(content);
  }

  @override
  Future<void> updateDayHistory(DayHistory dayHistory) async {
    final folder = await _getFolder();
    final file = File('${folder.path}/${_fileNameForDate(dayHistory.date)}');
    await file.writeAsString(dayHistory.toJson(), flush: true);
  }

  @override
  Future<void> deleteEvent(DateTime date, String eventId) async {
    final history = await loadDayHistory(date);
    history.events.removeWhere((e) => e.id == eventId);
    await updateDayHistory(history);
  }

  @override
  Future<void> updateEvent(DateTime originalDate, Event updatedEvent) async {
    if (originalDate == updatedEvent.timestamp) {
      await deleteEvent(originalDate, updatedEvent.id);
      await saveEvent(updatedEvent);
    } else {
      await deleteEvent(originalDate, updatedEvent.id);
      await saveEvent(updatedEvent);
    }
  }

  @override
  Future<List<DateTime>> getAvailableDates() async {
    final folder = await _getFolder();
    final files = folder.listSync().whereType<File>();
    return files.map((f) {
      final name = f.uri.pathSegments.last.replaceAll('.txt', '');
      final parts = name.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();
  }

  @override
  Future<String?> getFilePathForDate(DateTime date) async {
    final folder = await _getFolder();
    final file = File('${folder.path}/${_fileNameForDate(date)}');
    return file.existsSync() ? file.path : null;
  }

  @override
  Future<String?> getDayHistoryContent(DateTime date) async {
    final folder = await _getFolder();
    final file = File('${folder.path}/${_fileNameForDate(date)}');
    if (!file.existsSync()) return null;
    return await file.readAsString();
  }

  @override
  Future<String> getAppDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  @override
  Future<void> clearAllData() async {
    final folder = await _getFolder();
    if (folder.existsSync()) {
      await folder.delete(recursive: true);
    }
  }
}
