import 'package:sqflite/sqflite.dart';

import '../../domain/ports/source_database_port.dart';

final class SqfliteSourceDatabaseOpener implements SourceDatabaseOpener {
  const SqfliteSourceDatabaseOpener();

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    final database = await openDatabase(
      databasePath,
      readOnly: true,
      singleInstance: false,
    );
    await database.execute('PRAGMA query_only = ON');
    await database.execute('PRAGMA busy_timeout = 3000');
    return _SqfliteReadOnlySourceDatabase(database);
  }
}

final class _SqfliteReadOnlySourceDatabase implements ReadOnlySourceDatabase {
  const _SqfliteReadOnlySourceDatabase(this._database);

  final Database _database;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    _assertReadSql(sql);
    return _database.rawQuery(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    return _database.query(table, orderBy: orderBy);
  }

  @override
  Future<void> close() {
    return _database.close();
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

    throw StateError('Read-only source database rawQuery only accepts reads');
  }
}
