import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/contacts/contact_handle_keys.dart';
import '../../application/contacts/contact_projection_repository.dart';

class SqliteContactProjectionRepository implements ContactProjectionRepository {
  const SqliteContactProjectionRepository({
    required this.importLedgerDatabase,
    required this.graphDatabase,
  });

  final ImportLedger importLedgerDatabase;
  final ConversationGraphDatabase graphDatabase;

  @override
  Future<ContactProjectionResult> projectContacts() async {
    final contactRows = await importLedgerDatabase.queryTable(
      'contacts',
      columns: <String>[
        'ss_id',
        'display_name',
        'first_name',
        'last_name',
        'organization',
      ],
      orderBy: 'ss_id ASC',
    );
    final channelRows = await importLedgerDatabase.queryTable(
      'contact_channels',
      columns: <String>['contact_ss_id', 'value'],
      orderBy: 'contact_ss_id ASC, value ASC',
    );

    final handleSsIdsByKey = await _handleSsIdsByKey();
    final channelsByContact = <int, List<String>>{};
    for (final row in channelRows) {
      final contactId = _readNullableInt(row['contact_ss_id']);
      final value = (row['value'] as String?)?.trim();
      if (contactId == null || value == null || value.isEmpty) {
        continue;
      }
      channelsByContact.putIfAbsent(contactId, () => <String>[]).add(value);
    }

    var insertedContactCount = 0;
    var insertedContactHandleEdgeCount = 0;
    await graphDatabase.transaction(() async {
      for (final row in contactRows) {
        final contactId = _requiredInt(row, 'ss_id');
        final displayName = (row['display_name'] as String?)?.trim();
        final givenName = (row['first_name'] as String?)?.trim();
        final familyName = (row['last_name'] as String?)?.trim();
        final organization = (row['organization'] as String?)?.trim();
        if (!_isProjectableContact(
          displayName: displayName,
          givenName: givenName,
          familyName: familyName,
          organization: organization,
        )) {
          continue;
        }

        final insertedContactCountDelta = await graphDatabase
            .executeAndReadChanges(
              '''
              INSERT OR IGNORE INTO contacts (
                contact_id,
                display_name,
                given_name,
                family_name,
                organization
              ) VALUES (?, ?, ?, ?, ?)
              ''',
              <Object?>[
                contactId,
                _resolvedDisplayName(
                  displayName: displayName,
                  givenName: givenName,
                  familyName: familyName,
                  organization: organization,
                ),
                givenName,
                familyName,
                organization,
              ],
            );
        if (insertedContactCountDelta != 0) {
          insertedContactCount += 1;
        }

        for (final channelValue
            in channelsByContact[contactId] ?? const <String>[]) {
          for (final key in contactHandleKeys(channelValue)) {
            final handleSsId = handleSsIdsByKey[key];
            if (handleSsId == null) {
              continue;
            }
            final insertedEdgeCountDelta = await graphDatabase
                .executeAndReadChanges(
                  '''
                  INSERT OR IGNORE INTO contact_to_handle (
                    contact_id,
                    handle_ss_id,
                    handle_value
                  ) VALUES (?, ?, ?)
                  ''',
                  <Object?>[contactId, handleSsId, channelValue],
                );
            if (insertedEdgeCountDelta != 0) {
              insertedContactHandleEdgeCount += 1;
            }
            break;
          }
        }
      }
    });

    return ContactProjectionResult(
      examinedContactCount: contactRows.length,
      insertedContactCount: insertedContactCount,
      insertedContactHandleEdgeCount: insertedContactHandleEdgeCount,
    );
  }

  Future<Map<String, int>> _handleSsIdsByKey() async {
    final rows = await graphDatabase.selectRows('''
      SELECT
        h.id AS handle_value,
        ha.canonical_handle_ss_id AS canonical_handle_ss_id,
        ha.normalized_identifier AS normalized_identifier
      FROM handles h
      JOIN handle_aliases ha ON ha.handle_ss_id = h.ss_id
      ORDER BY h.ss_id ASC
      ''');
    final result = <String, int>{};
    for (final row in rows) {
      final handleSsId = _readNullableInt(row['canonical_handle_ss_id']);
      final handleValue = (row['handle_value'] as String?)?.trim();
      final normalized = (row['normalized_identifier'] as String?)?.trim();
      if (handleSsId == null || handleValue == null || handleValue.isEmpty) {
        continue;
      }
      for (final key in contactHandleKeys(handleValue)) {
        result.putIfAbsent(key, () => handleSsId);
      }
      if (normalized != null && normalized.isNotEmpty) {
        for (final key in contactHandleKeys(normalized)) {
          result.putIfAbsent(key, () => handleSsId);
        }
      }
    }
    return result;
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    final intValue = _readNullableInt(value);
    if (intValue == null) {
      throw StateError('contacts.$field is required');
    }
    return intValue;
  }

  static int? _readNullableInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return null;
  }
}

bool _isProjectableContact({
  required String? displayName,
  required String? givenName,
  required String? familyName,
  required String? organization,
}) {
  return _isMeaningful(displayName) ||
      _isMeaningful(givenName) ||
      _isMeaningful(familyName) ||
      _isMeaningful(organization);
}

bool _isMeaningful(String? value) {
  if (value == null || value.isEmpty) {
    return false;
  }
  return value != 'Unknown Contact';
}

String _resolvedDisplayName({
  required String? displayName,
  required String? givenName,
  required String? familyName,
  required String? organization,
}) {
  return displayName ??
      organization ??
      givenName ??
      familyName ??
      'Unknown Contact';
}
