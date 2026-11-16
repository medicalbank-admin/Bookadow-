import '../models/book_layout_model.dart';
import '../models/book_cover_model.dart';
import 'book_export_manager.dart';
import 'export_preflight_service.dart';
import 'publishing_readiness_service.dart';

class PublishingPreflightReport {
  final List<String> errors;
  final List<String> warnings;
  final DateTime generatedAt;

  const PublishingPreflightReport({
    required this.errors,
    required this.warnings,
    required this.generatedAt,
  });

  bool get isReady => errors.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;

  int get issueCount => errors.length + warnings.length;

  String get summary {
    if (errors.isNotEmpty) {
      return 'Publishing blocked: ${errors.length} issue(s) must be fixed.';
    }

    if (warnings.isNotEmpty) {
      return 'Ready with ${warnings.length} warning(s).';
    }

    return 'Book passed all available preflight checks.';
  }
}

class PublishingPreflightReportBuilder {
  final ExportPreflightService _exportPreflightService;
  final PublishingReadinessService _readinessService;

  PublishingPreflightReportBuilder({
    ExportPreflightService? exportPreflightService,
    PublishingReadinessService? readinessService,
  })  : _exportPreflightService =
            exportPreflightService ?? ExportPreflightService(),
        _readinessService =
            readinessService ?? PublishingReadinessService();

  PublishingPreflightReport buildReport({
    required String bookTitle,
    required String authorName,
    required String fileName,
    required List<ExportChapter> chapters,
    required BookLayoutModel layout,
    required BookCoverModel cover,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    final exportResult = _exportPreflightService.validate(
      fileName: fileName,
      chapters: chapters,
    );

    final readinessResult = _readinessService.validate(
      bookTitle: bookTitle,
      authorName: authorName,
      chapters: chapters,
      layout: layout,
      cover: cover,
    );

    errors.addAll(exportResult.errors);
    warnings.addAll(exportResult.warnings);

    errors.addAll(readinessResult.errors);
    warnings.addAll(readinessResult.warnings);

    return PublishingPreflightReport(
      errors: List.unmodifiable(errors.toSet()),
      warnings: List.unmodifiable(warnings.toSet()),
      generatedAt: DateTime.now(),
    );
  }
}
