import '../../../../essentials/source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/current_attachment_snapshot_lookup.dart';

class SourceScopedAttachmentSnapshotLookup
    implements CurrentAttachmentSnapshotLookup {
  const SourceScopedAttachmentSnapshotLookup({
    required ImportLedger importLedger,
  }) : _importLedger = importLedger;

  final ImportLedger _importLedger;

  @override
  Future<bool> hasAttachmentsForSource(int sourceId) async {
    final rows = await _importLedger.queryTable(
      'attachments',
      columns: <String>['ss_id'],
      where: 'source_id = ?',
      whereArgs: <Object?>[sourceId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<List<int>> attachmentSsIdsForGuid({
    required int sourceId,
    required String guid,
  }) async {
    final rows = await _importLedger.queryTable(
      'attachments',
      columns: <String>['ss_id'],
      where: 'source_id = ? AND guid = ?',
      whereArgs: <Object?>[sourceId, guid],
    );
    return <int>[
      for (final row in rows)
        if (row['ss_id'] is int) row['ss_id']! as int,
    ];
  }
}
