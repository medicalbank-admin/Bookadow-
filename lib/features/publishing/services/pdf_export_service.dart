import 'dart:io';
import 'dart:typed_data';

import '../models/book_layout_model.dart';
import '../models/book_export_model.dart';
import '../models/export_history_model.dart';
import '../repositories/export_history_repository.dart';
import 'export_file_service.dart';
import 'pdf_document_generator.dart';

class PdfExportService {
  PdfExportService({
    PdfDocumentGenerator? generator,
    ExportFileService? fileService,
    ExportHistoryRepository? historyRepository,
  })  : _generator = generator ?? PdfDocumentGenerator(),
        _fileService = fileService ?? ExportFileService(),
        _historyRepository =
            historyRepository ?? ExportHistoryRepository();

  final PdfDocumentGenerator _generator;
  final ExportFileService _fileService;
  final ExportHistoryRepository _historyRepository;

  Future<ExportHistoryModel> exportBook({
    required String bookId,
    required String bookTitle,
    required String authorName,
    required List<PdfChapterContent> chapters,
    required BookLayoutModel layout,
    required BookExportModel exportSettings,
    String? subtitle,
  }) async {
    final startedAt = DateTime.now();

    final format = exportSettings.format;

    if (format != BookExportFormat.digitalPdf &&
        format != BookExportFormat.printReadyPdf) {
      throw ArgumentError(
        'PDF export requires a PDF export format.',
      );
    }

    final extension = 'pdf';

    final fileName = _fileService.sanitizeFileName(
      exportSettings.customFileName.trim().isEmpty
          ? bookTitle
          : exportSettings.customFileName,
    );

    try {
      await _historyRepository.initialize();

      final Uint8List bytes = await _generator.generatePdf(
        bookTitle: bookTitle,
        authorName: authorName,
        subtitle: subtitle,
        chapters: chapters,
        layout: layout,
        includeTitlePage: true,
        includePageNumbers: exportSettings.includePageNumbers,
        includeTableOfContents:
            exportSettings.includeTableOfContents,
      );

      final File file = await _fileService.createExportFile(
        fileName: fileName,
        extension: extension,
        bytes: bytes,
      );

      final int fileSize = await file.length();

      final record = ExportHistoryModel(
        id: 'export_${startedAt.microsecondsSinceEpoch}',
        bookId: bookId,
        fileName: fileName,
        filePath: file.path,
        format: format.name,
        fileSizeBytes: fileSize,
        createdAt: DateTime.now(),
        isSuccessful: true,
      );

      await _historyRepository.saveExport(record);

      return record;
    } catch (error) {
      final failedRecord = ExportHistoryModel(
        id: 'export_failed_${startedAt.microsecondsSinceEpoch}',
        bookId: bookId,
        fileName: fileName,
        filePath: '',
        format: format.name,
        fileSizeBytes: 0,
        createdAt: DateTime.now(),
        isSuccessful: false,
        errorMessage: error.toString(),
      );

      try {
        await _historyRepository.initialize();
        await _historyRepository.saveExport(failedRecord);
      } catch (_) {
        // Preserve the original export error.
      }

      rethrow;
    }
  }
}
