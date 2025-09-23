import 'package:flutter/material.dart';

class IconConstants {
  // Asset paths for custom icons
  static const String iconPath = 'assets/icons';
  static const String imagePath = 'assets/images';
  static const String animationPath = 'assets/animations';

  // Main action icons
  static const String bottle = '$iconPath/bottle.png';
  static const String droplet = '$iconPath/droplet.png';
  static const String poop = '$iconPath/poop.png';
  static const String clock = '$iconPath/clock.png';

  // Navigation icons
  static const String history = '$iconPath/history.png';
  static const String settings = '$iconPath/settings.png';
  static const String export = '$iconPath/export.png';
  static const String notification = '$iconPath/notification.png';

  // App icon and branding
  static const String appIcon = '$imagePath/app_icon/icon.png';
  static const String appIcon192 = '$imagePath/app_icon/icon_192.png';
  static const String appIcon512 = '$imagePath/app_icon/icon_512.png';

  // Splash and welcome
  static const String splashLogo = '$imagePath/splash/splash_logo.png';
  static const String babyCareBackground = '$imagePath/splash/baby_care_bg.png';

  // Illustrations
  static const String emptyHistory =
      '$imagePath/illustrations/empty_history.png';
  static const String welcomeBaby = '$imagePath/illustrations/welcome_baby.png';
  static const String feedingTime = '$imagePath/illustrations/feeding_time.png';

  // Animations
  static const String loadingBaby = '$animationPath/loading_baby.json';
  static const String successCheck = '$animationPath/success_check.json';
  static const String feedingTimer = '$animationPath/feeding_timer.json';

  // Icon sizes
  static const double smallIcon = 24.0;
  static const double mediumIcon = 32.0;
  static const double largeIcon = 48.0;
  static const double extraLargeIcon = 64.0;

  // Helper method to get icon widget
  static Widget getIcon(
    String assetPath, {
    double size = mediumIcon,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to material icon if asset not found
        return Icon(_getFallbackIcon(assetPath), size: size, color: color);
      },
    );
  }

  // Fallback material icons for missing assets
  static IconData _getFallbackIcon(String assetPath) {
    if (assetPath.contains('bottle')) return Icons.baby_changing_station;
    if (assetPath.contains('droplet')) return Icons.water_drop;
    if (assetPath.contains('poop')) return Icons.circle;
    if (assetPath.contains('clock')) return Icons.timer;
    if (assetPath.contains('history')) return Icons.history;
    if (assetPath.contains('settings')) return Icons.settings;
    if (assetPath.contains('export')) return Icons.share;
    if (assetPath.contains('notification')) return Icons.notifications;
    return Icons.help_outline;
  }

  // Pre-cache all assets
  static Future<void> precacheAssets(BuildContext context) async {
    final assets = [
      bottle,
      droplet,
      poop,
      clock,
      history,
      settings,
      export,
      notification,
      appIcon,
      splashLogo,
      emptyHistory,
      welcomeBaby,
      feedingTime,
    ];

    for (final asset in assets) {
      try {
        await precacheImage(AssetImage(asset), context);
      } catch (e) {
        // Asset might not exist, skip it
        print('Failed to precache asset: $asset');
      }
    }
  }
}
