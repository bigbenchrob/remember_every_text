import 'package:drift/drift.dart';

import '../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../domain/models/message_projection_snapshot.dart';

class ShadowWorkingMessageProjectionRepository {
  const ShadowWorkingMessageProjectionRepository({
    required WorkingDatabase workingDb,
  }) : _workingDb = workingDb;

  final WorkingDatabase _workingDb;

  Future<MessageProjectionSnapshot> readSnapshot() async {
    final rows = await _workingDb
        .customSelect(
          'SELECT COALESCE(MAX(id), 0) AS max_message_id, '
          'COUNT(*) AS total_message_count FROM messages;',
        )
        .get();

    return MessageProjectionSnapshot(
      maxMessageId: _readInt(rows, 'max_message_id'),
      totalMessageCount: _readInt(rows, 'total_message_count'),
    );
  }

  int _readInt(List<QueryRow> rows, String column) {
    if (rows.isEmpty) {
      throw StateError('Query returned no rows for $column.');
    }

    final value = rows.first.data[column];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer value for $column, got $value.');
  }
}
