import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_scoped_row_key.dart';

class HandleImportResult {
  const HandleImportResult({
    required this.startedAfterSourceRowId,
    required this.insertedHandleCount,
    required this.lastImportedSourceRowId,
  });

  final int startedAfterSourceRowId;
  final int insertedHandleCount;
  final int? lastImportedSourceRowId;
}

class HandleIdentityReconciliationResult {
  const HandleIdentityReconciliationResult({
    required this.examinedHandleCount,
    required this.localAccountHandleCount,
    required this.updatedHandleCount,
  });

  final int examinedHandleCount;
  final int localAccountHandleCount;
  final int updatedHandleCount;
}

class HandleImporter {
  const HandleImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  /// Reconciles local-account identity without importing source records.
  ///
  /// This deliberately scans all historical account evidence so aliases used
  /// by older devices remain identifiable even when chat.db has no new rows.
  Future<HandleIdentityReconciliationResult>
  reconcileLocalAccountIdentity() async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);
    try {
      final localAccountHandleKeys = await _readLocalAccountHandleKeys(
        sourceDb,
        includeMessageFallback: true,
      );
      final rows = await importLedger.queryTable(
        'handles',
        columns: const <String>['source_rowid', 'id', 'is_me'],
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      var localAccountHandleCount = 0;
      var updatedHandleCount = 0;

      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final isMe = localAccountHandleKeys.contains(
            _handleGroupingKey(_requiredString(row, 'id')),
          );
          if (isMe) {
            localAccountHandleCount += 1;
          }
          if ((row['is_me'] == 1) == isMe) {
            continue;
          }
          updatedHandleCount += await txn.update(
            'handles',
            <String, Object?>{'is_me': isMe ? 1 : 0},
            where: 'source_id = ? AND source_rowid = ?',
            whereArgs: <Object?>[sourceId, _requiredInt(row, 'source_rowid')],
          );
        }
      });

      return HandleIdentityReconciliationResult(
        examinedHandleCount: rows.length,
        localAccountHandleCount: localAccountHandleCount,
        updatedHandleCount: updatedHandleCount,
      );
    } finally {
      await sourceDb.close();
    }
  }

  Future<HandleImportResult> importNewHandles() async {
    final startedAfterSourceRowId =
        await importLedger.maxHandleSourceRowIdForSource(sourceId) ?? 0;
    final batchId = await importLedger.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    var insertedHandleCount = 0;
    int? lastImportedSourceRowId;
    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, id, service '
        'FROM handle ORDER BY ROWID ASC',
      );
      final hasNewSourceHandles = rows.any((row) {
        return _requiredInt(row, 'source_rowid') > startedAfterSourceRowId;
      });
      final localAccountHandleKeys = await _readLocalAccountHandleKeys(
        sourceDb,
        includeMessageFallback: hasNewSourceHandles,
      );

      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          if (sourceRowId > startedAfterSourceRowId) {
            lastImportedSourceRowId = sourceRowId;
          }
          final rawIdentifier = _requiredString(row, 'id');
          final isMe = localAccountHandleKeys.contains(
            _handleGroupingKey(rawIdentifier),
          );
          final insertedId = await txn
              .insertIgnore('handles', <String, Object?>{
                'ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceRowId,
                ),
                'source_id': sourceId,
                'source_rowid': sourceRowId,
                'id': rawIdentifier,
                'service': _nullableString(row, 'service'),
                'is_me': isMe ? 1 : 0,
                'batch_id': batchId,
              });

          if (insertedId == 0) {
            await txn.update(
              'handles',
              <String, Object?>{'is_me': isMe ? 1 : 0},
              where: 'source_id = ? AND source_rowid = ?',
              whereArgs: <Object?>[sourceId, sourceRowId],
            );
          }

          if (insertedId != 0) {
            insertedHandleCount += 1;
          }
        }
      });
    } finally {
      await sourceDb.close();
    }

    return HandleImportResult(
      startedAfterSourceRowId: startedAfterSourceRowId,
      insertedHandleCount: insertedHandleCount,
      lastImportedSourceRowId: lastImportedSourceRowId,
    );
  }

  Future<Set<String>> _readLocalAccountHandleKeys(
    ReadOnlySourceDatabase sourceDb, {
    required bool includeMessageFallback,
  }) async {
    final existingRows = await importLedger.queryTable(
      'handles',
      columns: const <String>['id'],
      where: 'source_id = ? AND is_me = 1',
      whereArgs: <Object?>[sourceId],
    );
    final keys = {
      for (final row in existingRows)
        if (_nullableString(row, 'id') case final String identifier)
          _handleGroupingKey(identifier),
    };
    final needsInitialBackfill = keys.isEmpty;
    final chatColumns = await _columnNames(sourceDb, 'chat');
    if (chatColumns.contains('account_login')) {
      final rows = await sourceDb.rawQuery(
        'SELECT DISTINCT account_login FROM chat '
        'WHERE account_login IS NOT NULL AND trim(account_login) != ?',
        const <Object?>[''],
      );
      for (final row in rows) {
        final value = _nullableString(row, 'account_login');
        if (value != null) {
          keys.add(_handleGroupingKey(value));
        }
      }
    }

    final shouldScanMessages = needsInitialBackfill || includeMessageFallback;
    final messageColumns = shouldScanMessages
        ? await _columnNames(sourceDb, 'message')
        : const <String>{};
    if (shouldScanMessages &&
        messageColumns.contains('destination_caller_id') &&
        messageColumns.contains('is_from_me')) {
      final rows = await sourceDb.rawQuery(
        'SELECT DISTINCT destination_caller_id FROM message '
        'WHERE is_from_me = 0 '
        'AND destination_caller_id IS NOT NULL '
        'AND trim(destination_caller_id) != ?',
        const <Object?>[''],
      );
      for (final row in rows) {
        final value = _nullableString(row, 'destination_caller_id');
        if (value != null) {
          keys.add(_handleGroupingKey(value));
        }
      }
    }
    return keys;
  }

  Future<Set<String>> _columnNames(
    ReadOnlySourceDatabase sourceDb,
    String table,
  ) async {
    final rows = await sourceDb.rawQuery('PRAGMA table_info($table)');
    return {
      for (final row in rows)
        if (row['name'] case final String name) name,
    };
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    throw StateError('handle.$field is required');
  }

  static String _requiredString(Map<String, Object?> row, String field) {
    final value = _nullableString(row, field);
    if (value == null) {
      throw StateError('handle.$field is required');
    }
    return value;
  }

  static String? _nullableString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static String _handleGroupingKey(String value) {
    final trimmed = value.trim();
    final withoutAccountKind = RegExp(r'^[eEpP]:').hasMatch(trimmed)
        ? trimmed.substring(2)
        : trimmed;
    return buildCanonicalHandleGroupingKey(rawIdentifier: withoutAccountKind);
  }
}
