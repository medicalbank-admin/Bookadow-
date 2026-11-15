enum ExportWorkflowStage {
  preparing,
  validating,
  generating,
  saving,
  completed,
  failed,
  cancelled,
}

class ExportWorkflowStatus {
  const ExportWorkflowStatus({
    required this.stage,
    required this.progress,
    required this.message,
    this.errorMessage,
    this.filePath,
    this.startedAt,
    this.completedAt,
  });

  final ExportWorkflowStage stage;
  final double progress;
  final String message;
  final String? errorMessage;
  final String? filePath;
  final DateTime? startedAt;
  final DateTime? completedAt;

  bool get isCompleted =>
      stage == ExportWorkflowStage.completed;

  bool get hasFailed =>
      stage == ExportWorkflowStage.failed;

  bool get isCancelled =>
      stage == ExportWorkflowStage.cancelled;

  bool get isFinished =>
      isCompleted || hasFailed || isCancelled;

  bool get isRunning => !isFinished;

  double get safeProgress =>
      progress.clamp(0.0, 1.0).toDouble();

  String get stageLabel {
    switch (stage) {
      case ExportWorkflowStage.preparing:
        return 'Preparing book';
      case ExportWorkflowStage.validating:
        return 'Validating settings';
      case ExportWorkflowStage.generating:
        return 'Generating document';
      case ExportWorkflowStage.saving:
        return 'Saving file';
      case ExportWorkflowStage.completed:
        return 'Completed';
      case ExportWorkflowStage.failed:
        return 'Failed';
      case ExportWorkflowStage.cancelled:
        return 'Cancelled';
    }
  }

  ExportWorkflowStatus copyWith({
    ExportWorkflowStage? stage,
    double? progress,
    String? message,
    String? errorMessage,
    String? filePath,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearError = false,
    bool clearFilePath = false,
  }) {
    return ExportWorkflowStatus(
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      filePath: clearFilePath
          ? null
          : filePath ?? this.filePath,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory ExportWorkflowStatus.initial() {
    return ExportWorkflowStatus(
      stage: ExportWorkflowStage.preparing,
      progress: 0,
      message: 'Preparing your book for export...',
    );
  }

  factory ExportWorkflowStatus.completed({
    required String filePath,
    DateTime? startedAt,
  }) {
    return ExportWorkflowStatus(
      stage: ExportWorkflowStage.completed,
      progress: 1,
      message: 'Your book has been exported successfully.',
      filePath: filePath,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );
  }

  factory ExportWorkflowStatus.failed({
    required String message,
    DateTime? startedAt,
  }) {
    return ExportWorkflowStatus(
      stage: ExportWorkflowStage.failed,
      progress: 0,
      message: 'Book export failed.',
      errorMessage: message,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );
  }
}
