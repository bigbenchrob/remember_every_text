import 'package:sqflite/sqflite.dart';

import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class MessageToAttachmentProjectionResult {
  const MessageToAttachmentProjectionResult({
    required this.examinedEdgeCount,
    required this.insertedEdgeCount,
  });

  final int examinedEdgeCount;
  final int insertedEdgeCount;
}

class MessageToAttachmentProjector {
  const MessageToAttachmentProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<MessageToAttachmentProjectionResult> projectEdges() async {
    final rows = await importDatabase.database.query(
      'message_to_attachment',
      columns: <String>['message_ss_id', 'attachment_ss_id'],
      orderBy: 'message_ss_id ASC, attachment_ss_id ASC',
    );

    var insertedEdgeCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final insertedId = await txn.insert(
          'message_to_attachment',
          row,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (insertedId != 0) {
          insertedEdgeCount += 1;
        }
      }
    });

    return MessageToAttachmentProjectionResult(
      examinedEdgeCount: rows.length,
      insertedEdgeCount: insertedEdgeCount,
    );
  }
}
