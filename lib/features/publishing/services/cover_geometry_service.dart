import '../models/book_layout_model.dart';
import 'spine_width_calculator.dart';

class CoverGeometry {
  const CoverGeometry({
    required this.trimWidth,
    required this.trimHeight,
    required this.spineWidth,
    required this.bleed,
    required this.wrapWidth,
    required this.wrapHeight,
    required this.backCoverX,
    required this.spineX,
    required this.frontCoverX,
  });

  final double trimWidth;
  final double trimHeight;
  final double spineWidth;
  final double bleed;

  final double wrapWidth;
  final double wrapHeight;

  // Horizontal positions measured from the left edge
  // of the complete wrap, including bleed.
  final double backCoverX;
  final double spineX;
  final double frontCoverX;

  double get backCoverY => bleed;

  double get frontCoverY => bleed;

  double get spineY => bleed;

  double get contentWidth => trimWidth * 2 + spineWidth;

  double get contentHeight => trimHeight;
}

class CoverGeometryService {
  CoverGeometryService._();

  /// Calculates full-wrap cover geometry.
  ///
  /// Layout order from left to right:
  /// Back cover | Spine | Front cover
  ///
  /// The narrow center section is technically called
  /// the book spine.
  static CoverGeometry calculate({
    required BookLayoutModel layout,
    required double spineWidthInches,
    double bleedInches = 0.125,
  }) {
    final trimWidth = layout.effectivePageWidth;
    final trimHeight = layout.effectivePageHeight;

    _validatePositive(trimWidth, 'trimWidth');
    _validatePositive(trimHeight, 'trimHeight');

    if (spineWidthInches < 0) {
      throw ArgumentError.value(
        spineWidthInches,
        'spineWidthInches',
        'Spine width cannot be negative.',
      );
    }

    if (bleedInches < 0) {
      throw ArgumentError.value(
        bleedInches,
        'bleedInches',
        'Bleed cannot be negative.',
      );
    }

    final wrapWidth = SpineWidthCalculator.calculateWrapWidth(
      trimWidthInches: trimWidth,
      spineWidthInches: spineWidthInches,
      bleedInches: bleedInches,
    );

    final wrapHeight = SpineWidthCalculator.calculateWrapHeight(
      trimHeightInches: trimHeight,
      bleedInches: bleedInches,
    );

    final backCoverX = bleedInches;
    final spineX = backCoverX + trimWidth;
    final frontCoverX = spineX + spineWidthInches;

    return CoverGeometry(
      trimWidth: trimWidth,
      trimHeight: trimHeight,
      spineWidth: spineWidthInches,
      bleed: bleedInches,
      wrapWidth: wrapWidth,
      wrapHeight: wrapHeight,
      backCoverX: backCoverX,
      spineX: spineX,
      frontCoverX: frontCoverX,
    );
  }

  /// Converts inches into PDF points.
  static double inchesToPoints(double inches) {
    if (inches < 0) {
      throw ArgumentError.value(
        inches,
        'inches',
        'Measurement cannot be negative.',
      );
    }

    return inches * 72;
  }

  /// Converts millimeters into PDF points.
  static double millimetersToPoints(double millimeters) {
    if (millimeters < 0) {
      throw ArgumentError.value(
        millimeters,
        'millimeters',
        'Measurement cannot be negative.',
      );
    }

    return millimeters * 72 / 25.4;
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
}
