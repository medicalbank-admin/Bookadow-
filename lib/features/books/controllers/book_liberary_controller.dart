import 'package:flutter/foundation.dart';

import '../models/book_model.dart';
import '../repositories/book_repository.dart';

class BookLibraryController extends ChangeNotifier {
  final BookRepository _repository;

  BookLibraryController({
    BookRepository? repository,
  }) : _repository = repository ?? BookRepository();

  List<BookModel> get books => _repository.getAllBooks();

  int get totalBooks => books.length;

  int get totalChapters {
    return books.fold<int>(
      0,
      (total, book) => total + book.chapterCount,
    );
  }

  int get totalWords {
    return books.fold<int>(
      0,
      (total, book) => total + book.wordCount,
    );
  }

  BookModel? getBook(String bookId) {
    return _repository.getBookById(bookId);
  }

  void createBook({
    required String title,
    String authorName = '',
    String languageCode = 'en',
  }) {
    final cleanedTitle = title.trim();

    if (cleanedTitle.isEmpty) {
      throw ArgumentError('Book title cannot be empty.');
    }

    final book = BookModel.create(
      title: cleanedTitle,
      authorName: authorName.trim(),
      languageCode: languageCode,
    );

    _repository.createBook(book);
    notifyListeners();
  }

  void updateBook(BookModel book) {
    if (book.title.trim().isEmpty) {
      throw ArgumentError('Book title cannot be empty.');
    }

    _repository.updateBook(
      book.copyWith(title: book.title.trim()),
    );

    notifyListeners();
  }

  void deleteBook(String bookId) {
    _repository.deleteBook(bookId);
    notifyListeners();
  }

  ChapterModel addChapter({
    required String bookId,
    required String title,
  }) {
    final cleanedTitle = title.trim();

    if (cleanedTitle.isEmpty) {
      throw ArgumentError('Chapter title cannot be empty.');
    }

    final chapter = _repository.addChapter(
      bookId: bookId,
      title: cleanedTitle,
    );

    notifyListeners();

    return chapter;
  }

  void updateChapter({
    required String bookId,
    required ChapterModel chapter,
  }) {
    if (chapter.title.trim().isEmpty) {
      throw ArgumentError('Chapter title cannot be empty.');
    }

    _repository.updateChapter(
      bookId: bookId,
      chapter: chapter.copyWith(
        title: chapter.title.trim(),
      ),
    );

    notifyListeners();
  }

  void deleteChapter({
    required String bookId,
    required String chapterId,
  }) {
    _repository.deleteChapter(
      bookId: bookId,
      chapterId: chapterId,
    );

    notifyListeners();
  }

  void reorderChapters({
    required String bookId,
    required int oldIndex,
    required int newIndex,
  }) {
    _repository.reorderChapters(
      bookId: bookId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    notifyListeners();
  }
}
