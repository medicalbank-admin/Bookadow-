import 'dart:io';

import '../models/book_export_model.dart';

class ExportFileValidationService {
  const ExportFileValidationService();

  Future<ExportFileValidationResult> validate({
    required String filePath,
    required BookExportFormat format,
    int minimumFileSizeBytes = 1,
  }) async {
    final List<String> errors = [];
    final File file = File(filePath);

    if (filePath.trim().isEmpty) {
      errors.add('The export file path is empty.');

      return ExportFileValidationResult(
        isValid: false,
        errors: errors,
        fileSizeBytes: 0,
      );
    }

    try {
      if (!await file.exists()) {
        errors.add('The exported file does not exist.');
      } else {
        final int fileSize = await file.length();

        if (fileSize < minimumFileSizeBytes) {
          errors.add('The exported file is empty or incomplete.');
        }

        final String expectedExtension =
            _expectedExtension(format);

        if (!filePath.toLowerCase().endsWith(
          expectedExtension,
        )) {
          errors.add(
            'The exported file has an incorrect extension.',
          );
        }

        return ExportFileValidationResult(
          isValid: errors.isEmpty,
          errors: errors,
          fileSizeBytes: fileSize,
        );
      }
    } on FileSystemException catch (error) {
      errors.add('Unable to inspect export file: ${error.message}');
    } catch (error) {
      errors.add('Unexpected file validation error: $error');
    }

    return ExportFileValidationResult(
      isValid: false,
      errors: errors,
      fileSizeBytes: 0,
    );
  }

  String _expectedExtension(BookExportFormat format) {
    switch (format) {
      case BookExportFormat.digitalPdf:
      case BookExportFormat.printReadyPdf:
        return '.pdf';

      case BookExportFormat.epub:
        return '.epub';

      case BookExportFormat.word:
        return '.docx';
    }
  }
}

class ExportFileValidationResult {
  const ExportFileValidationResult({
    required this.isValid,
    required this.errors,
    required this.fileSizeBytes,
  });

  final bool isValid;
  final List<String> errors;
  final int fileSizeBytes;

  bool get hasErrors => errors.isNotEmpty;

  String get summary {
    if (isValid) {
      return 'Export file passed validation.';
    }

    return errors.join('\n');
  }
}
