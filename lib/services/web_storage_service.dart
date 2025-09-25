import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/day_history.dart';
import 'storage_service.dart';

class WebStorageService implements StorageService {
  static const _keyPrefix = "baby_history_";

  String _dateKey(DateTime date) =>
      "$_keyPrefix${date.year}-${date.month}-${date.day}";

  @override
  Future<void> saveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(event.start);

    final existing = prefs.getString(key);
    final history = existing != null
        ? DayHistory.fromFile(existing, event.start)
        : DayHistory(date: event.start, events: []);

    final updated = history.addEvent(event);
    await prefs.setString(key, updated.toFile());
  }

  @override
  Future<DayHistory> loadDayHistory(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_dateKey(date));

    return data != null
        ? DayHistory.fromFile(data, date)
        : DayHistory(date: date, events: []);
  }

  @override
  Future<void> updateDayHistory(DayHistory dayHistory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey(dayHistory.date), dayHistory.toFile());
  }

  @override
  Future<void> deleteEvent(DateTime date, String eventId) async {
    final history = await loadDayHistory(date);
    final updated = history.removeEvent(eventId);
    await updateDayHistory(updated);
  }

  @override
  Future<void> updateEvent(DateTime originalDate, Event updatedEvent) async {
    if (originalDate != updatedEvent.start) {
      await deleteEvent(originalDate, updatedEvent.id);
      await saveEvent(updatedEvent);
    } else {
      final history = await loadDayHistory(originalDate);
      final updated = history.updateEvent(updatedEvent);
      await updateDayHistory(updated);
    }
  }

  @override
  Future<List<DateTime>> getAvailableDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .map((k) {
      final parts = k.replaceFirst(_keyPrefix, '').split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();
  }

  @override
  Future<String?> getFilePathForDate(DateTime date) async => null;

  @override
  Future<String?> getDayHistoryContent(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dateKey(date));
  }

  @override
  Future<String> getAppDirectoryPath() async {
    throw UnsupportedError("Web does not support file system paths");
  }

  @override
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (final k in keysToRemove) {
      await prefs.remove(k);
    }
  }
}
