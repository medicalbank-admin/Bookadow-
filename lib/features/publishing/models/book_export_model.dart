enum BookExportFormat {
  digitalPdf,
  printReadyPdf,
  epub,
  word,
}

enum PaperType {
  cream,
  white,
  standard,
}

enum PdfQuality {
  standard,
  high,
  print,
}

class BookExportModel {
  const BookExportModel({
    this.format = BookExportFormat.digitalPdf,
    this.paperType = PaperType.cream,
    this.quality = PdfQuality.high,
    this.includeCover = true,
    this.includeTableOfContents = true,
    this.includePageNumbers = true,
    this.includeBookmarks = true,
    this.embedFonts = true,
    this.includeBleed = false,
    this.enableRightToLeft = false,
    this.includeCopyrightPage = true,
    this.includeDedication = true,
    this.includeAcknowledgements = true,
    this.includeAuthorBio = true,
    this.includeBibliography = true,
    this.includeFootnotes = true,
    this.grayscale = false,
    this.customFileName = '',
  });

  final BookExportFormat format;
  final PaperType paperType;
  final PdfQuality quality;

  final bool includeCover;
  final bool includeTableOfContents;
  final bool includePageNumbers;
  final bool includeBookmarks;
  final bool embedFonts;
  final bool includeBleed;

  final bool enableRightToLeft;

  final bool includeCopyrightPage;
  final bool includeDedication;
  final bool includeAcknowledgements;
  final bool includeAuthorBio;
  final bool includeBibliography;
  final bool includeFootnotes;

  final bool grayscale;
  final String customFileName;

  bool get isPrintReady =>
      format == BookExportFormat.printReadyPdf;

  bool get isDigitalPdf =>
      format == BookExportFormat.digitalPdf;

  BookExportModel copyWith({
    BookExportFormat? format,
    PaperType? paperType,
    PdfQuality? quality,
    bool? includeCover,
    bool? includeTableOfContents,
    bool? includePageNumbers,
    bool? includeBookmarks,
    bool? embedFonts,
    bool? includeBleed,
    bool? enableRightToLeft,
    bool? includeCopyrightPage,
    bool? includeDedication,
    bool? includeAcknowledgements,
    bool? includeAuthorBio,
    bool? includeBibliography,
    bool? includeFootnotes,
    bool? grayscale,
    String? customFileName,
  }) {
    return BookExportModel(
      format: format ?? this.format,
      paperType: paperType ?? this.paperType,
      quality: quality ?? this.quality,
      includeCover: includeCover ?? this.includeCover,
      includeTableOfContents:
          includeTableOfContents ?? this.includeTableOfContents,
      includePageNumbers:
          includePageNumbers ?? this.includePageNumbers,
      includeBookmarks: includeBookmarks ?? this.includeBookmarks,
      embedFonts: embedFonts ?? this.embedFonts,
      includeBleed: includeBleed ?? this.includeBleed,
      enableRightToLeft:
          enableRightToLeft ?? this.enableRightToLeft,
      includeCopyrightPage:
          includeCopyrightPage ?? this.includeCopyrightPage,
      includeDedication:
          includeDedication ?? this.includeDedication,
      includeAcknowledgements:
          includeAcknowledgements ?? this.includeAcknowledgements,
      includeAuthorBio: includeAuthorBio ?? this.includeAuthorBio,
      includeBibliography:
          includeBibliography ?? this.includeBibliography,
      includeFootnotes: includeFootnotes ?? this.includeFootnotes,
      grayscale: grayscale ?? this.grayscale,
      customFileName: customFileName ?? this.customFileName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'format': format.name,
      'paperType': paperType.name,
      'quality': quality.name,
      'includeCover': includeCover,
      'includeTableOfContents': includeTableOfContents,
      'includePageNumbers': includePageNumbers,
      'includeBookmarks': includeBookmarks,
      'embedFonts': embedFonts,
      'includeBleed': includeBleed,
      'enableRightToLeft': enableRightToLeft,
      'includeCopyrightPage': includeCopyrightPage,
      'includeDedication': includeDedication,
      'includeAcknowledgements': includeAcknowledgements,
      'includeAuthorBio': includeAuthorBio,
      'includeBibliography': includeBibliography,
      'includeFootnotes': includeFootnotes,
      'grayscale': grayscale,
      'customFileName': customFileName,
    };
  }

  factory BookExportModel.fromMap(Map<String, dynamic> map) {
    return BookExportModel(
      format: _readEnum(
        BookExportFormat.values,
        map['format'],
        BookExportFormat.digitalPdf,
      ),
      paperType: _readEnum(
        PaperType.values,
        map['paperType'],
        PaperType.cream,
      ),
      quality: _readEnum(
        PdfQuality.values,
        map['quality'],
        PdfQuality.high,
      ),
      includeCover: map['includeCover'] as bool? ?? true,
      includeTableOfContents:
          map['includeTableOfContents'] as bool? ?? true,
      includePageNumbers:
          map['includePageNumbers'] as bool? ?? true,
      includeBookmarks:
          map['includeBookmarks'] as bool? ?? true,
      embedFonts: map['embedFonts'] as bool? ?? true,
      includeBleed: map['includeBleed'] as bool? ?? false,
      enableRightToLeft:
          map['enableRightToLeft'] as bool? ?? false,
      includeCopyrightPage:
          map['includeCopyrightPage'] as bool? ?? true,
      includeDedication:
          map['includeDedication'] as bool? ?? true,
      includeAcknowledgements:
          map['includeAcknowledgements'] as bool? ?? true,
      includeAuthorBio:
          map['includeAuthorBio'] as bool? ?? true,
      includeBibliography:
          map['includeBibliography'] as bool? ?? true,
      includeFootnotes:
          map['includeFootnotes'] as bool? ?? true,
      grayscale: map['grayscale'] as bool? ?? false,
      customFileName: map['customFileName'] as String? ?? '',
    );
  }

  static T _readEnum<T extends Enum>(
    List<T> values,
    dynamic storedValue,
    T fallback,
  ) {
    for (final value in values) {
      if (value.name == storedValue) {
        return value;
      }
    }

    return fallback;
  }
}
