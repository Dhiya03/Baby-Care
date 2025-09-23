import 'package:intl/intl.dart';

class DateHelper {
  // Date formats
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('MMM d, y HH:mm');
  static final _displayDateFormat = DateFormat('MMM d, y');
  static final _dayNameFormat = DateFormat('EEEE');

  // Format date for file names (yyyy-MM-dd)
  static String formatForFileName(DateTime date) {
    return _dateFormat.format(date);
  }

  // Format time for display (HH:mm)
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  // Format date and time for display (MMM d, y HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Format date for display (MMM d, y)
  static String formatDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  // Get relative date string (Today, Yesterday, or date)
  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';

    // If within the last week, show day name
    final daysDifference = today.difference(dateOnly).inDays;
    if (daysDifference > 0 && daysDifference < 7) {
      return _dayNameFormat.format(date);
    }

    return formatDate(date);
  }

  // Get date only (without time)
  static DateTime getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly == today;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly == yesterday;
  }

  // Get start of week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // Get end of week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }

  // Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Format duration in minutes to readable string
  static String formatDuration(int minutes) {
    if (minutes == 0) return '0m';
    if (minutes < 60) return '${minutes}m';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  // Format duration for timer display (MM:SS)
  static String formatTimerDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Parse date from file name format
  static DateTime? parseFromFileName(String fileName) {
    try {
      final dateString = fileName.replaceAll('.txt', '');
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get time ago string (e.g., "2 hours ago", "30 minutes ago")
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }

  // Get next feeding time based on interval
  static DateTime getNextFeedingTime(DateTime lastFeeding, int intervalHours) {
    return lastFeeding.add(Duration(hours: intervalHours));
  }

  // Check if it's time to feed based on last feeding and interval
  static bool isTimeToFeed(DateTime lastFeeding, int intervalHours) {
    final nextFeedingTime = getNextFeedingTime(lastFeeding, intervalHours);
    return DateTime.now().isAfter(nextFeedingTime);
  }

  // Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = getDateOnly(start);
    final endDate = getDateOnly(end);
    return endDate.difference(startDate).inDays;
  }

  // Generate date range
  static List<DateTime> generateDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    DateTime current = getDateOnly(start);
    final endDate = getDateOnly(end);

    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }
}
