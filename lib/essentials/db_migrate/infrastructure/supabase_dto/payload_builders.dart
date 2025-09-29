import 'package:drift/drift.dart';

import '../../../databases/infrastructure/data_sources/local/working/drift_db.dart';
import 'attachment_payload.dart';
import 'chat_payload.dart';
import 'message_payload.dart';

class SupabasePayloadBuilder {
  const SupabasePayloadBuilder({
    required this.database,
    required this.ownerUserId,
  });

  final DriftDb database;
  final String ownerUserId;

  static const int defaultBatchSize = 500;

  Future<List<SupabaseChatPayload>> buildChats({
    int? afterRowId,
    int limit = defaultBatchSize,
  }) async {
    final query = database.select(database.chats)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
      ..limit(limit);

    if (afterRowId != null) {
      query.where((tbl) => tbl.id.isBiggerThanValue(afterRowId));
    }

    final rows = await query.get();
    return rows.map<SupabaseChatPayload>(_mapChatRow).toList(growable: false);
  }

  Future<List<SupabaseMessagePayload>> buildMessages({
    int? afterRowId,
    int limit = defaultBatchSize,
  }) async {
    final query = database.select(database.messages)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
      ..limit(limit);

    if (afterRowId != null) {
      query.where((tbl) => tbl.id.isBiggerThanValue(afterRowId));
    }

    final rows = await query.get();
    return rows
        .map<SupabaseMessagePayload>(_mapMessageRow)
        .toList(growable: false);
  }

  Future<List<SupabaseAttachmentPayload>> buildAttachments({
    int? afterRowId,
    int limit = defaultBatchSize,
  }) async {
    final query = database.select(database.attachments)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
      ..limit(limit);

    if (afterRowId != null) {
      query.where((tbl) => tbl.id.isBiggerThanValue(afterRowId));
    }

    final rows = await query.get();
    return rows
        .map<SupabaseAttachmentPayload>(_mapAttachmentRow)
        .toList(growable: false);
  }

  SupabaseChatPayload _mapChatRow(Chat row) {
    return SupabaseChatPayload(
      ownerUserId: ownerUserId,
      guid: row.guid,
      service: 'Unknown',
      isGroup: false,
      displayName: row.displayName,
      computedName: row.displayName,
      lastMessageAtUtc: _timestampToUtc(row.endDate),
      createdAtUtc: _timestampToUtc(row.startDate),
      updatedAtUtc: _timestampToUtc(row.endDate),
    );
  }

  SupabaseMessagePayload _mapMessageRow(Message row) {
    final replyGuid = row.quotedMessageId == null
        ? null
        : 'message-${row.quotedMessageId}';

    return SupabaseMessagePayload(
      ownerUserId: ownerUserId,
      guid: 'message-${row.id}',
      chatId: row.chatId,
      isFromMe: row.isFromMe,
      senderIdentityId: row.senderHandleId,
      sentAtUtc: _timestampToUtc(row.timestamp),
      text: row.content,
      hasAttachments: row.hasAttachments,
      replyToGuid: replyGuid,
      updatedAtUtc: _timestampToUtc(row.importLastSyncedAt),
    );
  }

  SupabaseAttachmentPayload _mapAttachmentRow(Attachment row) {
    return SupabaseAttachmentPayload(
      ownerUserId: ownerUserId,
      messageGuid: 'message-${row.messageId}',
      importAttachmentId: row.id,
      localPath: row.filePath,
      mimeType: row.mimeType,
      sizeBytes: row.fileSize,
      thumbPath: row.thumbnailPath,
      createdAtUtc: _timestampToUtc(row.importLastSyncedAt),
    );
  }

  DateTime? _timestampToUtc(int? value) {
    if (value == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
}
