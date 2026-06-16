import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/contact_projection_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importLedgerDatabase;
  late ConversationGraphDatabase graphDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('contact_projector_test_');
    importLedgerDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
    graphDatabase = await openConversationGraphTestDatabase();
  });

  tearDown(() async {
    await importLedgerDatabase.close();
    await graphDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('projects meaningful contacts and source-scoped handle edges', () async {
    final handleSsId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 12);
    await graphDatabase.database.insert('handles', <String, Object?>{
      'ss_id': handleSsId,
      'id': '+16049995969',
      'service': 'iMessage',
    });
    await graphDatabase.database.insert('canonical_handles', <String, Object?>{
      'canonical_handle_ss_id': handleSsId,
      'display_handle': '+16049995969',
      'normalized_identifier': '6049995969',
      'service': 'iMessage',
      'alias_count': 1,
    });
    await graphDatabase.database.insert('handle_aliases', <String, Object?>{
      'handle_ss_id': handleSsId,
      'canonical_handle_ss_id': handleSsId,
      'raw_identifier': '+16049995969',
      'normalized_identifier': '6049995969',
      'alias_kind': 'canonical',
    });

    final contactSsId = await _insertImportContact(
      importLedgerDatabase,
      sourceRowId: 24,
      displayName: 'Cathie Campbell',
      firstName: 'Cathie',
      lastName: 'Campbell',
    );
    await _insertImportContactChannel(
      importLedgerDatabase,
      contactSsId: contactSsId,
      sourceContactRowId: 24,
      value: '6049995969',
    );
    await _insertImportContact(
      importLedgerDatabase,
      sourceRowId: 25,
      displayName: 'Unknown Contact',
    );

    final result = await ContactProjector(
      repository: SqliteContactProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectContacts();

    expect(result.examinedContactCount, 2);
    expect(result.insertedContactCount, 1);
    expect(result.insertedContactHandleEdgeCount, 1);

    final contacts = await graphDatabase.database.query('contacts');
    expect(contacts.single['contact_id'], contactSsId);
    expect(contacts.single['display_name'], 'Cathie Campbell');
    expect(contacts.single.containsKey('source_id'), isFalse);

    final edges = await graphDatabase.database.query('contact_to_handle');
    expect(edges.single['contact_id'], contactSsId);
    expect(edges.single['handle_ss_id'], handleSsId);
    expect(edges.single['handle_value'], '6049995969');

    final secondResult = await ContactProjector(
      repository: SqliteContactProjectionRepository(
        importLedgerDatabase: importLedgerDatabase,
        graphDatabase: graphDatabase,
      ),
    ).projectContacts();
    expect(secondResult.insertedContactCount, 0);
    expect(secondResult.insertedContactHandleEdgeCount, 0);
  });

  test(
    'projects meaningful contacts even when no graph handle currently matches',
    () async {
      final contactSsId = await _insertImportContact(
        importLedgerDatabase,
        sourceRowId: 31,
        displayName: 'Future Sender',
        firstName: 'Future',
        lastName: 'Sender',
      );

      final result = await ContactProjector(
        repository: SqliteContactProjectionRepository(
          importLedgerDatabase: importLedgerDatabase,
          graphDatabase: graphDatabase,
        ),
      ).projectContacts();

      expect(result.examinedContactCount, 1);
      expect(result.insertedContactCount, 1);
      expect(result.insertedContactHandleEdgeCount, 0);

      final contacts = await graphDatabase.database.query('contacts');
      expect(contacts.single['contact_id'], contactSsId);
      expect(contacts.single['display_name'], 'Future Sender');

      final edges = await graphDatabase.database.query('contact_to_handle');
      expect(edges, isEmpty);
    },
  );
}

Future<int> _insertImportContact(
  ImportDatabase importLedgerDatabase, {
  required int sourceRowId,
  required String displayName,
  String? firstName,
  String? lastName,
}) async {
  final contactSsId = SourceScopedRowKey.pack(
    sourceId: liveAddressBookSourceId,
    sourceRowId: sourceRowId,
  );
  final batchId = await importLedgerDatabase.insertImportBatch(
    sourceId: liveAddressBookSourceId,
    startedAtUtc: '2026-05-21T00:00:00.000Z',
  );
  await importLedgerDatabase.database.insert('contacts', <String, Object?>{
    'ss_id': contactSsId,
    'source_id': liveAddressBookSourceId,
    'source_rowid': sourceRowId,
    'display_name': displayName,
    'first_name': firstName,
    'last_name': lastName,
    'batch_id': batchId,
  });
  return contactSsId;
}

Future<void> _insertImportContactChannel(
  ImportDatabase importLedgerDatabase, {
  required int contactSsId,
  required int sourceContactRowId,
  required String value,
}) async {
  final batchId = await importLedgerDatabase.insertImportBatch(
    sourceId: liveAddressBookSourceId,
    startedAtUtc: '2026-05-21T00:00:00.000Z',
  );
  await importLedgerDatabase.database
      .insert('contact_channels', <String, Object?>{
        'source_id': liveAddressBookSourceId,
        'source_contact_rowid': sourceContactRowId,
        'contact_ss_id': contactSsId,
        'kind': 'phone',
        'value': value,
        'batch_id': batchId,
      });
}
