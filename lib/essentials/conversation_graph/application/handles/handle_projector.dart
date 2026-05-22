import 'package:sqflite/sqflite.dart';

import '../../../db/shared/handle_identifier_utils.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class HandleProjectionResult {
  const HandleProjectionResult({
    required this.examinedHandleCount,
    required this.insertedHandleCount,
  });

  final int examinedHandleCount;
  final int insertedHandleCount;
}

class HandleProjector {
  const HandleProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<HandleProjectionResult> projectHandles() async {
    final rows = await importDatabase.database.query(
      'handles',
      columns: <String>['ss_id', 'id', 'service'],
      orderBy: 'ss_id ASC',
    );

    var insertedHandleCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final insertedId = await txn.insert(
          'handles',
          row,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (insertedId != 0) {
          insertedHandleCount += 1;
        }
      }
      await _rebuildHandleAliases(txn);
    });

    return HandleProjectionResult(
      examinedHandleCount: rows.length,
      insertedHandleCount: insertedHandleCount,
    );
  }

  Future<void> _rebuildHandleAliases(Transaction txn) async {
    final rows = await txn.query(
      'handles',
      columns: <String>['ss_id', 'id', 'service'],
      orderBy: 'ss_id ASC',
    );
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

    await txn.delete('handle_aliases');
    await txn.delete('canonical_handles');

    for (final group in groups.values) {
      group.sort(_compareHandlePreference);
      final canonical = group.first;
      await txn.insert('canonical_handles', <String, Object?>{
        'canonical_handle_ss_id': canonical.ssId,
        'display_handle': _displayHandle(canonical),
        'normalized_identifier': canonical.normalizedIdentifier,
        'service': canonical.service,
        'alias_count': group.length,
      });
      for (final alias in group) {
        await txn.insert('handle_aliases', <String, Object?>{
          'handle_ss_id': alias.ssId,
          'canonical_handle_ss_id': canonical.ssId,
          'raw_identifier': alias.rawIdentifier,
          'normalized_identifier': alias.normalizedIdentifier,
          'alias_kind': alias.ssId == canonical.ssId ? 'canonical' : 'variant',
        });
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
