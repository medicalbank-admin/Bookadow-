import '../models/book_cover_model.dart';
import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';

class PublishingValidationResult {
  const PublishingValidationResult({
    required this.errors,
    required this.warnings,
  });

  final List<String> errors;
  final List<String> warnings;

  bool get isValid => errors.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;

  List<String> get allMessages => [
        ...errors,
        ...warnings,
      ];
}

class PublishingValidationService {
  PublishingValidationService._();

  static PublishingValidationResult validateLayout(
    BookLayoutModel layout,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (layout.effectivePageWidth <= 0 ||
        layout.effectivePageHeight <= 0) {
      errors.add('Book dimensions must be greater than zero.');
    }

    if (layout.topMargin < 0 ||
        layout.bottomMargin < 0 ||
        layout.insideMargin < 0 ||
        layout.outsideMargin < 0) {
      errors.add('Page margins cannot be negative.');
    }

    if (layout.usableWidth <= 0 || layout.usableHeight <= 0) {
      errors.add(
        'Margins are too large for the selected page size.',
      );
    }

    if (layout.fontSize < 6 || layout.fontSize > 36) {
      errors.add('Body font size must be between 6 and 36 pt.');
    }

    if (layout.lineSpacing < 0.8 ||
        layout.lineSpacing > 3.0) {
      errors.add(
        'Line spacing must be between 0.8 and 3.0.',
      );
    }

    if (layout.paragraphSpacing < 0) {
      errors.add('Paragraph spacing cannot be negative.');
    }

    if (layout.firstLineIndent < 0) {
      errors.add('First-line indentation cannot be negative.');
    }

    if (layout.format == BookFormat.custom &&
        (layout.customWidth <= 0 || layout.customHeight <= 0)) {
      errors.add(
        'Custom page width and height must be greater than zero.',
      );
    }

    if (layout.insideMargin < layout.outsideMargin) {
      warnings.add(
        'The inside margin is smaller than the outside margin. '
        'Check whether additional binding space is needed.',
      );
    }

    return PublishingValidationResult(
      errors: errors,
      warnings: warnings,
    );
  }

  static PublishingValidationResult validateCover(
    BookCoverModel cover,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (cover.title.trim().isEmpty) {
      errors.add('A book title is required.');
    }

    if (cover.authorName.trim().isEmpty) {
      warnings.add(
        'The author name has not been entered.',
      );
    }

    if (cover.spineWidthInches < 0) {
      errors.add('Spine width cannot be negative.');
    }

    if (cover.bleedInches < 0) {
      errors.add('Bleed cannot be negative.');
    }

    if (cover.spineWidthInches < 0.25 &&
        (cover.showSpineTitle || cover.showSpineAuthor)) {
      warnings.add(
        'The spine may be too narrow for readable text.',
      );
    }

    if (cover.showPublisherName &&
        cover.publisherName.trim().isEmpty) {
      warnings.add(
        'Publisher name is enabled but has not been entered.',
      );
    }

    if (cover.backCoverBlurb.trim().isEmpty) {
      warnings.add(
        'The back-cover description is empty.',
      );
    }

    return PublishingValidationResult(
      errors: errors,
      warnings: warnings,
    );
  }

  static PublishingValidationResult validateExport(
    BookExportModel export,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (export.format == BookExportFormat.printReadyPdf &&
        !export.embedFonts) {
      warnings.add(
        'Embedding fonts is recommended for print-ready PDFs.',
      );
    }

    if (export.format == BookExportFormat.printReadyPdf &&
        export.includeBleed == false) {
      warnings.add(
        'Print-ready covers commonly require bleed. '
        'Confirm the printer specifications.',
      );
    }

    if (export.format == BookExportFormat.epub &&
        export.includeBleed) {
      warnings.add(
        'Bleed is a print-layout setting and is not normally '
        'needed for EPUB files.',
      );
    }

    if (export.customFileName.trim().contains('/') ||
        export.customFileName.trim().contains(r'\')) {
      errors.add(
        'The export filename cannot contain path separators.',
      );
    }

    if (export.grayscale &&
        export.format == BookExportFormat.digitalPdf) {
      warnings.add(
        'Grayscale export will remove color from the digital PDF.',
      );
    }

    return PublishingValidationResult(
      errors: errors,
      warnings: warnings,
    );
  }

  static PublishingValidationResult validateAll({
    required BookLayoutModel layout,
    required BookCoverModel cover,
    required BookExportModel export,
  }) {
    final layoutResult = validateLayout(layout);
    final coverResult = validateCover(cover);
    final exportResult = validateExport(export);

    return PublishingValidationResult(
      errors: [
        ...layoutResult.errors,
        ...coverResult.errors,
        ...exportResult.errors,
      ],
      warnings: [
        ...layoutResult.warnings,
        ...coverResult.warnings,
        ...exportResult.warnings,
      ],
    );
  }
}
