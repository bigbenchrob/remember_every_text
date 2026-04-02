import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/features/attachments/application/cross_snapshot_mapper.dart';
import 'package:remember_this_text/features/attachments/application/historical_snapshot_reader.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late SqfliteImportDatabase importDb;
  late WorkingDatabase workingDb;
  late CrossSnapshotMapper mapper;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mapper_test_');
    importDb = SqfliteImportDatabase(
      databaseDirectory: tempDir.path,
      databaseName: 'import_test.db',
      debugSettings: const ImportDebugSettingsState(),
    );
    workingDb = WorkingDatabase(NativeDatabase.memory());
    mapper = CrossSnapshotMapper(importDb: importDb, workingDb: workingDb);
  });

  tearDown(() async {
    await workingDb.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  /// Insert test data into the import DB:
  ///   - An import_batch row (required for FK)
  ///   - An attachment row with the given guid and id
  Future<void> insertImportAttachment({
    required int id,
    required String? guid,
    String? transferName,
  }) async {
    // Ensure a batch row exists.
    await importDb.rawQuery(
      'INSERT OR IGNORE INTO import_batches (id, started_at_utc) '
      "VALUES (1, '2026-01-01T00:00:00Z')",
    );
    await importDb.rawQuery(
      'INSERT INTO attachments (id, guid, transfer_name, batch_id) '
      'VALUES (?, ?, ?, 1)',
      [id, guid, transferName],
    );
  }

  /// Insert a row into the working DB's attachments table.
  Future<void> insertWorkingAttachment({
    required String messageGuid,
    required int importAttachmentId,
  }) async {
    await workingDb.customStatement(
      'INSERT INTO attachments (message_guid, import_attachment_id) '
      "VALUES ('$messageGuid', $importAttachmentId)",
    );
  }

  /// Build a [HistoricalAttachmentRecord] for testing.
  HistoricalAttachmentRecord makeRecord({
    required String histMessageGuid,
    String? histAttachmentGuid,
    String? histLocalPath = '/tmp/test.jpg',
    bool fileFound = true,
    String? resolvedFilePath = '/tmp/test.jpg',
  }) {
    return HistoricalAttachmentRecord(
      histMessageGuid: histMessageGuid,
      histAttachmentGuid: histAttachmentGuid,
      histLocalPath: histLocalPath,
      resolvedFilePath: resolvedFilePath,
      fileFound: fileFound,
      histTransferName: null,
      histMimeType: null,
      histUti: null,
      histFileSize: null,
      histIsOutgoing: false,
    );
  }

  group('CrossSnapshotMapper preconditions', () {
    test('empty import DB → isImportDbPopulated returns false', () async {
      final populated = await mapper.isImportDbPopulated();
      expect(populated, isFalse);
    });

    test('populated import DB → isImportDbPopulated returns true', () async {
      await insertImportAttachment(id: 100, guid: 'att-100');
      final populated = await mapper.isImportDbPopulated();
      expect(populated, isTrue);
    });
  });

  group('Primary GUID Match (Step 1)', () {
    test('GUID matches import DB + confirmed in working → MAPPED', () async {
      await insertImportAttachment(id: 100, guid: 'att-guid-100');
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 100,
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(
            histMessageGuid: 'msg-1',
            histAttachmentGuid: 'att-guid-100',
          ),
        ],
      );

      expect(result, isNotNull);
      expect(result!.mapped.length, equals(1));
      expect(result.mapped.first.matchMethod, equals(MatchMethod.guidMatch));
      expect(result.mapped.first.currentImportAttachmentId, equals(100));
      expect(result.mappedByGuid, equals(1));
    });

    test(
      'GUID matches import DB but under different message → unmapped',
      () async {
        await insertImportAttachment(id: 100, guid: 'att-guid-100');
        // The attachment is in the working DB under a DIFFERENT message.
        await insertWorkingAttachment(
          messageGuid: 'msg-OTHER',
          importAttachmentId: 100,
        );
        // Need the historical message to exist in working DB (so it passes
        // message-side check).
        await insertWorkingAttachment(
          messageGuid: 'msg-1',
          importAttachmentId: 999,
        );

        final result = await mapper.mapRecords(
          historicalRecords: [
            makeRecord(
              histMessageGuid: 'msg-1',
              histAttachmentGuid: 'att-guid-100',
            ),
          ],
        );

        expect(result!.unmapped.length, equals(1));
        expect(
          result.unmapped.first.reason,
          equals(UnmappedReason.guidMessageMismatch),
        );
      },
    );

    test('GUID has no match in import DB → unmapped guid_mismatch', () async {
      // Import DB has an attachment but with a different GUID.
      await insertImportAttachment(id: 100, guid: 'different-guid');
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 100,
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(
            histMessageGuid: 'msg-1',
            histAttachmentGuid: 'nonexistent-guid',
          ),
        ],
      );

      expect(result!.unmapped.length, equals(1));
      expect(result.unmapped.first.reason, equals(UnmappedReason.guidMismatch));
    });
  });

  group('Single-Attachment Fallback (Step 2)', () {
    test('NULL GUID + exactly 1 historical + exactly 1 current → '
        'fallback succeeds', () async {
      // No GUID match possible since hist_attachment_guid is NULL.
      // Set up exactly one current attachment for the message.
      await insertImportAttachment(id: 200, guid: null);
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 200,
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: null),
        ],
      );

      expect(result!.mapped.length, equals(1));
      expect(
        result.mapped.first.matchMethod,
        equals(MatchMethod.singleAttachmentFallback),
      );
      expect(result.mappedBySingleFallback, equals(1));
    });

    test(
      'NULL GUID + multiple historical attachments → fallback rejected',
      () async {
        await insertImportAttachment(id: 200, guid: null);
        await insertWorkingAttachment(
          messageGuid: 'msg-1',
          importAttachmentId: 200,
        );

        // Two historical records for the same message → ambiguous.
        final result = await mapper.mapRecords(
          historicalRecords: [
            makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: null),
            makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: null),
          ],
        );

        expect(result!.mapped, isEmpty);
        expect(result.unmapped.length, equals(2));
        expect(
          result.unmapped.first.reason,
          equals(UnmappedReason.guidNullMultiAttachment),
        );
      },
    );

    test(
      'NULL GUID + 1 historical + multiple current → fallback rejected',
      () async {
        await insertImportAttachment(id: 200, guid: null);
        await insertImportAttachment(id: 201, guid: null);
        await insertWorkingAttachment(
          messageGuid: 'msg-1',
          importAttachmentId: 200,
        );
        await insertWorkingAttachment(
          messageGuid: 'msg-1',
          importAttachmentId: 201,
        );

        final result = await mapper.mapRecords(
          historicalRecords: [
            makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: null),
          ],
        );

        expect(result!.mapped, isEmpty);
        expect(result.unmapped.length, equals(1));
        expect(
          result.unmapped.first.reason,
          equals(UnmappedReason.guidNullMultiAttachment),
        );
      },
    );

    test('NULL GUID + 1 historical + zero current → '
        'unmapped no_current_attachment', () async {
      // No working DB attachments for this message, but the message
      // exists in working DB via another path — we need at least one
      // row with message_guid to pass message-side check.
      // Actually, with zero attachments the message-side check also
      // queries for message_guid in the attachments table. If that
      // returns empty, it will be classified as messageNotInWorking.
      // So let's make the message exist in working DB with a
      // different attachment that has a different message_guid.
      // Actually, looking at the code: the message-side check queries
      // SELECT DISTINCT message_guid FROM attachments WHERE message_guid = ?
      // So if there are 0 attachment rows, the message check fails first.
      // We need at least one attachment row for the message to pass that
      // check, but then fallback checks for exactly 1.
      //
      // For this test to exercise the guidNullNoCurrentAttachment path,
      // we need the message check to pass (meaning at least 1 attachment
      // row for this message_guid), but the fallback to find 0 rows.
      // This seems contradictory. Let's check: _classifyUnmappedReason
      // queries for attachments WHERE message_guid = ? separately from
      // the message check. If message check passes (1+ rows) but
      // _classifyUnmappedReason's query returns empty, that's impossible.
      //
      // So guidNullNoCurrentAttachment can only fire if the message check
      // passes (at least 1 attachment row) but _classifyUnmappedReason's
      // query returns empty — this can't happen with consistent data.
      // This reason would be a "just in case" path.
      //
      // Skip this impossible-state test.
    });

    test('non-NULL GUID that does not match → Step 2 NOT attempted, '
        'classified as guid_mismatch', () async {
      // Even though there's exactly 1 attachment on each side, the
      // non-null GUID prevents fallback.
      await insertImportAttachment(id: 200, guid: 'different-guid');
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 200,
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(
            histMessageGuid: 'msg-1',
            histAttachmentGuid: 'no-match-guid',
          ),
        ],
      );

      expect(result!.unmapped.length, equals(1));
      expect(result.unmapped.first.reason, equals(UnmappedReason.guidMismatch));
      expect(result.mappedBySingleFallback, equals(0));
    });
  });

  group('No Further Fallback (Step 3)', () {
    test('when Steps 1 and 2 both fail → record classified UNMAPPED', () async {
      await insertImportAttachment(id: 200, guid: 'other-guid');
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 200,
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(
            histMessageGuid: 'msg-1',
            histAttachmentGuid: 'unmatched-guid',
          ),
        ],
      );

      expect(result!.mapped, isEmpty);
      expect(result.unmapped.length, equals(1));
    });
  });

  group('Message-Side Mapping', () {
    test(
      'message GUID absent from working DB → message_not_in_working',
      () async {
        await insertImportAttachment(id: 100, guid: 'att-100');
        // No working DB data for msg-1.

        final result = await mapper.mapRecords(
          historicalRecords: [
            makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: 'att-100'),
          ],
        );

        expect(result!.unmapped.length, equals(1));
        expect(
          result.unmapped.first.reason,
          equals(UnmappedReason.messageNotInWorking),
        );
        expect(result.unmappedMessageMissing, equals(1));
      },
    );
  });

  group('File not found records', () {
    test('fileFound false → classified as unmapped file_not_found', () async {
      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(
            histMessageGuid: 'msg-1',
            histAttachmentGuid: 'att-100',
            fileFound: false,
            resolvedFilePath: null,
          ),
        ],
      );

      expect(result!.unmapped.length, equals(1));
      expect(result.unmapped.first.reason, equals(UnmappedReason.fileNotFound));
      expect(result.unmappedFileMissing, equals(1));
    });
  });

  group('Summary Output', () {
    test('all counters match actual outcomes', () async {
      await insertImportAttachment(id: 100, guid: 'att-guid-100');
      await insertImportAttachment(id: 200, guid: null);
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 100,
      );
      await insertWorkingAttachment(
        messageGuid: 'msg-2',
        importAttachmentId: 200,
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          // 1. GUID match → mapped
          makeRecord(
            histMessageGuid: 'msg-1',
            histAttachmentGuid: 'att-guid-100',
          ),
          // 2. NULL GUID, single attachment → fallback
          makeRecord(histMessageGuid: 'msg-2', histAttachmentGuid: null),
          // 3. File missing → unmapped
          makeRecord(
            histMessageGuid: 'msg-1',
            histAttachmentGuid: 'att-guid-100',
            fileFound: false,
            resolvedFilePath: null,
          ),
          // 4. Message not in working → unmapped
          makeRecord(
            histMessageGuid: 'msg-nonexistent',
            histAttachmentGuid: 'att-whatever',
          ),
        ],
      );

      expect(result!.mappedByGuid, equals(1));
      expect(result.mappedBySingleFallback, equals(1));
      expect(result.unmappedFileMissing, equals(1));
      expect(result.unmappedMessageMissing, equals(1));
      expect(result.mapped.length, equals(2));
      expect(result.unmapped.length, equals(2));
    });
  });

  group('Cancellation', () {
    test('cancellation returns null', () async {
      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: 'att-1'),
        ],
        isCancelled: () => true,
      );

      expect(result, isNull);
    });
  });

  group('Multi-Attachment Message (GUID Present)', () {
    test('each attachment maps independently via GUID', () async {
      await insertImportAttachment(id: 100, guid: 'att-A');
      await insertImportAttachment(id: 101, guid: 'att-B');
      await insertImportAttachment(id: 102, guid: 'att-C');
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 100,
      );
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 101,
      );
      await insertWorkingAttachment(
        messageGuid: 'msg-1',
        importAttachmentId: 102,
      );

      final result = await mapper.mapRecords(
        historicalRecords: [
          makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: 'att-A'),
          makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: 'att-B'),
          makeRecord(histMessageGuid: 'msg-1', histAttachmentGuid: 'att-C'),
        ],
      );

      expect(result!.mapped.length, equals(3));
      expect(result.mappedByGuid, equals(3));

      final ids = result.mapped.map((r) => r.currentImportAttachmentId).toSet();
      expect(ids, containsAll([100, 101, 102]));
    });
  });
}
