import '../models/book_export_model.dart';

class ExportFilenameService {
  const ExportFilenameService();

  String getExtension(BookExportFormat format) {
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

  String getFormatName(BookExportFormat format) {
    switch (format) {
      case BookExportFormat.digitalPdf:
        return 'Digital PDF';

      case BookExportFormat.printReadyPdf:
        return 'Print-Ready PDF';

      case BookExportFormat.epub:
        return 'EPUB';

      case BookExportFormat.word:
        return 'Word Document';
    }
  }

  String generateFilename({
    required String bookTitle,
    required BookExportFormat format,
    String? customFilename,
  }) {
    final String source =
        customFilename?.trim().isNotEmpty == true
            ? customFilename!.trim()
            : bookTitle.trim();

    final String safeName = sanitizeFilename(source);

    final String extension = getExtension(format);

    final String nameWithoutExtension =
        _removeKnownExtension(safeName);

    return '$nameWithoutExtension$extension';
  }

  String sanitizeFilename(String filename) {
    String result = filename.trim();

    result = result.replaceAll(
      RegExp(r'[<>:"/\\|?*\x00-\x1F]'),
      '',
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
      RegExp(r'^[_\.]+|[_\.]+$'),
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

  String _removeKnownExtension(String filename) {
    final String lower = filename.toLowerCase();

    const extensions = [
      '.pdf',
      '.epub',
      '.docx',
      '.doc',
    ];

    for (final String extension in extensions) {
      if (lower.endsWith(extension)) {
        return filename.substring(
          0,
          filename.length - extension.length,
        );
      }
    }

    return filename;
  }
}
