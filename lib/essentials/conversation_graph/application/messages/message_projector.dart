import 'package:sqflite/sqflite.dart';

import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';

class MessageProjectionResult {
  const MessageProjectionResult({
    required this.examinedMessageCount,
    required this.insertedMessageCount,
  });

  final int examinedMessageCount;
  final int insertedMessageCount;
}

class MessageProjector {
  const MessageProjector({
    required this.importDatabase,
    required this.workingDatabase,
  });

  final ImportDatabase importDatabase;
  final WorkingDatabase workingDatabase;

  Future<MessageProjectionResult> projectMessages() async {
    final rows = await importDatabase.database.query(
      'messages',
      columns: <String>[
        'ss_id',
        'source_id',
        'guid',
        'sender_handle_ss_id',
        'is_from_me',
        'date_utc',
        'text',
        'associated_message_guid',
        'raw_item_type',
        'raw_associated_message_type',
        'error_code',
        'is_system_message',
        'has_attributed_body_source',
        'has_message_summary_info',
        'has_payload_data_source',
      ],
      orderBy: 'ss_id ASC',
    );

    var insertedMessageCount = 0;
    await workingDatabase.database.transaction((txn) async {
      for (final row in rows) {
        final associatedMessageSsId = await _resolveAssociatedMessageSsId(row);
        final senderCanonicalHandleSsId =
            await _resolveSenderCanonicalHandleSsId(txn, row);
        final projectedValues = <String, Object?>{
          'guid': row['guid'],
          'sender_handle_ss_id': row['sender_handle_ss_id'],
          'sender_canonical_handle_ss_id': senderCanonicalHandleSsId,
          'is_from_me': row['is_from_me'],
          'date_utc': row['date_utc'],
          'text': row['text'],
          'associated_message_ss_id': associatedMessageSsId,
          'semantic_kind': _semanticKind(row),
          'item_kind': _itemKind(row),
          'is_system_message': _boolInt(row['is_system_message']),
          'is_sparse_artifact': _isSparseArtifact(row),
          'has_attributed_body_source': _boolInt(
            row['has_attributed_body_source'],
          ),
          'has_message_summary_info': _boolInt(row['has_message_summary_info']),
          'has_payload_data_source': _boolInt(row['has_payload_data_source']),
          'error_code': row['error_code'],
        };
        final insertedId = await txn.insert('messages', <String, Object?>{
          'ss_id': row['ss_id'],
          ...projectedValues,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        if (insertedId == 0) {
          await txn.update(
            'messages',
            projectedValues,
            where: 'ss_id = ?',
            whereArgs: <Object?>[row['ss_id']],
          );
        }

        if (insertedId != 0) {
          insertedMessageCount += 1;
        }
      }
    });

    return MessageProjectionResult(
      examinedMessageCount: rows.length,
      insertedMessageCount: insertedMessageCount,
    );
  }

  Future<int?> _resolveAssociatedMessageSsId(Map<String, Object?> row) async {
    final associatedGuid = row['associated_message_guid'];
    if (associatedGuid is! String || associatedGuid.isEmpty) {
      return null;
    }

    final sourceId = row['source_id'];
    if (sourceId is! int) {
      return null;
    }

    final rows = await importDatabase.database.query(
      'messages',
      columns: <String>['ss_id'],
      where: 'source_id = ? AND guid = ?',
      whereArgs: <Object?>[sourceId, associatedGuid],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.single['ss_id'] as int?;
  }

  Future<int?> _resolveSenderCanonicalHandleSsId(
    Transaction txn,
    Map<String, Object?> row,
  ) async {
    final senderHandleSsId = row['sender_handle_ss_id'];
    if (senderHandleSsId is! int) {
      return null;
    }

    final rows = await txn.query(
      'handle_aliases',
      columns: <String>['canonical_handle_ss_id'],
      where: 'handle_ss_id = ?',
      whereArgs: <Object?>[senderHandleSsId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.single['canonical_handle_ss_id'] as int?;
  }

  static String _semanticKind(Map<String, Object?> row) {
    if (_boolInt(row['is_system_message']) == 1) {
      return 'system';
    }
    if (_hasAssociatedMessage(row)) {
      return 'associated';
    }
    if (_boolInt(row['has_payload_data_source']) == 1) {
      return 'payload';
    }
    if (_hasText(row) && _boolInt(row['has_attributed_body_source']) == 1) {
      return 'rich_text';
    }
    if (_hasText(row)) {
      return 'text';
    }
    if (_isSparseArtifact(row) == 1) {
      return 'sparse_artifact';
    }
    return 'unknown';
  }

  static String _itemKind(Map<String, Object?> row) {
    if (_boolInt(row['is_system_message']) == 1) {
      return 'system';
    }
    if (_hasAssociatedMessage(row)) {
      return 'associated';
    }
    if (_boolInt(row['has_payload_data_source']) == 1) {
      return 'payload';
    }
    if (_hasText(row)) {
      return 'text';
    }
    return 'unknown';
  }

  static int _isSparseArtifact(Map<String, Object?> row) {
    if (_hasText(row)) {
      return 0;
    }
    if (_boolInt(row['is_system_message']) == 1) {
      return 0;
    }
    if (_hasAssociatedMessage(row)) {
      return 0;
    }
    if (_boolInt(row['has_attributed_body_source']) == 1) {
      return 0;
    }
    if (_boolInt(row['has_message_summary_info']) == 1) {
      return 0;
    }
    if (_boolInt(row['has_payload_data_source']) == 1) {
      return 0;
    }
    return 1;
  }

  static bool _hasAssociatedMessage(Map<String, Object?> row) {
    final associatedGuid = row['associated_message_guid'];
    if (associatedGuid is String && associatedGuid.isNotEmpty) {
      return true;
    }
    final associatedType = row['raw_associated_message_type'];
    return associatedType is int && associatedType != 0;
  }

  static bool _hasText(Map<String, Object?> row) {
    final text = row['text'];
    return text is String && text.isNotEmpty;
  }

  static int _boolInt(Object? value) {
    if (value is int && value != 0) {
      return 1;
    }
    return 0;
  }
}
