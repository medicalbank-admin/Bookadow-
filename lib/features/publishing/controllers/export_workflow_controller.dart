import 'package:flutter/foundation.dart';

import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';
import '../models/export_history_model.dart';
import '../models/export_workflow_status.dart';

import '../services/book_export_manager.dart';

class ExportWorkflowController extends ChangeNotifier {
  ExportWorkflowController({
    BookExportManager? exportManager,
  }) : _exportManager = exportManager ?? BookExportManager();

  final BookExportManager _exportManager;

  ExportWorkflowStatus _status =
      ExportWorkflowStatus.initial();

  ExportWorkflowStatus get status => _status;

  bool get isRunning => _status.isRunning;

  bool get isCompleted => _status.isCompleted;

  bool get hasFailed => _status.hasFailed;

  DateTime? _startedAt;

  void _updateStatus(ExportWorkflowStatus value) {
    _status = value;
    notifyListeners();
  }

  Future<ExportHistoryModel?> startExport({
    required String bookId,
    required String bookTitle,
    required String authorName,
    required BookExportModel settings,
    required BookLayoutModel layout,
    required List<ExportChapter> chapters,
    String? subtitle,
    String? description,
    String languageCode = 'en',
  }) async {
    if (isRunning && _startedAt != null) {
      return null;
    }

    _startedAt = DateTime.now();

    _updateStatus(
      ExportWorkflowStatus(
        stage: ExportWorkflowStage.preparing,
        progress: 0.1,
        message: 'Preparing your book...',
        startedAt: _startedAt,
      ),
    );

    try {
      if (chapters.isEmpty) {
        throw ArgumentError(
          'Your book must contain at least one chapter.',
        );
      }

      _updateStatus(
        ExportWorkflowStatus(
          stage: ExportWorkflowStage.validating,
          progress: 0.25,
          message: 'Checking export information...',
          startedAt: _startedAt,
        ),
      );

      _updateStatus(
        ExportWorkflowStatus(
          stage: ExportWorkflowStage.generating,
          progress: 0.45,
          message: 'Generating your document...',
          startedAt: _startedAt,
        ),
      );

      final ExportHistoryModel result =
          await _exportManager.exportBook(
        bookId: bookId,
        bookTitle: bookTitle,
        authorName: authorName,
        settings: settings,
        layout: layout,
        chapters: chapters,
        subtitle: subtitle,
        description: description,
        languageCode: languageCode,
      );

      _updateStatus(
        ExportWorkflowStatus(
          stage: ExportWorkflowStage.saving,
          progress: 0.9,
          message: 'Finalizing exported file...',
          startedAt: _startedAt,
        ),
      );

      _updateStatus(
        ExportWorkflowStatus.completed(
          filePath: result.filePath,
          startedAt: _startedAt,
        ),
      );

      return result;
    } catch (error) {
      _updateStatus(
        ExportWorkflowStatus.failed(
          message: error.toString(),
          startedAt: _startedAt,
        ),
      );

      return null;
    } finally {
      _startedAt = null;
    }
  }

  void reset() {
    _startedAt = null;
    _updateStatus(ExportWorkflowStatus.initial());
  }
}
