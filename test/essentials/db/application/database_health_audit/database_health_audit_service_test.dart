import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_models.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_queries.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_service.dart';

void main() {
  group('DatabaseHealthAuditService', () {
    test(
      'uses injected full disk access state in environment report',
      () async {
        final service = DatabaseHealthAuditService(
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
        final service = DatabaseHealthAuditService(
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
  });
}

class _FakeHealthQueryLayer extends DatabaseHealthQueryLayer {
  _FakeHealthQueryLayer({required this.databaseKey, required this.role});

  @override
  final String databaseKey;

  @override
  final String role;

  @override
  String get databasePath => '/tmp/$databaseKey.db';

  @override
  Future<bool> databaseFileExists() async => true;

  @override
  Future<List<Map<String, Object?>>> query(String sql) async {
    final normalized = sql.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized == 'SELECT 1 AS ok') {
      return <Map<String, Object?>>[
        <String, Object?>{'ok': 1},
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
