import 'package:sqflite/sqflite.dart';

import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import 'source_join_prevalidation.dart';

class ChatToHandleImporter extends BaseTableImporter {
  ChatToHandleImporter();

  @override
  String get name => 'chat_to_handle';

  @override
  List<String> get dependsOn => const <String>['handles', 'chats'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    await validateSourceChatHandleJoinIntegrity(ctx);
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'chat-to-handle-not-empty',
      'Chat-to-handle table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final handleSourceRowIdToLedgerId = _decodeSourceRowIdToLedgerId(
      ctx.readScratch<Object?>('handles.sourceRowIdToLedgerId'),
    );
    final chatSourceRowIdToLedgerId = _decodeSourceRowIdToLedgerId(
      ctx.readScratch<Object?>('chats.sourceRowIdToLedgerId'),
    );

    String? whereClause;
    final whereArgs = <Object>[];
    final maxChatRowId = ctx.sourceMaxChatRowIdAtBatchStart;
    final maxHandleRowId = ctx.sourceMaxHandleRowIdAtBatchStart;

    if (maxChatRowId != null) {
      whereClause = 'chat_id <= ?';
      whereArgs.add(maxChatRowId);
    }
    if (maxHandleRowId != null) {
      whereClause = whereClause == null
          ? 'handle_id <= ?'
          : '$whereClause AND handle_id <= ?';
      whereArgs.add(maxHandleRowId);
    }

    final rows = await ctx.messagesDb.query(
      'chat_handle_join',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    if (rows.isEmpty) {
      ctx.info('ChatToHandleImporter: no chat memberships detected.');
      ctx.writeScratch('chatMemberships.inserted', 0);
      return;
    }

    final missingChatSourceRowIds = rows
        .map((row) => row['chat_id'])
        .whereType<int>()
        .where(
          (sourceRowId) => !chatSourceRowIdToLedgerId.containsKey(sourceRowId),
        )
        .toSet();
    if (missingChatSourceRowIds.isNotEmpty) {
      chatSourceRowIdToLedgerId.addAll(
        await ctx.importDb.chatIdsBySourceRowIds(
          missingChatSourceRowIds,
          sourceId: ctx.chatSourceId,
        ),
      );
    }

    final missingHandleSourceRowIds = rows
        .map((row) => row['handle_id'])
        .whereType<int>()
        .where(
          (sourceRowId) =>
              !handleSourceRowIdToLedgerId.containsKey(sourceRowId),
        )
        .toSet();
    if (missingHandleSourceRowIds.isNotEmpty) {
      handleSourceRowIdToLedgerId.addAll(
        await ctx.importDb.handleIdsBySourceRowIds(
          missingHandleSourceRowIds,
          sourceId: ctx.chatSourceId,
        ),
      );
    }

    // Collect valid pairs, then batch-insert.
    // PK (chat_id, handle_id) with REPLACE handles duplicates.
    final pairs = <Map<String, Object?>>[];
    for (final row in rows) {
      final sourceChatRowId = row['chat_id'] as int?;
      final sourceHandleRowId = row['handle_id'] as int?;
      final chatId = sourceChatRowId == null
          ? null
          : chatSourceRowIdToLedgerId[sourceChatRowId];
      final handleId = sourceHandleRowId == null
          ? null
          : handleSourceRowIdToLedgerId[sourceHandleRowId];
      if (chatId != null && handleId != null) {
        pairs.add(<String, Object?>{'chat_id': chatId, 'handle_id': handleId});
      }
    }

    final db = await ctx.importDb.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final pair in pairs) {
        batch.insert(
          'chat_to_handle',
          pair,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });

    ctx.info(
      'ChatToHandleImporter: inserted ${pairs.length} memberships '
      '(batched, from ${rows.length} source rows).',
    );
    ctx.writeScratch('chatMemberships.inserted', pairs.length);
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    await expectTrueOrThrow(
      ok: total > 0,
      errorCode: 'chat-to-handle-empty',
      message: 'Chat-to-handle table should contain rows after import.',
    );
  }
}

Map<int, int> _decodeSourceRowIdToLedgerId(Object? raw) {
  if (raw is Map<int, int>) {
    return Map<int, int>.from(raw);
  }
  if (raw is Map<String, Object?>) {
    final result = <int, int>{};
    raw.forEach((key, value) {
      final sourceRowId = int.tryParse(key);
      final ledgerId = value is int
          ? value
          : value is num
          ? value.toInt()
          : int.tryParse('$value');
      if (sourceRowId != null && ledgerId != null) {
        result[sourceRowId] = ledgerId;
      }
    });
    return result;
  }
  return <int, int>{};
}
