import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'storage_service.dart';
import '../models/day_history.dart';

class ExportService {
  final StorageService _storageService;

  ExportService(this._storageService);

  // Export single day as text file
  Future<void> exportDay(DateTime date) async {
    try {
      final filePath = await _storageService.getFilePathForDate(date);
      if (filePath != null && await File(filePath).exists()) {
        await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Baby care summary report',
        subject: 'Baby Care Summary - ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
      );
      
      // Clean up temp file after sharing
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to export summary report: $e');
    }
  }

  // Format duration in minutes to readable string
  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  // Get all available files for bulk export
  Future<List<DateTime>> getAvailableDatesForExport() async {
    return await _storageService.getAvailableDates();
  }

  // Export all available data
  Future<void> exportAllData() async {
    try {
      final availableDates = await getAvailableDatesForExport();
      
      if (availableDates.isEmpty) {
        throw Exception('No data available to export');
      }

      final files = <XFile>[];
      
      // Add individual day files
      for (final date in availableDates) {
        final filePath = await _storageService.getFilePathForDate(date);
        if (filePath != null && await File(filePath).exists()) {
          files.add(XFile(filePath));
        }
      }

      if (files.isEmpty) {
        throw Exception('No valid files found to export');
      }

      await Share.shareXFiles(
        files,
        text: 'Complete baby care history (${files.length} files)',
        subject: 'Baby Care History - Complete Export',
      );
    } catch (e) {
      throw Exception('Failed to export all data: $e');
    }
  }

  // Create and export weekly summary
  Future<void> exportWeeklySummary(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    await exportSummaryReport(weekStart, weekEnd);
  }

  // Create and export monthly summary
  Future<void> exportMonthlySummary(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0); // Last day of month
    await exportSummaryReport(monthStart, monthEnd);
  }
}Files(
          [XFile(filePath)],
          text: 'Baby history for ${DateFormat('yyyy-MM-dd').format(date)}',
          subject: 'Baby Care History - ${DateFormat('MMM d, y').format(date)}',
        );
      } else {
        throw Exception('No data available for ${DateFormat('yyyy-MM-dd').format(date)}');
      }
    } catch (e) {
      throw Exception('Failed to export day: $e');
    }
  }

  // Export multiple days as separate files
  Future<void> exportDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final files = <XFile>[];
      final current = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      while (!current.isAfter(end)) {
        final filePath = await _storageService.getFilePathForDate(current);
        if (filePath != null && await File(filePath).exists()) {
          files.add(XFile(filePath));
        }
        current.add(const Duration(days: 1));
      }

      if (files.isEmpty) {
        throw Exception('No data available for the selected date range');
      }

      await Share.shareXFiles(
        files,
        text: 'Baby history from ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
        subject: 'Baby Care History - Date Range',
      );
    } catch (e) {
      throw Exception('Failed to export date range: $e');
    }
  }

  // Create summary report for a date range
  Future<String> createSummaryReport(DateTime startDate, DateTime endDate) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Baby Care Summary Report');
      buffer.writeln('Period: ${DateFormat('MMM d, y').format(startDate)} - ${DateFormat('MMM d, y').format(endDate)}');
      buffer.writeln('Generated: ${DateFormat('MMM d, y HH:mm').format(DateTime.now())}');
      buffer.writeln();
      buffer.writeln('=' * 50);
      buffer.writeln();

      final current = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      
      int totalDays = 0;
      int totalFeedings = 0;
      int totalFeedingMinutes = 0;
      int totalUrinations = 0;
      int totalStools = 0;
      final dailyStats = <String>[];

      while (!current.isAfter(end)) {
        final dayHistory = await _storageService.loadDayHistory(current);
        
        if (dayHistory.hasEvents) {
          totalDays++;
          totalFeedings += dayHistory.feedingCount;
          totalFeedingMinutes += dayHistory.totalFeedingMinutes;
          totalUrinations += dayHistory.urinationCount;
          totalStools += dayHistory.stoolCount;

          dailyStats.add(
            '${DateFormat('MMM d').format(current)}: '
            '${dayHistory.feedingCount}F (${dayHistory.totalFeedingMinutes}m), '
            '${dayHistory.urinationCount}U, ${dayHistory.stoolCount}S'
          );
        }
        
        current.add(const Duration(days: 1));
      }

      // Overall statistics
      buffer.writeln('SUMMARY STATISTICS');
      buffer.writeln('-' * 20);
      buffer.writeln('Days with data: $totalDays');
      buffer.writeln('Total feedings: $totalFeedings');
      buffer.writeln('Total feeding time: ${_formatDuration(totalFeedingMinutes)}');
      buffer.writeln('Average feeding time: ${totalFeedings > 0 ? _formatDuration(totalFeedingMinutes ~/ totalFeedings) : '0m'}');
      buffer.writeln('Total urinations: $totalUrinations');
      buffer.writeln('Total stools: $totalStools');
      buffer.writeln();

      if (totalDays > 0) {
        buffer.writeln('Daily averages:');
        buffer.writeln('- Feedings: ${(totalFeedings / totalDays).toStringAsFixed(1)} per day');
        buffer.writeln('- Feeding time: ${_formatDuration((totalFeedingMinutes / totalDays).round())} per day');
        buffer.writeln('- Urinations: ${(totalUrinations / totalDays).toStringAsFixed(1)} per day');
        buffer.writeln('- Stools: ${(totalStools / totalDays).toStringAsFixed(1)} per day');
        buffer.writeln();
      }

      // Daily breakdown
      if (dailyStats.isNotEmpty) {
        buffer.writeln('DAILY BREAKDOWN');
        buffer.writeln('-' * 15);
        for (final stat in dailyStats) {
          buffer.writeln(stat);
        }
        buffer.writeln();
      }

      buffer.writeln('Legend: F=Feedings, U=Urinations, S=Stools');
      buffer.writeln('Note: Times shown in minutes (m)');

      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to create summary report: $e');
    }
  }

  // Export summary report as text file
  Future<void> exportSummaryReport(DateTime startDate, DateTime endDate) async {
    try {
      final report = await createSummaryReport(startDate, endDate);
      
      // Create temporary file
      final tempDir = await _storageService._getHistoryDir();
      final tempFile = File('${tempDir.path}/summary_${DateFormat('yyyy-MM-dd').format(startDate)}_to_${DateFormat('yyyy-MM-dd').format(endDate)}.txt');
      
      await tempFile.writeAsString(report);
      
      await Share.shareX