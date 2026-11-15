import '../../books/models/book_model.dart';
import 'book_export_manager.dart';
import 'quill_content_converter.dart';

class BookExportDataBuilder {
  const BookExportDataBuilder();

  final QuillContentConverter _converter =
      const QuillContentConverter();

  BookExportData build(BookModel book) {
    final List<ConvertedChapter> convertedChapters =
        _converter.convertChapters(
      book.chapters.map((chapter) {
        return ChapterContentInput(
          title: chapter.title,
          contentJson: chapter.contentJson,
        );
      }).toList(),
    );

    return BookExportData(
      bookId: book.id,
      title: book.title,
      authorName: book.authorName,
      subtitle: book.subtitle,
      description: book.description,
      languageCode: book.languageCode,
      chapters: convertedChapters.map((chapter) {
        return ExportChapter(
          title: chapter.title,
          text: chapter.text,
        );
      }).toList(),
    );
  }
}

class BookExportData {
  const BookExportData({
    required this.bookId,
    required this.title,
    required this.authorName,
    required this.subtitle,
    required this.description,
    required this.languageCode,
    required this.chapters,
  });

  final String bookId;
  final String title;
  final String authorName;
  final String? subtitle;
  final String description;
  final String languageCode;
  final List<ExportChapter> chapters;
}
