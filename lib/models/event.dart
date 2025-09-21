import '../utils/constants.dart';

class Event {
  final String id;
  final String type;
  final DateTime start;
  final DateTime? end;
  final int durationMinutes;
  final String notes;

  Event({
    required this.id,
    required this.type,
    required this.start,
    this.end,
    required this.durationMinutes,
    this.notes = AppConstants.defaultNotes,
  });

  // Create feeding event
  factory Event.feeding({
    required String id,
    required DateTime start,
    DateTime? end,
    int durationMinutes = 0,
    String notes = AppConstants.defaultNotes,
  }) {
    return Event(
      id: id,
      type: AppConstants.feedingType,
      start: start,
      end: end,
      durationMinutes: durationMinutes,
      notes: notes,
    );
  }

  // Create instant event (urine/stool)
  factory Event.instant({
    required String id,
    required String type,
    required DateTime timestamp,
    String notes = AppConstants.defaultNotes,
  }) {
    return Event(
      id: id,
      type: type,
      start: timestamp,
      end: null,
      durationMinutes: 0,
      notes: notes,
    );
  }

  // Convert to file line format
  String toFileLine() {
    final startIso = start.toIso8601String();
    final endIso = end?.toIso8601String() ?? '';
    final cleanNotes = notes.replaceAll(',', ';').replaceAll('\n', ' ');
    return '$type,$startIso,$endIso,$durationMinutes,$cleanNotes';
  }

  // Parse from file line
  static Event fromFileLine(String line, String id) {
    final parts = line.split(',');
    if (parts.length < 4) {
      throw FormatException('Invalid event line format: $line');
    }
    
    return Event(
      id: id,
      type: parts[0],
      start: DateTime.parse(parts[1]),
      end: parts[2].isEmpty ? null : DateTime.parse(parts[2]),
      durationMinutes: int.tryParse(parts[3]) ?? 0,
      notes: parts.length > 4 ? parts.sublist(4).join(',') : AppConstants.defaultNotes,
    );
  }

  // Copy with modifications
  Event copyWith({
    String? id,
    String? type,
    DateTime? start,
    DateTime? end,
    int? durationMinutes,
    String? notes,
  }) {
    return Event(
      id: id ?? this.id,
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
    );
  }

  // Check if event is feeding
  bool get isFeeding => type == AppConstants.feedingType;
  
  // Check if event is instant (urine/stool)
  bool get isInstant => type == AppConstants.urinationType || type == AppConstants.stoolType;
  
  // Get display duration
  String get displayDuration {
    if (durationMinutes == 0) return '';
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  String toString() {
    return 'Event(id: $id, type: $type, start: $start, end: $end, duration: $durationMinutes, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.type == type &&
        other.start == start &&
        other.end == end &&
        other.durationMinutes == durationMinutes &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(id, type, start, end, durationMinutes, notes);
  }
}