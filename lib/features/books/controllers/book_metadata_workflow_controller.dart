import 'package:flutter/foundation.dart';

import '../models/book_metadata_model.dart';
import '../services/book_metadata_workflow_service.dart';

class BookMetadataWorkflowController extends ChangeNotifier {
  BookMetadataWorkflowController({
    BookMetadataWorkflowService? service,
  }) : _service = service ?? BookMetadataWorkflowService();

  final BookMetadataWorkflowService _service;

  BookMetadataWorkflowResult? _result;
  bool _isEvaluating = false;
  String? _errorMessage;

  BookMetadataWorkflowResult? get result => _result;
  bool get isEvaluating => _isEvaluating;
  String? get errorMessage => _errorMessage;

  bool get canProceed => _result?.canProceed ?? false;

  Future<void> evaluate(BookMetadataModel metadata) async {
    _isEvaluating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = _service.evaluate(metadata);
    } catch (error) {
      _errorMessage = 'Unable to evaluate book metadata: $error';
      _result = null;
    } finally {
      _isEvaluating = false;
      notifyListeners();
    }
  }

  void clear() {
    _result = null;
    _errorMessage = null;
    _isEvaluating = false;
    notifyListeners();
  }
}
