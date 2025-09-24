// lib/providers/export_provider.dart - Export State Management
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/export_service.dart';
import 'event_provider.dart';

final exportProvider = StateNotifierProvider<ExportNotifier, ExportState>((
  ref,
) {
  final exportService = ref.watch(exportServiceProvider);
  return ExportNotifier(exportService);
});

class ExportState {
  final bool isExporting;
  final String? error;
  final String? successMessage;

  const ExportState({
    this.isExporting = false,
    this.error,
    this.successMessage,
  });

  ExportState copyWith({
    bool? isExporting,
    String? error,
    String? successMessage,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ExportNotifier extends StateNotifier<ExportState> {
  final ExportService _exportService;

  ExportNotifier(this._exportService) : super(const ExportState());

  // Export single day
  Future<void> exportDay(DateTime date) async {
    state = state.copyWith(isExporting: true, error: null);
    try {
      await _exportService.exportDay(date);
      state = state.copyWith(
        isExporting: false,
        successMessage: 'Day exported successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export day: $e',
      );
    }
  }

  // Export date range
  Future<void> exportDateRange(DateTime start, DateTime end) async {
    state = state.copyWith(isExporting: true, error: null);
    try {
      await _exportService.exportDateRange(start, end);
      state = state.copyWith(
        isExporting: false,
        successMessage: 'Date range exported successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export date range: $e',
      );
    }
  }

  // Export as CSV
  Future<void> exportAsCSV(DateTime start, DateTime end) async {
    state = state.copyWith(isExporting: true, error: null);
    try {
      await _exportService.exportAsCSV(start, end);
      state = state.copyWith(
        isExporting: false,
        successMessage: 'CSV exported successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export CSV: $e',
      );
    }
  }

  // Export medical report
  Future<void> exportMedicalReport(DateTime start, DateTime end) async {
    state = state.copyWith(isExporting: true, error: null);
    try {
      await _exportService.exportMedicalReport(start, end);
      state = state.copyWith(
        isExporting: false,
        successMessage: 'Medical report exported successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export medical report: $e',
      );
    }
  }

  // Export all data
  Future<void> exportAllData() async {
    state = state.copyWith(isExporting: true, error: null);
    try {
      await _exportService.exportAllData();
      state = state.copyWith(
        isExporting: false,
        successMessage: 'All data exported successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Failed to export all data: $e',
      );
    }
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}
