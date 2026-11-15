
import 'dart:convert';

class QuillContentConverter {
  const QuillContentConverter();

  /// Converts Quill Delta JSON into readable plain text.
  String toPlainText(String contentJson) {
    if (contentJson.trim().isEmpty) {
      return '';
    }

    try {
      final dynamic decoded = jsonDecode(contentJson);

      if (decoded is! List) {
        return contentJson;
      }

      final StringBuffer result = StringBuffer();

      for (final dynamic operation in decoded) {
        if (operation is! Map<String, dynamic>) {
          continue;
        }

        final dynamic insert = operation['insert'];

        if (insert is String) {
          result.write(insert);
        } else if (insert is Map) {
          result.write(_convertEmbed(insert));
        }
      }

      return _cleanText(result.toString());
    } on FormatException {
      return contentJson;
    } catch (_) {
      return contentJson;
    }
  }

  /// Converts multiple chapter contents into export-ready chapters.
  List<ConvertedChapter> convertChapters(
    List<ChapterContentInput> chapters,
  ) {
    return chapters.map((chapter) {
      return ConvertedChapter(
        title: chapter.title,
        text: toPlainText(chapter.contentJson),
      );
    }).toList();
  }

  String _convertEmbed(Map<dynamic, dynamic> embed) {
    if (embed.containsKey('image')) {
      return '\n[Image]\n';
    }

    if (embed.containsKey('video')) {
      return '\n[Video]\n';
    }

    return '';
  }

  String _cleanText(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class ChapterContentInput {
  const ChapterContentInput({
    required this.title,
    required this.contentJson,
  });

  final String title;
  final String contentJson;
}

class ConvertedChapter {
  const ConvertedChapter({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;
}
