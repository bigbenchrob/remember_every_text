import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_instance_id.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_marker.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_marker_store.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages_lineage_admission_authority.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_evidence_reader.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/message_lens_attachment_identity_evidence_factory.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/sqlite_message_lens_attachment_recovery_donor_qualifier.dart';
import 'package:remember_this_text/features/settings/application/message_lens_historical_archive_preflight.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/message_lens_historical_archive_preflight_service.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory temporaryRoot;
  late Directory donorRoot;
  late _RecordingLineageAuthority lineageAuthority;
  late _FakeCurrentEvidenceReader currentEvidenceReader;

  setUp(() async {
    temporaryRoot = await Directory.systemTemp.createTemp(
      'message_lens_historical_preflight_test_',
    );
    donorRoot = Directory(path.join(temporaryRoot.path, 'donor'))..createSync();
    lineageAuthority = _RecordingLineageAuthority(_sameLineageAdmission());
    currentEvidenceReader = _FakeCurrentEvidenceReader();
  });

  tearDown(() async {
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  MessageLensHistoricalArchivePreflightService service() {
    return MessageLensHistoricalArchivePreflightService(
      donorQualifier: SqliteMessageLensAttachmentRecoveryDonorQualifier(
        currentArchiveRoot: path.join(temporaryRoot.path, 'current'),
        currentArchiveInstanceId: '123e4567-e89b-42d3-a456-426614174001',
        currentArchiveEnvironment: ArchiveEnvironment.development,
      ),
      lineageAdmissionAuthority: lineageAuthority,
      currentEvidenceReader: currentEvidenceReader,
    );
  }

  test(
    'arbitrary folder is structurally invalid before lineage admission',
    () async {
      final result = await service().inspect(folderPath: donorRoot.path);

      expect(result, isA<MessageLensHistoricalArchiveInvalidFolder>());
      expect(lineageAuthority.messageLensCandidatePaths, isEmpty);
      expect(currentEvidenceReader.liveRelationshipReadCount, 0);
    },
  );

  test(
    'recognizable unsupported archive is incompatible, not invalid',
    () async {
      await _writeMarker(donorRoot);
      File(
        path.join(donorRoot.path, 'macos_import_ss.db'),
      ).writeAsBytesSync(const []);
      File(
        path.join(donorRoot.path, 'user_overlays.db'),
      ).writeAsBytesSync(const []);

      final result = await service().inspect(folderPath: donorRoot.path);

      expect(result, isA<MessageLensHistoricalArchiveIncompatible>());
      expect(lineageAuthority.messageLensCandidatePaths, isEmpty);
      expect(currentEvidenceReader.liveRelationshipReadCount, 0);
    },
  );

  test('copied filenames without MessageLens schemas cannot qualify', () async {
    Directory(path.join(donorRoot.path, 'attachment_archive')).createSync();
    for (final databaseName in const <String>[
      'macos_import_ss.db',
      'user_overlays.db',
      'working_ss.db',
    ]) {
      File(path.join(donorRoot.path, databaseName)).writeAsBytesSync(const []);
    }

    final result = await service().inspect(folderPath: donorRoot.path);

    expect(result, isA<MessageLensHistoricalArchiveIncompatible>());
    expect(lineageAuthority.messageLensCandidatePaths, isEmpty);
  });

  for (final fixture in const <({int import, int overlay, int graph})>[
    (import: 8, overlay: 5, graph: 1),
    (import: 9, overlay: 5, graph: 1),
    (import: 10, overlay: 1, graph: 2),
  ]) {
    test(
      'supported legacy ${fixture.import}/${fixture.overlay}/${fixture.graph} '
      'donor reaches attachment preflight without durable identity',
      () async {
        await _createCompatibleDonor(
          donorRoot,
          includeMarker: false,
          importVersion: fixture.import,
          overlayVersion: fixture.overlay,
          graphVersion: fixture.graph,
        );

        final result = await service().inspect(folderPath: donorRoot.path);

        expect(result, isA<MessageLensHistoricalArchiveReady>());
        final ready = result as MessageLensHistoricalArchiveReady;
        expect(ready.donor.archiveInstanceId, isNull);
        expect(ready.donor.format.name, 'importSchemaV${fixture.import}');
        expect(ready.attachmentPreflight.recoverableCount, 1);
        expect(
          File(
            path.join(
              donorRoot.path,
              FileSystemArchiveMarkerStore.markerFileName,
            ),
          ).existsSync(),
          isFalse,
        );
        expect(lineageAuthority.messageLensCandidatePaths, hasLength(1));
      },
    );
  }

  test('unrecognized legacy schema tuple is incompatible', () async {
    await _createCompatibleDonor(
      donorRoot,
      includeMarker: false,
      importVersion: 7,
      overlayVersion: 5,
      graphVersion: 1,
    );

    final result = await service().inspect(folderPath: donorRoot.path);

    expect(result, isA<MessageLensHistoricalArchiveIncompatible>());
    expect(lineageAuthority.messageLensCandidatePaths, isEmpty);
  });

  test('lineage rejection occurs before attachment matching', () async {
    await _createCompatibleDonor(donorRoot);
    lineageAuthority.result = _contradictoryLineageAdmission();

    final result = await service().inspect(folderPath: donorRoot.path);

    expect(result, isA<MessageLensHistoricalArchiveLineageRejected>());
    expect(lineageAuthority.messageLensCandidatePaths, hasLength(1));
    expect(currentEvidenceReader.liveRelationshipReadCount, 0);
    expect(currentEvidenceReader.payloadStatusReadCount, 0);
  });

  test(
    'insufficient lineage evidence occurs before attachment matching',
    () async {
      await _createCompatibleDonor(donorRoot, includeMarker: false);
      lineageAuthority.result = _insufficientLineageAdmission();

      final result = await service().inspect(folderPath: donorRoot.path);

      expect(result, isA<MessageLensHistoricalArchiveLineageRejected>());
      expect(
        (result as MessageLensHistoricalArchiveLineageRejected).admission,
        isA<InsufficientMessagesLineageAdmission>(),
      );
      expect(lineageAuthority.messageLensCandidatePaths, hasLength(1));
      expect(currentEvidenceReader.liveRelationshipReadCount, 0);
      expect(currentEvidenceReader.payloadStatusReadCount, 0);
    },
  );

  test(
    'same-lineage donor produces exact read-only recovery evidence',
    () async {
      await _createCompatibleDonor(donorRoot);
      final importPath = path.join(donorRoot.path, 'macos_import_ss.db');
      final overlayPath = path.join(donorRoot.path, 'user_overlays.db');
      final importModifiedAt = File(importPath).lastModifiedSync();
      final overlayModifiedAt = File(overlayPath).lastModifiedSync();

      final result = await service().inspect(folderPath: donorRoot.path);

      expect(result, isA<MessageLensHistoricalArchiveReady>());
      final ready = result as MessageLensHistoricalArchiveReady;
      expect(ready.donor.archiveInstanceId, _donorArchiveInstanceId);
      expect(ready.donor.format.name, 'currentMarkerV1');
      expect(ready.attachmentPreflight.examinedCount, 1);
      expect(ready.attachmentPreflight.recoverableCount, 1);
      expect(ready.attachmentPreflight.recoverableBytes, 3);
      expect(ready.attachmentPreflight.alreadyPresentCount, 0);
      expect(currentEvidenceReader.liveRelationshipReadCount, 1);
      expect(currentEvidenceReader.payloadStatusReadCount, 1);
      expect(File(importPath).lastModifiedSync(), importModifiedAt);
      expect(File(overlayPath).lastModifiedSync(), overlayModifiedAt);
      expect(File('$importPath-wal').existsSync(), isFalse);
      expect(File('$overlayPath-wal').existsSync(), isFalse);
    },
  );

  test('reselecting an ephemeral donor recomputes preflight', () async {
    await _createCompatibleDonor(donorRoot, includeMarker: false);

    final first = await service().inspect(folderPath: donorRoot.path);
    final second = await service().inspect(folderPath: donorRoot.path);

    expect(first, isA<MessageLensHistoricalArchiveReady>());
    expect(second, isA<MessageLensHistoricalArchiveReady>());
    expect(lineageAuthority.messageLensCandidatePaths, hasLength(2));
    expect(currentEvidenceReader.liveRelationshipReadCount, 2);
  });
}

const _donorArchiveInstanceId = '123e4567-e89b-42d3-a456-426614174000';
const _payloadBytes = <int>[1, 2, 3];

Future<void> _writeMarker(Directory donorRoot) async {
  await File(
    path.join(donorRoot.path, FileSystemArchiveMarkerStore.markerFileName),
  ).writeAsString(
    '${jsonEncode(ArchiveMarker(formatVersion: ArchiveMarker.currentFormatVersion, environment: ArchiveEnvironment.development, archiveInstanceId: ArchiveInstanceId(_donorArchiveInstanceId), createdAtUtc: DateTime.utc(2026, 1, 1)).toJson())}\n',
  );
}

Future<void> _createCompatibleDonor(
  Directory donorRoot, {
  bool includeMarker = true,
  int importVersion = 10,
  int overlayVersion = 1,
  int graphVersion = 2,
}) async {
  if (includeMarker) {
    await _writeMarker(donorRoot);
  }
  final payloadDirectory = Directory(
    path.join(donorRoot.path, 'attachment_archive', 'ab'),
  )..createSync(recursive: true);
  File(
    path.join(payloadDirectory.path, 'payload.bin'),
  ).writeAsBytesSync(_payloadBytes);

  final importDatabase = sqlite3.open(
    path.join(donorRoot.path, 'macos_import_ss.db'),
  );
  importDatabase.execute('PRAGMA user_version = $importVersion');
  importDatabase.execute('''
    CREATE TABLE source_registry (
      source_id INTEGER PRIMARY KEY,
      source_kind TEXT NOT NULL
    )
  ''');
  importDatabase.execute('''
    CREATE TABLE messages (
      ss_id INTEGER PRIMARY KEY,
      source_id INTEGER NOT NULL,
      source_rowid INTEGER NOT NULL,
      guid TEXT NOT NULL
    )
  ''');
  importDatabase.execute('''
    CREATE TABLE attachments (
      ss_id INTEGER PRIMARY KEY,
      source_id INTEGER NOT NULL,
      source_rowid INTEGER NOT NULL,
      guid TEXT,
      filename TEXT,
      transfer_name TEXT,
      mime_type TEXT,
      uti TEXT,
      total_bytes INTEGER
    )
  ''');
  importDatabase.execute('''
    CREATE TABLE message_to_attachment (
      message_source_id INTEGER NOT NULL,
      attachment_source_id INTEGER NOT NULL,
      source_message_rowid INTEGER NOT NULL,
      source_attachment_rowid INTEGER NOT NULL,
      message_ss_id INTEGER NOT NULL,
      attachment_ss_id INTEGER NOT NULL
    )
  ''');
  final messageSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 41);
  final attachmentSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 42);
  importDatabase.execute(
    "INSERT INTO source_registry VALUES (1, 'live_chat_db')",
  );
  importDatabase.execute('INSERT INTO messages VALUES (?, 1, 41, ?)', [
    messageSsId,
    'message-guid',
  ]);
  importDatabase
      .execute('INSERT INTO attachments VALUES (?, 1, 42, ?, ?, ?, ?, ?, ?)', [
        attachmentSsId,
        'attachment-guid',
        '~/Library/Messages/Attachments/payload.bin',
        'payload.bin',
        'application/octet-stream',
        'public.data',
        3,
      ]);
  importDatabase.execute(
    'INSERT INTO message_to_attachment VALUES (1, 1, 41, 42, ?, ?)',
    [messageSsId, attachmentSsId],
  );
  importDatabase.dispose();

  final overlayDatabase = sqlite3.open(
    path.join(donorRoot.path, 'user_overlays.db'),
  );
  overlayDatabase.execute('PRAGMA user_version = $overlayVersion');
  overlayDatabase.execute('''
    CREATE TABLE archived_attachments (
      message_guid TEXT NOT NULL,
      import_attachment_id INTEGER NOT NULL,
      archive_relative_path TEXT NOT NULL,
      file_size_bytes INTEGER NOT NULL,
      content_hash TEXT
    )
  ''');
  overlayDatabase.execute(
    'INSERT INTO archived_attachments VALUES (?, ?, ?, ?, ?)',
    [
      'message-guid',
      42,
      'ab/payload.bin',
      3,
      sha256.convert(_payloadBytes).toString(),
    ],
  );
  overlayDatabase.dispose();

  final graphDatabase = sqlite3.open(
    path.join(donorRoot.path, 'working_ss.db'),
  );
  graphDatabase.execute('PRAGMA user_version = $graphVersion');
  graphDatabase.execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY)');
  graphDatabase.execute('CREATE TABLE attachments (ss_id INTEGER PRIMARY KEY)');
  graphDatabase.execute('''
    CREATE TABLE message_to_attachment (
      message_ss_id INTEGER NOT NULL,
      attachment_ss_id INTEGER NOT NULL
    )
  ''');
  graphDatabase.dispose();
}

final class _RecordingLineageAuthority
    implements MessagesLineageAdmissionAuthority {
  _RecordingLineageAuthority(this.result);

  MessagesLineageAdmission result;
  final List<String> messageLensCandidatePaths = [];

  @override
  Future<MessagesLineageAdmission> verifyMacMessagesCandidate({
    required String candidateChatDatabasePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MessagesLineageAdmission> verifyMessageLensCandidate({
    required String candidateImportLedgerPath,
  }) async {
    messageLensCandidatePaths.add(candidateImportLedgerPath);
    return result;
  }
}

final class _FakeCurrentEvidenceReader
    implements CurrentMessageLensAttachmentEvidenceReader {
  var liveRelationshipReadCount = 0;
  var payloadStatusReadCount = 0;

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>>
  readLiveSourceRelationships() async {
    liveRelationshipReadCount += 1;
    return [_relationshipEvidence()];
  }

  @override
  Future<CurrentAttachmentPayloadStatus> readPayloadStatus(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    payloadStatusReadCount += 1;
    return CurrentAttachmentPayloadStatus.missing;
  }

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>> readRelationships({
    required int sourceId,
    required int originalMessageRowId,
    required int originalAttachmentRowId,
  }) async {
    return [_relationshipEvidence()];
  }
}

MessageLensAttachmentRelationshipEvidence _relationshipEvidence() {
  return const MessageLensAttachmentIdentityEvidenceFactory().create(
    messageSsId: SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 41),
    messageSourceId: 1,
    originalMessageRowId: 41,
    messageGuid: 'message-guid',
    attachmentSsId: SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 42),
    attachmentSourceId: 1,
    originalAttachmentRowId: 42,
    attachmentGuid: 'attachment-guid',
    relationshipOccurrenceCount: 1,
    filename: '~/Library/Messages/Attachments/payload.bin',
    transferName: 'payload.bin',
    mimeType: 'application/octet-stream',
    uti: 'public.data',
    totalBytes: 3,
  );
}

SameMessagesLineageAdmission _sameLineageAdmission() {
  return MessagesLineageAdmission.fromEvidence(_lineageEvidence())
      as SameMessagesLineageAdmission;
}

ContradictoryMessagesLineageAdmission _contradictoryLineageAdmission() {
  return MessagesLineageAdmission.fromEvidence(
        _lineageEvidence(contradictionCount: 1),
      )
      as ContradictoryMessagesLineageAdmission;
}

InsufficientMessagesLineageAdmission _insufficientLineageAdmission() {
  return MessagesLineageAdmission.fromEvidence(
        _lineageEvidence(matchingCount: 10, matchingRowIdBandCount: 1),
      )
      as InsufficientMessagesLineageAdmission;
}

MessagesLineageEvidence _lineageEvidence({
  int contradictionCount = 0,
  int? matchingCount,
  int matchingRowIdBandCount = 4,
}) {
  return MessagesLineageEvidence(
    candidateRecordCount: 80,
    usableCandidateIdentityCount: 80,
    blankCandidateGuidCount: 0,
    inconsistentCandidateIdentityCount: 0,
    duplicateCandidateRowIdCount: 0,
    currentRowsInCandidateRangeCount: 80,
    comparableCount: 80,
    matchingCount: matchingCount ?? 80 - contradictionCount,
    contradictionCount: contradictionCount,
    missingCurrentRowCount: 0,
    unusableCurrentGuidCount: 0,
    matchingRowIdBandCount: matchingRowIdBandCount,
    candidateSourceShapeIsCoherent: true,
    currentSourceShapeIsCoherent: true,
  );
}
