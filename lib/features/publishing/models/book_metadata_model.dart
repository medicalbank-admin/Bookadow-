class BookMetadataModel {
  final String bookId;
  final String isbn;
  final String title;
  final String subtitle;
  final String author;
  final String contributors;
  final String publisher;
  final String publicationDate;
  final String edition;
  final String language;
  final String description;
  final String keywords;
  final String categories;
  final String copyright;
  final String website;
  final String seriesName;
  final String seriesNumber;
  final String countryOfPublication;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookMetadataModel({
    required this.bookId,
    this.isbn = '',
    this.title = '',
    this.subtitle = '',
    this.author = '',
    this.contributors = '',
    this.publisher = '',
    this.publicationDate = '',
    this.edition = 'First Edition',
    this.language = 'en',
    this.description = '',
    this.keywords = '',
    this.categories = '',
    this.copyright = '',
    this.website = '',
    this.seriesName = '',
    this.seriesNumber = '',
    this.countryOfPublication = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookMetadataModel.create({
    required String bookId,
    required String title,
    required String author,
  }) {
    final now = DateTime.now();

    return BookMetadataModel(
      bookId: bookId,
      title: title,
      author: author,
      createdAt: now,
      updatedAt: now,
    );
  }

  BookMetadataModel copyWith({
    String? isbn,
    String? title,
    String? subtitle,
    String? author,
    String? contributors,
    String? publisher,
    String? publicationDate,
    String? edition,
    String? language,
    String? description,
    String? keywords,
    String? categories,
    String? copyright,
    String? website,
    String? seriesName,
    String? seriesNumber,
    String? countryOfPublication,
    DateTime? updatedAt,
  }) {
    return BookMetadataModel(
      bookId: bookId,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      contributors: contributors ?? this.contributors,
      publisher: publisher ?? this.publisher,
      publicationDate: publicationDate ?? this.publicationDate,
      edition: edition ?? this.edition,
      language: language ?? this.language,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      categories: categories ?? this.categories,
      copyright: copyright ?? this.copyright,
      website: website ?? this.website,
      seriesName: seriesName ?? this.seriesName,
      seriesNumber: seriesNumber ?? this.seriesNumber,
      countryOfPublication:
          countryOfPublication ?? this.countryOfPublication,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'isbn': isbn,
      'title': title,
      'subtitle': subtitle,
      'author': author,
      'contributors': contributors,
      'publisher': publisher,
      'publicationDate': publicationDate,
      'edition': edition,
      'language': language,
      'description': description,
      'keywords': keywords,
      'categories': categories,
      'copyright': copyright,
      'website': website,
      'seriesName': seriesName,
      'seriesNumber': seriesNumber,
      'countryOfPublication': countryOfPublication,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BookMetadataModel.fromMap(Map<String, dynamic> map) {
    return BookMetadataModel(
      bookId: map['bookId'] as String? ?? '',
      isbn: map['isbn'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      author: map['author'] as String? ?? '',
      contributors: map['contributors'] as String? ?? '',
      publisher: map['publisher'] as String? ?? '',
      publicationDate: map['publicationDate'] as String? ?? '',
      edition: map['edition'] as String? ?? 'First Edition',
      language: map['language'] as String? ?? 'en',
      description: map['description'] as String? ?? '',
      keywords: map['keywords'] as String? ?? '',
      categories: map['categories'] as String? ?? '',
      copyright: map['copyright'] as String? ?? '',
      website: map['website'] as String? ?? '',
      seriesName: map['seriesName'] as String? ?? '',
      seriesNumber: map['seriesNumber'] as String? ?? '',
      countryOfPublication:
          map['countryOfPublication'] as String? ?? '',
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            map['updatedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  bool get hasIsbn => isbn.trim().isNotEmpty;

  bool get hasPublisher => publisher.trim().isNotEmpty;

  bool get hasDescription => description.trim().isNotEmpty;

  bool get hasKeywords => keywords.trim().isNotEmpty;
}
