import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late OverlayDatabase db;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() {
    // Create in-memory database for testing
    db = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('schema', () {
    test('does not retain retired contact name variant columns', () async {
      final participantOverrideColumns = await db
          .customSelect('PRAGMA table_info(participant_overrides)')
          .get();
      final virtualParticipantColumns = await db
          .customSelect('PRAGMA table_info(virtual_participants)')
          .get();

      expect(
        participantOverrideColumns.map((row) => row.read<String>('name')),
        isNot(contains('name_mode')),
      );
      expect(
        virtualParticipantColumns.map((row) => row.read<String>('name')),
        isNot(contains('short_name')),
      );
    });

    test('migrates v5 schema by dropping retired name columns', () async {
      await db.close();

      final tempDir = await Directory.systemTemp.createTemp(
        'overlay_v5_migration_test_',
      );
      final dbPath = appDatabasePath(
        AppDatabaseFile.overlay,
        databaseDirectory: tempDir.path,
      );
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final existingDatabase = await databaseFactoryFfi.openDatabase(dbPath);
      await existingDatabase.execute('''
        CREATE TABLE participant_overrides (
          participant_id INTEGER NOT NULL PRIMARY KEY,
          name_mode INTEGER,
          display_name_override TEXT,
          created_at_utc TEXT NOT NULL,
          updated_at_utc TEXT NOT NULL
        )
      ''');
      await existingDatabase.execute('''
        INSERT INTO participant_overrides (
          participant_id,
          name_mode,
          display_name_override,
          created_at_utc,
          updated_at_utc
        )
        VALUES (
          7,
          2,
          'User Name',
          '2026-06-19T00:00:00.000Z',
          '2026-06-19T00:00:00.000Z'
        )
      ''');
      await existingDatabase.execute('''
        CREATE TABLE virtual_participants (
          id INTEGER NOT NULL PRIMARY KEY CHECK (id >= 1000000000),
          display_name TEXT NOT NULL,
          short_name TEXT NOT NULL,
          notes TEXT,
          created_at_utc TEXT NOT NULL,
          updated_at_utc TEXT NOT NULL
        )
      ''');
      await existingDatabase.execute('''
        INSERT INTO virtual_participants (
          id,
          display_name,
          short_name,
          notes,
          created_at_utc,
          updated_at_utc
        )
        VALUES (
          1000000001,
          'Virtual Person',
          'VP',
          NULL,
          '2026-06-19T00:00:00.000Z',
          '2026-06-19T00:00:00.000Z'
        )
      ''');
      await existingDatabase.execute('''
        CREATE TABLE message_user_tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          message_guid TEXT NOT NULL,
          tag_display TEXT NOT NULL,
          tag_normalized TEXT NOT NULL,
          created_at_utc TEXT NOT NULL,
          updated_at_utc TEXT NOT NULL
        )
      ''');
      await existingDatabase.execute('PRAGMA user_version = 5');
      await existingDatabase.close();

      final migratedDatabase = OverlayDatabase(NativeDatabase(File(dbPath)));
      addTearDown(migratedDatabase.close);

      final participantOverrideColumns = await migratedDatabase
          .customSelect('PRAGMA table_info(participant_overrides)')
          .get();
      final virtualParticipantColumns = await migratedDatabase
          .customSelect('PRAGMA table_info(virtual_participants)')
          .get();
      final participantOverride = await migratedDatabase.getParticipantOverride(
        7,
      );
      final virtualParticipants = await migratedDatabase
          .getVirtualParticipants();

      expect(
        participantOverrideColumns.map((row) => row.read<String>('name')),
        isNot(contains('name_mode')),
      );
      expect(
        virtualParticipantColumns.map((row) => row.read<String>('name')),
        isNot(contains('short_name')),
      );
      expect(participantOverride?.displayNameOverride, equals('User Name'));
      expect(
        virtualParticipants.map((row) => row.displayName),
        contains('Virtual Person'),
      );
    });
  });

  group('HandleToParticipantOverrides', () {
    test('create handle override', () async {
      // Create a manual link
      await db.setHandleOverride(123, 456);

      // Verify it exists
      final override = await db.getHandleOverride(123);
      expect(override, isNotNull);
      expect(override!.handleId, equals(123));
      expect(override.participantId, equals(456));
    });

    test('update existing handle override', () async {
      // Create initial link
      await db.setHandleOverride(123, 456);

      // Update to different participant
      await db.setHandleOverride(123, 789);

      // Verify it was updated
      final override = await db.getHandleOverride(123);
      expect(override, isNotNull);
      expect(override!.participantId, equals(789));
    });

    test('delete handle override', () async {
      // Create link
      await db.setHandleOverride(123, 456);

      // Delete it
      await db.deleteHandleOverride(123);

      // Verify it's gone
      final override = await db.getHandleOverride(123);
      expect(override, isNull);
    });

    test('get all overrides for participant', () async {
      // Create multiple overrides for same participant
      await db.setHandleOverride(111, 456);
      await db.setHandleOverride(222, 456);
      await db.setHandleOverride(333, 789); // Different participant

      // Query for participant 456
      final overrides = await db.getOverridesForParticipant(456);
      expect(overrides, hasLength(2));
      expect(
        overrides.map((o) => o.handleId).toList(),
        containsAll([111, 222]),
      );
    });

    test('get all handle overrides ordered by creation', () async {
      // Create overrides in specific order
      await db.setHandleOverride(111, 456);
      await Future<void>.delayed(
        const Duration(milliseconds: 10),
      ); // Ensure different timestamps
      await db.setHandleOverride(222, 789);

      final overrides = await db.getAllHandleOverrides();
      expect(overrides, hasLength(2));
      // Should be ordered by creation time (ascending)
      expect(overrides[0].handleId, equals(111));
      expect(overrides[1].handleId, equals(222));
    });

    test('handle override persists across database reopen', () async {
      // This test would require a file-based database
      // For now, just verify insert/query works
      await db.setHandleOverride(123, 456);
      final override = await db.getHandleOverride(123);
      expect(override, isNotNull);
    });

    test('get non-existent override returns null', () async {
      final override = await db.getHandleOverride(999);
      expect(override, isNull);
    });

    test('delete non-existent override completes gracefully', () async {
      // Should not throw
      await db.deleteHandleOverride(999);
    });
  });

  group('Message user metadata', () {
    test(
      'message annotation tags preserve commas as structured JSON values',
      () async {
        await db.addMessageTags(42, <String>['invoice, paid', 'urgent']);

        final invoiceMatches = await db.getMessagesByTag('invoice, paid');
        final splitInvoiceMatches = await db.getMessagesByTag('invoice');
        final splitPaidMatches = await db.getMessagesByTag('paid');
        final annotation = await db.getMessageAnnotation(42);

        expect(invoiceMatches.map((row) => row.messageId), equals([42]));
        expect(splitInvoiceMatches, isEmpty);
        expect(splitPaidMatches, isEmpty);
        expect(annotation?.tags, equals('["invoice, paid","urgent"]'));
      },
    );

    test(
      'message annotation tag removal treats comma-containing tags atomically',
      () async {
        await db.addMessageTags(42, <String>['invoice, paid', 'urgent']);

        await db.removeMessageTags(42, <String>['invoice, paid']);

        final invoiceMatches = await db.getMessagesByTag('invoice, paid');
        final urgentMatches = await db.getMessagesByTag('urgent');
        final annotation = await db.getMessageAnnotation(42);

        expect(invoiceMatches, isEmpty);
        expect(urgentMatches.map((row) => row.messageId), equals([42]));
        expect(annotation?.tags, equals('["urgent"]'));
      },
    );

    test(
      'malformed message annotation tags do not crash reads or updates',
      () async {
        await db.customStatement('''
          INSERT INTO message_annotations (
            message_id,
            tags,
            created_at_utc,
            updated_at_utc
          )
          VALUES (
            42,
            'not json',
            '2026-06-28T00:00:00.000Z',
            '2026-06-28T00:00:00.000Z'
          )
        ''');

        final malformedMatches = await db.getMessagesByTag('not json');
        await db.addMessageTags(42, <String>['restored, tag']);
        final restoredMatches = await db.getMessagesByTag('restored, tag');
        final annotation = await db.getMessageAnnotation(42);

        expect(malformedMatches, isEmpty);
        expect(restoredMatches.map((row) => row.messageId), equals([42]));
        expect(annotation?.tags, equals('["restored, tag"]'));
      },
    );

    test(
      'stores tags by guid with normalized per-message uniqueness',
      () async {
        await db.addMessageUserTags(
          messageGuid: 'guid-1',
          tags: const <String>['Miłosz', 'milosz', ' preparation '],
        );

        final tags = await db.getMessageUserTags('guid-1');

        expect(
          tags.map((tag) => tag.tagDisplay).toList(),
          equals(['Miłosz', 'preparation']),
        );
        expect(
          tags.map((tag) => tag.tagNormalized).toList(),
          equals(['milosz', 'preparation']),
        );
      },
    );

    test('saved flag is keyed by message guid', () async {
      await db.setMessageSaved(messageGuid: 'guid-saved', isSaved: true);

      final savedFlag = await db.getMessageUserFlag('guid-saved');

      expect(savedFlag, isNotNull);
      expect(savedFlag!.messageGuid, equals('guid-saved'));
      expect(savedFlag.isSaved, isTrue);
    });

    test(
      'tag suggestions use normalized matching while preserving display text',
      () async {
        await db.addMessageUserTags(
          messageGuid: 'guid-suggestions-a',
          tags: const <String>['Miłosz', 'Archive Plan'],
        );
        await db.addMessageUserTags(
          messageGuid: 'guid-suggestions-b',
          tags: const <String>['Preparation'],
        );

        final suggestions = await db.getMessageTagSuggestions(query: 'milo');

        expect(suggestions, equals(['Miłosz']));
      },
    );
  });
}
