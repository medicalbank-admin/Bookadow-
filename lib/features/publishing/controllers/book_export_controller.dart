import 'package:flutter/foundation.dart';

import '../../books/models/book_model.dart';

import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';
import '../models/export_history_model.dart';

import '../repositories/publishing_repository.dart';

import '../services/book_export_manager.dart';
import '../services/book_export_data_builder.dart';

class BookExportController extends ChangeNotifier {
  BookExportController({
    required this.book,
    BookExportManager? exportManager,
    BookExportDataBuilder? dataBuilder,
    PublishingRepository? publishingRepository,
  })  : _exportManager = exportManager ?? BookExportManager(),
        _dataBuilder = dataBuilder ?? const BookExportDataBuilder(),
        _publishingRepository =
            publishingRepository ?? PublishingRepository();

  final BookModel book;

  final BookExportManager _exportManager;
  final BookExportDataBuilder _dataBuilder;
  final PublishingRepository _publishingRepository;

  bool isLoading = false;
  bool isExporting = false;

  String? errorMessage;
  ExportHistoryModel? lastExport;

  BookLayoutModel layout = BookLayoutModel();
  BookExportModel settings = BookExportModel();

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _publishingRepository.initialize();

      final savedSettings =
          await _publishingRepository.getSettings(book.id);

      if (savedSettings != null) {
        layout = savedSettings.layout;
        settings = savedSettings.export;
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateExportSettings(BookExportModel value) {
    settings = value;
    notifyListeners();
  }

  void updateLayout(BookLayoutModel value) {
    layout = value;
    notifyListeners();
  }

  Future<ExportHistoryModel?> exportBook() async {
    if (isExporting) {
      return null;
    }

    isExporting = true;
    errorMessage = null;
    lastExport = null;
    notifyListeners();

    try {
      final BookExportData data = _dataBuilder.build(book);

      final ExportHistoryModel result =
          await _exportManager.exportBook(
        bookId: data.bookId,
        bookTitle: data.title,
        authorName: data.authorName,
        subtitle: data.subtitle,
        description: data.description,
        languageCode: data.languageCode,
        chapters: data.chapters,
        settings: settings,
        layout: layout,
      );

      lastExport = result;
      return result;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
