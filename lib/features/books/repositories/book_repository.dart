import '../models/book_model.dart';

class BookRepository {
  final List<BookModel> _books = [];

  List<BookModel> getAllBooks() {
    return List.unmodifiable(_books);
  }

  BookModel? getBookById(String bookId) {
    for (final book in _books) {
      if (book.id == bookId) {
        return book;
      }
    }

    return null;
  }

  void createBook(BookModel book) {
    if (_books.any((existing) => existing.id == book.id)) {
      throw StateError('A book with this ID already exists.');
    }

    _books.add(book);
  }

  void updateBook(BookModel updatedBook) {
    final index = _books.indexWhere(
      (book) => book.id == updatedBook.id,
    );

    if (index == -1) {
      throw StateError('Book not found.');
    }

    _books[index] = updatedBook;
  }

  void deleteBook(String bookId) {
    _books.removeWhere((book) => book.id == bookId);
  }

  ChapterModel addChapter({
    required String bookId,
    required String title,
  }) {
    final book = getBookById(bookId);

    if (book == null) {
      throw StateError('Book not found.');
    }

    final chapter = ChapterModel.create(
      title: title,
      order: book.chapters.length,
    );

    final updatedBook = book.copyWith(
      chapters: [...book.chapters, chapter],
    );

    updateBook(updatedBook);

    return chapter;
  }

  void updateChapter({
    required String bookId,
    required ChapterModel chapter,
  }) {
    final book = getBookById(bookId);

    if (book == null) {
      throw StateError('Book not found.');
    }

    final index = book.chapters.indexWhere(
      (item) => item.id == chapter.id,
    );

    if (index == -1) {
      throw StateError('Chapter not found.');
    }

    final chapters = [...book.chapters];
    chapters[index] = chapter;

    updateBook(
      book.copyWith(chapters: chapters),
    );
  }

  void deleteChapter({
    required String bookId,
    required String chapterId,
  }) {
    final book = getBookById(bookId);

    if (book == null) {
      throw StateError('Book not found.');
    }

    final chapters = book.chapters
        .where((chapter) => chapter.id != chapterId)
        .toList();

    final reorderedChapters = [
      for (var index = 0; index < chapters.length; index++)
        chapters[index].copyWith(order: index),
    ];

    updateBook(
      book.copyWith(chapters: reorderedChapters),
    );
  }

  void reorderChapters({
    required String bookId,
    required int oldIndex,
    required int newIndex,
  }) {
    final book = getBookById(bookId);

    if (book == null) {
      throw StateError('Book not found.');
    }

    final chapters = [...book.chapters];

    if (oldIndex < 0 || oldIndex >= chapters.length) {
      throw RangeError.index(oldIndex, chapters);
    }

    if (newIndex < 0 || newIndex > chapters.length) {
      throw RangeError.range(
        newIndex,
        0,
        chapters.length,
      );
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final chapter = chapters.removeAt(oldIndex);
    chapters.insert(newIndex, chapter);

    final reorderedChapters = [
      for (var index = 0; index < chapters.length; index++)
        chapters[index].copyWith(order: index),
    ];

    updateBook(
      book.copyWith(chapters: reorderedChapters),
    );
  }
}
