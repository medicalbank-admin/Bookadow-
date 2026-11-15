
import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';
import '../models/export_history_model.dart';

import 'epub_export_service.dart';
import 'epub_document_generator.dart';

import 'pdf_export_service.dart';
import 'pdf_document_generator.dart';

import 'word_export_service.dart';
import 'word_document_generator.dart';

class BookExportManager {
  BookExportManager({
    PdfExportService? pdfService,
    EpubExportService? epubService,
    WordExportService? wordService,
  })  : _pdfService = pdfService ?? PdfExportService(),
        _epubService = epubService ?? EpubExportService(),
        _wordService = wordService ?? WordExportService();

  final PdfExportService _pdfService;
  final EpubExportService _epubService;
  final WordExportService _wordService;

  Future<ExportHistoryModel> exportBook({
    required String bookId,
    required String bookTitle,
    required String authorName,
    required BookExportModel settings,
    required BookLayoutModel layout,
    required List<ExportChapter> chapters,
    String? subtitle,
    String? description,
    String languageCode = 'en',
  }) async {
    if (chapters.isEmpty) {
      throw ArgumentError(
        'Add at least one chapter before exporting.',
      );
    }

    switch (settings.format) {
      case BookExportFormat.digitalPdf:
      case BookExportFormat.printReadyPdf:
        return _pdfService.exportBook(
          bookId: bookId,
          bookTitle: bookTitle,
          authorName: authorName,
          subtitle: subtitle,
          chapters: chapters
              .map(
                (chapter) => PdfChapterContent(
                  title: chapter.title,
                  text: chapter.text,
                ),
              )
              .toList(),
          layout: layout,
          exportSettings: settings,
        );

      case BookExportFormat.epub:
        return _epubService.exportBook(
          bookId: bookId,
          bookTitle: bookTitle,
          authorName: authorName,
          subtitle: subtitle,
          description: description,
          languageCode: languageCode,
          chapters: chapters
              .map(
                (chapter) => EpubChapterContent(
                  title: chapter.title,
                  text: chapter.text,
                ),
              )
              .toList(),
          exportSettings: settings,
        );

      case BookExportFormat.word:
        return _wordService.exportBook(
          bookId: bookId,
          bookTitle: bookTitle,
          authorName: authorName,
          subtitle: subtitle,
          description: description,
          chapters: chapters
              .map(
                (chapter) => WordChapterContent(
                  title: chapter.title,
                  text: chapter.text,
                ),
              )
              .toList(),
          exportSettings: settings,
        );
    }
  }
}

class ExportChapter {
  const ExportChapter({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;
}
