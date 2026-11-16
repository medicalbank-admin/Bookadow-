
import '../models/book_metadata_model.dart';

class BookMetadataValidationResult {
  final List<String> errors;
  final List<String> warnings;

  const BookMetadataValidationResult({
    this.errors = const [],
    this.warnings = const [],
  });

  bool get isValid => errors.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;

  int get issueCount => errors.length + warnings.length;
}

class BookMetadataValidationService {
  const BookMetadataValidationService();

  BookMetadataValidationResult validate(
    BookMetadataModel metadata,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (metadata.bookId.trim().isEmpty) {
      errors.add('Book ID is required.');
    }

    if (metadata.title.trim().isEmpty) {
      errors.add('Book title is required.');
    }

    if (metadata.language.trim().isEmpty) {
      errors.add('Language is required.');
    } else {
      final languagePattern = RegExp(
        r'^[a-zA-Z]{2,3}(-[a-zA-Z0-9]{2,8})*$',
      );

      if (!languagePattern.hasMatch(metadata.language.trim())) {
        errors.add(
          'Language code is invalid. Use codes such as en, ur or en-US.',
        );
      }
    }

    if (metadata.isbn.trim().isNotEmpty &&
        !_isValidIsbn(metadata.isbn)) {
      errors.add('ISBN-10 or ISBN-13 is invalid.');
    }

    if (metadata.website.trim().isNotEmpty &&
        !_isValidWebsite(metadata.website)) {
      errors.add('Website URL must be a valid HTTP or HTTPS address.');
    }

    if (metadata.publicationDate.trim().isNotEmpty &&
        !_isValidDate(metadata.publicationDate)) {
      errors.add(
        'Publication date is invalid. Use YYYY-MM-DD format.',
      );
    }

    if (metadata.author.trim().isEmpty) {
      warnings.add('Author name has not been provided.');
    }

    if (metadata.publisher.trim().isEmpty) {
      warnings.add('Publisher information is missing.');
    }

    if (metadata.description.trim().isEmpty) {
      warnings.add('A book description is recommended.');
    }

    if (metadata.keywords.trim().isEmpty) {
      warnings.add('Adding keywords can improve book discovery.');
    }

    if (metadata.categories.trim().isEmpty) {
      warnings.add('Book categories have not been specified.');
    }

    if (metadata.edition.trim().isEmpty) {
      warnings.add('Edition information is missing.');
    }

    return BookMetadataValidationResult(
      errors: errors,
      warnings: warnings,
    );
  }

  bool _isValidDate(String value) {
    final date = DateTime.tryParse(value.trim());

    if (date == null) {
      return false;
    }

    return RegExp(r'^\d{4}-\d{2}-\d{2}$')
        .hasMatch(value.trim());
  }

  bool _isValidWebsite(String value) {
    final uri = Uri.tryParse(value.trim());

    if (uri == null) {
      return false;
    }

    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
  }

  bool _isValidIsbn(String value) {
    final isbn = value.replaceAll(
      RegExp(r'[-\s]'),
      '',
    ).toUpperCase();

    if (isbn.length == 10) {
      return _isValidIsbn10(isbn);
    }

    if (isbn.length == 13) {
      return _isValidIsbn13(isbn);
    }

    return false;
  }

  bool _isValidIsbn10(String isbn) {
    final pattern = RegExp(r'^\d{9}[\dX]$');

    if (!pattern.hasMatch(isbn)) {
      return false;
    }

    var sum = 0;

    for (var i = 0; i < 10; i++) {
      final character = isbn[i];

      final digit = character == 'X'
          ? 10
          : int.parse(character);

      sum += digit * (10 - i);
    }

    return sum % 11 == 0;
  }

  bool _isValidIsbn13(String isbn) {
    if (!RegExp(r'^\d{13}$').hasMatch(isbn)) {
      return false;
    }

    var sum = 0;

    for (var i = 0; i < 12; i++) {
      final digit = int.parse(isbn[i]);

      sum += digit * (i.isEven ? 1 : 3);
    }

    final checkDigit = (10 - (sum % 10)) % 10;

    return checkDigit == int.parse(isbn[12]);
  }
}
