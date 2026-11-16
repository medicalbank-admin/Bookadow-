import '../models/book_metadata_model.dart';

class BookMetadataValidationResult {
  final List<String> errors;
  final List<String> warnings;

  const BookMetadataValidationResult({
    required this.errors,
    required this.warnings,
  });

  bool get isValid => errors.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;

  int get issueCount => errors.length + warnings.length;
}

class BookMetadataValidationService {
  BookMetadataValidationResult validate(
    BookMetadataModel metadata,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (metadata.bookId.trim().isEmpty) {
      errors.add('Book ID is missing.');
    }

    if (metadata.title.trim().isEmpty) {
      errors.add('Book title is required.');
    }

    if (metadata.author.trim().isEmpty) {
      warnings.add('Author name has not been provided.');
    }

    if (metadata.language.trim().isEmpty) {
      errors.add('Book language is required.');
    } else if (!_isValidLanguageCode(metadata.language)) {
      errors.add(
        'Language must be a valid two- or three-letter code, '
        'optionally followed by a region.',
      );
    }

    if (metadata.isbn.trim().isNotEmpty &&
        !_isValidIsbn(metadata.isbn)) {
      errors.add(
        'ISBN must be a valid ISBN-10 or ISBN-13 number.',
      );
    }

    if (metadata.website.trim().isNotEmpty &&
        !_isValidWebsite(metadata.website)) {
      errors.add('Website must be a valid HTTP or HTTPS URL.');
    }

    if (metadata.publicationDate.trim().isNotEmpty &&
        DateTime.tryParse(metadata.publicationDate.trim()) == null) {
      errors.add(
        'Publication date must use a valid date format, '
        'preferably YYYY-MM-DD.',
      );
    }

    if (metadata.publisher.trim().isEmpty) {
      warnings.add('Publisher information is missing.');
    }

    if (metadata.description.trim().isEmpty) {
      warnings.add('A book description is recommended.');
    }

    if (metadata.keywords.trim().isEmpty) {
      warnings.add('Adding keywords can improve book discoverability.');
    }

    if (metadata.categories.trim().isEmpty) {
      warnings.add('Book categories have not been specified.');
    }

    if (metadata.edition.trim().isEmpty) {
      warnings.add('Edition information is missing.');
    }

    return BookMetadataValidationResult(
      errors: List.unmodifiable(errors),
      warnings: List.unmodifiable(warnings),
    );
  }

  bool _isValidLanguageCode(String value) {
    final pattern = RegExp(
      r'^[a-zA-Z]{2,3}(-[a-zA-Z]{2,8})*$',
    );

    return pattern.hasMatch(value.trim());
  }

  bool _isValidWebsite(String value) {
    final uri = Uri.tryParse(value.trim());

    if (uri == null || !uri.hasAuthority) {
      return false;
    }

    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
  }

  bool _isValidIsbn(String value) {
    final isbn = value.replaceAll(RegExp(r'[-\s]'), '');

    if (RegExp(r'^\d{9}[\dXx]$').hasMatch(isbn)) {
      return _isValidIsbn10(isbn);
    }

    if (RegExp(r'^\d{13}$').hasMatch(isbn)) {
      return _isValidIsbn13(isbn);
    }

    return false;
  }

  bool _isValidIsbn10(String isbn) {
    var sum = 0;

    for (var i = 0; i < 10; i++) {
      final digit = isbn[i].toUpperCase() == 'X'
          ? 10
          : int.parse(isbn[i]);

      sum += digit * (10 - i);
    }

    return sum % 11 == 0;
  }

  bool _isValidIsbn13(String isbn) {
    var sum = 0;

    for (var i = 0; i < 13; i++) {
      final digit = int.parse(isbn[i]);

      sum += digit * (i.isEven ? 1 : 3);
    }

    return sum % 10 == 0;
  }
}
