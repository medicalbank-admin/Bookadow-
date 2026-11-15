
import 'package:flutter/foundation.dart';

import '../models/book_cover_model.dart';
import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';
import '../repositories/publishing_repository.dart';

class PublishingController extends ChangeNotifier {
  PublishingController({
    PublishingRepository? repository,
  }) : _repository = repository ?? PublishingRepository();

  final PublishingRepository _repository;

  String? _bookId;

  BookLayoutModel _layout = const BookLayoutModel();
  BookCoverModel _cover = const BookCoverModel();
  BookExportModel _export = const BookExportModel();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  String? _errorMessage;
  DateTime? _lastSavedAt;

  BookLayoutModel get layout => _layout;
  BookCoverModel get cover => _cover;
  BookExportModel get export => _export;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  String? get errorMessage => _errorMessage;
  DateTime? get lastSavedAt => _lastSavedAt;

  String? get bookId => _bookId;

  Future<void> initialize(String bookId) async {
    if (bookId.trim().isEmpty) {
      throw ArgumentError('Book ID cannot be empty.');
    }

    _bookId = bookId;
    _isLoading = true;
    _errorMessage = null;
    _hasUnsavedChanges = false;

    notifyListeners();

    try {
      final settings = await _repository.getSettings(bookId);

      if (_bookId != bookId) return;

      if (settings != null) {
        _layout = settings.layout;
        _cover = settings.cover;
        _export = settings.export;
        _lastSavedAt = settings.updatedAt;
      } else {
        _layout = const BookLayoutModel();
        _cover = const BookCoverModel();
        _export = const BookExportModel();
        _lastSavedAt = null;
      }
    } catch (error) {
      _errorMessage = 'Could not load publishing settings: $error';
    } finally {
      if (_bookId == bookId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void updateLayout(BookLayoutModel updatedLayout) {
    _layout = updatedLayout;
    _markChanged();
  }

  void updateCover(BookCoverModel updatedCover) {
    _cover = updatedCover;
    _markChanged();
  }

  void updateExport(BookExportModel updatedExport) {
    _export = updatedExport;
    _markChanged();
  }

  void _markChanged() {
    _hasUnsavedChanges = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    final currentBookId = _bookId;

    if (currentBookId == null || currentBookId.trim().isEmpty) {
      _errorMessage = 'No book has been selected.';
      notifyListeners();
      return false;
    }

    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    // Capture a consistent snapshot of the current settings.
    final layoutSnapshot = _layout;
    final coverSnapshot = _cover;
    final exportSnapshot = _export;

    try {
      await _repository.saveSettings(
        bookId: currentBookId,
        layout: layoutSnapshot,
        cover: coverSnapshot,
        export: exportSnapshot,
      );

      _lastSavedAt = DateTime.now();

      // Keep unsaved status if the user edited settings
      // while the save operation was running.
      _hasUnsavedChanges =
          _layout != layoutSnapshot ||
          _cover != coverSnapshot ||
          _export != exportSnapshot;

      return true;
    } catch (error) {
      _errorMessage = 'Could not save publishing settings: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> reloadSettings() async {
    final currentBookId = _bookId;

    if (currentBookId == null) {
      _errorMessage = 'No book has been selected.';
      notifyListeners();
      return false;
    }

    await initialize(currentBookId);

    return _errorMessage == null;
  }

  void resetToDefaults() {
    _layout = const BookLayoutModel();
    _cover = const BookCoverModel();
    _export = const BookExportModel();

    _markChanged();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
