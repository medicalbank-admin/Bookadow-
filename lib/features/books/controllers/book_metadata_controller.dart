import 'package:flutter/foundation.dart';

import '../models/book_metadata_model.dart';
import '../repositories/book_metadata_repository.dart';

class BookMetadataController extends ChangeNotifier {
  final BookMetadataRepository _repository;

  BookMetadataModel? _metadata;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _errorMessage;

  BookMetadataController({
    BookMetadataRepository? repository,
  }) : _repository =
            repository ?? BookMetadataRepository();

  BookMetadataModel? get metadata => _metadata;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  String? get errorMessage => _errorMessage;

  bool get hasMetadata => _metadata != null;

  Future<void> initialize({
    required String bookId,
    String title = '',
    String author = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.initialize();

      final existing =
          await _repository.getByBookId(bookId);

      if (existing != null) {
        _metadata = existing;
      } else {
        _metadata = BookMetadataModel.create(
          bookId: bookId,
          title: title,
          author: author,
        );
      }

      _hasUnsavedChanges = false;
    } catch (error) {
      _errorMessage =
          'Unable to load book metadata: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateMetadata(BookMetadataModel updatedMetadata) {
    if (_metadata == null) {
      return;
    }

    if (updatedMetadata.bookId != _metadata!.bookId) {
      _errorMessage =
          'The metadata book ID cannot be changed.';
      notifyListeners();
      return;
    }

    _metadata = updatedMetadata.copyWith(
      updatedAt: DateTime.now(),
    );

    _hasUnsavedChanges = true;
    _errorMessage = null;

    notifyListeners();
  }

  void createMetadata({
    required String bookId,
    String title = '',
    String author = '',
  }) {
    _metadata = BookMetadataModel.create(
      bookId: bookId,
      title: title,
      author: author,
    );

    _hasUnsavedChanges = true;
    _errorMessage = null;

    notifyListeners();
  }

  Future<bool> save() async {
    final currentMetadata = _metadata;

    if (currentMetadata == null) {
      _errorMessage = 'No metadata is available to save.';
      notifyListeners();
      return false;
    }

    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final metadataToSave = currentMetadata.copyWith(
        updatedAt: DateTime.now(),
      );

      await _repository.save(metadataToSave);

      _metadata = metadataToSave;
      _hasUnsavedChanges = false;

      return true;
    } catch (error) {
      _errorMessage =
          'Unable to save book metadata: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    final currentMetadata = _metadata;

    if (currentMetadata == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final refreshed = await _repository.getByBookId(
        currentMetadata.bookId,
      );

      if (refreshed != null) {
        _metadata = refreshed;
        _hasUnsavedChanges = false;
      }
    } catch (error) {
      _errorMessage =
          'Unable to reload book metadata: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
