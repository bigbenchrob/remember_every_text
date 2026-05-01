import 'dart:convert';
import 'dart:typed_data';

import '../../../../../core/util/date_converter.dart';
import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class MessagesImporter extends BaseTableImporter with RowProgressReporter {
  MessagesImporter();

  @override
  String get name => 'messages';

  @override
  List<String> get dependsOn => const <String>['chat_to_handle'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'messages-not-empty',
      'Messages table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final chatSourceId = ctx.chatSourceId;
    if (chatSourceId == null) {
      throw Exception(
        'MessagesImporter requires chatSourceId on the import context',
      );
    }

    final chatSourceRowIdToLedgerId = _decodeSourceRowIdToLedgerId(
      ctx.readScratch<Object?>('chats.sourceRowIdToLedgerId'),
    );
    final handleSourceRowIdToLedgerId = _decodeSourceRowIdToLedgerId(
      ctx.readScratch<Object?>('handles.sourceRowIdToLedgerId'),
    );

    // Pre-load all chat_message_join mappings to avoid per-row queries.
    final joinBounds = _buildJoinBounds(
      maxMessageRowIdInclusive: ctx.sourceMaxMessageRowIdAtBatchStart,
      maxChatRowIdInclusive: ctx.sourceMaxChatRowIdAtBatchStart,
    );
    final chatJoinRows = await ctx.messagesDb.query(
      'chat_message_join',
      columns: <String>['message_id', 'chat_id'],
      where: joinBounds.whereClause,
      whereArgs: joinBounds.whereArgs,
    );
    final chatIdByMessage = <int, int>{};
    for (final jr in chatJoinRows) {
      final msgId = jr['message_id'];
      final chatId = jr['chat_id'];
      if (msgId is int && chatId is int) {
        chatIdByMessage[msgId] = chatId;
      }
    }

    final missingChatSourceRowIds = chatIdByMessage.values
        .where(
          (sourceRowId) => !chatSourceRowIdToLedgerId.containsKey(sourceRowId),
        )
        .toSet();
    if (missingChatSourceRowIds.isNotEmpty) {
      chatSourceRowIdToLedgerId.addAll(
        await ctx.importDb.chatIdsBySourceRowIds(missingChatSourceRowIds),
      );
    }

    final minRowId = ctx.previousMaxMessageRowId;
    final maxRowId = ctx.sourceMaxMessageRowIdAtBatchStart;
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
      'message',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'ROWID ASC',
    );

    final insertedIds = <int>[];
    final extractionCandidates = <int>{};
    final messageToChat = <int, int>{};
    final messageSourceRowIdToLedgerId = <int, int>{};
    final recoveredInsertedIds = <int>[];
    final recoveredExtractionCandidates = <int>{};
    final recoveredSourceRowIdToLedgerId = <int, int>{};

    final db = await ctx.importDb.database;
    final recoveredRows = await db.rawQuery(
      'SELECT id, source_message_rowid FROM recovered_unlinked_messages '
      'WHERE source_id = ?',
      <Object?>[chatSourceId],
    );
    final recoveredMessageToChat = <int, int>{};
    final recoveredSourceMessageRowIdToLedgerId = <int, int>{};
    for (final recoveredRow in recoveredRows) {
      final recoveredMessageId = recoveredRow['id'] as int?;
      final recoveredSourceMessageRowId =
          recoveredRow['source_message_rowid'] as int?;
      if (recoveredMessageId != null && recoveredSourceMessageRowId != null) {
        recoveredSourceMessageRowIdToLedgerId[recoveredSourceMessageRowId] =
            recoveredMessageId;
      }
      final sourceChatRowId = recoveredSourceMessageRowId == null
          ? null
          : chatIdByMessage[recoveredSourceMessageRowId];
      final chatId = sourceChatRowId == null
          ? null
          : chatSourceRowIdToLedgerId[sourceChatRowId];
      if (recoveredSourceMessageRowId != null && chatId != null) {
        recoveredMessageToChat[recoveredSourceMessageRowId] = chatId;
      }
    }

    final promotedIds = await ctx.importDb.promoteRecoveredMessagesToLinked(
      messageSourceRowIdToChatId: recoveredMessageToChat,
      batchId: ctx.batchId,
      sourceId: chatSourceId,
    );
    if (promotedIds.isNotEmpty) {
      insertedIds.addAll(promotedIds);
      for (final entry in recoveredMessageToChat.entries) {
        final promotedId = recoveredSourceMessageRowIdToLedgerId[entry.key];
        if (promotedId != null) {
          messageSourceRowIdToLedgerId[entry.key] = promotedId;
          messageToChat[promotedId] = entry.value;
          recoveredSourceRowIdToLedgerId.remove(entry.key);
        }
      }
      ctx.info(
        'MessagesImporter: promoted ${promotedIds.length} recovered '
        'message(s) into linked messages.',
      );
    }

    if (rows.isEmpty) {
      ctx.info('MessagesImporter: no new messages detected.');
      ctx.writeScratch('messages.inserted', insertedIds.length);
      ctx.writeScratch('messages.insertedIds', insertedIds);
      ctx.writeScratch(
        'messages.sourceRowIdToLedgerId',
        messageSourceRowIdToLedgerId,
      );
      ctx.writeScratch('messages.extractionCandidates', <int>[]);
      ctx.writeScratch(
        'messages.messageToChat',
        messageToChat.map((key, value) => MapEntry(key.toString(), value)),
      );
      ctx.writeScratch('messages.updated', 0);
      ctx.writeScratch('messages.deduplicated', 0);
      ctx.writeScratch('messages.missingGuids', 0);
      ctx.writeScratch('recoveredUnlinkedMessages.inserted', 0);
      ctx.writeScratch('recoveredUnlinkedMessages.insertedIds', <int>[]);
      ctx.writeScratch(
        'recoveredUnlinkedMessages.sourceRowIdToLedgerId',
        recoveredSourceRowIdToLedgerId,
      );
      ctx.writeScratch(
        'recoveredUnlinkedMessages.extractionCandidates',
        <int>[],
      );
      ctx.writeScratch('recoveredUnlinkedMessages.updated', 0);
      ctx.writeScratch('recoveredUnlinkedMessages.deduplicated', 0);
      return;
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
          sourceId: chatSourceId,
        ),
      );
    }

    var processed = 0;
    var inserted = insertedIds.length;
    var updated = 0;
    var deduplicated = 0;
    var missingGuids = 0;
    var recoveredInserted = 0;
    var recoveredUpdated = 0;
    var recoveredDeduplicated = 0;

    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = row['guid'] as String?;
      if (sourceRowId == null || guid == null || guid.isEmpty) {
        missingGuids += 1;
        processed += 1;
        continue;
      }

      final sourceChatRowId = chatIdByMessage[sourceRowId];
      final chatId = sourceChatRowId == null
          ? null
          : chatSourceRowIdToLedgerId[sourceChatRowId];
      final senderHandleId = handleSourceRowIdToLedgerId[row['handle_id']];

      final text = row['text'] as String?;
      final attributed = row['attributedBody'] as Uint8List?;
      final messageSummaryInfo = row['message_summary_info'] as Uint8List?;
      final payloadData = row['payload_data'] as Uint8List?;
      final rawItemType = row['item_type'] as int?;
      final rawAssociatedMessageType = row['associated_message_type'] as int?;
      final resolvedText = (text == null || text.isEmpty) ? null : text;
      final needsExtraction =
          (resolvedText == null || resolvedText.isEmpty) && attributed != null;
      if (chatId == null) {
        if (needsExtraction) {
          recoveredExtractionCandidates.add(sourceRowId);
        }

        final result = await ctx.importDb.insertRecoveredUnlinkedMessage(
          sourceRowid: sourceRowId,
          guid: guid,
          senderHandleId: senderHandleId,
          service: (row['service'] as String?)?.trim() ?? 'Unknown',
          isFromMe: (row['is_from_me'] as int? ?? 0) == 1,
          dateUtc: DateConverter.appleToIsoString(row['date']),
          dateReadUtc: DateConverter.appleToIsoString(row['date_read']),
          dateDeliveredUtc: DateConverter.appleToIsoString(
            row['date_delivered'],
          ),
          subject: (row['subject'] as String?)?.trim(),
          text: resolvedText,
          attributedBodyBlob: attributed,
          rawItemType: rawItemType,
          rawAssociatedMessageType: rawAssociatedMessageType,
          messageSummaryInfoBlob: messageSummaryInfo,
          payloadDataBlob: payloadData,
          hasAttributedBodySource: attributed != null,
          hasMessageSummaryInfo: messageSummaryInfo != null,
          hasPayloadDataSource: payloadData != null,
          itemType: _inferItemType(row),
          errorCode: row['error'] as int?,
          isSystemMessage: (row['is_system_message'] as int? ?? 0) == 1,
          threadOriginatorGuid: row['thread_originator_guid'] as String?,
          associatedMessageGuid: row['associated_message_guid'] as String?,
          balloonBundleId: row['balloon_bundle_id'] as String?,
          payloadJson: _decodeOptionalBlob(row['payload_data']),
          batchId: ctx.batchId,
          sourceId: chatSourceId,
          firstImportBatchId: ctx.batchId,
          lastImportBatchId: ctx.batchId,
        );

        recoveredSourceRowIdToLedgerId[sourceRowId] = result.id;

        if (result.inserted) {
          recoveredInserted += 1;
          recoveredInsertedIds.add(result.id);
        }
        if (result.updated) {
          recoveredUpdated += 1;
        }
        if (result.deduplicated) {
          recoveredDeduplicated += 1;
        }
      } else {
        if (needsExtraction) {
          extractionCandidates.add(sourceRowId);
        }

        final result = await ctx.importDb.insertMessage(
          sourceRowid: sourceRowId,
          guid: guid,
          chatId: chatId,
          senderHandleId: senderHandleId,
          service: (row['service'] as String?)?.trim() ?? 'Unknown',
          isFromMe: (row['is_from_me'] as int? ?? 0) == 1,
          dateUtc: DateConverter.appleToIsoString(row['date']),
          dateReadUtc: DateConverter.appleToIsoString(row['date_read']),
          dateDeliveredUtc: DateConverter.appleToIsoString(
            row['date_delivered'],
          ),
          subject: (row['subject'] as String?)?.trim(),
          text: resolvedText,
          attributedBodyBlob: attributed,
          rawItemType: rawItemType,
          rawAssociatedMessageType: rawAssociatedMessageType,
          messageSummaryInfoBlob: messageSummaryInfo,
          payloadDataBlob: payloadData,
          hasAttributedBodySource: attributed != null,
          hasMessageSummaryInfo: messageSummaryInfo != null,
          hasPayloadDataSource: payloadData != null,
          itemType: _inferItemType(row),
          errorCode: row['error'] as int?,
          isSystemMessage: (row['is_system_message'] as int? ?? 0) == 1,
          threadOriginatorGuid: row['thread_originator_guid'] as String?,
          associatedMessageGuid: row['associated_message_guid'] as String?,
          balloonBundleId: row['balloon_bundle_id'] as String?,
          payloadJson: _decodeOptionalBlob(row['payload_data']),
          batchId: ctx.batchId,
          sourceId: chatSourceId,
          firstImportBatchId: ctx.batchId,
          lastImportBatchId: ctx.batchId,
        );

        messageSourceRowIdToLedgerId[sourceRowId] = result.id;
        if (result.shouldLinkToChat) {
          messageToChat[result.id] = chatId;
        }

        if (result.inserted) {
          inserted += 1;
          insertedIds.add(result.id);
        }
        if (result.updated) {
          updated += 1;
        }
        if (result.deduplicated) {
          deduplicated += 1;
        }
      }

      processed += 1;
      if (processed % 500 == 0 || processed == rows.length) {
        ctx.info(
          'MessagesImporter: processed $processed/${rows.length} messages '
          '(inserted $inserted)',
        );
        reportRowProgress(processed: processed, total: rows.length);
      }
    }

    ctx.writeScratch('messages.inserted', inserted);
    ctx.writeScratch('messages.updated', updated);
    ctx.writeScratch('messages.deduplicated', deduplicated);
    ctx.writeScratch('messages.missingGuids', missingGuids);
    ctx.writeScratch('messages.insertedIds', insertedIds);
    ctx.writeScratch(
      'messages.sourceRowIdToLedgerId',
      messageSourceRowIdToLedgerId,
    );
    ctx.writeScratch(
      'messages.extractionCandidates',
      extractionCandidates.toList(),
    );
    ctx.writeScratch(
      'messages.messageToChat',
      messageToChat.map((key, value) => MapEntry(key.toString(), value)),
    );
    ctx.writeScratch('recoveredUnlinkedMessages.inserted', recoveredInserted);
    ctx.writeScratch('recoveredUnlinkedMessages.updated', recoveredUpdated);
    ctx.writeScratch(
      'recoveredUnlinkedMessages.deduplicated',
      recoveredDeduplicated,
    );
    ctx.writeScratch(
      'recoveredUnlinkedMessages.insertedIds',
      recoveredInsertedIds,
    );
    ctx.writeScratch(
      'recoveredUnlinkedMessages.sourceRowIdToLedgerId',
      recoveredSourceRowIdToLedgerId,
    );
    ctx.writeScratch(
      'recoveredUnlinkedMessages.extractionCandidates',
      recoveredExtractionCandidates.toList(),
    );

    if (rows.isNotEmpty) {
      final lastRowId = rows.last['ROWID'];
      if (lastRowId is int) {
        ctx.writeScratch('messages.lastSourceRowId', lastRowId);
      }
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    final recoveredTotal = await count(
      ctx.importDb,
      'recovered_unlinked_messages',
    );
    ctx.info(
      'MessagesImporter: ledger now tracks $total linked messages and '
      '$recoveredTotal recovered unlinked messages.',
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

({String? whereClause, List<Object>? whereArgs}) _buildJoinBounds({
  required int? maxMessageRowIdInclusive,
  required int? maxChatRowIdInclusive,
}) {
  String? whereClause;
  final whereArgs = <Object>[];
  if (maxMessageRowIdInclusive != null) {
    whereClause = 'message_id <= ?';
    whereArgs.add(maxMessageRowIdInclusive);
  }
  if (maxChatRowIdInclusive != null) {
    whereClause = whereClause == null
        ? 'chat_id <= ?'
        : '$whereClause AND chat_id <= ?';
    whereArgs.add(maxChatRowIdInclusive);
  }

  return (
    whereClause: whereClause,
    whereArgs: whereArgs.isEmpty ? null : whereArgs,
  );
}

String _inferItemType(Map<String, Object?> row) {
  final text = row['text'] as String?;
  final associated = row['associated_message_guid'] as String?;
  final balloonId = row['balloon_bundle_id'] as String?;
  final payloadBlob = row['payload_data'];
  final itemType = row['item_type'] as int?;

  if (itemType == 6 || (associated != null && associated.isNotEmpty)) {
    return 'reaction-carrier';
  }
  if (itemType == 8) {
    return 'sticker';
  }
  if (itemType == 0 && (text == null || text.isEmpty)) {
    if (balloonId != null && balloonId.isNotEmpty) {
      return 'balloon';
    }
    if (payloadBlob is Uint8List && payloadBlob.isNotEmpty) {
      return 'unknown';
    }
    return 'attachment-only';
  }
  if (itemType == 10) {
    return 'system';
  }
  return 'text';
}

String? _decodeOptionalBlob(Object? blob) {
  if (blob is Uint8List) {
    try {
      return utf8.decode(blob, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }
  return null;
}
