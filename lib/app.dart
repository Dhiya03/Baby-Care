import 'package:flutter/material.dart';
import 'screens/edit_entry_screen.dart';
import 'screens/feeding_timer_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

class BabyCareApp extends StatelessWidget {
  const BabyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Care',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/feeding-timer': (context) => const FeedingTimerScreen(),
        '/history': (context) => const HistoryScreen(),
        '/edit-entry': (context) => const EditEntryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
