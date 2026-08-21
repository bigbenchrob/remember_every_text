import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_lineage_verifier.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_archive_lineage_evidence.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/source_database_message_lens_archive_lineage_evidence_repository.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory tempDirectory;
  late String donorPath;
  late String currentPath;

  setUpAll(() {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'message-lens-lineage-test-',
    );
    donorPath = '${tempDirectory.path}/macos_import_ss.db';
    currentPath = '${tempDirectory.path}/chat.db';
  });

  tearDown(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('compares every overlapping ROWID and GUID exactly', () async {
    _createDonor(donorPath, count: 80);
    _createCurrent(currentPath, count: 80);

    final result = await _verify(
      donorPath: donorPath,
      currentPath: currentPath,
    );

    expect(result.status, MessageLensArchiveLineageAdmissionStatus.sameLineage);
    expect(result.evidence.donorMessageCount, 80);
    expect(result.evidence.comparableCount, 80);
    expect(result.evidence.matchingCount, 80);
    expect(result.evidence.contradictionCount, 0);
    expect(result.evidence.matchingRowIdBandCount, 4);
  });

  test(
    'rejects a foreign donor with the same ROWIDs and different GUIDs',
    () async {
      _createDonor(donorPath, count: 80);
      _createCurrent(
        currentPath,
        count: 80,
        guidForRowId: (rowId) => 'foreign-guid-$rowId',
      );

      final result = await _verify(
        donorPath: donorPath,
        currentPath: currentPath,
      );

      expect(
        result.status,
        MessageLensArchiveLineageAdmissionStatus.contradictoryLineage,
      );
      expect(result.evidence.matchingCount, 0);
      expect(result.evidence.contradictionCount, 80);
    },
  );

  test('shared GUID at another ROWID does not prove lineage', () async {
    _createDonor(donorPath, count: 80);
    _createCurrent(
      currentPath,
      count: 80,
      guidForRowId: (rowId) => rowId == 1 ? 'different-guid' : 'guid-$rowId',
      extraRows: const <int, String>{100: 'guid-1'},
    );

    final result = await _verify(
      donorPath: donorPath,
      currentPath: currentPath,
    );

    expect(
      result.status,
      MessageLensArchiveLineageAdmissionStatus.contradictoryLineage,
    );
    expect(result.evidence.contradictionCount, 1);
    expect(result.evidence.matchingCount, 79);
  });

  test('too little comparable evidence fails closed', () async {
    _createDonor(donorPath, count: 80);
    _createCurrent(currentPath, count: 40);

    final result = await _verify(
      donorPath: donorPath,
      currentPath: currentPath,
    );

    expect(
      result.status,
      MessageLensArchiveLineageAdmissionStatus.insufficientEvidence,
    );
    expect(result.evidence.matchingCount, 40);
    expect(result.evidence.missingCurrentRowCount, 40);
  });

  test(
    'a copied donor at a different path keeps the same lineage evidence',
    () async {
      _createDonor(donorPath, count: 80);
      _createCurrent(currentPath, count: 80);
      final copiedDirectory = Directory('${tempDirectory.path}/remounted')
        ..createSync();
      final copiedDonorPath = '${copiedDirectory.path}/renamed-ledger.db';
      File(donorPath).copySync(copiedDonorPath);

      final original = await _verify(
        donorPath: donorPath,
        currentPath: currentPath,
      );
      final copied = await _verify(
        donorPath: copiedDonorPath,
        currentPath: currentPath,
      );

      expect(
        original.status,
        MessageLensArchiveLineageAdmissionStatus.sameLineage,
      );
      expect(
        copied.status,
        MessageLensArchiveLineageAdmissionStatus.sameLineage,
      );
      expect(copied.evidence.matchingCount, original.evidence.matchingCount);
      expect(
        copied.evidence.contradictionCount,
        original.evidence.contradictionCount,
      );
    },
  );

  test(
    'inconsistent donor packed identity cannot authorize recovery',
    () async {
      _createDonor(donorPath, count: 80, inconsistentRowId: 40);
      _createCurrent(currentPath, count: 80);

      final result = await _verify(
        donorPath: donorPath,
        currentPath: currentPath,
      );

      expect(
        result.status,
        MessageLensArchiveLineageAdmissionStatus.insufficientEvidence,
      );
      expect(result.evidence.inconsistentScopedIdentityCount, 1);
    },
  );

  test(
    'historical donor sources are ignored as ancestry diagnostics',
    () async {
      _createDonor(donorPath, count: 0, includeLiveSource: false);
      _createCurrent(currentPath, count: 80);

      final result = await _verify(
        donorPath: donorPath,
        currentPath: currentPath,
      );

      expect(
        result.status,
        MessageLensArchiveLineageAdmissionStatus.insufficientEvidence,
      );
      expect(result.evidence.donorRegisteredSourceCount, 1);
      expect(result.evidence.donorLiveSourceCount, 0);
    },
  );
}

Future<MessageLensArchiveLineageAdmission> _verify({
  required String donorPath,
  required String currentPath,
}) {
  const repository = SourceDatabaseMessageLensArchiveLineageEvidenceRepository(
    sourceDatabaseOpener: SqfliteSourceDatabaseOpener(),
  );
  final verifier = MessageLensAttachmentRecoveryLineageVerifier(
    evidenceRepository: repository,
    authoritativeCurrentMessagesDatabasePath: currentPath,
  );
  return verifier.verifyDonor(donorImportDatabasePath: donorPath);
}

void _createDonor(
  String path, {
  required int count,
  bool includeLiveSource = true,
  int? inconsistentRowId,
}) {
  final database = sqlite3.open(path);
  try {
    database.execute('''
      CREATE TABLE source_registry (
        source_id INTEGER PRIMARY KEY,
        source_key TEXT NOT NULL UNIQUE,
        source_kind TEXT NOT NULL
      );
      CREATE TABLE messages (
        ss_id INTEGER PRIMARY KEY,
        source_id INTEGER NOT NULL,
        source_rowid INTEGER NOT NULL,
        guid TEXT NOT NULL,
        UNIQUE(source_id, source_rowid)
      );
    ''');
    if (includeLiveSource) {
      database.execute(
        'INSERT INTO source_registry '
        '(source_id, source_key, source_kind) VALUES (?, ?, ?)',
        <Object?>[
          liveChatDbSourceId,
          liveChatDbSourceKey,
          liveChatDbSourceKind,
        ],
      );
      for (var rowId = 1; rowId <= count; rowId++) {
        final packedRowId = rowId == inconsistentRowId ? rowId + 1000 : rowId;
        database.execute(
          'INSERT INTO messages '
          '(ss_id, source_id, source_rowid, guid) VALUES (?, ?, ?, ?)',
          <Object?>[
            SourceScopedRowKey.pack(
              sourceId: liveChatDbSourceId,
              sourceRowId: packedRowId,
            ),
            liveChatDbSourceId,
            rowId,
            'guid-$rowId',
          ],
        );
      }
    } else {
      database.execute(
        'INSERT INTO source_registry '
        '(source_id, source_key, source_kind) VALUES (3, ?, ?)',
        <Object?>[
          'historical-messages-archive:/Archive/chat.db',
          historicalMessagesArchiveSourceKind,
        ],
      );
    }
  } finally {
    database.dispose();
  }
}

void _createCurrent(
  String path, {
  required int count,
  String Function(int rowId)? guidForRowId,
  Map<int, String> extraRows = const <int, String>{},
}) {
  final database = sqlite3.open(path);
  try {
    database.execute('''
      CREATE TABLE message (
        ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
        guid TEXT UNIQUE NOT NULL
      );
    ''');
    for (var rowId = 1; rowId <= count; rowId++) {
      database.execute(
        'INSERT INTO message (ROWID, guid) VALUES (?, ?)',
        <Object?>[rowId, guidForRowId?.call(rowId) ?? 'guid-$rowId'],
      );
    }
    for (final MapEntry(key: rowId, value: guid) in extraRows.entries) {
      database.execute(
        'INSERT INTO message (ROWID, guid) VALUES (?, ?)',
        <Object?>[rowId, guid],
      );
    }
  } finally {
    database.dispose();
  }
}
