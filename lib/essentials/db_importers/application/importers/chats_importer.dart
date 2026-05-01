import '../../../../../core/util/date_converter.dart';

import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class ChatsImporter extends BaseTableImporter with RowProgressReporter {
  ChatsImporter();

  @override
  String get name => 'chats';

  @override
  List<String> get dependsOn => const <String>['handles'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'chats-not-empty',
      'Chats table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final chatSourceId = ctx.chatSourceId;
    if (chatSourceId == null) {
      throw Exception(
        'ChatsImporter requires chatSourceId on the import context',
      );
    }

    final minRowId = ctx.previousMaxChatRowId;
    final maxRowId = ctx.sourceMaxChatRowIdAtBatchStart;
    String? whereClause;
    final whereArgs = <Object>[];
    if (minRowId != null) {
      whereClause = 'ROWID > ?';
      whereArgs.add(minRowId);
    }
    if (maxRowId != null) {
      whereClause = whereClause == null
          ? 'ROWID <= ?'
          : '$whereClause AND ROWID <= ?';
      whereArgs.add(maxRowId);
    }

    final rows = await ctx.messagesDb.query(
      'chat',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'ROWID ASC',
    );

    if (rows.isEmpty) {
      ctx.info('ChatsImporter: no new chats detected.');
      ctx.writeScratch('chats.inserted', 0);
      ctx.writeScratch('chats.sourceRowIdToLedgerId', <int, int>{});
      return;
    }

    var processed = 0;
    var inserted = 0;
    var updatedCount = 0;
    var deduplicated = 0;
    final sourceRowIdToLedgerId = <int, int>{};
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = (row['guid'] as String?)?.trim();
      if (sourceRowId == null || guid == null || guid.isEmpty) {
        processed += 1;
        continue;
      }

      final rawService =
          (row['service_name'] as String?) ?? (row['service'] as String?);
      final service = rawService?.trim() ?? 'Unknown';
      final displayName = (row['display_name'] as String?)?.trim();
      final isGroup = (row['is_group'] as int? ?? 0) == 1;
      final created = DateConverter.toIntSafe(row['creation_date']);
      final updatedTimestamp = DateConverter.toIntSafe(
        row['last_read_message_timestamp'],
      );

      final result = await ctx.importDb.insertChat(
        sourceRowid: sourceRowId,
        guid: guid,
        service: service,
        displayName: displayName,
        isGroup: isGroup,
        createdAtUtc: DateConverter.appleToIsoString(created),
        updatedAtUtc: DateConverter.appleToIsoString(updatedTimestamp),
        batchId: ctx.batchId,
        sourceId: chatSourceId,
        firstImportBatchId: ctx.batchId,
        lastImportBatchId: ctx.batchId,
      );

      sourceRowIdToLedgerId[sourceRowId] = result.id;
      if (result.inserted) {
        inserted += 1;
      }
      if (result.updated) {
        updatedCount += 1;
      }
      if (result.deduplicated) {
        deduplicated += 1;
      }
      processed += 1;
      if (processed % 200 == 0 || processed == rows.length) {
        ctx.info(
          'ChatsImporter: processed $processed/${rows.length} chats from chat.db',
        );
        reportRowProgress(processed: processed, total: rows.length);
      }
    }

    ctx.writeScratch('chats.inserted', inserted);
    ctx.writeScratch('chats.updated', updatedCount);
    ctx.writeScratch('chats.deduplicated', deduplicated);
    ctx.writeScratch('chats.sourceRowIdToLedgerId', sourceRowIdToLedgerId);
    if (rows.isNotEmpty) {
      final lastRowId = rows.last['ROWID'];
      if (lastRowId is int) {
        ctx.writeScratch('chats.lastSourceRowId', lastRowId);
      }
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    await expectTrueOrThrow(
      ok: total > 0,
      errorCode: 'chats-empty',
      message: 'Chats table should contain rows after import.',
    );
  }
}
