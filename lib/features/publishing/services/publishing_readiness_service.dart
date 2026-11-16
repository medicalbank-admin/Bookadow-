
import '../models/book_cover_model.dart';
import '../models/book_layout_model.dart';
import '../services/book_export_manager.dart';

class PublishingReadinessResult {
  const PublishingReadinessResult({
    required this.isReady,
    required this.errors,
    required this.warnings,
  });

  final bool isReady;
  final List<String> errors;
  final List<String> warnings;
}

class PublishingReadinessService {
  const PublishingReadinessService();

  PublishingReadinessResult validate({
    required String title,
    required String authorName,
    required List<ExportChapter> chapters,
    required BookLayoutModel layout,
    required BookCoverModel cover,
    required bool includeCover,
  }) {
    final List<String> errors = [];
    final List<String> warnings = [];

    if (title.trim().isEmpty) {
      errors.add('Your book title is required.');
    }

    if (authorName.trim().isEmpty) {
      warnings.add(
        'An author name has not been provided.',
      );
    }

    if (chapters.isEmpty) {
      errors.add(
        'Add at least one chapter before publishing.',
      );
    }

    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];

      if (chapter.title.trim().isEmpty) {
        warnings.add(
          'Chapter ${i + 1} has no title.',
        );
      }

      if (chapter.text.trim().isEmpty) {
        warnings.add(
          'Chapter ${i + 1} is empty.',
        );
      }
    }

    if (layout.fontSize < 6 || layout.fontSize > 36) {
      errors.add(
        'The selected font size is outside the supported range.',
      );
    }

    if (layout.lineSpacing <= 0) {
      errors.add(
        'Line spacing must be greater than zero.',
      );
    }

    if (layout.effectivePageWidth <= 0 ||
        layout.effectivePageHeight <= 0) {
      errors.add(
        'The selected page dimensions are invalid.',
      );
    }

    if (layout.topMargin + layout.bottomMargin >=
        layout.effectivePageHeight) {
      errors.add(
        'Top and bottom margins leave no usable page height.',
      );
    }

    if (layout.insideMargin + layout.outsideMargin >=
        layout.effectivePageWidth) {
      errors.add(
        'Inside and outside margins leave no usable page width.',
      );
    }

    if (includeCover) {
      if (cover.title.trim().isEmpty) {
        warnings.add(
          'Your cover does not have a title.',
        );
      }

      if (cover.showSpineTitle &&
          cover.spineWidthInches <= 0) {
        errors.add(
          'The cover spine width must be greater than zero.',
        );
      }

      if (cover.bleedInches < 0) {
        errors.add(
          'Cover bleed cannot be negative.',
        );
      }
    }

    return PublishingReadinessResult(
      isReady: errors.isEmpty,
      errors: List.unmodifiable(errors),
      warnings: List.unmodifiable(warnings),
    );
  }
}
