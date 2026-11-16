
import 'package:flutter/foundation.dart';

import '../models/book_metadata_model.dart';
import '../services/book_metadata_validation_service.dart';

class BookMetadataValidationController extends ChangeNotifier {
  final BookMetadataValidationService _validationService;

  BookMetadataValidationResult? _result;
  bool _isValidating = false;
  String? _errorMessage;

  BookMetadataValidationController({
    BookMetadataValidationService? validationService,
  }) : _validationService =
            validationService ??
            const BookMetadataValidationService();

  BookMetadataValidationResult? get result => _result;

  bool get isValidating => _isValidating;

  bool get isValid => _result?.isValid ?? false;

  bool get hasWarnings => _result?.hasWarnings ?? false;

  String? get errorMessage => _errorMessage;

  Future<BookMetadataValidationResult?> validate(
    BookMetadataModel metadata,
  ) async {
    if (_isValidating) {
      return _result;
    }

    _isValidating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = _validationService.validate(metadata);
      return _result;
    } catch (error) {
      _errorMessage = 'Metadata validation failed: $error';
      _result = null;
      return null;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }
}
