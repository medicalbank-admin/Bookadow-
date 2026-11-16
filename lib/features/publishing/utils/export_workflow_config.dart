
class ExportWorkflowConfig {
  ExportWorkflowConfig._();

  // Export progress
  static const double initialProgress = 0.0;
  static const double preparingProgress = 0.10;
  static const double validatingProgress = 0.25;
  static const double generatingProgress = 0.45;
  static const double savingProgress = 0.90;
  static const double completedProgress = 1.0;

  // File configuration
  static const String defaultExportFolder =
      'BOOKADOW_Exports';

  static const String defaultFileName =
      'bookadow_book';

  static const int maximumFileNameLength = 100;

  // Export validation
  static const int minimumChapterCount = 1;
  static const int maximumChapterCount = 500;
  static const int maximumFileNameLengthAllowed = 100;

  // Supported file extensions
  static const String pdfExtension = '.pdf';
  static const String epubExtension = '.epub';
  static const String wordExtension = '.docx';

  // Export options
  static const bool defaultIncludeCover = true;
  static const bool defaultIncludeTableOfContents = true;
  static const bool defaultIncludePageNumbers = true;
  static const bool defaultEmbedFonts = true;

  // User-facing messages
  static const String preparingMessage =
      'Preparing your manuscript...';

  static const String validatingMessage =
      'Checking your publishing settings...';

  static const String generatingMessage =
      'Generating your document...';

  static const String savingMessage =
      'Saving your exported file...';

  static const String completedMessage =
      'Your book has been exported successfully.';

  static const String failedMessage =
      'Export failed. Please try again.';

  static const String cancelledMessage =
      'Export was cancelled.';
}
