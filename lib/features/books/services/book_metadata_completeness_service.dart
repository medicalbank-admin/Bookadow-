import '../models/book_metadata_model.dart';

class BookMetadataCompletenessResult {
  final int completedFields;
  final int totalFields;
  final List<String> missingFields;

  const BookMetadataCompletenessResult({
    required this.completedFields,
    required this.totalFields,
    required this.missingFields,
  });

  double get percentage {
    if (totalFields == 0) return 0;

    return completedFields / totalFields;
  }

  int get percentageValue => (percentage * 100).round();

  bool get isComplete => missingFields.isEmpty;
}

class BookMetadataCompletenessService {
  const BookMetadataCompletenessService();

  BookMetadataCompletenessResult calculate(
    BookMetadataModel metadata,
  ) {
    final fields = <String, String>{
      'Book title': metadata.title,
      'Author': metadata.author,
      'Language': metadata.language,
      'Description': metadata.description,
      'Publisher': metadata.publisher,
      'ISBN': metadata.isbn,
      'Publication date': metadata.publicationDate,
      'Edition': metadata.edition,
      'Categories': metadata.categories,
      'Keywords': metadata.keywords,
      'Copyright': metadata.copyright,
      'Country of publication':
          metadata.countryOfPublication,
    };

    final missingFields = fields.entries
        .where((entry) => entry.value.trim().isEmpty)
        .map((entry) => entry.key)
        .toList();

    final completedFields =
        fields.length - missingFields.length;

    return BookMetadataCompletenessResult(
      completedFields: completedFields,
      totalFields: fields.length,
      missingFields: missingFields,
    );
  }
}
