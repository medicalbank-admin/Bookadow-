class PublishingConstants {
  PublishingConstants._();

  // Standard print bleed in inches.
  static const double standardBleedInches = 0.125;

  // Standard minimum safety margin in inches.
  static const double minimumSafetyMarginInches = 0.25;

  // Standard measurement conversion.
  static const double inchesToMillimeters = 25.4;
  static const double millimetersToInches = 1 / 25.4;

  // Standard book trim sizes in inches.
  static const Map<String, List<double>> bookFormats = {
    'Pocket (5 × 8)': [5.0, 8.0],
    'Digest (5.5 × 8.5)': [5.5, 8.5],
    'Trade Paperback (6 × 9)': [6.0, 9.0],
    'US Letter (8.5 × 11)': [8.5, 11.0],
    'A4': [8.27, 11.69],
    'A5': [5.83, 8.27],
  };

  // Common paper categories.
  static const List<String> paperTypes = [
    'Cream',
    'White',
    'Standard',
  ];

  // Paper calipers are illustrative defaults in inches.
  // Replace these with the printer's actual specifications.
  static const Map<String, double> paperCalipers = {
    'Cream': 0.0025,
    'White': 0.0023,
    'Standard': 0.0024,
  };

  // Supported export formats.
  static const List<String> exportFormats = [
    'Digital PDF',
    'Print-ready PDF',
    'EPUB',
    'Word Document',
  ];

  // Recommended typography options.
  static const List<String> fontFamilies = [
    'Georgia',
    'Garamond',
    'Times New Roman',
    'Arial',
    'Roboto',
    'Open Sans',
    'Merriweather',
    'Lora',
  ];

  // Common font sizes for book interiors.
  static const List<double> bodyFontSizes = [
    9,
    9.5,
    10,
    10.5,
    11,
    11.5,
    12,
  ];

  // Common line spacing options.
  static const List<double> lineSpacingOptions = [
    1.0,
    1.15,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  // Common bleed options in inches.
  static const List<double> bleedOptions = [
    0.0,
    0.0625,
    0.125,
    0.1875,
    0.25,
  ];

  // Page numbering styles.
  static const List<String> pageNumberStyles = [
    'Bottom Center',
    'Bottom Outside',
    'Top Center',
    'Top Outside',
  ];

  // Common chapter heading alignments.
  static const List<String> chapterAlignments = [
    'Left',
    'Center',
    'Right',
  ];

  // Minimum values for publishing validation.
  static const int minimumBookPages = 1;
  static const int minimumChapterCount = 1;
  static const int maximumCustomBookTitleLength = 200;

  // Supported text directions.
  static const String leftToRight = 'LTR';
  static const String rightToLeft = 'RTL';
}
