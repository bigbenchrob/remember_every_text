import 'package:drift/native.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';

export 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';

Future<ConversationGraphDatabase> openConversationGraphTestDatabase() async {
  final database = ConversationGraphDatabase(NativeDatabase.memory());
  await database.customSelect('SELECT 1').get();
  return database;
}

extension ConversationGraphTestDatabaseCompat on ConversationGraphDatabase {
  ConversationGraphTestTableApi get database =>
      ConversationGraphTestTableApi(this);
}

class ConversationGraphTestTableApi {
  const ConversationGraphTestTableApi(this._database);

  final ConversationGraphDatabase _database;

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    Object? conflictAlgorithm,
  }) async {
    final columns = values.keys.toList(growable: false);
    final placeholders = List.filled(columns.length, '?').join(', ');
    final conflictClause = conflictAlgorithm == null ? '' : 'OR IGNORE ';
    return _database.executeAndReadChanges(
      '''
      INSERT $conflictClause INTO $table (
        ${columns.join(', ')}
      ) VALUES ($placeholders)
      ''',
      [for (final column in columns) values[column]],
    );
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) {
    final projection = columns == null ? '*' : columns.join(', ');
    final buffer = StringBuffer('SELECT $projection FROM $table');
    if (where != null && where.isNotEmpty) {
      buffer.write(' WHERE $where');
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      buffer.write(' ORDER BY $orderBy');
    }
    return _database.selectRows(buffer.toString(), whereArgs ?? const []);
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?> args = const <Object?>[],
  ]) {
    return _database.selectRows(sql, args);
  }
}
