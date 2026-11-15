
import 'package:flutter/foundation.dart';

import '../models/export_history_model.dart';
import '../repositories/export_history_repository.dart';

class ExportHistoryController extends ChangeNotifier {
  ExportHistoryController({
    ExportHistoryRepository? repository,
  }) : _repository =
            repository ?? ExportHistoryRepository();

  final ExportHistoryRepository _repository;

  List<ExportHistoryModel> _exports = [];

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  List<ExportHistoryModel> get exports =>
      List.unmodifiable(_exports);

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  int get exportCount => _exports.length;

  int get successfulExports =>
      _exports.where((item) => item.isSuccessful).length;

  int get failedExports =>
      _exports.where((item) => !item.isSuccessful).length;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.initialize();
      await refresh();

      _isInitialized = true;
    } catch (error) {
      _errorMessage = 'Unable to load export history: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      _errorMessage = null;
      _exports = await _repository.getAllExports();
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Unable to refresh export history: $error';
      notifyListeners();
    }
  }

  Future<void> loadExportsForBook(String bookId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exports = await _repository.getExportsForBook(bookId);
    } catch (error) {
      _errorMessage = 'Unable to load book exports: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExport(ExportHistoryModel record) async {
    try {
      _errorMessage = null;

      await _repository.saveExport(record);
      await refresh();
    } catch (error) {
      _errorMessage = 'Unable to save export record: $error';
      notifyListeners();
    }
  }

  Future<void> deleteExport(String id) async {
    try {
      _errorMessage = null;

      await _repository.deleteExport(id);
      _exports.removeWhere((item) => item.id == id);

      notifyListeners();
    } catch (error) {
      _errorMessage = 'Unable to delete export record: $error';
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      _errorMessage = null;

      await _repository.clearHistory();
      _exports = [];

      notifyListeners();
    } catch (error) {
      _errorMessage = 'Unable to clear export history: $error';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
