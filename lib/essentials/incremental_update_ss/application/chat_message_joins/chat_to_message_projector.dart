import 'package:sqflite/sqflite.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class ChatToMessageProjectionResult {
  const ChatToMessageProjectionResult({
    required this.examinedEdgeCount,
    required this.insertedEdgeCount,
  });

  final int examinedEdgeCount;
  final int insertedEdgeCount;
}

class ChatToMessageProjector {
  const ChatToMessageProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<ChatToMessageProjectionResult> projectEdges() async {
    final rows = await importDatabase.database.query(
      'chat_to_message',
      columns: <String>['chat_ss_id', 'message_ss_id'],
      orderBy: 'ss_id ASC',
    );

    var insertedEdgeCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final insertedId = await txn.insert(
          'chat_to_message',
          row,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (insertedId != 0) {
          insertedEdgeCount += 1;
        }
      }
    });

    return ChatToMessageProjectionResult(
      examinedEdgeCount: rows.length,
      insertedEdgeCount: insertedEdgeCount,
    );
  }
}
