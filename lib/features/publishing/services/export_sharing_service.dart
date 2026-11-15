import 'dart:io';

import 'package:share_plus/share_plus.dart';

class ExportSharingService {
  Future<bool> shareExportedFile({
    required String filePath,
    String? subject,
    String? message,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('The exported file could not be found.');
    }

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(filePath),
        ],
        subject: subject,
        text: message,
      ),
    );

    return result.status == ShareResultStatus.success;
  }

  Future<bool> shareMultipleFiles({
    required List<String> filePaths,
    String? subject,
    String? message,
  }) async {
    if (filePaths.isEmpty) {
      throw ArgumentError('No files were selected for sharing.');
    }

    final files = <XFile>[];

    for (final filePath in filePaths) {
      final file = File(filePath);

      if (!await file.exists()) {
        continue;
      }

      files.add(XFile(filePath));
    }

    if (files.isEmpty) {
      throw Exception('None of the selected files could be found.');
    }

    final result = await SharePlus.instance.share(
      ShareParams(
        files: files,
        subject: subject,
        text: message,
      ),
    );

    return result.status == ShareResultStatus.success;
  }
}
