import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'constants.dart';

class FileHelper {
  // Get app documents directory
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Get baby history directory
  static Future<Directory> getBabyHistoryDirectory() async {
    final docs = await getDocumentsDirectory();
    final historyDir = Directory(
      '${docs.path}/${AppConstants.historyFolderName}',
    );

    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }

    return historyDir;
  }

  // Get file name for date
  static String getFileNameForDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day${AppConstants.fileExtension}';
  }

  // Get file path for date
  static Future<String> getFilePathForDate(DateTime date) async {
    final historyDir = await getBabyHistoryDirectory();
    final fileName = getFileNameForDate(date);
    return '${historyDir.path}/$fileName';
  }

  // Check if file exists for date
  static Future<bool> fileExistsForDate(DateTime date) async {
    final filePath = await getFilePathForDate(date);
    return await File(filePath).exists();
  }

  // Get file size for date
  static Future<int> getFileSizeForDate(DateTime date) async {
    try {
      final filePath = await getFilePathForDate(date);
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      // File doesn't exist or can't be accessed
    }
    return 0;
  }

  // Get all history files
  static Future<List<File>> getAllHistoryFiles() async {
    try {
      final historyDir = await getBabyHistoryDirectory();
      final entities = await historyDir.list().toList();

      return entities
          .where(
            (entity) =>
                entity is File &&
                entity.path.endsWith(AppConstants.fileExtension),
          )
          .cast<File>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get total storage used
  static Future<int> getTotalStorageUsed() async {
    try {
      final files = await getAllHistoryFiles();
      int totalSize = 0;

      for (final file in files) {
        totalSize += await file.length();
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  // Format file size to human readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Create backup file name with timestamp
  static String createBackupFileName(String originalName) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    final nameWithoutExtension = originalName.replaceAll('.$extension', '');
    return '${nameWithoutExtension}_backup_$timestamp.$extension';
  }

  // Validate file name
  static bool isValidFileName(String fileName) {
    // Check if it matches our date format pattern
    final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}\.txt$');
    return pattern.hasMatch(fileName);
  }

  // Clean up old backup files (keep only last N backups)
  static Future<void> cleanupOldBackups({int keepCount = 5}) async {
    try {
      final historyDir = await getBabyHistoryDirectory();
      final entities = await historyDir.list().toList();

      final backupFiles = entities
          .where((entity) => entity is File && entity.path.contains('_backup_'))
          .cast<File>()
          .toList();

      if (backupFiles.length <= keepCount) return;

      // Sort by modification time (oldest first)
      backupFiles.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return aStat.modified.compareTo(bStat.modified);
      });

      // Delete oldest files
      final filesToDelete = backupFiles.take(backupFiles.length - keepCount);
      for (final file in filesToDelete) {
        try {
          await file.delete();
        } catch (e) {
          // Ignore individual file deletion errors
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  // Create directory if it doesn't exist
  static Future<Directory> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  // Copy file to backup location
  static Future<void> createBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;

      final fileName = file.uri.pathSegments.last;
      final backupName = createBackupFileName(fileName);
      final historyDir = await getBabyHistoryDirectory();
      final backupPath = '${historyDir.path}/$backupName';

      await file.copy(backupPath);

      // Clean up old backups
      await cleanupOldBackups();
    } catch (e) {
      // Ignore backup errors
    }
  }

  // Atomic file write (write to temp file, then rename)
  static Future<void> writeFileAtomically(
    String filePath,
    String content,
  ) async {
    final tempPath = '$filePath.tmp';
    final tempFile = File(tempPath);
    final targetFile = File(filePath);

    try {
      // Write to temp file
      await tempFile.writeAsString(content);

      // Create backup of existing file if it exists
      if (await targetFile.exists()) {
        await createBackup(filePath);
      }

      // Atomic rename
      await tempFile.rename(filePath);
    } catch (e) {
      // Clean up temp file if something went wrong
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }
}
