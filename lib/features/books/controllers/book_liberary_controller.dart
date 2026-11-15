
import 'package:flutter/foundation.dart';

import '../models/book_model.dart';
import '../repositories/sqlite_book_repository.dart';

class BookLibraryController extends ChangeNotifier {
  BookLibraryController({
    SqliteBookRepository? repository,
  }) : _repository = repository ?? SqliteBookRepository();

  final SqliteBookRepository _repository;

  List<BookModel> _books = [];

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  List<BookModel> get books => List.unmodifiable(_books);

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  int get totalBooks => _books.length;

  int get totalChapters {
    return _books.fold<int>(
      0,
      (total, book) => total + book.chapterCount,
    );
  }

  int get totalWords {
    return _books.fold<int>(
      0,
      (total, book) => total + book.wordCount,
    );
  }

  /// Loads books from the local SQLite database.
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _repository.getAllBooks();
      _isInitialized = true;
    } catch (error) {
      _errorMessage = 'Unable to load your books: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the local book collection.
  Future<void> refresh() async {
    _errorMessage = null;

    try {
      _books = await _repository.getAllBooks();
      _isInitialized = true;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Unable to refresh your library: $error';
      notifyListeners();
      rethrow;
    }
  }

  BookModel? getBook(String bookId) {
    try {
      return _books.firstWhere(
        (book) => book.id == bookId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Creates and saves a new book.
  Future<BookModel> createBook({
    required String title,
    String authorName = '',
    String languageCode = 'en',
  }) async {
    final book = BookModel.create(
      title: title,
      authorName: authorName,
      languageCode: languageCode,
    );

    await _repository.createBook(book);

    _books = [book, ..._books];
    notifyListeners();

    return book;
  }

  /// Updates book information.
  Future<void> updateBook(BookModel updatedBook) async {
    await _repository.updateBook(updatedBook);

    final index = _books.indexWhere(
      (book) => book.id == updatedBook.id,
    );

    if (index == -1) return;

    _books[index] = updatedBook;
    notifyListeners();
  }

  /// Deletes a book and its chapters.
  Future<void> deleteBook(String bookId) async {
    await _repository.deleteBook(bookId);

    _books.removeWhere(
      (book) => book.id == bookId,
    );

    notifyListeners();
  }

  /// Adds a chapter to a book.
  Future<ChapterModel> addChapter({
    required String bookId,
    required String title,
  }) async {
    final chapter = await _repository.addChapter(
      bookId: bookId,
      title: title,
    );

    final index = _books.indexWhere(
      (book) => book.id == bookId,
    );

    if (index != -1) {
      final book = _books[index];

      _books[index] = book.copyWith(
        chapters: [...book.chapters, chapter],
      );

      notifyListeners();
    }

    return chapter;
  }

  /// Saves chapter content and metadata.
  Future<void> updateChapter({
    required String bookId,
    required ChapterModel chapter,
  }) async {
    await _repository.updateChapter(
      bookId: bookId,
      chapter: chapter,
    );

    final bookIndex = _books.indexWhere(
      (book) => book.id == bookId,
    );

    if (bookIndex == -1) return;

    final book = _books[bookIndex];

    final chapters = book.chapters.map((item) {
      return item.id == chapter.id ? chapter : item;
    }).toList();

    _books[bookIndex] = book.copyWith(
      chapters: chapters,
    );

    notifyListeners();
  }

  /// Deletes a chapter.
  Future<void> deleteChapter({
    required String bookId,
    required String chapterId,
  }) async {
    await _repository.deleteChapter(
      bookId: bookId,
      chapterId: chapterId,
    );

    final bookIndex = _books.indexWhere(
      (book) => book.id == bookId,
    );

    if (bookIndex == -1) return;

    final book = _books[bookIndex];

    final remainingChapters = book.chapters
        .where((chapter) => chapter.id != chapterId)
        .toList();

    final reorderedChapters = <ChapterModel>[];

    for (var i = 0; i < remainingChapters.length; i++) {
      reorderedChapters.add(
        remainingChapters[i].copyWith(order: i),
      );
    }

    _books[bookIndex] = book.copyWith(
      chapters: reorderedChapters,
    );

    notifyListeners();
  }

  /// Changes the order of chapters.
  Future<void> reorderChapters({
    required String bookId,
    required int oldIndex,
    required int newIndex,
  }) async {
    await _repository.reorderChapters(
      bookId: bookId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    final bookIndex = _books.indexWhere(
      (book) => book.id == bookId,
    );

    if (bookIndex == -1) return;

    final book = _books[bookIndex];
    final chapters = [...book.chapters];

    if (oldIndex < 0 || oldIndex >= chapters.length) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    if (newIndex < 0 || newIndex >= chapters.length) return;

    final chapter = chapters.removeAt(oldIndex);
    chapters.insert(newIndex, chapter);

    final reorderedChapters = <ChapterModel>[];

    for (var i = 0; i < chapters.length; i++) {
      reorderedChapters.add(
        chapters[i].copyWith(order: i),
      );
    }

    _books[bookIndex] = book.copyWith(
      chapters: reorderedChapters,
    );

    notifyListeners();
  }
}
