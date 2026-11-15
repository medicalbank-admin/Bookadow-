
import 'dart:io';

import '../models/export_history_model.dart';
import '../models/book_export_model.dart';
import '../repositories/export_history_repository.dart';
import 'epub_document_generator.dart';
import 'export_file_service.dart';

class EpubExportService {
  EpubExportService({
    EpubDocumentGenerator? generator,
    ExportFileService? fileService,
    ExportHistoryRepository? historyRepository,
  })  : _generator = generator ?? EpubDocumentGenerator(),
        _fileService = fileService ?? ExportFileService(),
        _historyRepository =
            historyRepository ?? ExportHistoryRepository();

  final EpubDocumentGenerator _generator;
  final ExportFileService _fileService;
  final ExportHistoryRepository _historyRepository;

  Future<ExportHistoryModel> exportBook({
    required String bookId,
    required String bookTitle,
    required String authorName,
    required List<EpubChapterContent> chapters,
    required BookExportModel exportSettings,
    String? subtitle,
    String languageCode = 'en',
    String? description,
  }) async {
    final startedAt = DateTime.now();

    if (exportSettings.format != BookExportFormat.epub) {
      throw ArgumentError(
        'EPUB export requires the EPUB export format.',
      );
    }

    final fileName = _fileService.sanitizeFileName(
      exportSettings.customFileName.trim().isEmpty
          ? bookTitle
          : exportSettings.customFileName,
    );

    try {
      await _historyRepository.initialize();

      final bytes = _generator.generateEpub(
        bookTitle: bookTitle,
        authorName: authorName,
        chapters: chapters,
        subtitle: subtitle,
        languageCode: languageCode,
        description: description,
      );

      final File file = await _fileService.createExportFile(
        fileName: fileName,
        extension: 'epub',
        bytes: bytes,
      );

      final fileSize = await file.length();

      final record = ExportHistoryModel(
        id: 'export_${startedAt.microsecondsSinceEpoch}',
        bookId: bookId,
        fileName: fileName,
        filePath: file.path,
        format: BookExportFormat.epub.name,
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
        format: BookExportFormat.epub.name,
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
