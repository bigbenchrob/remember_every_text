import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../providers.dart';
import '../../../domain/known_sources.dart';
import '../../../infrastructure/import_database_provider.dart';
import '../../../infrastructure/working_database_provider.dart';

part 'incremental_update_status_provider.g.dart';

class IncrementalUpdateStatus {
  const IncrementalUpdateStatus({
    required this.chatDbPath,
    required this.importDatabaseName,
    required this.workingDatabaseName,
    required this.sourceId,
    required this.sourceMessageCount,
    required this.sourceMaxRowId,
    required this.ledgerMessageCount,
    required this.ledgerMaxSourceRowId,
    required this.workingMessageCount,
    required this.associatedMessageEdgeCount,
  });

  final String chatDbPath;
  final String importDatabaseName;
  final String workingDatabaseName;
  final int sourceId;
  final int sourceMessageCount;
  final int sourceMaxRowId;
  final int ledgerMessageCount;
  final int ledgerMaxSourceRowId;
  final int workingMessageCount;
  final int associatedMessageEdgeCount;

  int get rowIdDelta => sourceMaxRowId - ledgerMaxSourceRowId;
  int get messageCountDelta => sourceMessageCount - ledgerMessageCount;

  String get cursorState {
    if (rowIdDelta == 0) {
      return 'current';
    }
    if (rowIdDelta > 0) {
      return 'source ahead';
    }
    return 'ledger ahead';
  }
}

@riverpod
Future<IncrementalUpdateStatus> incrementalUpdateStatus(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);

  final sourceSnapshot = await _readSourceMessageSnapshot(
    pathsHelper.chatDBPath,
  );
  final ledgerSnapshot = await _readLedgerMessageSnapshot(
    importDatabase,
    liveChatDbSourceId,
  );
  final workingSnapshot = await _readWorkingMessageSnapshot(workingDatabase);

  return IncrementalUpdateStatus(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabaseName: importDatabaseFileName,
    workingDatabaseName: workingDatabaseFileName,
    sourceId: liveChatDbSourceId,
    sourceMessageCount: sourceSnapshot.count,
    sourceMaxRowId: sourceSnapshot.maxRowId,
    ledgerMessageCount: ledgerSnapshot.count,
    ledgerMaxSourceRowId: ledgerSnapshot.maxRowId,
    workingMessageCount: workingSnapshot.count,
    associatedMessageEdgeCount: workingSnapshot.associatedMessageEdgeCount,
  );
}

Future<_MessageSnapshot> _readSourceMessageSnapshot(String chatDbPath) async {
  final db = await openDatabase(
    chatDbPath,
    readOnly: true,
    singleInstance: false,
  );

  try {
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS message_count, '
      'COALESCE(MAX(ROWID), 0) AS max_rowid FROM message',
    );
    final row = rows.single;

    return _MessageSnapshot(
      count: _readInt(row['message_count']),
      maxRowId: _readInt(row['max_rowid']),
    );
  } finally {
    await db.close();
  }
}

Future<_MessageSnapshot> _readLedgerMessageSnapshot(
  ImportDatabase importDatabase,
  int sourceId,
) async {
  final rows = await importDatabase.database.rawQuery(
    'SELECT COUNT(*) AS message_count, '
    'COALESCE(MAX(source_rowid), 0) AS max_rowid '
    'FROM messages WHERE source_id = ?',
    <Object?>[sourceId],
  );
  final row = rows.single;

  return _MessageSnapshot(
    count: _readInt(row['message_count']),
    maxRowId: _readInt(row['max_rowid']),
  );
}

Future<_WorkingMessageSnapshot> _readWorkingMessageSnapshot(
  WorkingDatabase workingDatabase,
) async {
  final rows = await workingDatabase.database.rawQuery(
    'SELECT COUNT(*) AS message_count, '
    'COUNT(associated_message_ss_id) AS associated_message_edge_count '
    'FROM messages',
  );
  final row = rows.single;

  return _WorkingMessageSnapshot(
    count: _readInt(row['message_count']),
    associatedMessageEdgeCount: _readInt(row['associated_message_edge_count']),
  );
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return 0;
}

class _MessageSnapshot {
  const _MessageSnapshot({required this.count, required this.maxRowId});

  final int count;
  final int maxRowId;
}

class _WorkingMessageSnapshot {
  const _WorkingMessageSnapshot({
    required this.count,
    required this.associatedMessageEdgeCount,
  });

  final int count;
  final int associatedMessageEdgeCount;
}
