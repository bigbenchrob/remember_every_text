import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../domain/models/message_projection_snapshot.dart';

class ShadowImportMessageProjectionRepository {
  const ShadowImportMessageProjectionRepository({
    required SqfliteImportDatabase importDb,
  }) : _importDb = importDb;

  final SqfliteImportDatabase _importDb;

  Future<MessageProjectionSnapshot> readSnapshot() async {
    final rows = await _importDb.rawQuery(
      'SELECT COALESCE(MAX(id), 0) AS max_message_id, '
      'COUNT(*) AS total_message_count FROM messages;',
    );

    return MessageProjectionSnapshot(
      maxMessageId: _readInt(rows, 'max_message_id'),
      totalMessageCount: _readInt(rows, 'total_message_count'),
    );
  }

  int _readInt(List<Map<String, Object?>> rows, String column) {
    if (rows.isEmpty) {
      throw StateError('Query returned no rows for $column.');
    }

    final value = rows.first[column];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer value for $column, got $value.');
  }
}
