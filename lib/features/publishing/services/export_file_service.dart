import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ExportFileService {
  static const String exportFolderName = 'BOOKADOW_Exports';

  Future<Directory> getExportDirectory() async {
    final appDirectory =
        await getApplicationDocumentsDirectory();

    final exportDirectory = Directory(
      path.join(
        appDirectory.path,
        exportFolderName,
      ),
    );

    if (!await exportDirectory.exists()) {
      await exportDirectory.create(recursive: true);
    }

    return exportDirectory;
  }

  Future<String> generateFilePath({
    required String fileName,
    required String extension,
  }) async {
    final directory = await getExportDirectory();

    final safeName = sanitizeFileName(fileName);
    final safeExtension = extension
        .replaceAll('.', '')
        .trim()
        .toLowerCase();

    if (safeExtension.isEmpty) {
      throw ArgumentError('A file extension is required.');
    }

    return path.join(
      directory.path,
      '$safeName.$safeExtension',
    );
  }

  Future<File> createExportFile({
    required String fileName,
    required String extension,
    required List<int> bytes,
  }) async {
    final filePath = await generateFilePath(
      fileName: fileName,
      extension: extension,
    );

    final file = File(filePath);

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }

  Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      return 0;
    }

    return file.length();
  }

  Future<bool> deleteFile(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      return false;
    }

    await file.delete();
    return true;
  }

  Future<List<FileSystemEntity>> getExportedFiles() async {
    final directory = await getExportDirectory();

    final files = await directory
        .list(followLinks: false)
        .where((entity) => entity is File)
        .toList();

    files.sort((a, b) {
      return b.statSync().modified.compareTo(
            a.statSync().modified,
          );
    });

    return files;
  }

  String sanitizeFileName(String fileName) {
    var result = fileName.trim();

    result = result.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );

    result = result.replaceAll(
      RegExp(r'\s+'),
      '_',
    );

    result = result.replaceAll(
      RegExp(r'_+'),
      '_',
    );

    result = result.replaceAll(
      RegExp(r'^\.+|\.+$'),
      '',
    );

    if (result.isEmpty) {
      result = 'BOOKADOW_Book';
    }

    if (result.length > 120) {
      result = result.substring(0, 120);
    }

    return result;
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
