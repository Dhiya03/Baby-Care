/// Abstract class defining the contract for export services.
///
/// This class uses a factory constructor in the provider to supply a
/// platform-specific implementation. It will provide [ExportServiceMobile] on
/// mobile platforms and [ExportServiceWeb] on the web.
abstract class ExportService {
  /// Exports a single day's history.
  Future<bool> exportDay(DateTime date);

  /// Exports a range of dates.
  Future<bool> exportDateRange(DateTime startDate, DateTime endDate);

  /// Creates and shares a summary report for a date range.
  Future<void> exportSummaryReport(DateTime startDate, DateTime endDate);

  /// Exports all available data.
  Future<bool> exportAllData();

  /// Exports a weekly summary report.
  Future<void> exportWeeklySummary(DateTime weekStart);

  /// Exports a monthly summary report.
  Future<void> exportMonthlySummary(DateTime month);

  /// Exports a date range as a CSV file.
  Future<void> exportAsCSV(DateTime startDate, DateTime endDate);

  /// Creates and shares a professional medical report for a date range.
  Future<void> exportMedicalReport(DateTime startDate, DateTime endDate);
}
