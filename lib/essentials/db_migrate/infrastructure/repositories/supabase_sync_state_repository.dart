import 'package:drift/drift.dart';

import '../../../databases/infrastructure/data_sources/local/working/drift_db.dart';

/// Repository facade for interacting with the Supabase sync bookkeeping tables.
class SupabaseSyncStateRepository {
  SupabaseSyncStateRepository({required this.database});

  final DriftDb database;

  static const String chatsTableKey = 'chats';
  static const String messagesTableKey = 'messages';
  static const String attachmentsTableKey = 'attachments';

  Future<SupabaseSyncStateData?> fetchState(String targetTable) {
    return (database.select(database.supabaseSyncState)
          ..where((tbl) => tbl.targetTable.equals(targetTable))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsertState({
    required String targetTable,
    int? lastBatchId,
    int? lastSyncedRowId,
    String? lastSyncedGuid,
    DateTime? lastSyncedAt,
  }) async {
    final existing = await fetchState(targetTable);
    if (existing == null) {
      await database
          .into(database.supabaseSyncState)
          .insert(
            SupabaseSyncStateCompanion.insert(
              targetTable: targetTable,
              lastBatchId: Value(lastBatchId),
              lastSyncedRowId: Value(lastSyncedRowId),
              lastSyncedGuid: Value(lastSyncedGuid),
              lastSyncedAt: Value(lastSyncedAt),
            ),
            mode: InsertMode.insertOrReplace,
          );
      return;
    }

    await (database.update(
      database.supabaseSyncState,
    )..where((tbl) => tbl.id.equals(existing.id))).write(
      SupabaseSyncStateCompanion(
        lastBatchId: Value(lastBatchId ?? existing.lastBatchId),
        lastSyncedRowId: Value(lastSyncedRowId ?? existing.lastSyncedRowId),
        lastSyncedGuid: Value(lastSyncedGuid ?? existing.lastSyncedGuid),
        lastSyncedAt: Value(lastSyncedAt ?? existing.lastSyncedAt),
      ),
    );
  }

  Future<void> logAttempt({
    required int? batchId,
    required String? targetTable,
    required String status,
    required int attempt,
    String? requestId,
    String? message,
  }) {
    return database
        .into(database.supabaseSyncLogs)
        .insert(
          SupabaseSyncLogsCompanion.insert(
            batchId: Value(batchId),
            targetTable: Value(targetTable),
            status: Value(status),
            attempt: Value(attempt),
            requestId: Value(requestId),
            message: Value(message),
          ),
        );
  }

  Future<List<SupabaseSyncLog>> recentLogs({int limit = 50}) {
    return (database.select(database.supabaseSyncLogs)
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.createdAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }
}
