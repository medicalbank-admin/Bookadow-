import '../services/book_export_manager.dart';
import 'export_filename_validation_service.dart';

class ExportPreflightResult {
  const ExportPreflightResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    this.fileName,
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final String? fileName;
}

class ExportPreflightService {
  ExportPreflightService({
    ExportFilenameValidationService? filenameValidator,
  }) : _filenameValidator = filenameValidator ??
            const ExportFilenameValidationService();

  final ExportFilenameValidationService _filenameValidator;

  ExportPreflightResult validate({
    required String fileName,
    required String extension,
    required List<ExportChapter> chapters,
  }) {
    final List<String> errors = [];
    final List<String> warnings = [];

    final filenameResult = _filenameValidator.validate(
      fileName,
      extension: extension,
    );

    if (!filenameResult.isValid) {
      errors.add(filenameResult.message);
    }

    if (chapters.isEmpty) {
      errors.add(
        'Your manuscript must contain at least one chapter.',
      );
    }

    for (int index = 0; index < chapters.length; index++) {
      final chapter = chapters[index];

      if (chapter.title.trim().isEmpty) {
        warnings.add(
          'Chapter ${index + 1} has no title.',
        );
      }

      if (chapter.text.trim().isEmpty) {
        warnings.add(
          'Chapter ${index + 1} contains no text.',
        );
      }
    }

    if (chapters.length > 500) {
      warnings.add(
        'Your manuscript contains more than 500 chapters.',
      );
    }

    return ExportPreflightResult(
      isValid: errors.isEmpty,
      errors: List.unmodifiable(errors),
      warnings: List.unmodifiable(warnings),
      fileName: filenameResult.sanitizedFileName,
    );
  }
}
