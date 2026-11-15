
import 'dart:io';

import 'package:open_filex/open_filex.dart';

class ExportFileOpenService {
  const ExportFileOpenService();

  Future<ExportOpenResult> openFile(String filePath) async {
    if (filePath.trim().isEmpty) {
      return const ExportOpenResult(
        isSuccessful: false,
        message: 'File path is empty.',
      );
    }

    final File file = File(filePath);

    try {
      if (!await file.exists()) {
        return const ExportOpenResult(
          isSuccessful: false,
          message: 'Exported file could not be found.',
        );
      }

      final result = await OpenFilex.open(filePath);

      if (result.type == ResultType.done) {
        return const ExportOpenResult(
          isSuccessful: true,
          message: 'File opened successfully.',
        );
      }

      return ExportOpenResult(
        isSuccessful: false,
        message: result.message.isNotEmpty
            ? result.message
            : 'No compatible application could open this file.',
      );
    } on FileSystemException catch (error) {
      return ExportOpenResult(
        isSuccessful: false,
        message: 'Unable to access file: ${error.message}',
      );
    } catch (error) {
      return ExportOpenResult(
        isSuccessful: false,
        message: 'Unable to open file: $error',
      );
    }
  }
}

class ExportOpenResult {
  const ExportOpenResult({
    required this.isSuccessful,
    required this.message,
  });

  final bool isSuccessful;
  final String message;
}
