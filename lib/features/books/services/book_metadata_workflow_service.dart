import '../models/book_metadata_model.dart';
import 'book_metadata_validation_service.dart';
import 'book_metadata_completeness_service.dart';

class BookMetadataWorkflowResult {
  const BookMetadataWorkflowResult({
    required this.validation,
    required this.completeness,
  });

  final BookMetadataValidationResult validation;
  final BookMetadataCompletenessResult completeness;

  bool get canProceed => validation.isValid;

  bool get hasWarnings => validation.hasWarnings;

  double get completionPercentage =>
    completeness.percentageValue.toDouble();
}

class BookMetadataWorkflowService {
  BookMetadataWorkflowService({
    BookMetadataValidationService? validationService,
    BookMetadataCompletenessService? completenessService,
  })  : _validationService =
            validationService ?? BookMetadataValidationService(),
        _completenessService =
            completenessService ?? BookMetadataCompletenessService();

  final BookMetadataValidationService _validationService;
  final BookMetadataCompletenessService _completenessService;

  BookMetadataWorkflowResult evaluate(
    BookMetadataModel metadata,
  ) {
    return BookMetadataWorkflowResult(
      validation: _validationService.validate(metadata),
      completeness: _completenessService.calculate(metadata),
    );
  }
}
