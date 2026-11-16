import 'package:flutter/foundation.dart';

import '../services/print_specification_validator.dart';

class PrintSpecificationController extends ChangeNotifier {
  final PrintSpecificationValidator _validator;

  PrintSpecificationController({
    PrintSpecificationValidator? validator,
  }) : _validator = validator ?? PrintSpecificationValidator();

  PrintSpecificationResult? _result;
  bool _isValidating = false;
  String? _errorMessage;

  PrintSpecificationResult? get result => _result;

  bool get isValidating => _isValidating;

  bool get hasResult => _result != null;

  String? get errorMessage => _errorMessage;

  bool get isValid => _result?.isValid ?? false;

  Future<PrintSpecificationResult?> validateSpecifications({
    required double trimWidthInches,
    required double trimHeightInches,
    required int pageCount,
    required double paperCaliperInches,
    required double bleedInches,
    double minimumSpineWidthInches = 0,
    double maximumSpineWidthInches = 10,
  }) async {
    if (_isValidating) {
      return null;
    }

    _isValidating = true;
    _result = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final validationResult = _validator.validate(
        trimWidthInches: trimWidthInches,
        trimHeightInches: trimHeightInches,
        pageCount: pageCount,
        paperCaliperInches: paperCaliperInches,
        bleedInches: bleedInches,
        minimumSpineWidthInches: minimumSpineWidthInches,
        maximumSpineWidthInches: maximumSpineWidthInches,
      );

      _result = validationResult;
      return validationResult;
    } catch (error) {
      _errorMessage = 'Print validation failed: $error';
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
