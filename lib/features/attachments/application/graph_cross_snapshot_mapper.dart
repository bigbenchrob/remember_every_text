import '../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../../essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'cross_snapshot_mapping.dart';
import 'historical_snapshot_reader.dart';

/// Maps historical attachment records to source-scoped graph identity.
///
/// This replaces the retained recovery bridge that routed historical snapshots
/// through retained import/projection storage before graph refresh.
///
/// The graph-era bridge is:
/// historical snapshot -> source-scoped import ledger -> conversation graph.
///
/// Overlay archive rows still use the existing legacy-compatible
/// `(message_guid, import_attachment_id)` key during this compatibility slice,
/// so mapped records also expose the live-source attachment ROWID as
/// [MappedAttachmentRecord.currentImportAttachmentId].
class GraphCrossSnapshotMapper {
  const GraphCrossSnapshotMapper({
    required this.importDb,
    required this.graphDb,
    this.sourceId = liveChatDbSourceId,
  });

  final ImportDatabase importDb;
  final ConversationGraphDatabase graphDb;
  final int sourceId;

  Future<bool> isImportDbPopulated() async {
    final rows = await importDb.database.rawQuery(
      'SELECT COUNT(*) AS c FROM attachments WHERE source_id = ?',
      <Object?>[sourceId],
    );
    final count = rows.first['c'] as int? ?? 0;
    return count > 0;
  }

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
        AND (ss_id >> ?) = ?
      ''',
      <Object?>[messageGuid, SourceScopedRowKey.sourceRowIdBits, sourceId],
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
      final importRows = await importDb.database.rawQuery(
        '''
        SELECT ss_id
        FROM attachments
        WHERE source_id = ?
          AND guid = ?
        ''',
        <Object?>[sourceId, histAttachmentGuid],
      );
      for (final row in importRows) {
        final attachmentSsId = row['ss_id'];
        if (attachmentSsId is! int) {
          continue;
        }
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
      final importRows = await importDb.database.rawQuery(
        '''
        SELECT ss_id
        FROM attachments
        WHERE source_id = ?
          AND guid = ?
        ''',
        <Object?>[sourceId, histAttachmentGuid],
      );
      if (importRows.isEmpty) {
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
        AND (attachment_ss_id >> ?) = ?
      ''',
      <Object?>[
        ...currentMessageSsIds,
        SourceScopedRowKey.sourceRowIdBits,
        sourceId,
      ],
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
    return MappedAttachmentRecord(
      histMessageGuid: record.histMessageGuid,
      currentMessageGuid: record.histMessageGuid,
      currentImportAttachmentId: SourceScopedRowKey.unpackSourceRowId(
        attachmentSsId,
      ),
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
