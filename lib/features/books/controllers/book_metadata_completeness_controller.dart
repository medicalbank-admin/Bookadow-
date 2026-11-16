
import 'package:flutter/foundation.dart';

import '../models/book_metadata_model.dart';
import '../services/book_metadata_completeness_service.dart';

class BookMetadataCompletenessController extends ChangeNotifier {
  BookMetadataCompletenessController({
    BookMetadataCompletenessService? service,
  }) : _service = service ?? BookMetadataCompletenessService();

  final BookMetadataCompletenessService _service;

  BookMetadataCompletenessResult? _result;
  bool _isCalculating = false;

  BookMetadataCompletenessResult? get result => _result;
  bool get isCalculating => _isCalculating;

  double get completionPercentage =>
    (_result?.percentageValue ?? 0).toDouble();

  bool get isComplete => _result?.isComplete ?? false;

  List<String> get missingFields =>
      _result?.missingFields ?? const [];

  void calculate(BookMetadataModel metadata) {
    _isCalculating = true;
    notifyListeners();

    try {
      _result = _service.calculate(metadata);
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  void clear() {
    _result = null;
    _isCalculating = false;
    notifyListeners();
  }
}
