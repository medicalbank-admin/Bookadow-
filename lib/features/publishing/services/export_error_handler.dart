class ExportErrorHandler {
  const ExportErrorHandler();

  String getMessage(Object error) {
    final String message = error.toString().toLowerCase();

    if (message.contains('permission')) {
      return 'BOOKADOW does not have permission to save this file. '
          'Please check your device permissions and try again.';
    }

    if (message.contains('space') ||
        message.contains('storage')) {
      return 'Your device may not have enough storage space. '
          'Free up some space and try again.';
    }

    if (message.contains('file') &&
        message.contains('not found')) {
      return 'The required file could not be found. '
          'Please check your manuscript and try again.';
    }

    if (message.contains('chapter')) {
      return 'There was a problem processing your chapters. '
          'Please review your manuscript and try again.';
    }

    if (message.contains('format') ||
        message.contains('unsupported')) {
      return 'The selected export format could not be processed. '
          'Please choose another format.';
    }

    if (message.contains('network') ||
        message.contains('socket')) {
      return 'A network connection problem occurred. '
          'Please check your connection and try again.';
    }

    return 'BOOKADOW could not complete this export. '
        'Please try again. If the problem continues, '
        'contact support.';
  }

  String getTechnicalDetails(Object error) {
    return error.toString();
  }

  bool isStorageError(Object error) {
    final String message = error.toString().toLowerCase();

    return message.contains('storage') ||
        message.contains('no space') ||
        message.contains('disk full');
  }

  bool isPermissionError(Object error) {
    return error.toString().toLowerCase().contains('permission');
  }

  bool isNetworkError(Object error) {
    final String message = error.toString().toLowerCase();

    return message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection');
  }
}
