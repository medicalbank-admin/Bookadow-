
class BookCoverModel {
  const BookCoverModel({
    this.title = '',
    this.subtitle = '',
    this.authorName = '',
    this.backCoverBlurb = '',
    this.authorBio = '',
    this.publisherName = '',
    this.frontBackgroundColor = 0xFF142238,
    this.backBackgroundColor = 0xFF142238,
    this.spineBackgroundColor = 0xFF142238,
    this.titleColor = 0xFFFFFFFF,
    this.subtitleColor = 0xFFE4D5B8,
    this.authorColor = 0xFFFFFFFF,
    this.backTextColor = 0xFFFFFFFF,
    this.spineTextColor = 0xFFFFFFFF,
    this.titleFontFamily = 'Georgia',
    this.bodyFontFamily = 'Georgia',
    this.coverImagePath,
    this.publisherLogoPath,
    this.showSubtitle = true,
    this.showAuthorName = true,
    this.showSpineTitle = true,
    this.showSpineAuthor = false,
    this.showBarcodeArea = true,
    this.showPublisherName = false,
    this.spineWidthInches = 0.25,
    this.bleedInches = 0.125,
  });

  final String title;
  final String subtitle;
  final String authorName;
  final String backCoverBlurb;
  final String authorBio;
  final String publisherName;

  // Colors are stored as ARGB integers for easy serialization.
  final int frontBackgroundColor;
  final int backBackgroundColor;
  final int spineBackgroundColor;

  final int titleColor;
  final int subtitleColor;
  final int authorColor;
  final int backTextColor;
  final int spineTextColor;

  final String titleFontFamily;
  final String bodyFontFamily;

  // Local file paths can be used offline.
  // Cloud image URLs can be added when cloud storage is implemented.
  final String? coverImagePath;
  final String? publisherLogoPath;

  final bool showSubtitle;
  final bool showAuthorName;
  final bool showSpineTitle;
  final bool showSpineAuthor;
  final bool showBarcodeArea;
  final bool showPublisherName;

  // Physical measurements are in inches.
  final double spineWidthInches;
  final double bleedInches;

  BookCoverModel copyWith({
    String? title,
    String? subtitle,
    String? authorName,
    String? backCoverBlurb,
    String? authorBio,
    String? publisherName,
    int? frontBackgroundColor,
    int? backBackgroundColor,
    int? spineBackgroundColor,
    int? titleColor,
    int? subtitleColor,
    int? authorColor,
    int? backTextColor,
    int? spineTextColor,
    String? titleFontFamily,
    String? bodyFontFamily,
    String? coverImagePath,
    String? publisherLogoPath,
    bool? showSubtitle,
    bool? showAuthorName,
    bool? showSpineTitle,
    bool? showSpineAuthor,
    bool? showBarcodeArea,
    bool? showPublisherName,
    double? spineWidthInches,
    double? bleedInches,
    bool clearCoverImage = false,
    bool clearPublisherLogo = false,
  }) {
    return BookCoverModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      authorName: authorName ?? this.authorName,
      backCoverBlurb: backCoverBlurb ?? this.backCoverBlurb,
      authorBio: authorBio ?? this.authorBio,
      publisherName: publisherName ?? this.publisherName,
      frontBackgroundColor:
          frontBackgroundColor ?? this.frontBackgroundColor,
      backBackgroundColor:
          backBackgroundColor ?? this.backBackgroundColor,
      spineBackgroundColor:
          spineBackgroundColor ?? this.spineBackgroundColor,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      authorColor: authorColor ?? this.authorColor,
      backTextColor: backTextColor ?? this.backTextColor,
      spineTextColor: spineTextColor ?? this.spineTextColor,
      titleFontFamily: titleFontFamily ?? this.titleFontFamily,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
      coverImagePath: clearCoverImage
          ? null
          : coverImagePath ?? this.coverImagePath,
      publisherLogoPath: clearPublisherLogo
          ? null
          : publisherLogoPath ?? this.publisherLogoPath,
      showSubtitle: showSubtitle ?? this.showSubtitle,
      showAuthorName: showAuthorName ?? this.showAuthorName,
      showSpineTitle: showSpineTitle ?? this.showSpineTitle,
      showSpineAuthor: showSpineAuthor ?? this.showSpineAuthor,
      showBarcodeArea: showBarcodeArea ?? this.showBarcodeArea,
      showPublisherName:
          showPublisherName ?? this.showPublisherName,
      spineWidthInches:
          spineWidthInches ?? this.spineWidthInches,
      bleedInches: bleedInches ?? this.bleedInches,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'authorName': authorName,
      'backCoverBlurb': backCoverBlurb,
      'authorBio': authorBio,
      'publisherName': publisherName,
      'frontBackgroundColor': frontBackgroundColor,
      'backBackgroundColor': backBackgroundColor,
      'spineBackgroundColor': spineBackgroundColor,
      'titleColor': titleColor,
      'subtitleColor': subtitleColor,
      'authorColor': authorColor,
      'backTextColor': backTextColor,
      'spineTextColor': spineTextColor,
      'titleFontFamily': titleFontFamily,
      'bodyFontFamily': bodyFontFamily,
      'coverImagePath': coverImagePath,
      'publisherLogoPath': publisherLogoPath,
      'showSubtitle': showSubtitle,
      'showAuthorName': showAuthorName,
      'showSpineTitle': showSpineTitle,
      'showSpineAuthor': showSpineAuthor,
      'showBarcodeArea': showBarcodeArea,
      'showPublisherName': showPublisherName,
      'spineWidthInches': spineWidthInches,
      'bleedInches': bleedInches,
    };
  }

  factory BookCoverModel.fromMap(Map<String, dynamic> map) {
    return BookCoverModel(
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      backCoverBlurb: map['backCoverBlurb'] as String? ?? '',
      authorBio: map['authorBio'] as String? ?? '',
      publisherName: map['publisherName'] as String? ?? '',
      frontBackgroundColor:
          _readInt(map['frontBackgroundColor'], 0xFF142238),
      backBackgroundColor:
          _readInt(map['backBackgroundColor'], 0xFF142238),
      spineBackgroundColor:
          _readInt(map['spineBackgroundColor'], 0xFF142238),
      titleColor: _readInt(map['titleColor'], 0xFFFFFFFF),
      subtitleColor: _readInt(map['subtitleColor'], 0xFFE4D5B8),
      authorColor: _readInt(map['authorColor'], 0xFFFFFFFF),
      backTextColor: _readInt(map['backTextColor'], 0xFFFFFFFF),
      spineTextColor: _readInt(map['spineTextColor'], 0xFFFFFFFF),
      titleFontFamily:
          map['titleFontFamily'] as String? ?? 'Georgia',
      bodyFontFamily:
          map['bodyFontFamily'] as String? ?? 'Georgia',
      coverImagePath: map['coverImagePath'] as String?,
      publisherLogoPath: map['publisherLogoPath'] as String?,
      showSubtitle: map['showSubtitle'] as bool? ?? true,
      showAuthorName: map['showAuthorName'] as bool? ?? true,
      showSpineTitle: map['showSpineTitle'] as bool? ?? true,
      showSpineAuthor: map['showSpineAuthor'] as bool? ?? false,
      showBarcodeArea: map['showBarcodeArea'] as bool? ?? true,
      showPublisherName:
          map['showPublisherName'] as bool? ?? false,
      spineWidthInches:
          _readDouble(map['spineWidthInches'], 0.25),
      bleedInches: _readDouble(map['bleedInches'], 0.125),
    );
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static double _readDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return fallback;
  }
}
