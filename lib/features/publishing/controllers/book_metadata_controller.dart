import 'package:flutter/foundation.dart';

import '../models/book_metadata_model.dart';
import '../repositories/book_metadata_repository.dart';

class BookMetadataController extends ChangeNotifier {
  final BookMetadataRepository _repository;
  final String bookId;

  BookMetadataController({
    required this.bookId,
    BookMetadataRepository? repository,
  }) : _repository = repository ?? BookMetadataRepository();

  BookMetadataModel? _metadata;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isInitialized = false;
  String? _errorMessage;

  BookMetadataModel? get metadata => _metadata;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  bool get hasMetadata => _metadata != null;

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.initialize();

      _metadata = await _repository.getByBookId(bookId);

      _isInitialized = true;
    } catch (error) {
      _errorMessage = 'Unable to load book metadata: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateMetadata(BookMetadataModel updatedMetadata) {
    if (updatedMetadata.bookId != bookId) {
      _errorMessage = 'Metadata belongs to a different book.';
      notifyListeners();
      return;
    }

    _metadata = updatedMetadata.copyWith(
      updatedAt: DateTime.now(),
    );

    _errorMessage = null;
    notifyListeners();
  }

  void createMetadata({
    required String title,
    required String author,
  }) {
    _metadata = BookMetadataModel.create(
      bookId: bookId,
      title: title,
      author: author,
    );

    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> save() async {
    if (_isSaving || _metadata == null) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final metadataToSave = _metadata!.copyWith(
        updatedAt: DateTime.now(),
      );

      await _repository.save(metadataToSave);

      _metadata = metadataToSave;

      return true;
    } catch (error) {
      _errorMessage = 'Unable to save book metadata: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    _isInitialized = false;
    await initialize();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
