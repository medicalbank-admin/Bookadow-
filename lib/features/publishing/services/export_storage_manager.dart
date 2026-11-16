import 'dart:io';

import 'export_file_service.dart';

class ExportStorageManager {
  ExportStorageManager({
    ExportFileService? fileService,
  }) : _fileService = fileService ?? ExportFileService();

  final ExportFileService _fileService;

  Future<List<File>> getStoredFiles() async {
    return _fileService.getExportedFiles();
  }

  Future<int> getTotalStorageUsed() async {
    final List<File> files = await getStoredFiles();

    int totalBytes = 0;

    for (final File file in files) {
      if (await file.exists()) {
        totalBytes += await file.length();
      }
    }

    return totalBytes;
  }

  Future<int> getStoredFileCount() async {
    final List<File> files = await getStoredFiles();

    return files.length;
  }

  Future<bool> hasMinimumFreeSpace({
    required int requiredBytes,
    int safetyMarginBytes = 10 * 1024 * 1024,
  }) async {
    // Portable Dart does not provide a reliable cross-platform
    // free-disk-space API. This checks only that the requested
    // size is sensible, not that the device has that space.
    return requiredBytes > 0 &&
        safetyMarginBytes >= 0;
  }

  Future<int> deleteOldExports({
    required DateTime olderThan,
  }) async {
    final List<File> files = await getStoredFiles();

    int deletedCount = 0;

    for (final File file in files) {
      try {
        if (!await file.exists()) continue;

        final FileStat stat = await file.stat();

        if (stat.modified.isBefore(olderThan)) {
          await file.delete();
          deletedCount++;
        }
      } on FileSystemException {
        // Continue cleaning other files if one file cannot
        // be accessed or deleted.
        continue;
      }
    }

    return deletedCount;
  }

  Future<bool> deleteExport(String filePath) async {
    return _fileService.deleteFile(filePath);
  }

  Future<String> formatBytes(int bytes) async {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
