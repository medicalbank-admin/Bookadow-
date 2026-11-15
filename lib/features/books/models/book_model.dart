class BookModel {
  final String id;
  final String title;
  final String subtitle;
  final String authorName;
  final String description;
  final String languageCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChapterModel> chapters;

  const BookModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.authorName = '',
    this.description = '',
    this.languageCode = 'en',
    required this.createdAt,
    required this.updatedAt,
    this.chapters = const [],
  });

  factory BookModel.create({
    required String title,
    String authorName = '',
    String languageCode = 'en',
  }) {
    final now = DateTime.now();

    return BookModel(
      id: 'book_${now.microsecondsSinceEpoch}',
      title: title,
      authorName: authorName,
      languageCode: languageCode,
      createdAt: now,
      updatedAt: now,
    );
  }

  int get chapterCount => chapters.length;

  int get wordCount {
    return chapters.fold<int>(
      0,
      (total, chapter) => total + chapter.wordCount,
    );
  }

  BookModel copyWith({
    String? title,
    String? subtitle,
    String? authorName,
    String? description,
    String? languageCode,
    DateTime? updatedAt,
    List<ChapterModel>? chapters,
  }) {
    return BookModel(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      authorName: authorName ?? this.authorName,
      description: description ?? this.description,
      languageCode: languageCode ?? this.languageCode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      chapters: chapters ?? this.chapters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'authorName': authorName,
      'description': description,
      'languageCode': languageCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    final rawChapters = map['chapters'] as List<dynamic>? ?? [];

    return BookModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled Book',
      subtitle: map['subtitle'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      languageCode: map['languageCode'] as String? ?? 'en',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      chapters: rawChapters
          .map(
            (chapter) => ChapterModel.fromMap(
              Map<String, dynamic>.from(chapter as Map),
            ),
          )
          .toList(),
    );
  }
}

class ChapterModel {
  static const String emptyContent = '[{"insert":"\\n"}]';

  final String id;
  final String title;
  final String contentJson;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChapterModel({
    required this.id,
    required this.title,
    this.contentJson = emptyContent,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterModel.create({
    required String title,
    required int order,
  }) {
    final now = DateTime.now();

    return ChapterModel(
      id: 'chapter_${now.microsecondsSinceEpoch}',
      title: title,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  int get wordCount {
    final plainText = contentJson
        .replaceAll(RegExp(r'"insert"\s*:\s*"'), '')
        .replaceAll(RegExp(r'\\n|\\t'), ' ')
        .replaceAll(RegExp(r'["{}\[\]]'), ' ')
        .trim();

    if (plainText.isEmpty) return 0;

    return plainText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  ChapterModel copyWith({
    String? title,
    String? contentJson,
    int? order,
    DateTime? updatedAt,
  }) {
    return ChapterModel(
      id: id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      order: order ?? this.order,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'contentJson': contentJson,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled Chapter',
      contentJson: map['contentJson'] as String? ?? emptyContent,
      order: map['order'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
