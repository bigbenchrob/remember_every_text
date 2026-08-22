import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import '../../../../essentials/db/application/read_only_sql_guard.dart';
import '../../application/message_lens_attachment_evidence_reader.dart';
import '../../domain/entities/message_lens_attachment_recovery.dart';
import 'message_lens_attachment_identity_evidence_factory.dart';

/// Narrow, read-only compatibility reader for a donor MessageLens archive.
///
/// It supports source-scoped import databases containing the relational
/// messages/attachments/message_to_attachment columns used below and overlay
/// databases containing the current archived_attachments compatibility shape.
/// Missing tables or columns fail closed; donor databases are never migrated.
class SqliteMessageLensAttachmentDonorEvidenceReader
    implements MessageLensDonorAttachmentEvidenceReader {
  const SqliteMessageLensAttachmentDonorEvidenceReader({
    required this.donorArchiveRoot,
    required this.donorSourceScopedImportDatabasePath,
    required this.donorOverlayDatabasePath,
    MessageLensAttachmentIdentityEvidenceFactory evidenceFactory =
        const MessageLensAttachmentIdentityEvidenceFactory(),
  }) : _evidenceFactory = evidenceFactory;

  final String donorArchiveRoot;
  final String donorSourceScopedImportDatabasePath;
  final String donorOverlayDatabasePath;
  final MessageLensAttachmentIdentityEvidenceFactory _evidenceFactory;

  @override
  Future<void> validateCompatibility() {
    return Isolate.run(() {
      final importDatabase = _openDonorDatabase(
        donorSourceScopedImportDatabasePath,
      );
      try {
        _requireImportLedgerShape(importDatabase);
        _readLiveSourceId(importDatabase);
      } finally {
        importDatabase.dispose();
      }

      final overlayDatabase = _openDonorDatabase(donorOverlayDatabasePath);
      try {
        _requireArchiveMetadataShape(overlayDatabase);
      } finally {
        overlayDatabase.dispose();
      }
    });
  }

  @override
  Future<void> validateExecutionIntegrity() {
    return Isolate.run(() {
      final importDatabase = _openDonorDatabase(
        donorSourceScopedImportDatabasePath,
      );
      try {
        _requireHealthyDatabase(importDatabase);
      } finally {
        importDatabase.dispose();
      }

      final overlayDatabase = _openDonorDatabase(donorOverlayDatabasePath);
      try {
        _requireHealthyDatabase(overlayDatabase);
      } finally {
        overlayDatabase.dispose();
      }
    });
  }

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>>
  readLiveSourceRelationships() {
    return Isolate.run(() {
      final database = _openDonorDatabase(donorSourceScopedImportDatabasePath);
      try {
        _requireImportLedgerShape(database);
        final sourceId = _readLiveSourceId(database);
        const sql = '''
        SELECT
          m.ss_id AS message_ss_id,
          m.source_id AS message_source_id,
          m.source_rowid AS source_message_rowid,
          m.guid AS message_guid,
          a.ss_id AS attachment_ss_id,
          a.source_id AS attachment_source_id,
          a.source_rowid AS source_attachment_rowid,
          a.guid AS attachment_guid,
          a.filename,
          a.transfer_name,
          a.mime_type,
          a.uti,
          a.total_bytes
        FROM message_to_attachment AS ma
        JOIN messages AS m ON m.ss_id = ma.message_ss_id
        JOIN attachments AS a ON a.ss_id = ma.attachment_ss_id
        WHERE ma.message_source_id = ?
          AND ma.attachment_source_id = ?
        ORDER BY ma.source_message_rowid, ma.source_attachment_rowid
        ''';
        assertReadOnlySql(
          sql,
          boundary: 'MessageLens donor attachment evidence',
        );
        final rows = database.select(sql, <Object?>[sourceId, sourceId]);
        return _relationshipEvidence(rows);
      } finally {
        database.dispose();
      }
    });
  }

  @override
  Future<List<MessageLensArchivedPayloadClaim>> readArchivedPayloadClaims() {
    return Isolate.run(() {
      final database = _openDonorDatabase(donorOverlayDatabasePath);
      try {
        _requireArchiveMetadataShape(database);
        const sql = '''
        SELECT
          message_guid,
          import_attachment_id,
          archive_relative_path,
          file_size_bytes,
          content_hash
        FROM archived_attachments
        ORDER BY message_guid, import_attachment_id
        ''';
        assertReadOnlySql(sql, boundary: 'MessageLens donor payload evidence');
        return <MessageLensArchivedPayloadClaim>[
          for (final row in database.select(sql))
            MessageLensArchivedPayloadClaim(
              archiveCompatibilityKey: ArchiveCompatibilityKey.fromStoredTuple(
                messageGuid: row['message_guid'] as String,
                importAttachmentId: row['import_attachment_id'] as int,
              ),
              payload: MessageLensArchivedPayloadEvidence(
                archiveRelativePath: row['archive_relative_path'] as String,
                recordedSizeBytes: row['file_size_bytes'] as int,
                recordedSha256: row['content_hash'] as String?,
              ),
            ),
        ];
      } finally {
        database.dispose();
      }
    });
  }

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>> readRelationships({
    required int sourceId,
    required int originalMessageRowId,
    required int originalAttachmentRowId,
  }) {
    return Isolate.run(() {
      final database = _openDonorDatabase(donorSourceScopedImportDatabasePath);
      try {
        _requireImportLedgerShape(database);

        const sql = '''
        SELECT
          m.ss_id AS message_ss_id,
          m.source_id AS message_source_id,
          m.source_rowid AS source_message_rowid,
          m.guid AS message_guid,
          a.ss_id AS attachment_ss_id,
          a.source_id AS attachment_source_id,
          a.source_rowid AS source_attachment_rowid,
          a.guid AS attachment_guid,
          a.filename,
          a.transfer_name,
          a.mime_type,
          a.uti,
          a.total_bytes
        FROM message_to_attachment AS ma
        JOIN messages AS m ON m.ss_id = ma.message_ss_id
        JOIN attachments AS a ON a.ss_id = ma.attachment_ss_id
        WHERE ma.message_source_id = ?
          AND ma.source_message_rowid = ?
          AND ma.attachment_source_id = ?
          AND ma.source_attachment_rowid = ?
      ''';
        assertReadOnlySql(
          sql,
          boundary: 'MessageLens donor attachment evidence',
        );
        final rows = database.select(sql, <Object?>[
          sourceId,
          originalMessageRowId,
          sourceId,
          originalAttachmentRowId,
        ]);
        return _relationshipEvidence(rows);
      } finally {
        database.dispose();
      }
    });
  }

  @override
  Future<MessageLensArchivedPayloadEvidence?> readArchivedPayload(
    ArchiveCompatibilityKey archiveKey,
  ) {
    return Isolate.run(() {
      final database = _openDonorDatabase(donorOverlayDatabasePath);
      try {
        _requireArchiveMetadataShape(database);
        const sql = '''
        SELECT archive_relative_path, file_size_bytes, content_hash
        FROM archived_attachments
        WHERE message_guid = ? AND import_attachment_id = ?
        LIMIT 2
      ''';
        assertReadOnlySql(sql, boundary: 'MessageLens donor payload evidence');
        final rows = database.select(sql, <Object?>[
          archiveKey.messageGuid,
          archiveKey.archiveCompatibilityAttachmentId,
        ]);
        if (rows.isEmpty) {
          return null;
        }
        if (rows.length != 1) {
          throw StateError('Donor attachment archive evidence is ambiguous.');
        }
        final row = rows.single;
        return MessageLensArchivedPayloadEvidence(
          archiveRelativePath: row['archive_relative_path'] as String,
          recordedSizeBytes: row['file_size_bytes'] as int,
          recordedSha256: row['content_hash'] as String?,
        );
      } finally {
        database.dispose();
      }
    });
  }

  Database _openDonorDatabase(String databasePath) {
    final normalizedRoot = path.normalize(path.absolute(donorArchiveRoot));
    final normalizedDatabasePath = path.normalize(path.absolute(databasePath));
    if (!path.isWithin(normalizedRoot, normalizedDatabasePath)) {
      throw StateError('Required donor database is outside the archive root.');
    }
    if (FileSystemEntity.typeSync(normalizedDatabasePath, followLinks: false) !=
        FileSystemEntityType.file) {
      throw StateError('Required donor database is unavailable.');
    }
    final database = sqlite3.open(
      normalizedDatabasePath,
      mode: OpenMode.readOnly,
    );
    database.execute('PRAGMA query_only = ON;');
    database.execute('PRAGMA busy_timeout = 3000;');
    return database;
  }

  List<MessageLensAttachmentRelationshipEvidence> _relationshipEvidence(
    ResultSet rows,
  ) {
    final occurrenceCounts = <String, int>{};
    for (final row in rows) {
      final key =
          '${row['source_message_rowid']}:${row['source_attachment_rowid']}';
      occurrenceCounts.update(key, (count) => count + 1, ifAbsent: () => 1);
    }
    return <MessageLensAttachmentRelationshipEvidence>[
      for (final row in rows)
        _evidenceFactory.create(
          messageSsId: row['message_ss_id'] as int,
          messageSourceId: row['message_source_id'] as int,
          originalMessageRowId: row['source_message_rowid'] as int,
          messageGuid: row['message_guid'] as String,
          attachmentSsId: row['attachment_ss_id'] as int,
          attachmentSourceId: row['attachment_source_id'] as int,
          originalAttachmentRowId: row['source_attachment_rowid'] as int,
          attachmentGuid: row['attachment_guid'] as String?,
          relationshipOccurrenceCount:
              occurrenceCounts['${row['source_message_rowid']}:${row['source_attachment_rowid']}']!,
          filename: row['filename'] as String?,
          transferName: row['transfer_name'] as String?,
          mimeType: row['mime_type'] as String?,
          uti: row['uti'] as String?,
          totalBytes: row['total_bytes'] as int?,
        ),
    ];
  }

  static int _readLiveSourceId(Database database) {
    _requireColumns(database, 'source_registry', const <String>{
      'source_id',
      'source_kind',
    });
    const sql = '''
      SELECT source_id
      FROM source_registry
      WHERE source_kind = 'live_chat_db'
      ORDER BY source_id
    ''';
    assertReadOnlySql(sql, boundary: 'MessageLens donor source identity');
    final rows = database.select(sql);
    if (rows.length != 1) {
      throw StateError(
        'Unsupported donor schema: expected one live Messages source.',
      );
    }
    return rows.single['source_id'] as int;
  }

  static void _requireHealthyDatabase(Database database) {
    final quickCheck = database
        .select('PRAGMA quick_check')
        .single
        .values
        .first;
    final integrityCheck = database
        .select('PRAGMA integrity_check')
        .single
        .values
        .first;
    if (quickCheck != 'ok' || integrityCheck != 'ok') {
      throw StateError('Donor database integrity checks failed.');
    }
  }

  static void _requireImportLedgerShape(Database database) {
    _requireColumns(database, 'messages', const <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'guid',
    });
    _requireColumns(database, 'attachments', const <String>{
      'ss_id',
      'source_id',
      'source_rowid',
      'guid',
      'filename',
      'transfer_name',
      'mime_type',
      'uti',
      'total_bytes',
    });
    _requireColumns(database, 'message_to_attachment', const <String>{
      'message_source_id',
      'attachment_source_id',
      'source_message_rowid',
      'source_attachment_rowid',
      'message_ss_id',
      'attachment_ss_id',
    });
  }

  static void _requireArchiveMetadataShape(Database database) {
    _requireColumns(database, 'archived_attachments', const <String>{
      'message_guid',
      'import_attachment_id',
      'archive_relative_path',
      'file_size_bytes',
      'content_hash',
    });
  }

  static void _requireColumns(
    Database database,
    String table,
    Set<String> requiredColumns,
  ) {
    final tableRows = database.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>[table],
    );
    if (tableRows.length != 1) {
      throw StateError('Unsupported donor schema: missing $table.');
    }
    final columns = database
        .select('PRAGMA table_info("$table")')
        .map((row) => row['name'] as String)
        .toSet();
    final missing = requiredColumns.difference(columns);
    if (missing.isNotEmpty) {
      throw StateError(
        'Unsupported donor schema: $table is missing ${missing.join(', ')}.',
      );
    }
  }
}
