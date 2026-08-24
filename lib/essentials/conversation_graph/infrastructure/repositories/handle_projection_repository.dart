import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../db/shared/handle_identifier_utils.dart';
import '../../../source_scoped_import/domain/ports/import_ledger_port.dart';
import '../../application/handles/handle_projection_repository.dart';

class SqliteHandleProjectionRepository implements HandleProjectionRepository {
  const SqliteHandleProjectionRepository({
    required this.importLedgerDatabase,
    required this.graphDatabase,
    this.handleIdentifierInterpreter = interpretHandleIdentifier,
  });

  final ImportLedger importLedgerDatabase;
  final ConversationGraphDatabase graphDatabase;
  final HandleIdentifierInterpreter handleIdentifierInterpreter;

  @override
  Future<HandleProjectionResult> projectHandles() async {
    final rows = await importLedgerDatabase.queryTable(
      'handles',
      columns: <String>['ss_id', 'id', 'service', 'is_me'],
      orderBy: 'ss_id ASC',
    );

    var insertedHandleCount = 0;
    return graphDatabase.transaction(() async {
      for (final row in rows) {
        final isMe = row['is_me'] == 1;
        final insertedCount = await graphDatabase.executeAndReadChanges(
          '''
          INSERT OR IGNORE INTO handles (
            ss_id,
            id,
            service,
            is_me
          ) VALUES (?, ?, ?, ?)
          ''',
          <Object?>[
            row['ss_id'],
            row['id'],
            row['service'],
            if (isMe) 1 else 0,
          ],
        );
        if (insertedCount == 0) {
          await graphDatabase.executeSql(
            'UPDATE handles SET is_me = ? WHERE ss_id = ?',
            <Object?>[if (isMe) 1 else 0, row['ss_id']],
          );
        }
        if (insertedCount != 0) {
          insertedHandleCount += 1;
        }
      }
      final aliasResult = await _rebuildHandleAliases();
      await _synchronizeMessageCanonicalHandles();
      await _removeContactEdgesWithoutCanonicalHandle();

      return HandleProjectionResult(
        examinedHandleCount: rows.length,
        insertedHandleCount: insertedHandleCount,
        normalizedHandleCount: aliasResult.normalizedHandleCount,
        preservedUnnormalizedHandleCount:
            aliasResult.preservedUnnormalizedHandleCount,
      );
    });
  }

  @override
  Future<HandleIdentityProjectionResult> projectLocalAccountIdentity() async {
    final importRows = await importLedgerDatabase.queryTable(
      'handles',
      columns: const <String>['ss_id', 'is_me'],
      orderBy: 'ss_id ASC',
    );
    final graphRows = await graphDatabase.selectRows('''
      SELECT ss_id, is_me
      FROM handles
      ORDER BY ss_id ASC
      ''');
    final graphIdentityByHandleId = <int, bool>{
      for (final row in graphRows)
        if (row['ss_id'] case final int ssId) ssId: row['is_me'] == 1,
    };
    var updatedHandleCount = 0;

    await graphDatabase.transaction(() async {
      for (final row in importRows) {
        final ssId = row['ss_id'];
        if (ssId is! int || !graphIdentityByHandleId.containsKey(ssId)) {
          continue;
        }
        final isMe = row['is_me'] == 1;
        if (graphIdentityByHandleId[ssId] == isMe) {
          continue;
        }
        updatedHandleCount += await graphDatabase.executeAndReadChanges(
          'UPDATE handles SET is_me = ? WHERE ss_id = ?',
          <Object?>[if (isMe) 1 else 0, ssId],
        );
      }
    });

    return HandleIdentityProjectionResult(
      examinedHandleCount: importRows.length,
      updatedHandleCount: updatedHandleCount,
    );
  }

  Future<_HandleAliasRebuildResult> _rebuildHandleAliases() async {
    final rows = await graphDatabase.selectRows('''
      SELECT ss_id, id, service
      FROM handles
      ORDER BY ss_id ASC
      ''');
    final groups = <String, List<_ParsedHandle>>{};
    var normalizedHandleCount = 0;
    var preservedUnnormalizedHandleCount = 0;
    for (final row in rows) {
      final sourceHandle = _readSourceHandle(row);
      final interpretation = _interpretIdentifier(sourceHandle.rawIdentifier);
      switch (interpretation) {
        case NormalizedHandleIdentifier(:final normalizedIdentifier):
          normalizedHandleCount += 1;
          final parsed = _ParsedHandle(
            ssId: sourceHandle.ssId,
            rawIdentifier: sourceHandle.rawIdentifier,
            normalizedIdentifier: normalizedIdentifier,
            service: sourceHandle.service,
          );
          final group = groups.putIfAbsent(
            parsed.normalizedIdentifier,
            () => <_ParsedHandle>[],
          );
          group.add(parsed);
        case PreservedUnnormalizedHandleIdentifier():
          preservedUnnormalizedHandleCount += 1;
      }
    }

    await graphDatabase.executeSql('DELETE FROM handle_aliases');
    await graphDatabase.executeSql('DELETE FROM canonical_handles');

    for (final group in groups.values) {
      group.sort(_compareHandlePreference);
      final canonical = group.first;
      await graphDatabase.executeSql(
        '''
        INSERT INTO canonical_handles (
          canonical_handle_ss_id,
          display_handle,
          normalized_identifier,
          service,
          alias_count
        ) VALUES (?, ?, ?, ?, ?)
        ''',
        <Object?>[
          canonical.ssId,
          _displayHandle(canonical),
          canonical.normalizedIdentifier,
          canonical.service,
          group.length,
        ],
      );
      for (final alias in group) {
        await graphDatabase.executeSql(
          '''
          INSERT INTO handle_aliases (
            handle_ss_id,
            canonical_handle_ss_id,
            raw_identifier,
            normalized_identifier,
            alias_kind
          ) VALUES (?, ?, ?, ?, ?)
          ''',
          <Object?>[
            alias.ssId,
            canonical.ssId,
            alias.rawIdentifier,
            alias.normalizedIdentifier,
            if (alias.ssId == canonical.ssId) 'canonical' else 'variant',
          ],
        );
      }
    }

    return _HandleAliasRebuildResult(
      normalizedHandleCount: normalizedHandleCount,
      preservedUnnormalizedHandleCount: preservedUnnormalizedHandleCount,
    );
  }

  HandleIdentifierInterpretation _interpretIdentifier(String rawIdentifier) {
    try {
      return handleIdentifierInterpreter(rawIdentifier);
    } on HandleIdentifierNormalizationException {
      return const HandleIdentifierInterpretation.preservedUnnormalized();
    }
  }

  Future<void> _synchronizeMessageCanonicalHandles() {
    return graphDatabase.executeSql('''
      UPDATE messages
      SET sender_canonical_handle_ss_id = (
        SELECT ha.canonical_handle_ss_id
        FROM handle_aliases ha
        WHERE ha.handle_ss_id = messages.sender_handle_ss_id
      )
      WHERE sender_handle_ss_id IS NOT NULL
      ''');
  }

  Future<void> _removeContactEdgesWithoutCanonicalHandle() {
    return graphDatabase.executeSql('''
      DELETE FROM contact_to_handle
      WHERE handle_ss_id NOT IN (
        SELECT canonical_handle_ss_id
        FROM canonical_handles
      )
      ''');
  }
}

class _HandleAliasRebuildResult {
  const _HandleAliasRebuildResult({
    required this.normalizedHandleCount,
    required this.preservedUnnormalizedHandleCount,
  });

  final int normalizedHandleCount;
  final int preservedUnnormalizedHandleCount;
}

class _SourceHandle {
  const _SourceHandle({
    required this.ssId,
    required this.rawIdentifier,
    required this.service,
  });

  final int ssId;
  final String rawIdentifier;
  final String? service;
}

class _ParsedHandle {
  const _ParsedHandle({
    required this.ssId,
    required this.rawIdentifier,
    required this.normalizedIdentifier,
    required this.service,
  });

  final int ssId;
  final String rawIdentifier;
  final String normalizedIdentifier;
  final String? service;
}

_SourceHandle _readSourceHandle(Map<String, Object?> row) {
  final ssId = row['ss_id'];
  final rawIdentifier = (row['id'] as String?)?.trim();
  if (ssId is! int || rawIdentifier == null || rawIdentifier.isEmpty) {
    throw StateError('Projected handle source identity is incomplete.');
  }
  return _SourceHandle(
    ssId: ssId,
    rawIdentifier: rawIdentifier,
    service: row['service'] as String?,
  );
}

int _compareHandlePreference(_ParsedHandle left, _ParsedHandle right) {
  final leftScore = _handlePreferenceScore(left);
  final rightScore = _handlePreferenceScore(right);
  if (leftScore != rightScore) {
    return rightScore.compareTo(leftScore);
  }
  return left.ssId.compareTo(right.ssId);
}

int _handlePreferenceScore(_ParsedHandle handle) {
  final raw = handle.rawIdentifier;
  final normalized = handle.normalizedIdentifier;
  var score = 0;
  if (normalized.contains('@')) {
    if (raw.toLowerCase() == normalized) {
      score += 100;
    }
  } else {
    final rawDigits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawDigits == normalized || rawDigits.endsWith(normalized)) {
      score += 80;
    }
    if (raw.startsWith('+')) {
      score += 40;
    }
  }
  if (!raw.contains(':')) {
    score += 20;
  }
  return score;
}

String _displayHandle(_ParsedHandle handle) {
  if (handle.normalizedIdentifier.contains('@')) {
    return handle.normalizedIdentifier;
  }
  return formatPhoneNumberForDisplay(handle.rawIdentifier);
}
