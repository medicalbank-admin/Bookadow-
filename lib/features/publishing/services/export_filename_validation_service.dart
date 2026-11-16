import '../utils/export_workflow_config.dart';

class ExportFilenameValidationResult {
  const ExportFilenameValidationResult({
    required this.isValid,
    required this.message,
    this.sanitizedFileName,
  });

  final bool isValid;
  final String message;
  final String? sanitizedFileName;
}

class ExportFilenameValidationService {
  const ExportFilenameValidationService();

  ExportFilenameValidationResult validate(
    String fileName, {
    required String extension,
  }) {
    final String trimmedName = fileName.trim();

    if (trimmedName.isEmpty) {
      return const ExportFilenameValidationResult(
        isValid: false,
        message: 'Please enter a filename.',
      );
    }

    if (trimmedName.length >
        ExportWorkflowConfig.maximumFileNameLengthAllowed) {
      return const ExportFilenameValidationResult(
        isValid: false,
        message: 'The filename is too long.',
      );
    }

    final String sanitized = _sanitize(trimmedName);

    if (sanitized.isEmpty) {
      return const ExportFilenameValidationResult(
        isValid: false,
        message: 'Please use valid filename characters.',
      );
    }

    if (_isReservedName(sanitized)) {
      return const ExportFilenameValidationResult(
        isValid: false,
        message: 'This filename is reserved by the system.',
      );
    }

    final String normalizedExtension =
        extension.startsWith('.') ? extension : '.$extension';

    final String finalName = _removeKnownExtension(sanitized) +
        normalizedExtension;

    return ExportFilenameValidationResult(
      isValid: true,
      message: 'Filename is valid.',
      sanitizedFileName: finalName,
    );
  }

  String _sanitize(String value) {
    return value
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^[._]+|[._ ]+$'), '');
  }

  String _removeKnownExtension(String value) {
    final String lower = value.toLowerCase();

    for (final String extension in [
      '.pdf',
      '.epub',
      '.docx',
    ]) {
      if (lower.endsWith(extension)) {
        return value.substring(
          0,
          value.length - extension.length,
        );
      }
    }

    return value;
  }

  bool _isReservedName(String value) {
    final String name = value.toUpperCase();

    const Set<String> reservedNames = {
      'CON',
      'PRN',
      'AUX',
      'NUL',
      'COM1',
      'COM2',
      'COM3',
      'COM4',
      'COM5',
      'COM6',
      'COM7',
      'COM8',
      'COM9',
      'LPT1',
      'LPT2',
      'LPT3',
      'LPT4',
      'LPT5',
      'LPT6',
      'LPT7',
      'LPT8',
      'LPT9',
    };

    return reservedNames.contains(name);
  }
}
