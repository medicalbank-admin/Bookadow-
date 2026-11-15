
class ExportHistoryModel {
  const ExportHistoryModel({
    required this.id,
    required this.bookId,
    required this.fileName,
    required this.filePath,
    required this.format,
    required this.fileSizeBytes,
    required this.createdAt,
    this.isSuccessful = true,
    this.errorMessage,
  });

  final String id;
  final String bookId;
  final String fileName;
  final String filePath;
  final String format;
  final int fileSizeBytes;
  final DateTime createdAt;
  final bool isSuccessful;
  final String? errorMessage;

  String get formattedFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    }

    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }

    if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  ExportHistoryModel copyWith({
    String? id,
    String? bookId,
    String? fileName,
    String? filePath,
    String? format,
    int? fileSizeBytes,
    DateTime? createdAt,
    bool? isSuccessful,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ExportHistoryModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'fileName': fileName,
      'filePath': filePath,
      'format': format,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'isSuccessful': isSuccessful ? 1 : 0,
      'errorMessage': errorMessage,
    };
  }

  factory ExportHistoryModel.fromMap(Map<String, dynamic> map) {
    return ExportHistoryModel(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      fileName: map['fileName'] as String,
      filePath: map['filePath'] as String,
      format: map['format'] as String,
      fileSizeBytes: (map['fileSizeBytes'] as num).toInt(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSuccessful: (map['isSuccessful'] as num).toInt() == 1,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
