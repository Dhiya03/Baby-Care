import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';

// Settings model
class AppSettings {
  final bool remindersEnabled;
  final int reminderHours;
  final int urgentReminderHours;

  const AppSettings({
    this.remindersEnabled = true,
    this.reminderHours = AppConstants.defaultReminderHours,
    this.urgentReminderHours = AppConstants.urgentReminderHours,
  });

  AppSettings copyWith({
    bool? remindersEnabled,
    int? reminderHours,
    int? urgentReminderHours,
  }) {
    return AppSettings(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderHours: reminderHours ?? this.reminderHours,
      urgentReminderHours: urgentReminderHours ?? this.urgentReminderHours,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.remindersEnabled == remindersEnabled &&
        other.reminderHours == reminderHours &&
        other.urgentReminderHours == urgentReminderHours;
  }

  @override
  int get hashCode =>
      Object.hash(remindersEnabled, reminderHours, urgentReminderHours);
}

// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: Load from persistent storage (SharedPreferences)
    // For now, use defaults
  }

  void toggleReminders(bool enabled) {
    state = state.copyWith(remindersEnabled: enabled);
    _saveSettings();
  }

  void setReminderHours(int hours) {
    state = state.copyWith(reminderHours: hours);
    _saveSettings();
  }

  void setUrgentReminderHours(int hours) {
    state = state.copyWith(urgentReminderHours: hours);
    _saveSettings();
  }

  void _saveSettings() {
    // TODO: Save to persistent storage (SharedPreferences)
    // For now, just update state
  }
}

// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
