class SpineWidthCalculator {
  /// Calculates the spine width in inches.
  ///
  /// Formula:
  /// Spine width = (page count / 2) × paper caliper
  ///
  /// Paper caliper means the thickness of one sheet of paper,
  /// measured in inches.
  static double calculateInches({
    required int pageCount,
    required double paperCaliperInches,
  }) {
    if (pageCount <= 0) {
      throw ArgumentError.value(
        pageCount,
        'pageCount',
        'Page count must be greater than zero.',
      );
    }

    if (paperCaliperInches <= 0) {
      throw ArgumentError.value(
        paperCaliperInches,
        'paperCaliperInches',
        'Paper caliper must be greater than zero.',
      );
    }

    final width = (pageCount / 2) * paperCaliperInches;

    return double.parse(width.toStringAsFixed(4));
  }

  /// Calculates the spine width in millimeters.
  static double calculateMillimeters({
    required int pageCount,
    required double paperCaliperInches,
  }) {
    final inches = calculateInches(
      pageCount: pageCount,
      paperCaliperInches: paperCaliperInches,
    );

    return double.parse((inches * 25.4).toStringAsFixed(2));
  }

  /// Converts inches to millimeters.
  static double inchesToMillimeters(double inches) {
    if (inches < 0) {
      throw ArgumentError.value(
        inches,
        'inches',
        'Measurement cannot be negative.',
      );
    }

    return double.parse((inches * 25.4).toStringAsFixed(2));
  }

  /// Converts millimeters to inches.
  static double millimetersToInches(double millimeters) {
    if (millimeters < 0) {
      throw ArgumentError.value(
        millimeters,
        'millimeters',
        'Measurement cannot be negative.',
      );
    }

    return double.parse(
      (millimeters / 25.4).toStringAsFixed(4),
    );
  }

  /// Checks whether a calculated spine width is suitable
  /// for displaying spine text.
  static bool canDisplaySpineText({
    required double spineWidthInches,
    double minimumWidthInches = 0.25,
  }) {
    if (spineWidthInches < 0 || minimumWidthInches < 0) {
      return false;
    }

    return spineWidthInches >= minimumWidthInches;
  }

  /// Calculates the complete cover wrap width.
  ///
  /// Includes:
  /// - Back cover
  /// - Spine
  /// - Front cover
  /// - Left and right bleed
  static double calculateWrapWidth({
    required double trimWidthInches,
    required double spineWidthInches,
    double bleedInches = 0.125,
  }) {
    _validatePositive(trimWidthInches, 'trimWidthInches');
    _validateNonNegative(spineWidthInches, 'spineWidthInches');
    _validateNonNegative(bleedInches, 'bleedInches');

    return double.parse(
      (
        (trimWidthInches * 2) +
        spineWidthInches +
        (bleedInches * 2)
      ).toStringAsFixed(4),
    );
  }

  /// Calculates the complete cover wrap height.
  ///
  /// Includes top and bottom bleed.
  static double calculateWrapHeight({
    required double trimHeightInches,
    double bleedInches = 0.125,
  }) {
    _validatePositive(trimHeightInches, 'trimHeightInches');
    _validateNonNegative(bleedInches, 'bleedInches');

    return double.parse(
      (trimHeightInches + (bleedInches * 2))
          .toStringAsFixed(4),
    );
  }

  static void _validatePositive(double value, String name) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        name,
        'Value must be greater than zero.',
      );
    }
  }

  static void _validateNonNegative(double value, String name) {
    if (value < 0) {
      throw ArgumentError.value(
        value,
        name,
        'Value cannot be negative.',
      );
    }
  }
}
