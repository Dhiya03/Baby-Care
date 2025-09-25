import 'event.dart';
import '../utils/constants.dart';

class DayHistory {
  final DateTime date;
  final List<Event> events;

  DayHistory({required this.date, required this.events});

  // Get events by type
  List<Event> get feedingEvents =>
      events.where((e) => e.type == AppConstants.feedingType).toList();
  List<Event> get urinationEvents =>
      events.where((e) => e.type == AppConstants.urinationType).toList();
  List<Event> get stoolEvents =>
      events.where((e) => e.type == AppConstants.stoolType).toList();

  // Get events sorted by time
  List<Event> get sortedEvents {
    final sorted = List<Event>.from(events);
    sorted.sort((a, b) => a.start.compareTo(b.start));
    return sorted;
  }

  // Get last feeding event
  Event? get lastFeeding {
    final feedings = feedingEvents;
    if (feedings.isEmpty) return null;
    feedings.sort((a, b) => b.start.compareTo(a.start));
    return feedings.first;
  }

  // Total feeding duration for the day
  int get totalFeedingMinutes {
    return feedingEvents.fold(0, (sum, event) => sum + event.durationMinutes);
  }

  // Event counts
  int get feedingCount => feedingEvents.length;
  int get urinationCount => urinationEvents.length;
  int get stoolCount => stoolEvents.length;

  // Add event
  DayHistory addEvent(Event event) {
    final newEvents = List<Event>.from(events);
    newEvents.add(event);
    return DayHistory(date: date, events: newEvents);
  }

  // Remove event
  DayHistory removeEvent(String eventId) {
    final newEvents = events.where((e) => e.id != eventId).toList();
    return DayHistory(date: date, events: newEvents);
  }

  // Update event
  DayHistory updateEvent(Event updatedEvent) {
    final newEvents =
        events.map((e) => e.id == updatedEvent.id ? updatedEvent : e).toList();
    return DayHistory(date: date, events: newEvents);
  }

  // Check if day has events
  bool get hasEvents => events.isNotEmpty;

  // Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) return 'Today';
    if (eventDate == yesterday) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  String toString() {
    return 'DayHistory(date: $date, events: ${events.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayHistory &&
        other.date == date &&
        other.events.length == events.length;
  }

  @override
  int get hashCode => Object.hash(date, events.length);

  // Convert to savable string (e.g. for file or web storage)
String toFile() {
  final buffer = StringBuffer();
  for (var event in events) {
    buffer.writeln(event.toFileLine());
  }
  return buffer.toString();
}

// Parse from file content
static DayHistory fromFile(String content, DateTime date) {
  final lines = content.trim().split('\n');
  final events = <Event>[];
  int counter = 0;
  for (var line in lines) {
    if (line.trim().isEmpty) continue;
    events.add(Event.fromFileLine(line, 'event_$counter'));
    counter++;
  }
  return DayHistory(date: date, events: events);
}

Map<String, dynamic> toJson() => {
  'date': date.toIso8601String(),
  'events': events.map((e) => e.toJson()).toList(),
};

factory DayHistory.fromJson(Map<String, dynamic> json) => DayHistory(
  date: DateTime.parse(json['date']),
  events: (json['events'] as List)
      .map((e) => Event.fromJson(e))
      .toList(),
);


}
