import 'package:sqflite/sqflite.dart';

import '../../../db/application/read_only_sql_guard.dart';
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
    assertReadOnlySql(sql, boundary: 'Read-only source database rawQuery');
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
}
