import 'package:sqflite/sqflite.dart';

import '../../infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class HandleProjectionResult {
  const HandleProjectionResult({
    required this.examinedHandleCount,
    required this.insertedHandleCount,
  });

  final int examinedHandleCount;
  final int insertedHandleCount;
}

class HandleProjector {
  const HandleProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<HandleProjectionResult> projectHandles() async {
    final rows = await importDatabase.database.query(
      'handles',
      columns: <String>['ss_id', 'id', 'service'],
      orderBy: 'ss_id ASC',
    );

    var insertedHandleCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final insertedId = await txn.insert(
          'handles',
          row,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (insertedId != 0) {
          insertedHandleCount += 1;
        }
      }
    });

    return HandleProjectionResult(
      examinedHandleCount: rows.length,
      insertedHandleCount: insertedHandleCount,
    );
  }
}
