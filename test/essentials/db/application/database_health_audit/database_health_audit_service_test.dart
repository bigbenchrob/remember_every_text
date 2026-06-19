import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_models.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_report_writer.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_service.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_query_layer.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_runtime_environment.dart';

void main() {
  group('DatabaseHealthAuditService', () {
    test(
      'uses injected full disk access state in environment report',
      () async {
        final service = _buildService(
          hasFullDiskAccess: false,
          queryLayers: const [],
        );

        final report = await service.buildPhase1Report();

        expect(report.environment.hasFullDiskAccess, isFalse);
      },
    );

    test(
      'curates source-scoped graph databases in the health report',
      () async {
        final service = _buildService(
          hasFullDiskAccess: true,
          queryLayers: <DatabaseHealthQueryLayer>[
            _FakeHealthQueryLayer(
              databaseKey: 'source_scoped_import',
              role: 'source_scoped_import_ledger',
            ),
            _FakeHealthQueryLayer(
              databaseKey: 'conversation_graph',
              role: 'application_primary_source_scoped_graph',
            ),
          ],
        );

        final report = await service.buildPhase1Report();

        expect(
          report.tableInventory,
          contains(
            isA<TableInventoryEntry>()
                .having(
                  (entry) => entry.databaseKey,
                  'databaseKey',
                  'source_scoped_import',
                )
                .having((entry) => entry.tableName, 'tableName', 'messages'),
          ),
        );
        expect(
          report.tableInventory,
          contains(
            isA<TableInventoryEntry>()
                .having(
                  (entry) => entry.databaseKey,
                  'databaseKey',
                  'conversation_graph',
                )
                .having(
                  (entry) => entry.tableName,
                  'tableName',
                  'contact_to_handle',
                ),
          ),
        );
        expect(
          report.relationshipChecks.map((check) => check.checkKey),
          contains('contact_to_handle_to_handles_by_ss_id'),
        );
        expect(
          report.invariantChecks.map((check) => check.checkKey),
          contains('graph_contact_handle_edges_should_reference_rows'),
        );
        expect(report.errors, isEmpty);
      },
    );

    test('treats retained archive metadata database as metadata only', () async {
      final service = _buildService(
        hasFullDiskAccess: true,
        queryLayers: <DatabaseHealthQueryLayer>[
          _FakeHealthQueryLayer(
            databaseKey: 'import',
            role: 'retained_archive_metadata',
          ),
        ],
      );

      final report = await service.buildPhase1Report();
      final retainedMetadataTables = report.tableInventory
          .where((entry) => entry.databaseKey == 'import')
          .map((entry) => entry.tableName)
          .toSet();

      expect(
        retainedMetadataTables,
        containsAll(<String>{
          'schema_migrations',
          'historical_archive_sources',
        }),
      );
      expect(retainedMetadataTables, isNot(contains('messages')));
      expect(retainedMetadataTables, isNot(contains('import_batches')));
      expect(
        report.tableInventory
            .singleWhere(
              (entry) =>
                  entry.databaseKey == 'import' &&
                  entry.tableName == 'historical_archive_sources',
            )
            .notes,
        contains(
          'Retained archive-source metadata only; source facts live in source-scoped import.',
        ),
      );
      expect(
        report.relationshipChecks
            .where((check) => check.databaseKey == 'import')
            .map((check) => check.checkKey),
        isEmpty,
      );
      expect(report.invariantChecks, isEmpty);
      expect(report.errors, isEmpty);
    });

    test(
      'treats retained working database as historical reference only',
      () async {
        final service = _buildService(
          hasFullDiskAccess: true,
          queryLayers: <DatabaseHealthQueryLayer>[
            _FakeHealthQueryLayer(
              databaseKey: 'working',
              role: 'retained_historical_reference',
            ),
          ],
        );

        final report = await service.buildPhase1Report();
        final retainedWorkingTables = report.tableInventory
            .where((entry) => entry.databaseKey == 'working')
            .map((entry) => entry.tableName)
            .toSet();

        expect(
          retainedWorkingTables,
          containsAll(<String>{
            'schema_migrations',
            'projection_state',
            'recovered_unlinked_messages',
            'recovered_unlinked_attachments',
          }),
        );
        expect(retainedWorkingTables, isNot(contains('messages')));
        expect(retainedWorkingTables, isNot(contains('chats')));
        expect(retainedWorkingTables, isNot(contains('global_message_index')));
        expect(
          report.tableInventory
              .singleWhere(
                (entry) =>
                    entry.databaseKey == 'working' &&
                    entry.tableName == 'projection_state',
              )
              .notes,
          contains(
            'Retained historical projection-state metadata only; not an app-facing readiness source.',
          ),
        );
        expect(
          report.relationshipChecks
              .where((check) => check.databaseKey == 'working')
              .map((check) => check.checkKey),
          contains('recovered_unlinked_attachments_to_messages_by_guid'),
        );
        expect(
          report.relationshipChecks
              .where((check) => check.databaseKey == 'working')
              .map((check) => check.checkKey),
          isNot(contains('messages_to_chats')),
        );
        expect(
          report.invariantChecks.map((check) => check.checkKey),
          contains('projection_state_singleton_should_exist'),
        );
        expect(
          report.invariantChecks.map((check) => check.checkKey),
          isNot(contains('working_messages_should_have_chat_linkage')),
        );
        expect(report.errors, isEmpty);
      },
    );

    test(
      'does not inventory a retained database when its file is absent',
      () async {
        final service = _buildService(
          hasFullDiskAccess: true,
          queryLayers: <DatabaseHealthQueryLayer>[
            _FakeHealthQueryLayer(
              databaseKey: 'working',
              role: 'retained_historical_reference',
              fileExists: false,
            ),
          ],
        );

        final report = await service.buildPhase1Report();

        expect(report.databases.single.databaseKey, 'working');
        expect(report.databases.single.accessible, isFalse);
        expect(report.databases.single.readOnlyOpenSucceeded, isFalse);
        expect(report.tableInventory, isEmpty);
        expect(report.relationshipChecks, isEmpty);
        expect(report.invariantChecks, isEmpty);
        expect(report.errors, isEmpty);
      },
    );
  });
}

DatabaseHealthAuditService _buildService({
  required bool hasFullDiskAccess,
  required List<DatabaseHealthQueryLayer> queryLayers,
}) {
  return DatabaseHealthAuditService(
    hasFullDiskAccess: hasFullDiskAccess,
    queryLayers: queryLayers,
    runtimeEnvironment: const _FakeRuntimeEnvironment(),
    reportWriter: const _FakeReportWriter(),
  );
}

class _FakeRuntimeEnvironment implements DatabaseHealthRuntimeEnvironment {
  const _FakeRuntimeEnvironment();

  @override
  DatabaseHealthRuntimeEnvironmentSnapshot read() {
    return const DatabaseHealthRuntimeEnvironmentSnapshot(
      platform: 'test',
      platformVersion: 'test-version',
      timezone: 'test-zone',
    );
  }
}

class _FakeReportWriter implements DatabaseHealthAuditReportWriter {
  const _FakeReportWriter();

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    return '$outputDirectoryPath/database_health.json';
  }
}

class _FakeHealthQueryLayer extends DatabaseHealthQueryLayer {
  _FakeHealthQueryLayer({
    required this.databaseKey,
    required this.role,
    this.fileExists = true,
  });

  @override
  final String databaseKey;

  @override
  final String role;

  final bool fileExists;

  @override
  String get databasePath => '/tmp/$databaseKey.db';

  @override
  Future<bool> databaseFileExists() async => fileExists;

  @override
  Future<List<Map<String, Object?>>> query(String sql) async {
    if (!fileExists) {
      throw StateError('Fake database file is absent');
    }
    final normalized = sql.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized == 'SELECT 1 AS ok') {
      return <Map<String, Object?>>[
        <String, Object?>{'ok': 1},
      ];
    }
    if (normalized == 'SELECT 1 AS c') {
      return <Map<String, Object?>>[
        <String, Object?>{'c': 1},
      ];
    }
    if (normalized == 'PRAGMA user_version') {
      return <Map<String, Object?>>[
        <String, Object?>{'user_version': 1},
      ];
    }
    if (normalized.startsWith('SELECT name FROM sqlite_master')) {
      return _tablesFor(
        databaseKey,
      ).map((table) => <String, Object?>{'name': table}).toList();
    }
    if (normalized.startsWith('PRAGMA table_info')) {
      return const <Map<String, Object?>>[];
    }
    if (normalized.startsWith('SELECT COUNT(*) AS c')) {
      return <Map<String, Object?>>[
        <String, Object?>{'c': 0},
      ];
    }
    if (normalized.startsWith('SELECT CASE WHEN EXISTS')) {
      return <Map<String, Object?>>[
        <String, Object?>{'c': 0},
      ];
    }
    if (normalized.startsWith('SELECT SUM(CASE')) {
      return <Map<String, Object?>>[
        <String, Object?>{
          'null_count': 0,
          'non_null_count': 0,
          'distinct_count': 0,
        },
      ];
    }
    throw UnsupportedError('Unexpected fake health query: $normalized');
  }

  List<String> _tablesFor(String key) {
    return switch (key) {
      'import' => const <String>[
        'schema_migrations',
        'historical_archive_sources',
      ],
      'working' => const <String>[
        'schema_migrations',
        'projection_state',
        'recovered_unlinked_messages',
        'recovered_unlinked_attachments',
      ],
      'source_scoped_import' => const <String>[
        'source_registry',
        'import_batches',
        'messages',
        'handles',
        'chats',
        'chat_to_message',
        'chat_to_handle',
        'contacts',
        'contact_channels',
        'attachments',
        'message_to_attachment',
      ],
      'conversation_graph' => const <String>[
        'messages',
        'handles',
        'canonical_handles',
        'handle_aliases',
        'chats',
        'chat_to_message',
        'chat_to_handle',
        'contacts',
        'contact_to_handle',
        'attachments',
        'message_to_attachment',
      ],
      _ => const <String>[],
    };
  }
}
