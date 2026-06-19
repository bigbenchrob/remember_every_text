import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/retained_archive/domain/archive_compatibility_key.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_sql.dart';
import '../../application/cross_snapshot_mapper.dart';
import '../../application/cross_snapshot_mapping.dart';
import '../../application/current_attachment_snapshot_lookup.dart';
import '../../application/historical_snapshot_reader.dart';

/// Maps historical attachment records to source-scoped graph identity.
///
/// This replaces the old retained-database recovery bridge. Historical
/// snapshots now resolve against the source-scoped import ledger and
/// conversation graph, not retained `macos_import.db` / `working.db` rows.
///
/// The graph-era bridge is:
/// historical snapshot -> source-scoped import ledger -> conversation graph.
///
/// Overlay archive rows still use the existing compatibility key
/// `(message_guid, import_attachment_id)` during this slice. Mapped records
/// therefore expose the live-source attachment ROWID decoded from
/// `attachment_ss_id`, while the graph endpoints remain the canonical
/// `currentMessageSsId` / `currentAttachmentSsId` values.
class GraphCrossSnapshotMapper implements CrossSnapshotMapper {
  const GraphCrossSnapshotMapper({
    required this.attachmentLookup,
    required this.graphDb,
    this.sourceId = liveChatDbSourceId,
  });

  final CurrentAttachmentSnapshotLookup attachmentLookup;
  final ConversationGraphDatabase graphDb;
  final int sourceId;

  @override
  Future<bool> hasCurrentAttachmentSnapshot() async {
    return attachmentLookup.hasAttachmentsForSource(sourceId);
  }

  @override
  Future<CrossSnapshotMappingResult?> mapRecords({
    required List<HistoricalAttachmentRecord> historicalRecords,
    void Function(int processed)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final mapped = <MappedAttachmentRecord>[];
    final unmapped = <UnmappedAttachmentRecord>[];

    var mappedByGuid = 0;
    var mappedBySingleFallback = 0;
    var unmappedMessageMissing = 0;
    var unmappedGuidMismatch = 0;
    var unmappedAmbiguous = 0;
    var unmappedNoCurrentAttachment = 0;
    var unmappedFileMissing = 0;
    var totalWithFiles = 0;

    final historicalAttachmentCounts = <String, int>{};
    for (final record in historicalRecords) {
      historicalAttachmentCounts[record.histMessageGuid] =
          (historicalAttachmentCounts[record.histMessageGuid] ?? 0) + 1;
    }

    for (var i = 0; i < historicalRecords.length; i++) {
      if (isCancelled != null && isCancelled()) {
        return null;
      }

      final record = historicalRecords[i];
      if (!record.fileFound || record.resolvedFilePath == null) {
        unmapped.add(
          UnmappedAttachmentRecord(
            histMessageGuid: record.histMessageGuid,
            reason: UnmappedReason.fileNotFound,
            histAttachmentGuid: record.histAttachmentGuid,
            histLocalPath: record.histLocalPath,
          ),
        );
        unmappedFileMissing++;
        _reportProgress(onProgress, i, historicalRecords.length);
        continue;
      }

      totalWithFiles++;

      final messageSsIds = await _readGraphMessageSsIds(record.histMessageGuid);
      if (messageSsIds.isEmpty) {
        unmapped.add(
          UnmappedAttachmentRecord(
            histMessageGuid: record.histMessageGuid,
            reason: UnmappedReason.messageNotInGraph,
            histAttachmentGuid: record.histAttachmentGuid,
            histLocalPath: record.histLocalPath,
          ),
        );
        unmappedMessageMissing++;
        _reportProgress(onProgress, i, historicalRecords.length);
        continue;
      }

      final result = await _mapAttachment(
        record: record,
        currentMessageSsIds: messageSsIds,
        historicalAttachmentCount:
            historicalAttachmentCounts[record.histMessageGuid] ?? 1,
      );

      if (result != null) {
        mapped.add(result);
        if (result.matchMethod == MatchMethod.guidMatch) {
          mappedByGuid++;
        } else {
          mappedBySingleFallback++;
        }
      } else {
        final reason = await _classifyUnmappedReason(
          record: record,
          currentMessageSsIds: messageSsIds,
          historicalAttachmentCount:
              historicalAttachmentCounts[record.histMessageGuid] ?? 1,
        );
        unmapped.add(
          UnmappedAttachmentRecord(
            histMessageGuid: record.histMessageGuid,
            reason: reason,
            histAttachmentGuid: record.histAttachmentGuid,
            histLocalPath: record.histLocalPath,
          ),
        );
        switch (reason) {
          case UnmappedReason.guidMismatch:
          case UnmappedReason.guidMessageMismatch:
            unmappedGuidMismatch++;
          case UnmappedReason.guidNullMultiAttachment:
            unmappedAmbiguous++;
          case UnmappedReason.guidNullNoCurrentAttachment:
            unmappedNoCurrentAttachment++;
          case UnmappedReason.messageNotInGraph:
            unmappedMessageMissing++;
          case UnmappedReason.fileNotFound:
            unmappedFileMissing++;
        }
      }

      _reportProgress(onProgress, i, historicalRecords.length);
    }

    return CrossSnapshotMappingResult(
      mapped: mapped,
      unmapped: unmapped,
      totalWithFiles: totalWithFiles,
      mappedByGuid: mappedByGuid,
      mappedBySingleFallback: mappedBySingleFallback,
      unmappedMessageMissing: unmappedMessageMissing,
      unmappedGuidMismatch: unmappedGuidMismatch,
      unmappedAmbiguous: unmappedAmbiguous,
      unmappedNoCurrentAttachment: unmappedNoCurrentAttachment,
      unmappedFileMissing: unmappedFileMissing,
    );
  }

  Future<List<int>> _readGraphMessageSsIds(String messageGuid) async {
    final rows = await graphDb.selectRows(
      '''
      SELECT ss_id
      FROM messages
      WHERE guid = ?
        AND ${SourceScopedRowSql.sourceId('ss_id')} = ?
      ''',
      <Object?>[messageGuid, sourceId],
    );
    return [
      for (final row in rows)
        if (row['ss_id'] is int) row['ss_id']! as int,
    ];
  }

  Future<MappedAttachmentRecord?> _mapAttachment({
    required HistoricalAttachmentRecord record,
    required List<int> currentMessageSsIds,
    required int historicalAttachmentCount,
  }) async {
    final histAttachmentGuid = record.histAttachmentGuid;
    if (histAttachmentGuid != null && histAttachmentGuid.isNotEmpty) {
      final attachmentSsIds = await attachmentLookup.attachmentSsIdsForGuid(
        sourceId: sourceId,
        guid: histAttachmentGuid,
      );
      for (final attachmentSsId in attachmentSsIds) {
        final confirmedMessageSsId = await _confirmAttachmentTopology(
          currentMessageSsIds: currentMessageSsIds,
          attachmentSsId: attachmentSsId,
        );
        if (confirmedMessageSsId != null) {
          return _mappedRecord(
            record: record,
            messageSsId: confirmedMessageSsId,
            attachmentSsId: attachmentSsId,
            matchMethod: MatchMethod.guidMatch,
          );
        }
      }
      return null;
    }

    if (historicalAttachmentCount != 1) {
      return null;
    }

    final currentAttachmentRows = await _readCurrentAttachmentRows(
      currentMessageSsIds,
    );
    if (currentAttachmentRows.length != 1) {
      return null;
    }

    final row = currentAttachmentRows.single;
    return _mappedRecord(
      record: record,
      messageSsId: row.messageSsId,
      attachmentSsId: row.attachmentSsId,
      matchMethod: MatchMethod.singleAttachmentFallback,
    );
  }

  Future<UnmappedReason> _classifyUnmappedReason({
    required HistoricalAttachmentRecord record,
    required List<int> currentMessageSsIds,
    required int historicalAttachmentCount,
  }) async {
    final histAttachmentGuid = record.histAttachmentGuid;
    if (histAttachmentGuid != null && histAttachmentGuid.isNotEmpty) {
      final attachmentSsIds = await attachmentLookup.attachmentSsIdsForGuid(
        sourceId: sourceId,
        guid: histAttachmentGuid,
      );
      if (attachmentSsIds.isEmpty) {
        return UnmappedReason.guidMismatch;
      }
      return UnmappedReason.guidMessageMismatch;
    }

    if (historicalAttachmentCount != 1) {
      return UnmappedReason.guidNullMultiAttachment;
    }

    final currentAttachmentRows = await _readCurrentAttachmentRows(
      currentMessageSsIds,
    );
    if (currentAttachmentRows.isEmpty) {
      return UnmappedReason.guidNullNoCurrentAttachment;
    }
    return UnmappedReason.guidNullMultiAttachment;
  }

  Future<int?> _confirmAttachmentTopology({
    required List<int> currentMessageSsIds,
    required int attachmentSsId,
  }) async {
    if (currentMessageSsIds.isEmpty) {
      return null;
    }

    final placeholders = List.filled(
      currentMessageSsIds.length,
      '?',
    ).join(', ');
    final rows = await graphDb.selectRows(
      '''
      SELECT message_ss_id
      FROM message_to_attachment
      WHERE attachment_ss_id = ?
        AND message_ss_id IN ($placeholders)
      LIMIT 1
      ''',
      <Object?>[attachmentSsId, ...currentMessageSsIds],
    );
    if (rows.isEmpty) {
      return null;
    }
    final messageSsId = rows.single['message_ss_id'];
    return messageSsId is int ? messageSsId : null;
  }

  Future<List<_CurrentAttachmentRow>> _readCurrentAttachmentRows(
    List<int> currentMessageSsIds,
  ) async {
    if (currentMessageSsIds.isEmpty) {
      return const <_CurrentAttachmentRow>[];
    }

    final placeholders = List.filled(
      currentMessageSsIds.length,
      '?',
    ).join(', ');
    final rows = await graphDb.selectRows(
      '''
      SELECT DISTINCT message_ss_id, attachment_ss_id
      FROM message_to_attachment
      WHERE message_ss_id IN ($placeholders)
        AND ${SourceScopedRowSql.sourceId('attachment_ss_id')} = ?
      ''',
      <Object?>[...currentMessageSsIds, sourceId],
    );

    return [
      for (final row in rows)
        if (row['message_ss_id'] is int && row['attachment_ss_id'] is int)
          _CurrentAttachmentRow(
            messageSsId: row['message_ss_id']! as int,
            attachmentSsId: row['attachment_ss_id']! as int,
          ),
    ];
  }

  MappedAttachmentRecord _mappedRecord({
    required HistoricalAttachmentRecord record,
    required int messageSsId,
    required int attachmentSsId,
    required MatchMethod matchMethod,
  }) {
    final archiveKey = ArchiveCompatibilityKey.fromLiveAttachmentSsId(
      messageGuid: record.histMessageGuid,
      attachmentSsId: attachmentSsId,
    );
    return MappedAttachmentRecord(
      histMessageGuid: record.histMessageGuid,
      currentMessageGuid: record.histMessageGuid,
      currentImportAttachmentId: archiveKey.liveSourceAttachmentRowId,
      resolvedFilePath: record.resolvedFilePath!,
      matchMethod: matchMethod,
      histAttachmentGuid: record.histAttachmentGuid,
      histLocalPath: record.histLocalPath,
      currentMessageSsId: messageSsId,
      currentAttachmentSsId: attachmentSsId,
    );
  }

  void _reportProgress(
    void Function(int processed)? onProgress,
    int index,
    int total,
  ) {
    if (onProgress != null && (index % 200 == 0 || index == total - 1)) {
      onProgress(index + 1);
    }
  }
}

class _CurrentAttachmentRow {
  const _CurrentAttachmentRow({
    required this.messageSsId,
    required this.attachmentSsId,
  });

  final int messageSsId;
  final int attachmentSsId;
}
