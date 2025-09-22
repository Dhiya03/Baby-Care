class AppConstants {
  // Storage
  static const String historyFolderName = 'BabyHistory';
  static const String fileExtension = '.txt';

  // Event types
  static const String feedingType = 'Feeding';
  static const String urinationType = 'Urination';
  static const String stoolType = 'Stool';

  // Reminder settings
  static const int defaultReminderHours = 2;
  static const int urgentReminderHours = 3;

  // Notification IDs
  static const int reminderNotificationId = 100;
  static const int urgentReminderNotificationId = 101;

  // UI
  static const double buttonHeight = 80.0;
  static const double buttonRadius = 24.0;
  static const double cardRadius = 16.0;
  static const double spacing = 16.0;

  // File format
  static const String fileHeader = '# BabyHistory File:';
  static const String formatComment =
      '# Format: Type,TimestampStart,TimestampEnd,DurationMinutes,Notes';

  // Default notes
  static const String defaultNotes = 'None';
}
