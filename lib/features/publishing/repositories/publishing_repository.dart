import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_service.dart';
import '../models/book_cover_model.dart';
import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';

class PublishingRepository {
  PublishingRepository({
    DatabaseService? databaseService,
  }) : _databaseService =
            databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  static const String _tableName = 'publishing_settings';

  Future<void> initialize() async {
    final database = await _databaseService.database;

    await database.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        bookId TEXT PRIMARY KEY,
        layoutJson TEXT NOT NULL,
        coverJson TEXT NOT NULL,
        exportJson TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveSettings({
    required String bookId,
    required BookLayoutModel layout,
    required BookCoverModel cover,
    required BookExportModel export,
  }) async {
    if (bookId.trim().isEmpty) {
      throw ArgumentError('Book ID cannot be empty.');
    }

    await initialize();

    final database = await _databaseService.database;

    final settings = <String, dynamic>{
      'bookId': bookId,
      'layoutJson': jsonEncode(layout.toMap()),
      'coverJson': jsonEncode(cover.toMap()),
      'exportJson': jsonEncode(export.toMap()),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await database.insert(
      _tableName,
      settings,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PublishingSettings?> getSettings(String bookId) async {
    if (bookId.trim().isEmpty) {
      throw ArgumentError('Book ID cannot be empty.');
    }

    await initialize();

    final database = await _databaseService.database;

    final results = await database.query(
      _tableName,
      where: 'bookId = ?',
      whereArgs: [bookId],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;

    return PublishingSettings(
      bookId: row['bookId'] as String,
      layout: BookLayoutModel.fromMap(
        _decodeJson(row['layoutJson']),
      ),
      cover: BookCoverModel.fromMap(
        _decodeJson(row['coverJson']),
      ),
      export: BookExportModel.fromMap(
        _decodeJson(row['exportJson']),
      ),
      updatedAt: DateTime.tryParse(
            row['updatedAt'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Future<bool> hasSettings(String bookId) async {
    final settings = await getSettings(bookId);
    return settings != null;
  }

  Future<void> deleteSettings(String bookId) async {
    if (bookId.trim().isEmpty) {
      throw ArgumentError('Book ID cannot be empty.');
    }

    await initialize();

    final database = await _databaseService.database;

    await database.delete(
      _tableName,
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  Future<List<String>> getSavedBookIds() async {
    await initialize();

    final database = await _databaseService.database;

    final results = await database.query(
      _tableName,
      columns: ['bookId'],
      orderBy: 'updatedAt DESC',
    );

    return results
        .map((row) => row['bookId'] as String)
        .toList();
  }

  Map<String, dynamic> _decodeJson(dynamic value) {
    if (value is! String) {
      throw const FormatException(
        'Publishing settings contain invalid JSON data.',
      );
    }

    final decoded = jsonDecode(value);

    if (decoded is! Map) {
      throw const FormatException(
        'Publishing settings must be a JSON object.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }
}

class PublishingSettings {
  const PublishingSettings({
    required this.bookId,
    required this.layout,
    required this.cover,
    required this.export,
    required this.updatedAt,
  });

  final String bookId;
  final BookLayoutModel layout;
  final BookCoverModel cover;
  final BookExportModel export;
  final DateTime updatedAt;
}
