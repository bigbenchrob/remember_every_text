import 'package:sqflite/sqflite.dart';

import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import 'source_join_prevalidation.dart';

class MessageAttachmentsImporter extends BaseTableImporter
    with RowProgressReporter {
  MessageAttachmentsImporter();

  @override
  String get name => 'message_attachments';

  @override
  List<String> get dependsOn => const <String>['attachments'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    await validateSourceMessageAttachmentJoinIntegrity(ctx);
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'message-attachments-not-empty',
      'Message attachment join table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final linkedMessageSourceRowIdToLedgerId = _decodeSourceRowIdToLedgerId(
      ctx.readScratch<Object?>('messages.sourceRowIdToLedgerId'),
    );
    final recoveredMessageSourceRowIdToLedgerId = _decodeSourceRowIdToLedgerId(
      ctx.readScratch<Object?>(
        'recoveredUnlinkedMessages.sourceRowIdToLedgerId',
      ),
    );
    final attachmentSourceRowIdToLedgerId = _decodeSourceRowIdToLedgerId(
      ctx.readScratch<Object?>('attachments.sourceRowIdToLedgerId'),
    );

    final messageIds = linkedMessageSourceRowIdToLedgerId.keys.toSet();
    final recoveredMessageIds = recoveredMessageSourceRowIdToLedgerId.keys
        .toSet();
    final attachmentIds = attachmentSourceRowIdToLedgerId.keys.toSet();
    final joinPairs = await _collectJoinPairs(
      ctx.messagesDb,
      messageIds: <int>{...messageIds, ...recoveredMessageIds},
      attachmentIds: attachmentIds,
      minAttachmentSourceRowIdExclusive: ctx.previousMaxMessageAttachmentRowId,
      maxMessageSourceRowIdInclusive: ctx.sourceMaxMessageRowIdAtBatchStart,
      maxAttachmentSourceRowIdInclusive:
          ctx.sourceMaxAttachmentRowIdAtBatchStart,
    );

    if (joinPairs.isEmpty) {
      ctx.info('MessageAttachmentsImporter: no join pairs detected.');
      ctx.writeScratch('recoveredUnlinkedMessageAttachments.inserted', 0);
      ctx.writeScratch('messageAttachments.inserted', 0);
      return;
    }

    final unresolvedLinkedMessageSourceRowIds = joinPairs
        .map((pair) => pair.messageId)
        .where(
          (sourceRowId) =>
              !linkedMessageSourceRowIdToLedgerId.containsKey(sourceRowId),
        )
        .toSet();
    if (unresolvedLinkedMessageSourceRowIds.isNotEmpty) {
      linkedMessageSourceRowIdToLedgerId.addAll(
        await ctx.importDb.messageIdsBySourceRowIds(
          unresolvedLinkedMessageSourceRowIds,
          sourceId: ctx.chatSourceId,
        ),
      );
    }

    final unresolvedRecoveredMessageSourceRowIds = joinPairs
        .map((pair) => pair.messageId)
        .where(
          (sourceRowId) =>
              !linkedMessageSourceRowIdToLedgerId.containsKey(sourceRowId) &&
              !recoveredMessageSourceRowIdToLedgerId.containsKey(sourceRowId),
        )
        .toSet();
    if (unresolvedRecoveredMessageSourceRowIds.isNotEmpty) {
      recoveredMessageSourceRowIdToLedgerId.addAll(
        await ctx.importDb.recoveredMessageIdsBySourceRowIds(
          unresolvedRecoveredMessageSourceRowIds,
          sourceId: ctx.chatSourceId,
        ),
      );
    }

    final unresolvedAttachmentSourceRowIds = joinPairs
        .map((pair) => pair.attachmentId)
        .where(
          (sourceRowId) =>
              !attachmentSourceRowIdToLedgerId.containsKey(sourceRowId),
        )
        .toSet();
    if (unresolvedAttachmentSourceRowIds.isNotEmpty) {
      attachmentSourceRowIdToLedgerId.addAll(
        await ctx.importDb.attachmentIdsBySourceRowIds(
          unresolvedAttachmentSourceRowIds,
          sourceId: ctx.chatSourceId,
        ),
      );
    }

    final linkedPairs =
        <({int messageId, int attachmentId, int sourceRowid})>[];
    final recoveredPairs =
        <({int messageId, int attachmentId, int sourceRowid})>[];
    for (final pair in joinPairs) {
      final canonicalAttachmentId =
          attachmentSourceRowIdToLedgerId[pair.attachmentId];
      if (canonicalAttachmentId == null) {
        continue;
      }

      final linkedMessageId =
          linkedMessageSourceRowIdToLedgerId[pair.messageId];
      if (linkedMessageId != null) {
        linkedPairs.add((
          messageId: linkedMessageId,
          attachmentId: canonicalAttachmentId,
          sourceRowid: pair.attachmentId,
        ));
        continue;
      }

      final recoveredMessageId =
          recoveredMessageSourceRowIdToLedgerId[pair.messageId];
      if (recoveredMessageId != null) {
        recoveredPairs.add((
          messageId: recoveredMessageId,
          attachmentId: canonicalAttachmentId,
          sourceRowid: pair.attachmentId,
        ));
      }
    }

    final validPairCount = linkedPairs.length + recoveredPairs.length;
    final skipped = joinPairs.length - validPairCount;
    if (skipped > 0) {
      ctx.info(
        'MessageAttachmentsImporter: filtered out $skipped pairs '
        'referencing missing messages/attachments',
      );
    }

    if (linkedPairs.isEmpty && recoveredPairs.isEmpty) {
      ctx.info('MessageAttachmentsImporter: no valid join pairs remained.');
      ctx.writeScratch('messageAttachments.inserted', 0);
      ctx.writeScratch('recoveredUnlinkedMessageAttachments.inserted', 0);
      return;
    }

    await _insertPairs(
      ctx,
      pairs: linkedPairs,
      tableName: 'message_attachments',
      progressLabel: 'message attachments',
    );
    await _insertPairs(
      ctx,
      pairs: recoveredPairs,
      tableName: 'recovered_unlinked_message_attachments',
      progressLabel: 'recovered unlinked message attachments',
    );

    ctx.writeScratch('messageAttachments.inserted', linkedPairs.length);
    ctx.writeScratch(
      'recoveredUnlinkedMessageAttachments.inserted',
      recoveredPairs.length,
    );
  }

  Future<void> _insertPairs(
    IImportContext ctx, {
    required List<({int messageId, int attachmentId, int sourceRowid})> pairs,
    required String tableName,
    required String progressLabel,
  }) async {
    if (pairs.isEmpty) {
      return;
    }

    final total = pairs.length;
    var processed = 0;

    const chunkSize = 500;
    for (var offset = 0; offset < total; offset += chunkSize) {
      final end = (offset + chunkSize > total) ? total : offset + chunkSize;
      final chunkRows = <Map<String, Object?>>[];
      for (var i = offset; i < end; i++) {
        final pair = pairs[i];
        chunkRows.add(<String, Object?>{
          'message_id': pair.messageId,
          'attachment_id': pair.attachmentId,
          'source_rowid': pair.sourceRowid,
        });
      }

      if (tableName == 'message_attachments') {
        await ctx.importDb.insertMessageAttachmentsBatch(chunkRows);
      } else {
        await ctx.importDb.insertRecoveredUnlinkedMessageAttachmentsBatch(
          chunkRows,
        );
      }
      processed = end;
      ctx.info(
        'MessageAttachmentsImporter: processed $processed/$total '
        '$progressLabel',
      );
      reportRowProgress(processed: processed, total: total);
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    ctx.info(
      'MessageAttachmentsImporter: ledger now tracks $total message/attachment links.',
    );
  }
}

Future<Set<({int messageId, int attachmentId})>> _collectJoinPairs(
  Database messagesDb, {
  required Set<int> messageIds,
  required Set<int> attachmentIds,
  int? minAttachmentSourceRowIdExclusive,
  int? maxMessageSourceRowIdInclusive,
  int? maxAttachmentSourceRowIdInclusive,
}) async {
  final pairs = <({int messageId, int attachmentId})>{};

  Future<void> collectForIds(Set<int> ids, String column) async {
    if (ids.isEmpty) {
      return;
    }
    final ordered = ids.toList()..sort();
    const chunkSize = 200;
    var index = 0;
    while (index < ordered.length) {
      final end = (index + chunkSize > ordered.length)
          ? ordered.length
          : index + chunkSize;
      final chunk = ordered.sublist(index, end);
      final placeholders = List<String>.filled(chunk.length, '?').join(', ');
      final rows = await messagesDb.rawQuery(
        'SELECT message_id, attachment_id FROM message_attachment_join '
        'WHERE $column IN ($placeholders)',
        chunk.map<Object>((id) => id).toList(),
      );
      for (final row in rows) {
        final messageId = row['message_id'] as int?;
        final attachmentId = row['attachment_id'] as int?;
        if (messageId != null && attachmentId != null) {
          pairs.add((messageId: messageId, attachmentId: attachmentId));
        }
      }
      index = end;
    }
  }

  await collectForIds(messageIds, 'message_id');
  await collectForIds(attachmentIds, 'attachment_id');

  if (pairs.isEmpty && minAttachmentSourceRowIdExclusive != null) {
    final fallbackSql = StringBuffer(
      'SELECT message_id, attachment_id FROM message_attachment_join '
      'WHERE attachment_id > ?',
    );
    final fallbackArgs = <Object>[minAttachmentSourceRowIdExclusive];
    if (maxAttachmentSourceRowIdInclusive != null) {
      fallbackSql.write(' AND attachment_id <= ?');
      fallbackArgs.add(maxAttachmentSourceRowIdInclusive);
    }
    if (maxMessageSourceRowIdInclusive != null) {
      fallbackSql.write(' AND message_id <= ?');
      fallbackArgs.add(maxMessageSourceRowIdInclusive);
    }

    final fallbackRows = await messagesDb.rawQuery(
      fallbackSql.toString(),
      fallbackArgs,
    );
    for (final row in fallbackRows) {
      final messageId = row['message_id'] as int?;
      final attachmentId = row['attachment_id'] as int?;
      if (messageId != null && attachmentId != null) {
        pairs.add((messageId: messageId, attachmentId: attachmentId));
      }
    }
  }

  return pairs;
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
