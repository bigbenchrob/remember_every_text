import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_database_keys.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_query_layer.dart';
import 'package:remember_this_text/essentials/db/infrastructure/repositories/database_health_audit_queries.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  group('database health read-only SQL guard', () {
    test('allows select with and metadata pragma queries', () {
      expect(
        () => assertDatabaseHealthReadOnlySql('SELECT 1'),
        returnsNormally,
      );
      expect(
        () => assertDatabaseHealthReadOnlySql(
          'WITH rows AS (SELECT 1) SELECT * FROM rows',
        ),
        returnsNormally,
      );
      expect(
        () => assertDatabaseHealthReadOnlySql('PRAGMA user_version'),
        returnsNormally,
      );
      expect(
        () => assertDatabaseHealthReadOnlySql('PRAGMA table_info("messages")'),
        returnsNormally,
      );
      expect(
        () => assertDatabaseHealthReadOnlySql('SELECT 1;'),
        returnsNormally,
      );
    });

    test('rejects write and broad pragma queries before execution', () {
      expect(
        () => assertDatabaseHealthReadOnlySql('INSERT INTO probe VALUES (1)'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => assertDatabaseHealthReadOnlySql('PRAGMA journal_mode = WAL'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => assertDatabaseHealthReadOnlySql('SELECT 1; DROP TABLE probe'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => assertDatabaseHealthReadOnlySql(
          'WITH removed AS (DELETE FROM probe RETURNING *) SELECT * FROM removed',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('RetiredCleanupSqliteFileHealthQueryLayer', () {
    test('does not create a missing database file during inspection', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'database_health_query_layer_',
      );
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final missingPath = '${tempDir.path}/retired_working.db';
      final layer = RetiredCleanupSqliteFileHealthQueryLayer(
        databaseKey: databaseHealthKeyRetiredWorking,
        role: databaseHealthRoleRetiredWorkingCleanup,
        databasePath: missingPath,
      );

      expect(await layer.databaseFileExists(), isFalse);
      expect(File(missingPath).existsSync(), isFalse);

      await expectLater(
        layer.query('SELECT 1 AS ok'),
        throwsA(isA<StateError>()),
      );
      expect(File(missingPath).existsSync(), isFalse);
    });

    test('reads existing database files without mutating them', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'database_health_query_layer_',
      );
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final databasePath = '${tempDir.path}/retired_macos_import.db';
      final created = sqlite3.sqlite3.open(databasePath);
      try {
        created
          ..execute('CREATE TABLE probe (value INTEGER NOT NULL)')
          ..execute('INSERT INTO probe (value) VALUES (42)');
      } finally {
        created.dispose();
      }
      final lastModifiedBefore = File(databasePath).lastModifiedSync();

      final layer = RetiredCleanupSqliteFileHealthQueryLayer(
        databaseKey: databaseHealthKeyRetiredMacosImport,
        role: databaseHealthRoleRetiredMacosImportCleanup,
        databasePath: databasePath,
      );

      expect(await layer.databaseFileExists(), isTrue);
      expect(
        await layer.query('SELECT value FROM probe'),
        <Map<String, Object?>>[
          <String, Object?>{'value': 42},
        ],
      );
      expect(File(databasePath).lastModifiedSync(), lastModifiedBefore);
    });

    test('rejects write queries against retired cleanup files', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'database_health_query_layer_',
      );
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final databasePath = '${tempDir.path}/retired_macos_import.db';
      final created = sqlite3.sqlite3.open(databasePath);
      try {
        created
          ..execute('CREATE TABLE probe (value INTEGER NOT NULL)')
          ..execute('INSERT INTO probe (value) VALUES (42)');
      } finally {
        created.dispose();
      }

      final layer = RetiredCleanupSqliteFileHealthQueryLayer(
        databaseKey: databaseHealthKeyRetiredMacosImport,
        role: databaseHealthRoleRetiredMacosImportCleanup,
        databasePath: databasePath,
      );

      await expectLater(
        layer.query('INSERT INTO probe (value) VALUES (99)'),
        throwsA(isA<StateError>()),
      );

      final verification = sqlite3.sqlite3.open(databasePath);
      try {
        final values = verification.select(
          'SELECT value FROM probe ORDER BY value',
        );
        expect(<int>[for (final row in values) row['value'] as int], <int>[42]);
      } finally {
        verification.dispose();
      }
    });
  });
}
