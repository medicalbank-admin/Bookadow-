
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_service.dart';
import '../models/book_metadata_model.dart';

class BookMetadataRepository {
  final DatabaseService _databaseService;

  BookMetadataRepository({
    DatabaseService? databaseService,
  }) : _databaseService =
            databaseService ?? DatabaseService.instance;

  Future<Database> get _database async {
    return _databaseService.database;
  }

  Future<void> initialize() async {
    final db = await _database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS book_metadata (
        bookId TEXT PRIMARY KEY,
        isbn TEXT NOT NULL DEFAULT '',
        title TEXT NOT NULL DEFAULT '',
        subtitle TEXT NOT NULL DEFAULT '',
        author TEXT NOT NULL DEFAULT '',
        contributors TEXT NOT NULL DEFAULT '',
        publisher TEXT NOT NULL DEFAULT '',
        publicationDate TEXT NOT NULL DEFAULT '',
        edition TEXT NOT NULL DEFAULT '',
        language TEXT NOT NULL DEFAULT 'en',
        description TEXT NOT NULL DEFAULT '',
        keywords TEXT NOT NULL DEFAULT '',
        categories TEXT NOT NULL DEFAULT '',
        copyright TEXT NOT NULL DEFAULT '',
        website TEXT NOT NULL DEFAULT '',
        seriesName TEXT NOT NULL DEFAULT '',
        seriesNumber TEXT NOT NULL DEFAULT '',
        countryOfPublication TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (bookId)
          REFERENCES books (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_book_metadata_isbn
      ON book_metadata (isbn)
    ''');
  }

  Future<void> save(BookMetadataModel metadata) async {
    final db = await _database;

    await db.insert(
      'book_metadata',
      metadata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BookMetadataModel?> getByBookId(
    String bookId,
  ) async {
    final db = await _database;

    final results = await db.query(
      'book_metadata',
      where: 'bookId = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return BookMetadataModel.fromMap(results.first);
  }

  Future<List<BookMetadataModel>> getAll() async {
    final db = await _database;

    final results = await db.query(
      'book_metadata',
      orderBy: 'updatedAt DESC',
    );

    return results
        .map(BookMetadataModel.fromMap)
        .toList();
  }

  Future<bool> exists(String bookId) async {
    final db = await _database;

    final results = await db.query(
      'book_metadata',
      columns: ['bookId'],
      where: 'bookId = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  Future<int> delete(String bookId) async {
    final db = await _database;

    return db.delete(
      'book_metadata',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  Future<int> count() async {
    final db = await _database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM book_metadata',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
