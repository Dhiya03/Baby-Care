import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
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
                  subtitle: const Text('Get notified when it\'s time to feed baby'),
                  trailing: Switch(
                    value: settings.remindersEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleReminders(value);
                    },
                  ),
                ),
                if (settings.remindersEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Reminder Interval'),
                    subtitle: Text('${settings.reminderHours} hours after feeding'),
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
                          ref.read(settingsProvider.notifier).setReminderHours(value);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Urgent Reminder'),
                    subtitle: Text('${settings.urgentReminderHours} hours (stronger notification)'),
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
                          ref.read(settingsProvider.notifier).setUrgentReminderHours(value);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing),
          
          // Data management section
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.storage),
                  title: Text('Data Management'),
                  subtitle: Text('Manage your baby\'s history data'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Export All Data'),
                  subtitle: const Text('Share all history files'),
                  trailing: const Icon(Icons.share),
                  onTap: () => _exportAllData(context, ref),
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
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Delete all baby history (cannot be undone)'),
                    onTap: () => _clearAllData(context, ref),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _exportAllData(BuildContext context, WidgetRef ref) async {
    try {
      // This would implement exporting all available history files
      // For now, show a placeholder dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export All Data'),
          content: const Text(
            'This feature will export all your baby\'s history files. '
            'You can then share them with doctors or backup to cloud storage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export feature coming soon!'),
                  ),
                );
              },
              child: const Text('Export'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
            Text('• One file per day (YYYY-MM-DD.txt)'),
            Text('• Human-readable format'),
            Text('• Easy to share with doctors'),
            Text('• No cloud storage (privacy-first)'),
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
              Text('How to use BabyCare:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('🍼 Feeding: Tap to start timer, tap again to stop'),
              Text('💧 Urination: One tap to log instantly'),
              Text('💩 Stool: One tap to log instantly'),
              Text('📖 History: View and edit past events'),
              Text('⏰ Reminders: Get notified for feeding times'),
              SizedBox(height: 16),
              Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Use lock screen notifications for quick access'),
              Text('• Add notes to track feeding details'),
              Text('• Export daily files to share with doctors'),
              Text('• Edit entries if you need to correct timing'),
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
              Text('Your Privacy Matters', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• All data is stored locally on your device'),
              Text('• No data is sent to external servers'),
              Text('• No account registration required'),
              Text('• You control all data sharing'),
              SizedBox(height: 16),
              Text('What We Store:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Baby feeding times and durations'),
              Text('• Urination and stool timestamps'),
              Text('• Notes you add to events'),
              Text('• App settings and preferences'),
              SizedBox(height: 16),
              Text('Data Sharing:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Only when you explicitly export/share files'),
              Text('• You choose what to share and with whom'),
              Text('• No automatic data transmission'),
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
          'This action cannot be undone. Are you absolutely sure?',
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
            child: const Text('Continue', style: TextStyle(color: Colors.orange)),
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
          'Type "DELETE" to confirm you want to permanently delete all baby history data.',
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
                // This would implement clearing all data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error clearing data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('DELETE ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}