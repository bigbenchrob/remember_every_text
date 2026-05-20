import 'package:sqflite/sqflite.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class ChatToHandleProjectionResult {
  const ChatToHandleProjectionResult({
    required this.examinedEdgeCount,
    required this.insertedEdgeCount,
  });

  final int examinedEdgeCount;
  final int insertedEdgeCount;
}

class ChatToHandleProjector {
  const ChatToHandleProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<ChatToHandleProjectionResult> projectEdges() async {
    final rows = await importDatabase.database.query(
      'chat_to_handle',
      columns: <String>['chat_ss_id', 'handle_ss_id'],
      orderBy: 'chat_ss_id ASC, handle_ss_id ASC',
    );

    var insertedEdgeCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final insertedId = await txn.insert(
          'chat_to_handle',
          row,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (insertedId != 0) {
          insertedEdgeCount += 1;
        }
      }
    });

    return ChatToHandleProjectionResult(
      examinedEdgeCount: rows.length,
      insertedEdgeCount: insertedEdgeCount,
    );
  }
}
