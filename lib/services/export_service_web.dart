import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'storage_service.dart';
import 'export_service.dart';

/// Web implementation of ExportService using SharedPreferences and text sharing.
class ExportServiceWeb implements ExportService {
  final StorageService _storageService;

  ExportServiceWeb(this._storageService);

  @override
  Future<bool> exportDay(DateTime date) async {
    try {
      final content = await _storageService.getDayHistoryContent(date);
      if (content != null && content.isNotEmpty) {
        await Share.share(
          content,
          subject: 'Baby Care History - ${DateFormat('MMM d, y').format(date)}',
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Failed to export day: $e');
    }
  }

  @override
  Future<bool> exportDateRange(DateTime startDate, DateTime endDate) async {
    // Web share does not support multiple files, so we combine them into one string.
    try {
      final buffer = StringBuffer();
      int fileCount = 0;
      for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
        final current = startDate.add(Duration(days: i));
        final content = await _storageService.getDayHistoryContent(current);
        if (content != null && content.isNotEmpty) {
          buffer.writeln(content);
          buffer.writeln('\n' + ('-' * 50) + '\n');
          fileCount++;
        }
      }

      if (fileCount == 0) {
        return false;
      }

      await Share.share(
        buffer.toString(),
        subject:
            'Baby history from ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
      );
      return true;
    } catch (e) {
      throw Exception('Failed to export date range: $e');
    }
  }

  @override
  Future<void> exportSummaryReport(DateTime startDate, DateTime endDate) async {
    try {
      final report = await _createSummaryReport(startDate, endDate);
      await Share.share(
        report,
        subject:
            'Baby Care Summary - ${DateFormat('MMM d').format(startDate)} to ${DateFormat('MMM d, y').format(endDate)}',
      );
    } catch (e) {
      throw Exception('Failed to export summary report: $e');
    }
  }

  @override
  Future<bool> exportAllData() async {
    // Combine all data into a single text block for web sharing.
    try {
      final availableDates = await _storageService.getAvailableDates();
      if (availableDates.isEmpty) {
        return false;
      }

      final buffer = StringBuffer();
      for (final date in availableDates) {
        final content = await _storageService.getDayHistoryContent(date);
        if (content != null && content.isNotEmpty) {
          buffer.writeln(content);
          buffer.writeln('\n' + ('-' * 50) + '\n');
        }
      }

      if (buffer.isEmpty) {
        return false;
      }

      await Share.share(
        buffer.toString(),
        subject: 'Baby Care History - Complete Export',
      );
      return true;
    } catch (e) {
      throw Exception('Failed to export all data: $e');
    }
  }

  @override
  Future<void> exportAsCSV(DateTime startDate, DateTime endDate) async {
    try {
      final csvData = await _createCSVData(startDate, endDate);
      if (csvData.isEmpty) {
        throw Exception('No data to export for the selected range.');
      }
      // On web, we share the raw CSV data as text.
      await Share.share(
        csvData,
        subject: 'Baby Care CSV Export',
      );
    } catch (e) {
      throw Exception('Failed to export as CSV: $e');
    }
  }

  @override
  Future<void> exportMedicalReport(DateTime startDate, DateTime endDate) async {
    // On web, the medical report is the same as the summary report.
    await exportSummaryReport(startDate, endDate);
  }

  @override
  Future<void> exportWeeklySummary(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    await exportSummaryReport(weekStart, weekEnd);
  }

  @override
  Future<void> exportMonthlySummary(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(
      month.year,
      month.month + 1,
      0,
    ); // Last day of month
    await exportSummaryReport(monthStart, monthEnd);
  }

  Future<String> _createCSVData(DateTime startDate, DateTime endDate) async {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('id,type,start,end,duration_minutes,notes');

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final current = startDate.add(Duration(days: i));
      final dayHistory = await _storageService.loadDayHistory(current);
      for (final event in dayHistory.events) {
        final startIso = event.start.toIso8601String();
        final endIso = event.end?.toIso8601String() ?? '';
        // Escape quotes in notes for CSV safety
        final notes = '"${event.notes.replaceAll('"', '""')}"';
        buffer.writeln(
          '${event.id},${event.type},$startIso,$endIso,${event.durationMinutes},$notes',
        );
      }
    }
    return buffer.toString();
  }

  Future<String> _createSummaryReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // This logic is platform-agnostic and can be shared.
    final buffer = StringBuffer();
    buffer.writeln('Baby Care Summary Report');
    buffer.writeln(
      'Period: ${DateFormat('MMM d, y').format(startDate)} - ${DateFormat('MMM d, y').format(endDate)}',
    );
    buffer.writeln(
      'Generated: ${DateFormat('MMM d, y HH:mm').format(DateTime.now())}',
    );
    buffer.writeln();
    buffer.writeln('=' * 50);
    buffer.writeln();

    int totalDays = 0;
    int totalFeedings = 0;
    int totalFeedingMinutes = 0;
    int totalUrinations = 0;
    int totalStools = 0;
    final dailyStats = <String>[];

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final current = startDate.add(Duration(days: i));
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
          '${dayHistory.urinationCount}U, ${dayHistory.stoolCount}S',
        );
      }
    }

    buffer.writeln('SUMMARY STATISTICS');
    buffer.writeln('-' * 20);
    buffer.writeln('Days with data: $totalDays');
    buffer.writeln('Total feedings: $totalFeedings');
    buffer.writeln(
      'Total feeding time: ${_formatDuration(totalFeedingMinutes)}',
    );
    buffer.writeln(
      'Average feeding time: ${totalFeedings > 0 ? _formatDuration(totalFeedingMinutes ~/ totalFeedings) : '0m'}',
    );
    buffer.writeln('Total urinations: $totalUrinations');
    buffer.writeln('Total stools: $totalStools');
    buffer.writeln();

    if (totalDays > 0) {
      buffer.writeln('Daily averages:');
      buffer.writeln(
        '- Feedings: ${(totalFeedings / totalDays).toStringAsFixed(1)} per day',
      );
      buffer.writeln(
        '- Feeding time: ${_formatDuration((totalFeedingMinutes / totalDays).round())} per day',
      );
      buffer.writeln(
        '- Urinations: ${(totalUrinations / totalDays).toStringAsFixed(1)} per day',
      );
      buffer.writeln(
        '- Stools: ${(totalStools / totalDays).toStringAsFixed(1)} per day',
      );
      buffer.writeln();
    }

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
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}
