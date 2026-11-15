
import 'dart:async';

/// Handles delayed automatic saving for the BOOKADOW editor.
///
/// Each new edit resets the countdown. When the user stops editing
/// for the configured duration, the save callback is triggered.
class EditorAutosaveService {
  EditorAutosaveService({
    required Future<void> Function() onSave,
    this.delay = const Duration(seconds: 2),
    void Function(Object error)? onError,
  })  : _onSave = onSave,
        _onError = onError;

  final Future<void> Function() _onSave;
  final Duration delay;
  final void Function(Object error)? _onError;

  Timer? _timer;

  bool _isDisposed = false;
  bool _isSaving = false;
  bool _saveRequestedAgain = false;

  /// Returns whether a save operation is currently running.
  bool get isSaving => _isSaving;

  /// Returns whether a delayed save is waiting to run.
  bool get hasPendingSave => _timer?.isActive ?? false;

  /// Schedules a save after the user stops editing.
  void schedule() {
    if (_isDisposed) return;

    _timer?.cancel();

    _timer = Timer(delay, () {
      _timer = null;
      _runSave();
    });
  }

  /// Cancels any pending automatic save.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _saveRequestedAgain = false;
  }

  /// Immediately triggers a save instead of waiting for the timer.
  Future<void> saveNow() async {
    if (_isDisposed) return;

    _timer?.cancel();
    _timer = null;

    await _runSave();
  }

  Future<void> _runSave() async {
    if (_isDisposed) return;

    if (_isSaving) {
      _saveRequestedAgain = true;
      return;
    }

    _isSaving = true;

    try {
      do {
        _saveRequestedAgain = false;

        try {
          await _onSave();
        } catch (error) {
          _onError?.call(error);
        }
      } while (_saveRequestedAgain && !_isDisposed);
    } finally {
      _isSaving = false;
    }
  }

  /// Releases the timer and prevents future saves.
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    _saveRequestedAgain = false;
  }
}
