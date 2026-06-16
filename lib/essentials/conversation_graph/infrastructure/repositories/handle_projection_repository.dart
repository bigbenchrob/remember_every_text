import '../../../db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../db/shared/handle_identifier_utils.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../application/handles/handle_projection_repository.dart';

class SqliteHandleProjectionRepository implements HandleProjectionRepository {
  const SqliteHandleProjectionRepository({
    required this.importLedgerDatabase,
    required this.graphDatabase,
  });

  final ImportDatabase importLedgerDatabase;
  final ConversationGraphDatabase graphDatabase;

  @override
  Future<HandleProjectionResult> projectHandles() async {
    final rows = await importLedgerDatabase.database.query(
      'handles',
      columns: <String>['ss_id', 'id', 'service'],
      orderBy: 'ss_id ASC',
    );

    var insertedHandleCount = 0;
    await graphDatabase.transaction(() async {
      for (final row in rows) {
        final insertedCount = await graphDatabase.executeAndReadChanges(
          '''
          INSERT OR IGNORE INTO handles (
            ss_id,
            id,
            service
          ) VALUES (?, ?, ?)
          ''',
          <Object?>[row['ss_id'], row['id'], row['service']],
        );
        if (insertedCount != 0) {
          insertedHandleCount += 1;
        }
      }
      await _rebuildHandleAliases();
    });

    return HandleProjectionResult(
      examinedHandleCount: rows.length,
      insertedHandleCount: insertedHandleCount,
    );
  }

  Future<void> _rebuildHandleAliases() async {
    final rows = await graphDatabase.selectRows('''
      SELECT ss_id, id, service
      FROM handles
      ORDER BY ss_id ASC
      ''');
    final groups = <String, List<_ParsedHandle>>{};
    for (final row in rows) {
      final parsed = _parseHandle(row);
      if (parsed == null) {
        continue;
      }
      final group = groups.putIfAbsent(
        parsed.normalizedIdentifier,
        () => <_ParsedHandle>[],
      );
      group.add(parsed);
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
  }
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

_ParsedHandle? _parseHandle(Map<String, Object?> row) {
  final ssId = row['ss_id'];
  final rawIdentifier = (row['id'] as String?)?.trim();
  if (ssId is! int || rawIdentifier == null || rawIdentifier.isEmpty) {
    return null;
  }
  final normalizedIdentifier = buildCanonicalHandleGroupingKey(
    rawIdentifier: rawIdentifier,
  );
  return _ParsedHandle(
    ssId: ssId,
    rawIdentifier: rawIdentifier,
    normalizedIdentifier: normalizedIdentifier,
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
