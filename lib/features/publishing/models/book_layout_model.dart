enum BookFormat {
  pocket,
  digest,
  trade,
  letter,
  a4,
  a5,
  custom,
}

enum PageOrientation {
  portrait,
  landscape,
}

class BookLayoutModel {
  const BookLayoutModel({
    this.format = BookFormat.trade,
    this.orientation = PageOrientation.portrait,
    this.customWidth = 6,
    this.customHeight = 9,
    this.topMargin = 0.75,
    this.bottomMargin = 0.75,
    this.insideMargin = 0.85,
    this.outsideMargin = 0.65,
    this.fontFamily = 'Georgia',
    this.fontSize = 11,
    this.lineSpacing = 1.5,
    this.paragraphSpacing = 8,
    this.firstLineIndent = 0.25,
    this.showPageNumbers = true,
    this.showRunningHeaders = true,
  });

  final BookFormat format;
  final PageOrientation orientation;

  /// Custom page dimensions in inches.
  final double customWidth;
  final double customHeight;

  /// Page margins in inches.
  final double topMargin;
  final double bottomMargin;
  final double insideMargin;
  final double outsideMargin;

  /// Typography settings.
  final String fontFamily;
  final double fontSize;
  final double lineSpacing;
  final double paragraphSpacing;
  final double firstLineIndent;

  final bool showPageNumbers;
  final bool showRunningHeaders;

  double get pageWidth {
    switch (format) {
      case BookFormat.pocket:
        return 5;
      case BookFormat.digest:
        return 5.5;
      case BookFormat.trade:
        return 6;
      case BookFormat.letter:
        return 8.5;
      case BookFormat.a4:
        return 8.27;
      case BookFormat.a5:
        return 5.83;
      case BookFormat.custom:
        return customWidth;
    }
  }

  double get pageHeight {
    switch (format) {
      case BookFormat.pocket:
        return 8;
      case BookFormat.digest:
        return 8.5;
      case BookFormat.trade:
        return 9;
      case BookFormat.letter:
        return 11;
      case BookFormat.a4:
        return 11.69;
      case BookFormat.a5:
        return 8.27;
      case BookFormat.custom:
        return customHeight;
    }
  }

  double get effectivePageWidth {
    return orientation == PageOrientation.portrait
        ? pageWidth
        : pageHeight;
  }

  double get effectivePageHeight {
    return orientation == PageOrientation.portrait
        ? pageHeight
        : pageWidth;
  }

  double get usableWidth {
    return effectivePageWidth - insideMargin - outsideMargin;
  }

  double get usableHeight {
    return effectivePageHeight - topMargin - bottomMargin;
  }

  BookLayoutModel copyWith({
    BookFormat? format,
    PageOrientation? orientation,
    double? customWidth,
    double? customHeight,
    double? topMargin,
    double? bottomMargin,
    double? insideMargin,
    double? outsideMargin,
    String? fontFamily,
    double? fontSize,
    double? lineSpacing,
    double? paragraphSpacing,
    double? firstLineIndent,
    bool? showPageNumbers,
    bool? showRunningHeaders,
  }) {
    return BookLayoutModel(
      format: format ?? this.format,
      orientation: orientation ?? this.orientation,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      topMargin: topMargin ?? this.topMargin,
      bottomMargin: bottomMargin ?? this.bottomMargin,
      insideMargin: insideMargin ?? this.insideMargin,
      outsideMargin: outsideMargin ?? this.outsideMargin,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      paragraphSpacing:
          paragraphSpacing ?? this.paragraphSpacing,
      firstLineIndent:
          firstLineIndent ?? this.firstLineIndent,
      showPageNumbers:
          showPageNumbers ?? this.showPageNumbers,
      showRunningHeaders:
          showRunningHeaders ?? this.showRunningHeaders,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'format': format.name,
      'orientation': orientation.name,
      'customWidth': customWidth,
      'customHeight': customHeight,
      'topMargin': topMargin,
      'bottomMargin': bottomMargin,
      'insideMargin': insideMargin,
      'outsideMargin': outsideMargin,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'lineSpacing': lineSpacing,
      'paragraphSpacing': paragraphSpacing,
      'firstLineIndent': firstLineIndent,
      'showPageNumbers': showPageNumbers,
      'showRunningHeaders': showRunningHeaders,
    };
  }

  factory BookLayoutModel.fromMap(Map<String, dynamic> map) {
    return BookLayoutModel(
      format: BookFormat.values.firstWhere(
        (value) => value.name == map['format'],
        orElse: () => BookFormat.trade,
      ),
      orientation: PageOrientation.values.firstWhere(
        (value) => value.name == map['orientation'],
        orElse: () => PageOrientation.portrait,
      ),
      customWidth: _readDouble(map, 'customWidth', 6),
      customHeight: _readDouble(map, 'customHeight', 9),
      topMargin: _readDouble(map, 'topMargin', 0.75),
      bottomMargin: _readDouble(map, 'bottomMargin', 0.75),
      insideMargin: _readDouble(map, 'insideMargin', 0.85),
      outsideMargin: _readDouble(map, 'outsideMargin', 0.65),
      fontFamily: map['fontFamily'] as String? ?? 'Georgia',
      fontSize: _readDouble(map, 'fontSize', 11),
      lineSpacing: _readDouble(map, 'lineSpacing', 1.5),
      paragraphSpacing: _readDouble(map, 'paragraphSpacing', 8),
      firstLineIndent: _readDouble(map, 'firstLineIndent', 0.25),
      showPageNumbers: map['showPageNumbers'] as bool? ?? true,
      showRunningHeaders:
          map['showRunningHeaders'] as bool? ?? true,
    );
  }

  static double _readDouble(
    Map<String, dynamic> map,
    String key,
    double fallback,
  ) {
    final value = map[key];

    if (value is num) return value.toDouble();

    return fallback;
  }
}
