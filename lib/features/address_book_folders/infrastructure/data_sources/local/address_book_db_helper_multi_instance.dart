import 'package:sqflite/sqflite.dart';

/// Opens one AddressBook SQLite candidate path for viability checks.
///
/// AddressBook folder discovery probes multiple candidate database paths, so
/// this helper intentionally avoids singleton database ownership.
class AddressBookDbHelperMultiInstance {
  final String _path;
  Database? _db;
  AddressBookDbHelperMultiInstance(this._path);

  Future<Database> get _database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<void> verifyReadable() async {
    await _database;
  }

  Future<List<Map<String, Object?>>> readRows(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    _assertReadSql(sql);
    final db = await _database;
    return db.rawQuery(sql, arguments);
  }

  Future<Database> _initDatabase() async {
    Database db;
    try {
      db = await openReadOnlyDatabase(_path);
      await db.execute('PRAGMA query_only = ON');
      await db.execute('PRAGMA busy_timeout = 3000');
    } catch (error) {
      throw StateError(
        "AddressBook database couldn't be opened at path '$_path': $error",
      );
    }
    return db;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  static void _assertReadSql(String sql) {
    final normalized = sql.trimLeft().toLowerCase();
    if (normalized.startsWith('select ') ||
        normalized.startsWith('select\n') ||
        normalized.startsWith('pragma ') ||
        normalized.startsWith('pragma\n') ||
        normalized.startsWith('with ') ||
        normalized.startsWith('with\n')) {
      return;
    }

    throw StateError('AddressBook readRows only accepts read queries');
  }
}
