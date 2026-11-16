class PrintSpecificationResult {
  final List<String> errors;
  final List<String> warnings;
  final double calculatedSpineWidthInches;
  final double totalCoverWidthInches;
  final double totalCoverHeightInches;

  const PrintSpecificationResult({
    required this.errors,
    required this.warnings,
    required this.calculatedSpineWidthInches,
    required this.totalCoverWidthInches,
    required this.totalCoverHeightInches,
  });

  bool get isValid => errors.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;
}

class PrintSpecificationValidator {
  PrintSpecificationResult validate({
    required double trimWidthInches,
    required double trimHeightInches,
    required int pageCount,
    required double paperCaliperInches,
    required double bleedInches,
    double minimumSpineWidthInches = 0,
    double maximumSpineWidthInches = 10,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    if (trimWidthInches <= 0 || trimHeightInches <= 0) {
      errors.add('Trim width and height must be greater than zero.');
    }

    if (pageCount <= 0) {
      errors.add('Page count must be greater than zero.');
    }

    if (paperCaliperInches <= 0) {
      errors.add('Paper caliper must be greater than zero.');
    }

    if (bleedInches < 0) {
      errors.add('Bleed cannot be negative.');
    }

    if (minimumSpineWidthInches < 0 ||
        maximumSpineWidthInches < minimumSpineWidthInches) {
      errors.add('The spine width limits are invalid.');
    }

    if (errors.isNotEmpty) {
      return PrintSpecificationResult(
        errors: List.unmodifiable(errors),
        warnings: List.unmodifiable(warnings),
        calculatedSpineWidthInches: 0,
        totalCoverWidthInches: 0,
        totalCoverHeightInches: 0,
      );
    }

    // Paper caliper represents the thickness of one sheet.
    // A conventional perfect-bound spine uses approximately half
    // the page count multiplied by the sheet caliper.
    final spineWidth = (pageCount / 2) * paperCaliperInches;

    final coverWidth =
        (trimWidthInches * 2) + spineWidth + (bleedInches * 2);

    final coverHeight =
        trimHeightInches + (bleedInches * 2);

    if (spineWidth < minimumSpineWidthInches) {
      errors.add(
        'Calculated spine width is below the supplied minimum.',
      );
    }

    if (spineWidth > maximumSpineWidthInches) {
      errors.add(
        'Calculated spine width exceeds the supplied maximum.',
      );
    }

    if (pageCount.isOdd) {
      warnings.add(
        'The page count is odd. Confirm the printer requirements '
        'for blank-page handling.',
      );
    }

    if (pageCount < 4) {
      warnings.add(
        'The manuscript has very few pages. Confirm that the '
        'selected binding method supports it.',
      );
    }

    warnings.add(
      'Confirm paper caliper, binding method, bleed and cover '
      'dimensions with your actual printing provider.',
    );

    return PrintSpecificationResult(
      errors: List.unmodifiable(errors),
      warnings: List.unmodifiable(warnings),
      calculatedSpineWidthInches: spineWidth,
      totalCoverWidthInches: coverWidth,
      totalCoverHeightInches: coverHeight,
    );
  }
}
