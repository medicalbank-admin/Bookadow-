import 'dart:io';

import 'package:path/path.dart' as path;

import 'export_file_service.dart';

class ExportFileManagementService {
  ExportFileManagementService({
    ExportFileService? fileService,
  }) : _fileService = fileService ?? ExportFileService();

  final ExportFileService _fileService;

  Future<List<ManagedExportFile>> getAllFiles() async {
    final List<File> files =
        await _fileService.getExportedFiles();

    final List<ManagedExportFile> results = [];

    for (final File file in files) {
      try {
        if (!await file.exists()) continue;

        final FileStat stat = await file.stat();

        results.add(
          ManagedExportFile(
            path: file.path,
            name: path.basename(file.path),
            extension: path.extension(file.path).toLowerCase(),
            sizeBytes: stat.size,
            modifiedAt: stat.modified,
          ),
        );
      } on FileSystemException {
        continue;
      }
    }

    results.sort(
      (a, b) => b.modifiedAt.compareTo(a.modifiedAt),
    );

    return results;
  }

  Future<List<ManagedExportFile>> searchFiles(String query) async {
    final List<ManagedExportFile> files = await getAllFiles();
    final String normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) return files;

    return files.where((file) {
      return file.name.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);

      if (!await file.exists()) return false;

      await file.delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }

  Future<int> getTotalStorageUsed() async {
    final List<ManagedExportFile> files = await getAllFiles();

    return files.fold<int>(
      0,
      (total, file) => total + file.sizeBytes,
    );
  }

  Future<int> getFileCount() async {
    final List<ManagedExportFile> files = await getAllFiles();
    return files.length;
  }

  Future<bool> deleteAllFiles() async {
    final List<ManagedExportFile> files = await getAllFiles();
    bool successful = true;

    for (final ManagedExportFile file in files) {
      final bool deleted = await deleteFile(file.path);
      if (!deleted) successful = false;
    }

    return successful;
  }

  String formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class ManagedExportFile {
  const ManagedExportFile({
    required this.path,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.modifiedAt,
  });

  final String path;
  final String name;
  final String extension;
  final int sizeBytes;
  final DateTime modifiedAt;
}
