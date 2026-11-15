import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_service.dart';
import '../models/book_model.dart';

class SqliteBookRepository {
  final DatabaseService _databaseService;

  SqliteBookRepository({
    DatabaseService? databaseService,
  }) : _databaseService =
            databaseService ?? DatabaseService.instance;

  Future<Database> get _database =>
      _databaseService.database;

  Future<List<BookModel>> getAllBooks() async {
    final db = await _database;

    final rows = await db.query(
      DatabaseService.booksTable,
      orderBy: 'updatedAt DESC',
    );

    final books = await Future.wait(
      rows.map((row) => _loadBookWithChapters(db, row)),
    );

    return books;
  }

  Future<BookModel?> getBookById(String bookId) async {
    final db = await _database;

    final rows = await db.query(
      DatabaseService.booksTable,
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return _loadBookWithChapters(db, rows.first);
  }

  Future<BookModel> _loadBookWithChapters(
    DatabaseExecutor db,
    Map<String, dynamic> bookRow,
  ) async {
    final chapterRows = await db.query(
      DatabaseService.chaptersTable,
      where: 'bookId = ?',
      whereArgs: [bookRow['id']],
      orderBy: 'chapterOrder ASC',
    );

    final chapters = chapterRows
        .map((row) => ChapterModel.fromMap({
              'id': row['id'],
              'title': row['title'],
              'contentJson': row['contentJson'],
              'order': row['chapterOrder'],
              'createdAt': row['createdAt'],
              'updatedAt': row['updatedAt'],
            }))
        .toList();

    return BookModel.fromMap({
      ...bookRow,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
    });
  }

  Future<void> createBook(BookModel book) async {
    final db = await _database;

    await db.transaction((transaction) async {
      await transaction.insert(
        DatabaseService.booksTable,
        {
          'id': book.id,
          'title': book.title,
          'subtitle': book.subtitle,
          'authorName': book.authorName,
          'description': book.description,
          'languageCode': book.languageCode,
          'createdAt': book.createdAt.toIso8601String(),
          'updatedAt': book.updatedAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      for (final chapter in book.chapters) {
        await _insertChapter(
          transaction,
          book.id,
          chapter,
        );
      }
    });
  }

  Future<void> updateBook(BookModel book) async {
    final db = await _database;

    final updatedRows = await db.update(
      DatabaseService.booksTable,
      {
        'title': book.title,
        'subtitle': book.subtitle,
        'authorName': book.authorName,
        'description': book.description,
        'languageCode': book.languageCode,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [book.id],
    );

    if (updatedRows == 0) {
      throw StateError('Book not found.');
    }
  }

  Future<void> deleteBook(String bookId) async {
    final db = await _database;

    final deletedRows = await db.delete(
      DatabaseService.booksTable,
      where: 'id = ?',
      whereArgs: [bookId],
    );

    if (deletedRows == 0) {
      throw StateError('Book not found.');
    }
  }

  Future<ChapterModel> addChapter({
    required String bookId,
    required String title,
  }) async {
    final db = await _database;

    return db.transaction((transaction) async {
      final books = await transaction.query(
        DatabaseService.booksTable,
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [bookId],
        limit: 1,
      );

      if (books.isEmpty) {
        throw StateError('Book not found.');
      }

      final existingChapters = await transaction.query(
        DatabaseService.chaptersTable,
        columns: ['id'],
        where: 'bookId = ?',
        whereArgs: [bookId],
      );

      final chapter = ChapterModel.create(
        title: title,
        order: existingChapters.length,
      );

      await _insertChapter(
        transaction,
        bookId,
        chapter,
      );

      await _touchBook(transaction, bookId);

      return chapter;
    });
  }

  Future<void> _insertChapter(
    DatabaseExecutor db,
    String bookId,
    ChapterModel chapter,
  ) async {
    await db.insert(
      DatabaseService.chaptersTable,
      {
        'id': chapter.id,
        'bookId': bookId,
        'title': chapter.title,
        'contentJson': chapter.contentJson,
        'chapterOrder': chapter.order,
        'createdAt': chapter.createdAt.toIso8601String(),
        'updatedAt': chapter.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateChapter({
    required String bookId,
    required ChapterModel chapter,
  }) async {
    final db = await _database;

    await db.transaction((transaction) async {
      final updatedRows = await transaction.update(
        DatabaseService.chaptersTable,
        {
          'title': chapter.title,
          'contentJson': chapter.contentJson,
          'chapterOrder': chapter.order,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND bookId = ?',
        whereArgs: [chapter.id, bookId],
      );

      if (updatedRows == 0) {
        throw StateError('Chapter not found.');
      }

      await _touchBook(transaction, bookId);
    });
  }

  Future<void> deleteChapter({
    required String bookId,
    required String chapterId,
  }) async {
    final db = await _database;

    await db.transaction((transaction) async {
      final deletedRows = await transaction.delete(
        DatabaseService.chaptersTable,
        where: 'id = ? AND bookId = ?',
        whereArgs: [chapterId, bookId],
      );

      if (deletedRows == 0) {
        throw StateError('Chapter not found.');
      }

      await _reorderAll(transaction, bookId);
      await _touchBook(transaction, bookId);
    });
  }

  Future<void> reorderChapters({
    required String bookId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final db = await _database;

    await db.transaction((transaction) async {
      final rows = await transaction.query(
        DatabaseService.chaptersTable,
        where: 'bookId = ?',
        whereArgs: [bookId],
        orderBy: 'chapterOrder ASC',
      );

      if (oldIndex < 0 || oldIndex >= rows.length) {
        throw RangeError.index(oldIndex, rows);
      }

      if (newIndex < 0 || newIndex > rows.length) {
        throw RangeError.range(
          newIndex,
          0,
          rows.length,
        );
      }

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final reordered = [...rows];
      final movedChapter = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, movedChapter);

      final batch = transaction.batch();

      for (var index = 0; index < reordered.length; index++) {
        batch.update(
          DatabaseService.chaptersTable,
          {'chapterOrder': index},
          where: 'id = ? AND bookId = ?',
          whereArgs: [
            reordered[index]['id'],
            bookId,
          ],
        );
      }

      await batch.commit(noResult: true);
      await _touchBook(transaction, bookId);
    });
  }

  Future<void> _reorderAll(
    DatabaseExecutor db,
    String bookId,
  ) async {
    final rows = await db.query(
      DatabaseService.chaptersTable,
      columns: ['id'],
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'chapterOrder ASC',
    );

    final batch = db.batch();

    for (var index = 0; index < rows.length; index++) {
      batch.update(
        DatabaseService.chaptersTable,
        {'chapterOrder': index},
        where: 'id = ?',
        whereArgs: [rows[index]['id']],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> _touchBook(
    DatabaseExecutor db,
    String bookId,
  ) async {
    await db.update(
      DatabaseService.booksTable,
      {'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }
}
