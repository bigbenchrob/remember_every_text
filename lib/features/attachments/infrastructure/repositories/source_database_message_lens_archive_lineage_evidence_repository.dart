import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/ports/source_database_port.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import '../../application/message_lens_archive_lineage_evidence_repository.dart';
import '../../domain/entities/message_lens_archive_lineage_evidence.dart';

/// Compares all usable donor live-source message identities with the current
/// Mac Messages source through isolated read-only database handles.
final class SourceDatabaseMessageLensArchiveLineageEvidenceRepository
    implements MessageLensArchiveLineageEvidenceRepository {
  const SourceDatabaseMessageLensArchiveLineageEvidenceRepository({
    required SourceDatabaseOpener sourceDatabaseOpener,
  }) : _sourceDatabaseOpener = sourceDatabaseOpener;

  static const int _rowIdBandCount = 4;

  final SourceDatabaseOpener _sourceDatabaseOpener;

  @override
  Future<MessageLensArchiveLineageEvidence> compareExactly({
    required String donorImportDatabasePath,
    required String authoritativeCurrentMessagesDatabasePath,
  }) async {
    ReadOnlySourceDatabase? donorDatabase;
    ReadOnlySourceDatabase? currentDatabase;
    try {
      donorDatabase = await _sourceDatabaseOpener.openReadOnly(
        donorImportDatabasePath,
      );

      final sourceRows = await donorDatabase.rawQuery(
        'SELECT source_id, source_kind FROM source_registry '
        'ORDER BY source_id ASC',
      );
      final liveSourceRows = sourceRows
          .where((row) => row['source_kind'] == liveChatDbSourceKind)
          .toList(growable: false);

      if (liveSourceRows.length != 1) {
        return _emptyEvidence(
          donorRegisteredSourceCount: sourceRows.length,
          donorLiveSourceCount: liveSourceRows.length,
        );
      }

      final liveSourceId = _requiredInt(liveSourceRows.single, 'source_id');
      final donorRows = await donorDatabase.rawQuery(
        'SELECT ss_id, source_id, source_rowid, guid FROM messages '
        'WHERE source_id = ? ORDER BY source_rowid ASC',
        <Object?>[liveSourceId],
      );

      final donorAnchors = <_MessageIdentityAnchor>[];
      final seenRowIds = <int>{};
      var blankDonorGuidCount = 0;
      var inconsistentScopedIdentityCount = 0;
      var duplicateDonorRowIdCount = 0;

      for (final row in donorRows) {
        final ssId = _requiredInt(row, 'ss_id');
        final sourceId = _requiredInt(row, 'source_id');
        final sourceRowId = _requiredInt(row, 'source_rowid');
        final guid = _trimmedString(row['guid']);

        final scopedIdentityIsConsistent =
            SourceScopedRowKey.unpackSourceId(ssId) == sourceId &&
            SourceScopedRowKey.unpackSourceRowId(ssId) == sourceRowId;
        if (!scopedIdentityIsConsistent) {
          inconsistentScopedIdentityCount += 1;
          continue;
        }
        if (!seenRowIds.add(sourceRowId)) {
          duplicateDonorRowIdCount += 1;
          continue;
        }
        if (guid == null) {
          blankDonorGuidCount += 1;
          continue;
        }
        donorAnchors.add(
          _MessageIdentityAnchor(sourceRowId: sourceRowId, guid: guid),
        );
      }

      if (donorAnchors.isEmpty) {
        return MessageLensArchiveLineageEvidence(
          donorRegisteredSourceCount: sourceRows.length,
          donorLiveSourceCount: liveSourceRows.length,
          donorMessageCount: donorRows.length,
          usableDonorIdentityCount: 0,
          blankDonorGuidCount: blankDonorGuidCount,
          inconsistentScopedIdentityCount: inconsistentScopedIdentityCount,
          duplicateDonorRowIdCount: duplicateDonorRowIdCount,
          currentRowsInDonorRangeCount: 0,
          comparableCount: 0,
          matchingCount: 0,
          contradictionCount: 0,
          missingCurrentRowCount: 0,
          unusableCurrentGuidCount: 0,
          matchingRowIdBandCount: 0,
        );
      }

      currentDatabase = await _sourceDatabaseOpener.openReadOnly(
        authoritativeCurrentMessagesDatabasePath,
      );
      final minimumDonorRowId = donorAnchors.first.sourceRowId;
      final maximumDonorRowId = donorAnchors.last.sourceRowId;
      final currentRows = await currentDatabase.rawQuery(
        'SELECT ROWID AS source_rowid, guid FROM message '
        'WHERE ROWID BETWEEN ? AND ? ORDER BY ROWID ASC',
        <Object?>[minimumDonorRowId, maximumDonorRowId],
      );
      final currentGuidByRowId = <int, String?>{
        for (final row in currentRows)
          _requiredInt(row, 'source_rowid'): _trimmedString(row['guid']),
      };

      var comparableCount = 0;
      var matchingCount = 0;
      var contradictionCount = 0;
      var missingCurrentRowCount = 0;
      var unusableCurrentGuidCount = 0;
      final matchingBands = <int>{};

      for (final donorAnchor in donorAnchors) {
        if (!currentGuidByRowId.containsKey(donorAnchor.sourceRowId)) {
          missingCurrentRowCount += 1;
          continue;
        }
        final currentGuid = currentGuidByRowId[donorAnchor.sourceRowId];
        if (currentGuid == null) {
          unusableCurrentGuidCount += 1;
          continue;
        }

        comparableCount += 1;
        if (currentGuid == donorAnchor.guid) {
          matchingCount += 1;
          matchingBands.add(
            _rowIdBand(
              rowId: donorAnchor.sourceRowId,
              minimumRowId: minimumDonorRowId,
              maximumRowId: maximumDonorRowId,
            ),
          );
        } else {
          contradictionCount += 1;
        }
      }

      return MessageLensArchiveLineageEvidence(
        donorRegisteredSourceCount: sourceRows.length,
        donorLiveSourceCount: liveSourceRows.length,
        donorMessageCount: donorRows.length,
        usableDonorIdentityCount: donorAnchors.length,
        blankDonorGuidCount: blankDonorGuidCount,
        inconsistentScopedIdentityCount: inconsistentScopedIdentityCount,
        duplicateDonorRowIdCount: duplicateDonorRowIdCount,
        currentRowsInDonorRangeCount: currentRows.length,
        comparableCount: comparableCount,
        matchingCount: matchingCount,
        contradictionCount: contradictionCount,
        missingCurrentRowCount: missingCurrentRowCount,
        unusableCurrentGuidCount: unusableCurrentGuidCount,
        matchingRowIdBandCount: matchingBands.length,
      );
    } finally {
      await currentDatabase?.close();
      await donorDatabase?.close();
    }
  }

  static MessageLensArchiveLineageEvidence _emptyEvidence({
    required int donorRegisteredSourceCount,
    required int donorLiveSourceCount,
  }) {
    return MessageLensArchiveLineageEvidence(
      donorRegisteredSourceCount: donorRegisteredSourceCount,
      donorLiveSourceCount: donorLiveSourceCount,
      donorMessageCount: 0,
      usableDonorIdentityCount: 0,
      blankDonorGuidCount: 0,
      inconsistentScopedIdentityCount: 0,
      duplicateDonorRowIdCount: 0,
      currentRowsInDonorRangeCount: 0,
      comparableCount: 0,
      matchingCount: 0,
      contradictionCount: 0,
      missingCurrentRowCount: 0,
      unusableCurrentGuidCount: 0,
      matchingRowIdBandCount: 0,
    );
  }

  static int _rowIdBand({
    required int rowId,
    required int minimumRowId,
    required int maximumRowId,
  }) {
    final span = maximumRowId - minimumRowId + 1;
    final band = ((rowId - minimumRowId) * _rowIdBandCount) ~/ span;
    return band.clamp(0, _rowIdBandCount - 1);
  }

  static int _requiredInt(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw StateError('$key must be an integer.');
  }

  static String? _trimmedString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

final class _MessageIdentityAnchor {
  const _MessageIdentityAnchor({required this.sourceRowId, required this.guid});

  final int sourceRowId;
  final String guid;
}
