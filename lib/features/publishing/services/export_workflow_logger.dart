import 'dart:developer' as developer;

class ExportWorkflowLogger {
  const ExportWorkflowLogger();

  static const String _name = 'BOOKADOW.Export';

  void info(
    String message, {
    String? bookId,
  }) {
    developer.log(
      message,
      name: _name,
      level: 800,
      error: bookId == null ? null : 'Book ID: $bookId',
    );
  }

  void warning(
    String message, {
    String? bookId,
  }) {
    developer.log(
      message,
      name: _name,
      level: 900,
      error: bookId == null ? null : 'Book ID: $bookId',
    );
  }

  void error(
    String message, {
    Object? exception,
    StackTrace? stackTrace,
    String? bookId,
  }) {
    developer.log(
      message,
      name: _name,
      level: 1000,
      error: exception,
      stackTrace: stackTrace,
      sequenceNumber: bookId?.hashCode,
    );
  }

  void exportStarted(String bookId) {
    info(
      'Book export started.',
      bookId: bookId,
    );
  }

  void exportCompleted(
    String bookId, {
    required String filePath,
  }) {
    info(
      'Book export completed. File: $filePath',
      bookId: bookId,
    );
  }

  void exportFailed(
    String bookId, {
    required Object exception,
    StackTrace? stackTrace,
  }) {
    error(
      'Book export failed.',
      exception: exception,
      stackTrace: stackTrace,
      bookId: bookId,
    );
  }
}
