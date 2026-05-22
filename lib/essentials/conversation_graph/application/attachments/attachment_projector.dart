import 'package:sqflite/sqflite.dart';

import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class AttachmentProjectionResult {
  const AttachmentProjectionResult({
    required this.examinedAttachmentCount,
    required this.insertedAttachmentCount,
  });

  final int examinedAttachmentCount;
  final int insertedAttachmentCount;
}

class AttachmentProjector {
  const AttachmentProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<AttachmentProjectionResult> projectAttachments() async {
    final rows = await importDatabase.database.query(
      'attachments',
      columns: <String>[
        'ss_id',
        'guid',
        'filename',
        'transfer_name',
        'uti',
        'mime_type',
        'total_bytes',
        'created_at_utc',
      ],
      orderBy: 'ss_id ASC',
    );

    var insertedAttachmentCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final insertedId = await txn.insert(
          'attachments',
          row,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (insertedId == 0) {
          await txn.update(
            'attachments',
            row,
            where: 'ss_id = ?',
            whereArgs: <Object?>[row['ss_id']],
          );
        }
        if (insertedId != 0) {
          insertedAttachmentCount += 1;
        }
      }
    });

    return AttachmentProjectionResult(
      examinedAttachmentCount: rows.length,
      insertedAttachmentCount: insertedAttachmentCount,
    );
  }
}
