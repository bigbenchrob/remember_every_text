import '../../../../essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/current_attachment_snapshot_lookup.dart';

class SourceScopedAttachmentSnapshotLookup
    implements CurrentAttachmentSnapshotLookup {
  const SourceScopedAttachmentSnapshotLookup({
    required ImportDatabase importLedgerDb,
  }) : _importLedgerDb = importLedgerDb;

  final ImportDatabase _importLedgerDb;

  @override
  Future<bool> hasAttachmentsForSource(int sourceId) async {
    final rows = await _importLedgerDb.database.rawQuery(
      'SELECT COUNT(*) AS c FROM attachments WHERE source_id = ?',
      <Object?>[sourceId],
    );
    final count = rows.first['c'] as int? ?? 0;
    return count > 0;
  }

  @override
  Future<List<int>> attachmentSsIdsForGuid({
    required int sourceId,
    required String guid,
  }) async {
    final rows = await _importLedgerDb.database.rawQuery(
      '''
      SELECT ss_id
      FROM attachments
      WHERE source_id = ?
        AND guid = ?
      ''',
      <Object?>[sourceId, guid],
    );
    return <int>[
      for (final row in rows)
        if (row['ss_id'] is int) row['ss_id']! as int,
    ];
  }
}
