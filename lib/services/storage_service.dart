import '../models/event.dart';
import '../models/day_history.dart';

/// Abstract class defining the contract for storage services.
abstract class StorageService {
  /// Saves a single event.
  Future<void> saveEvent(Event event);

  /// Loads all events for a specific date.
  Future<DayHistory> loadDayHistory(DateTime date);

  /// Overwrites the file for a given day with the new history.
  Future<void> updateDayHistory(DayHistory dayHistory);

  /// Deletes a single event by its ID from the corresponding day's file.
  Future<void> deleteEvent(DateTime date, String eventId);

  /// Updates an existing event. Handles moving the event if the date has changed.
  Future<void> updateEvent(DateTime originalDate, Event updatedEvent);

  /// Returns a list of all dates for which history files exist.
  Future<List<DateTime>> getAvailableDates();

  /// Returns the file path for a given date's history, for sharing purposes.
  Future<String?> getFilePathForDate(DateTime date);

  /// Returns the raw string content for a given date's history.
  Future<String?> getDayHistoryContent(DateTime date);

  /// Returns a path to a directory for temporary files. Not applicable on web.
  Future<String> getAppDirectoryPath();

  /// Deletes all stored history data.
  Future<void> clearAllData();
}
