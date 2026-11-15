
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_service.dart';
import '../models/export_history_model.dart';

class ExportHistoryRepository {
  static const String _tableName = 'export_history';

  Future<Database> get _database async {
    return DatabaseService.instance.database;
  }

  Future<void> initialize() async {
    final db = await _database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        format TEXT NOT NULL,
        fileSizeBytes INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        isSuccessful INTEGER NOT NULL DEFAULT 1,
        errorMessage TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_export_history_book
      ON $_tableName (bookId)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_export_history_date
      ON $_tableName (createdAt)
    ''');
  }

  Future<void> saveExport(ExportHistoryModel record) async {
    final db = await _database;

    await db.insert(
      _tableName,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExportHistoryModel>> getAllExports({
    int limit = 100,
  }) async {
    final db = await _database;

    final rows = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
      limit: limit.clamp(1, 1000),
    );

    return rows
        .map(ExportHistoryModel.fromMap)
        .toList();
  }

  Future<List<ExportHistoryModel>> getExportsForBook(
    String bookId, {
    int limit = 100,
  }) async {
    final db = await _database;

    final rows = await db.query(
      _tableName,
      where: 'bookId = ?',
      whereArgs: [bookId],
      orderBy: 'createdAt DESC',
      limit: limit.clamp(1, 1000),
    );

    return rows
        .map(ExportHistoryModel.fromMap)
        .toList();
  }

  Future<ExportHistoryModel?> getExportById(String id) async {
    final db = await _database;

    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return ExportHistoryModel.fromMap(rows.first);
  }

  Future<void> deleteExport(String id) async {
    final db = await _database;

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteExportsForBook(String bookId) async {
    final db = await _database;

    await db.delete(
      _tableName,
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> clearHistory() async {
    final db = await _database;
    await db.delete(_tableName);
  }

  Future<int> getExportCount() async {
    final db = await _database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $_tableName',
    );

    return (result.first['total'] as int?) ?? 0;
  }
}
