import 'dart:typed_data';

abstract interface class ImportLedger {
  Future<int> insertImportBatch({
    required int sourceId,
    required String startedAtUtc,
  });

  Future<int> getOrCreateSource({
    required String sourceKey,
    required String sourceKind,
    String? sourceLabel,
  });

  Future<int?> sourceIdForKey(String sourceKey);

  Future<SourceScopedImportSourceDeletionResult> deleteRowsForSource({
    required int sourceId,
  });

  Future<int?> maxMessageSourceRowIdForSource(int sourceId);

  Future<int?> maxHandleSourceRowIdForSource(int sourceId);

  Future<int?> maxAttachmentSourceRowIdForSource(int sourceId);

  Future<List<ImportLedgerMessageTextCandidate>>
  findMessagesNeedingTextEnrichment({
    int? sourceId,
    int? startedAfterSourceRowId,
  });

  Future<T> writeTransaction<T>(
    Future<T> Function(ImportLedgerWriteTransaction txn) action,
  );
}

abstract interface class ImportLedgerWriteTransaction {
  Future<int> insertIgnore(String table, Map<String, Object?> values);

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  });
}

final class ImportLedgerMessageTextCandidate {
  const ImportLedgerMessageTextCandidate({
    required this.ssId,
    required this.sourceRowId,
    required this.attributedBodyBlob,
  });

  final int ssId;
  final int sourceRowId;
  final Uint8List attributedBodyBlob;
}

final class SourceScopedImportSourceDeletionResult {
  const SourceScopedImportSourceDeletionResult({
    required this.sourceId,
    required this.messages,
    required this.chats,
    required this.handles,
    required this.contacts,
    required this.contactChannels,
    required this.attachments,
    required this.chatMessageEdges,
    required this.chatHandleEdges,
    required this.messageAttachmentEdges,
    required this.importBatches,
  });

  final int sourceId;
  final int messages;
  final int chats;
  final int handles;
  final int contacts;
  final int contactChannels;
  final int attachments;
  final int chatMessageEdges;
  final int chatHandleEdges;
  final int messageAttachmentEdges;
  final int importBatches;

  int get deletedSourceFactCount {
    return messages +
        chats +
        handles +
        contacts +
        contactChannels +
        attachments;
  }

  int get deletedTopologyEdgeCount {
    return chatMessageEdges + chatHandleEdges + messageAttachmentEdges;
  }
}
