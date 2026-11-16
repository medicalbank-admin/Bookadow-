import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_service.dart';
import '../models/book_metadata_model.dart';

class BookMetadataRepository {
  static const String _tableName = 'book_metadata';

  Future<Database> get _database async {
    return DatabaseService.instance.database;
  }

  Future<void> initialize() async {
    final db = await _database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        bookId TEXT PRIMARY KEY,
        isbn TEXT NOT NULL DEFAULT '',
        title TEXT NOT NULL DEFAULT '',
        subtitle TEXT NOT NULL DEFAULT '',
        author TEXT NOT NULL DEFAULT '',
        contributors TEXT NOT NULL DEFAULT '',
        publisher TEXT NOT NULL DEFAULT '',
        publicationDate TEXT NOT NULL DEFAULT '',
        edition TEXT NOT NULL DEFAULT 'First Edition',
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
        FOREIGN KEY (bookId) REFERENCES books(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_book_metadata_isbn
      ON $_tableName(isbn)
    ''');
  }

  Future<void> save(BookMetadataModel metadata) async {
    final db = await _database;

    await db.insert(
      _tableName,
      metadata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BookMetadataModel?> getByBookId(String bookId) async {
    final db = await _database;

    final results = await db.query(
      _tableName,
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
      _tableName,
      orderBy: 'updatedAt DESC',
    );

    return results
        .map(BookMetadataModel.fromMap)
        .toList(growable: false);
  }

  Future<bool> exists(String bookId) async {
    final db = await _database;

    final results = await db.rawQuery(
      'SELECT 1 FROM $_tableName WHERE bookId = ? LIMIT 1',
      [bookId],
    );

    return results.isNotEmpty;
  }

  Future<void> delete(String bookId) async {
    final db = await _database;

    await db.delete(
      _tableName,
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  Future<int> count() async {
    final db = await _database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $_tableName',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
