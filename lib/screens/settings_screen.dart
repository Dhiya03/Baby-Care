import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../providers/event_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacing),
        children: [
          // Reminder settings section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Feeding Reminders'),
                  subtitle: const Text(
                    'Get notified when it\'s time to feed baby',
                  ),
                  trailing: Switch(
                    value: settings.remindersEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleReminders(value);
                    },
                  ),
                ),
                if (settings.remindersEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Reminder Interval'),
                    subtitle: Text(
                      '${settings.reminderHours} hours after feeding',
                    ),
                    trailing: DropdownButton<int>(
                      value: settings.reminderHours,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 hour')),
                        DropdownMenuItem(value: 2, child: Text('2 hours')),
                        DropdownMenuItem(value: 3, child: Text('3 hours')),
                        DropdownMenuItem(value: 4, child: Text('4 hours')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsProvider.notifier)
                              .setReminderHours(value);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Urgent Reminder'),
                    subtitle: Text(
                      '${settings.urgentReminderHours} hours (stronger notification)',
                    ),
                    trailing: DropdownButton<int>(
                      value: settings.urgentReminderHours,
                      items: const [
                        DropdownMenuItem(value: 2, child: Text('2 hours')),
                        DropdownMenuItem(value: 3, child: Text('3 hours')),
                        DropdownMenuItem(value: 4, child: Text('4 hours')),
                        DropdownMenuItem(value: 5, child: Text('5 hours')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsProvider.notifier)
                              .setUrgentReminderHours(value);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing),

          // Enhanced data management section
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.storage),
                  title: Text('Data Management'),
                  subtitle: Text('Export and manage your baby\'s history data'),
                ),
                const Divider(height: 1),

                // Enhanced export options
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Export All Data'),
                  subtitle: const Text('Complete history backup'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportAllData(context, ref),
                ),

                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('Medical Report'),
                  subtitle: const Text(
                    'Professional format for healthcare providers',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMedicalReportDialog(context, ref),
                ),

                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('Export as CSV'),
                  subtitle: const Text('Spreadsheet format for analysis'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCSVExportDialog(context, ref),
                ),

                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Weekly Summary'),
                  subtitle: const Text('Last 7 days summary'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportWeeklySummary(context, ref),
                ),

                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Monthly Summary'),
                  subtitle: const Text('Current month analysis'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportMonthlySummary(context, ref),
                ),

                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Storage Location'),
                  subtitle: const Text('View where data is stored'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showStorageInfo(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing),

          // App info section
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  subtitle: Text('BabyCare App v1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showHelp(context),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing),

          // Debug section (only in development)
          if (const bool.fromEnvironment('DEBUG', defaultValue: false))
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.bug_report),
                    title: Text('Debug'),
                    subtitle: Text('Development tools'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Clear All Data',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text(
                      'Delete all baby history (cannot be undone)',
                    ),
                    onTap: () => _clearAllData(context, ref),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Enhanced export methods
  void _exportAllData(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export All Data'),
        content: const Text(
          'This will export all your baby\'s history files. '
          'This may take a few moments and create multiple files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(eventActionsProvider).exportAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data exported successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error exporting all data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Export All'),
          ),
        ],
      ),
    );
  }

  void _showMedicalReportDialog(BuildContext context, WidgetRef ref) {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Report'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This will create a professional report suitable for sharing '
                'with healthcare providers. The report includes feeding patterns, '
                'statistics, and potential areas of concern.',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('MMM d, y').format(startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: endDate,
                  );
                  if (picked != null) {
                    setState(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(DateFormat('MMM d, y').format(endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(eventActionsProvider)
                    .exportMedicalReport(startDate, endDate);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medical report exported successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error exporting medical report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create Report'),
          ),
        ],
      ),
    );
  }

  void _showCSVExportDialog(BuildContext context, WidgetRef ref) {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
    DateTime endDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This will create a CSV file that can be opened in Excel, '
                'Google Sheets, or other spreadsheet applications for analysis.',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('MMM d, y').format(startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: endDate,
                  );
                  if (picked != null) {
                    setState(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(DateFormat('MMM d, y').format(endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(eventActionsProvider)
                    .exportAsCSV(startDate, endDate);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV file exported successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error exporting CSV: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Export CSV'),
          ),
        ],
      ),
    );
  }

  void _exportWeeklySummary(BuildContext context, WidgetRef ref) async {
    try {
      final weekStart = DateTime.now().subtract(const Duration(days: 6));
      await ref.read(eventActionsProvider).exportWeeklySummary(weekStart);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weekly summary exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting weekly summary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _exportMonthlySummary(BuildContext context, WidgetRef ref) async {
    try {
      final now = DateTime.now();
      await ref.read(eventActionsProvider).exportMonthlySummary(now);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monthly summary exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting monthly summary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStorageInfo(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your baby\'s data is stored locally on your device in:'),
            SizedBox(height: 8),
            Text(
              '/Documents/BabyHistory/',
              style: TextStyle(
                fontFamily: 'monospace',
                backgroundColor: Color(0xFFF5F5F5),
              ),
            ),
            SizedBox(height: 16),
            Text('File Format:'),
            Text('• One file per day (YYYY-MM-DD.txt)'),
            Text('• Human-readable CSV-like format'),
            Text('• Easy to share with healthcare providers'),
            Text('• No cloud storage (privacy-first)'),
            SizedBox(height: 16),
            Text('Export Options:'),
            Text('• Daily, weekly, or monthly summaries'),
            Text('• CSV format for spreadsheet analysis'),
            Text('• Medical reports for doctors'),
            Text('• Complete history backup'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use BabyCare:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('🍼 Feeding: Tap to start timer, tap again to stop'),
              Text('💧 Urination: One tap to log instantly'),
              Text('💩 Stool: One tap to log instantly'),
              Text('📖 History: View and edit past events'),
              Text('⏰ Reminders: Get notified for feeding times'),
              SizedBox(height: 16),
              Text(
                'Export Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Medical Reports: Professional format for doctors'),
              Text('• CSV Export: For analysis in spreadsheet apps'),
              Text('• Weekly/Monthly: Automated summary reports'),
              Text('• Complete Backup: Export all historical data'),
              SizedBox(height: 16),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Export medical reports before doctor visits'),
              Text('• Use CSV export for detailed analysis'),
              Text('• Regular backups ensure data safety'),
              Text('• Add notes to provide context for healthcare providers'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• All data is stored locally on your device'),
              Text('• No data is sent to external servers'),
              Text('• No account registration required'),
              Text('• You control all data sharing through export features'),
              SizedBox(height: 16),
              Text(
                'What We Store:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Baby feeding times and durations'),
              Text('• Urination and stool timestamps'),
              Text('• Notes you add to events'),
              Text('• App settings and preferences'),
              SizedBox(height: 16),
              Text(
                'Data Sharing:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Only when you explicitly export/share files'),
              Text('• You choose what to share and with whom'),
              Text('• Multiple export formats for different needs'),
              Text('• No automatic data transmission'),
              Text('• Medical reports are formatted for healthcare providers'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete ALL baby history data. '
          'Consider exporting your data first as a backup. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmClearAllData(context, ref);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This will permanently delete all baby history data. '
          'Have you exported your data as a backup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(eventActionsProvider).clearAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'DELETE ALL',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
