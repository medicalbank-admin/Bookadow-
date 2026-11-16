import 'package:flutter/foundation.dart';

import '../models/book_cover_model.dart';
import '../models/book_layout_model.dart';
import '../services/book_export_manager.dart';
import '../services/publishing_preflight_report_builder.dart';

class PublishingPreflightController extends ChangeNotifier {
  final PublishingPreflightReportBuilder _reportBuilder;

  PublishingPreflightController({
    PublishingPreflightReportBuilder? reportBuilder,
  }) : _reportBuilder =
            reportBuilder ?? PublishingPreflightReportBuilder();

  PublishingPreflightReport? _report;
  bool _isChecking = false;
  String? _errorMessage;

  PublishingPreflightReport? get report => _report;

  bool get isChecking => _isChecking;

  String? get errorMessage => _errorMessage;

  bool get hasReport => _report != null;

  bool get isReady => _report?.isReady ?? false;

  Future<PublishingPreflightReport?> runChecks({
    required String bookTitle,
    required String authorName,
    required String fileName,
    required List<ExportChapter> chapters,
    required BookLayoutModel layout,
    required BookCoverModel cover,
  }) async {
    if (_isChecking) {
      return null;
    }

    _isChecking = true;
    _errorMessage = null;
    _report = null;
    notifyListeners();

    try {
      final result = _reportBuilder.buildReport(
        bookTitle: bookTitle,
        authorName: authorName,
        fileName: fileName,
        chapters: chapters,
        layout: layout,
        cover: cover,
      );

      _report = result;
      return result;
    } catch (error) {
      _errorMessage = 'Unable to complete publishing checks: $error';
      return null;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void clearReport() {
    _report = null;
    _errorMessage = null;
    notifyListeners();
  }
}
