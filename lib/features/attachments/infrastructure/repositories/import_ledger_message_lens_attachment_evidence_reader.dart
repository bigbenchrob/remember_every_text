import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/attachment_archive_file_store.dart';
import '../../application/attachment_archive_read_store.dart';
import '../../application/message_lens_attachment_evidence_reader.dart';
import '../../domain/entities/message_lens_attachment_recovery.dart';
import 'message_lens_attachment_identity_evidence_factory.dart';

/// Current-side evidence adapter. It consumes canonical import-ledger and
/// archive-store abstractions and never opens an application database itself.
class ImportLedgerMessageLensAttachmentEvidenceReader
    implements CurrentMessageLensAttachmentEvidenceReader {
  const ImportLedgerMessageLensAttachmentEvidenceReader({
    required ImportLedger importLedger,
    required AttachmentArchiveReadStore archiveReadStore,
    required AttachmentArchiveFileStore archiveFileStore,
    required String archiveDirectoryPath,
    MessageLensAttachmentIdentityEvidenceFactory evidenceFactory =
        const MessageLensAttachmentIdentityEvidenceFactory(),
  }) : _importLedger = importLedger,
       _archiveReadStore = archiveReadStore,
       _archiveFileStore = archiveFileStore,
       _archiveDirectoryPath = archiveDirectoryPath,
       _evidenceFactory = evidenceFactory;

  final ImportLedger _importLedger;
  final AttachmentArchiveReadStore _archiveReadStore;
  final AttachmentArchiveFileStore _archiveFileStore;
  final String _archiveDirectoryPath;
  final MessageLensAttachmentIdentityEvidenceFactory _evidenceFactory;

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>>
  readLiveSourceRelationships() async {
    final sourceRows = await _importLedger.queryTable(
      'source_registry',
      where: 'source_kind = ?',
      whereArgs: const <Object?>[liveChatDbSourceKind],
    );
    if (sourceRows.length != 1) {
      throw StateError(
        'Current attachment evidence requires one live Messages source.',
      );
    }
    final sourceId = _requiredInt(sourceRows.single, 'source_id');
    final relationships = await _importLedger.queryTable(
      'message_to_attachment',
      where: 'message_source_id = ? AND attachment_source_id = ?',
      whereArgs: <Object?>[sourceId, sourceId],
    );
    final messages = await _importLedger.queryTable(
      'messages',
      where: 'source_id = ?',
      whereArgs: <Object?>[sourceId],
    );
    final attachments = await _importLedger.queryTable(
      'attachments',
      where: 'source_id = ?',
      whereArgs: <Object?>[sourceId],
    );
    final messagesByRowId = <int, Map<String, Object?>>{
      for (final message in messages)
        _requiredInt(message, 'source_rowid'): message,
    };
    final attachmentsByRowId = <int, Map<String, Object?>>{
      for (final attachment in attachments)
        _requiredInt(attachment, 'source_rowid'): attachment,
    };
    final occurrenceCounts = <String, int>{};
    for (final relationship in relationships) {
      final key =
          '${_requiredInt(relationship, 'source_message_rowid')}:'
          '${_requiredInt(relationship, 'source_attachment_rowid')}';
      occurrenceCounts.update(key, (count) => count + 1, ifAbsent: () => 1);
    }

    final evidence = <MessageLensAttachmentRelationshipEvidence>[];
    for (final relationship in relationships) {
      final messageRowId = _requiredInt(relationship, 'source_message_rowid');
      final attachmentRowId = _requiredInt(
        relationship,
        'source_attachment_rowid',
      );
      final message = messagesByRowId[messageRowId];
      final attachment = attachmentsByRowId[attachmentRowId];
      if (message == null || attachment == null) {
        throw StateError(
          'Current attachment relationship references missing source rows.',
        );
      }
      evidence.add(
        _evidenceFactory.create(
          messageSsId: _requiredInt(relationship, 'message_ss_id'),
          messageSourceId: _requiredInt(relationship, 'message_source_id'),
          originalMessageRowId: messageRowId,
          messageGuid: _requiredString(message, 'guid'),
          attachmentSsId: _requiredInt(relationship, 'attachment_ss_id'),
          attachmentSourceId: _requiredInt(
            relationship,
            'attachment_source_id',
          ),
          originalAttachmentRowId: attachmentRowId,
          attachmentGuid: attachment['guid'] as String?,
          relationshipOccurrenceCount:
              occurrenceCounts['$messageRowId:$attachmentRowId']!,
          filename: attachment['filename'] as String?,
          transferName: attachment['transfer_name'] as String?,
          mimeType: attachment['mime_type'] as String?,
          uti: attachment['uti'] as String?,
          totalBytes: attachment['total_bytes'] as int?,
        ),
      );
    }
    return evidence;
  }

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>> readRelationships({
    required int sourceId,
    required int originalMessageRowId,
    required int originalAttachmentRowId,
  }) async {
    final relationships = await _importLedger.queryTable(
      'message_to_attachment',
      where:
          'message_source_id = ? AND source_message_rowid = ? '
          'AND attachment_source_id = ? AND source_attachment_rowid = ?',
      whereArgs: <Object?>[
        sourceId,
        originalMessageRowId,
        sourceId,
        originalAttachmentRowId,
      ],
    );
    if (relationships.isEmpty) {
      return const <MessageLensAttachmentRelationshipEvidence>[];
    }

    final messages = await _importLedger.queryTable(
      'messages',
      where: 'source_id = ? AND source_rowid = ?',
      whereArgs: <Object?>[sourceId, originalMessageRowId],
    );
    final attachments = await _importLedger.queryTable(
      'attachments',
      where: 'source_id = ? AND source_rowid = ?',
      whereArgs: <Object?>[sourceId, originalAttachmentRowId],
    );
    if (messages.length != 1 || attachments.length != 1) {
      return const <MessageLensAttachmentRelationshipEvidence>[];
    }

    final message = messages.single;
    final attachment = attachments.single;
    return <MessageLensAttachmentRelationshipEvidence>[
      for (final relationship in relationships)
        _evidenceFactory.create(
          messageSsId: _requiredInt(relationship, 'message_ss_id'),
          messageSourceId: _requiredInt(relationship, 'message_source_id'),
          originalMessageRowId: _requiredInt(
            relationship,
            'source_message_rowid',
          ),
          messageGuid: _requiredString(message, 'guid'),
          attachmentSsId: _requiredInt(relationship, 'attachment_ss_id'),
          attachmentSourceId: _requiredInt(
            relationship,
            'attachment_source_id',
          ),
          originalAttachmentRowId: _requiredInt(
            relationship,
            'source_attachment_rowid',
          ),
          attachmentGuid: attachment['guid'] as String?,
          relationshipOccurrenceCount: relationships.length,
          filename: attachment['filename'] as String?,
          transferName: attachment['transfer_name'] as String?,
          mimeType: attachment['mime_type'] as String?,
          uti: attachment['uti'] as String?,
          totalBytes: attachment['total_bytes'] as int?,
        ),
    ];
  }

  @override
  Future<CurrentAttachmentPayloadStatus> readPayloadStatus(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    final record = await _archiveReadStore.readArchiveRecord(archiveKey);
    if (record == null || !record.archiveFileExists) {
      return CurrentAttachmentPayloadStatus.missing;
    }
    final integrity = await _archiveFileStore.checkIntegrity(
      archiveDirectoryPath: _archiveDirectoryPath,
      relativePath: record.archiveRelativePath,
      storedHash: record.contentHash,
    );
    if (!integrity.fileExists) {
      return CurrentAttachmentPayloadStatus.missing;
    }
    if (record.contentHash != null && integrity.hashMatches != true) {
      return CurrentAttachmentPayloadStatus.presentConflict;
    }
    if (record.fileSizeBytes != null &&
        integrity.actualSizeBytes != record.fileSizeBytes) {
      return CurrentAttachmentPayloadStatus.presentConflict;
    }
    return CurrentAttachmentPayloadStatus.presentValid;
  }

  static int _requiredInt(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is! int) {
      throw StateError('Current attachment evidence is missing integer $key.');
    }
    return value;
  }

  static String _requiredString(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value is! String || value.trim().isEmpty) {
      throw StateError('Current attachment evidence is missing string $key.');
    }
    return value;
  }
}
