import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  static const String _databaseName = 'bookadow.db';
  static const int _databaseVersion = 1;

  static const String booksTable = 'books';
  static const String chaptersTable = 'chapters';

  Future<Database>? _databaseFuture;

  Future<Database> get database async {
    _databaseFuture ??= _initializeDatabase();
    return _databaseFuture!;
  }

  Future<Database> _initializeDatabase() async {
    final databaseDirectory = await getDatabasesPath();

    final databasePath = path.join(
      databaseDirectory,
      _databaseName,
    );

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE $booksTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL DEFAULT '',
        authorName TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        languageCode TEXT NOT NULL DEFAULT 'en',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $chaptersTable (
        id TEXT PRIMARY KEY,
        bookId TEXT NOT NULL,
        title TEXT NOT NULL,
        contentJson TEXT NOT NULL,
        chapterOrder INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,

        FOREIGN KEY (bookId)
          REFERENCES $booksTable (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_chapters_bookId
      ON $chaptersTable (bookId)
    ''');

    await db.execute('''
      CREATE INDEX idx_chapters_order
      ON $chaptersTable (bookId, chapterOrder)
    ''');
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Add database migrations here when the schema changes.
    // Never delete existing user books during an upgrade.
  }

  Future<void> close() async {
    final currentDatabase = _databaseFuture;

    if (currentDatabase == null) return;

    final db = await currentDatabase;

    if (db.isOpen) {
      await db.close();
    }

    _databaseFuture = null;
  }
}
