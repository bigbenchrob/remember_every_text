import '../application/messages_lineage_anchor_repository.dart';
import '../domain/known_sources.dart';
import '../domain/messages_lineage_anchor.dart';
import '../domain/ports/source_database_port.dart';
import '../domain/source_scoped_row_key.dart';

final class SourceDatabaseMessagesLineageAnchorRepository
    implements MessagesLineageAnchorRepository {
  const SourceDatabaseMessagesLineageAnchorRepository({
    required SourceDatabaseOpener sourceDatabaseOpener,
  }) : _sourceDatabaseOpener = sourceDatabaseOpener;

  final SourceDatabaseOpener _sourceDatabaseOpener;

  @override
  Future<MessagesLineageAnchorEvidence> readMacMessagesDatabase({
    required String databasePath,
  }) async {
    final database = await _sourceDatabaseOpener.openReadOnly(databasePath);
    try {
      final rows = await database.rawQuery(
        'SELECT ROWID AS original_messages_rowid, guid FROM message '
        'ORDER BY ROWID ASC',
      );
      return _buildEvidence(
        rows: rows,
        sourceShapeIsCoherent: true,
        readRowId: (row) => _requiredInt(row, 'original_messages_rowid'),
      );
    } finally {
      await database.close();
    }
  }

  @override
  Future<MessagesLineageAnchorEvidence> readMessageLensImportLedger({
    required String databasePath,
  }) async {
    final database = await _sourceDatabaseOpener.openReadOnly(databasePath);
    try {
      final sourceRows = await database.rawQuery(
        'SELECT source_id, source_kind FROM source_registry '
        'ORDER BY source_id ASC',
      );
      final liveSourceRows = sourceRows
          .where((row) => row['source_kind'] == liveChatDbSourceKind)
          .toList(growable: false);
      if (liveSourceRows.length != 1) {
        return const MessagesLineageAnchorEvidence(
          anchors: <MessagesLineageAnchor>[],
          blankGuidRowIds: <int>{},
          observedRecordCount: 0,
          blankGuidCount: 0,
          inconsistentIdentityCount: 0,
          duplicateRowIdCount: 0,
          sourceShapeIsCoherent: false,
        );
      }

      final liveSourceId = _requiredInt(liveSourceRows.single, 'source_id');
      final rows = await database.rawQuery(
        'SELECT ss_id, source_id, source_rowid, guid FROM messages '
        'WHERE source_id = ? ORDER BY source_rowid ASC',
        <Object?>[liveSourceId],
      );
      return _buildEvidence(
        rows: rows,
        sourceShapeIsCoherent: true,
        readRowId: (row) {
          final ssId = _requiredInt(row, 'ss_id');
          final sourceId = _requiredInt(row, 'source_id');
          final sourceRowId = _requiredInt(row, 'source_rowid');
          final identityIsConsistent =
              SourceScopedRowKey.unpackSourceId(ssId) == sourceId &&
              SourceScopedRowKey.unpackSourceRowId(ssId) == sourceRowId;
          return identityIsConsistent ? sourceRowId : null;
        },
      );
    } finally {
      await database.close();
    }
  }

  static MessagesLineageAnchorEvidence _buildEvidence({
    required List<Map<String, Object?>> rows,
    required bool sourceShapeIsCoherent,
    required int? Function(Map<String, Object?> row) readRowId,
  }) {
    final anchors = <MessagesLineageAnchor>[];
    final seenRowIds = <int>{};
    final blankGuidRowIds = <int>{};
    var blankGuidCount = 0;
    var inconsistentIdentityCount = 0;
    var duplicateRowIdCount = 0;

    for (final row in rows) {
      final rowId = readRowId(row);
      if (rowId == null) {
        inconsistentIdentityCount += 1;
        continue;
      }
      if (!seenRowIds.add(rowId)) {
        duplicateRowIdCount += 1;
        continue;
      }
      final guid = _trimmedString(row['guid']);
      if (guid == null) {
        blankGuidCount += 1;
        blankGuidRowIds.add(rowId);
        continue;
      }
      anchors.add(
        MessagesLineageAnchor(originalMessagesRowId: rowId, messageGuid: guid),
      );
    }

    return MessagesLineageAnchorEvidence(
      anchors: List<MessagesLineageAnchor>.unmodifiable(anchors),
      blankGuidRowIds: Set<int>.unmodifiable(blankGuidRowIds),
      observedRecordCount: rows.length,
      blankGuidCount: blankGuidCount,
      inconsistentIdentityCount: inconsistentIdentityCount,
      duplicateRowIdCount: duplicateRowIdCount,
      sourceShapeIsCoherent: sourceShapeIsCoherent,
    );
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
