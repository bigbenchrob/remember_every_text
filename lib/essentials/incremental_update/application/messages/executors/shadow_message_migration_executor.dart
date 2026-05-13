import 'package:flutter/foundation.dart';

import '../../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../../db/infrastructure/data_sources/local/working/working_database.dart';

class ShadowMessageMigrationExecutor {
  const ShadowMessageMigrationExecutor({
    required SqfliteImportDatabase shadowImportDb,
    required WorkingDatabase shadowWorkingDb,
  }) : _shadowImportDb = shadowImportDb,
       _shadowWorkingDb = shadowWorkingDb;

  static const String _importAttachAlias = 'shadow_import_messages';
  static const int _shadowPlaceholderChatId = -1;
  static const String _shadowPlaceholderChatGuid =
      '__shadow_incremental_update_placeholder_chat__';

  final SqfliteImportDatabase _shadowImportDb;
  final WorkingDatabase _shadowWorkingDb;

  Future<ShadowMessageMigrationResult> migrateMessages() async {
    final importSqlite = await _shadowImportDb.database;
    final escapedImportPath = importSqlite.path.replaceAll("'", "''");

    await _shadowWorkingDb.customStatement(
      "ATTACH DATABASE '$escapedImportPath' AS $_importAttachAlias",
    );

    try {
      return await _shadowWorkingDb.transaction(() async {
        await _ensureShadowPlaceholderChat();

        await _shadowWorkingDb.customStatement('''
          INSERT OR IGNORE INTO messages (
            id,
            guid,
            chat_id,
            is_from_me,
            sent_at_utc,
            delivered_at_utc,
            read_at_utc,
            status,
            text,
            raw_item_type,
            raw_associated_message_type,
            semantic_kind,
            is_sparse_artifact,
            has_attributed_body_source,
            has_message_summary_info,
            has_payload_data_source,
            item_type,
            is_system_message,
            error_code,
            has_attachments,
            associated_message_guid,
            thread_originator_guid,
            balloon_bundle_id,
            payload_json,
            is_starred,
            is_deleted_local,
            batch_id
          )
          SELECT
            m.id,
            m.guid,
            $_shadowPlaceholderChatId,
            COALESCE(m.is_from_me, 0),
            m.date_utc,
            m.date_delivered_utc,
            m.date_read_utc,
            'unknown',
            m.text,
            m.raw_item_type,
            m.raw_associated_message_type,
            CASE
              WHEN COALESCE(m.is_system_message, 0) = 1 OR m.item_type = 'system' THEN 'system'
              WHEN COALESCE(m.has_message_summary_info, 0) = 1 THEN 'edited-or-unsent'
              WHEN m.item_type = 'reaction-carrier'
                OR m.associated_message_guid IS NOT NULL
                OR COALESCE(m.raw_associated_message_type, 0) != 0 THEN 'associated'
              WHEN m.item_type = 'balloon'
                OR COALESCE(m.has_payload_data_source, 0) = 1
                OR COALESCE(LENGTH(TRIM(m.balloon_bundle_id)), 0) > 0 THEN 'balloon-or-app'
              WHEN m.item_type = 'attachment-only' THEN 'attachment-only'
              WHEN COALESCE(m.has_attributed_body_source, 0) = 1 THEN 'rich-text'
              WHEN COALESCE(LENGTH(TRIM(m.text)), 0) > 0 THEN 'plain-text'
              WHEN COALESCE(m.raw_item_type, -1) >= 0 THEN 'sparse-artifact'
              ELSE 'unknown-variant'
            END,
            CASE
              WHEN COALESCE(LENGTH(TRIM(m.text)), 0) = 0
                AND COALESCE(m.has_attributed_body_source, 0) = 0
                AND COALESCE(m.has_message_summary_info, 0) = 0
                AND COALESCE(m.has_payload_data_source, 0) = 0
              THEN 1 ELSE 0
            END,
            COALESCE(m.has_attributed_body_source, 0),
            COALESCE(m.has_message_summary_info, 0),
            COALESCE(m.has_payload_data_source, 0),
            CASE m.item_type
              WHEN 'text' THEN 'text'
              WHEN 'attachment-only' THEN 'attachment-only'
              WHEN 'sticker' THEN 'sticker'
              WHEN 'reaction-carrier' THEN 'reaction-carrier'
              WHEN 'system' THEN 'system'
              WHEN 'unknown' THEN 'unknown'
              WHEN 'balloon' THEN 'balloon'
              ELSE 'unknown'
            END,
            COALESCE(m.is_system_message, 0),
            m.error_code,
            0,
            m.associated_message_guid,
            m.thread_originator_guid,
            m.balloon_bundle_id,
            m.payload_json,
            0,
            0,
            m.batch_id
          FROM $_importAttachAlias.messages m
          WHERE m.guid IS NOT NULL
            AND LENGTH(TRIM(m.guid)) > 0;
        ''');

        final changes = await _shadowWorkingDb
            .customSelect('SELECT changes() AS inserted_message_count')
            .getSingle();
        final insertedMessageCount = _readInt(
          changes.data,
          'inserted_message_count',
        );

        final result = ShadowMessageMigrationResult(
          insertedMessageCount: insertedMessageCount,
        );

        debugPrint(
          'Shadow message migration executed: '
          'insertedMessageCount=${result.insertedMessageCount}',
        );

        return result;
      });
    } finally {
      await _detachImportWithRetry();
    }
  }

  Future<void> _ensureShadowPlaceholderChat() async {
    await _shadowWorkingDb.customStatement('''
      INSERT OR IGNORE INTO chats (
        id,
        guid,
        service,
        is_group,
        is_ignored
      ) VALUES (
        $_shadowPlaceholderChatId,
        '$_shadowPlaceholderChatGuid',
        'Unknown',
        0,
        0
      );
    ''');
  }

  Future<void> _detachImportWithRetry() async {
    const maxAttempts = 5;
    var attempt = 0;

    while (true) {
      attempt += 1;
      try {
        await _shadowWorkingDb.customStatement(
          'DETACH DATABASE $_importAttachAlias',
        );
        return;
      } catch (error) {
        final message = error.toString();
        final isLocked =
            message.contains('database is locked') ||
            message.contains('SQLITE_LOCKED') ||
            message.contains('SQLITE_BUSY');
        if (!isLocked || attempt >= maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 150 * attempt));
      }
    }
  }

  int _readInt(Map<String, Object?> row, String column) {
    final value = row[column];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    throw FormatException('Expected integer value for $column, got $value.');
  }
}

@immutable
class ShadowMessageMigrationResult {
  const ShadowMessageMigrationResult({required this.insertedMessageCount});

  final int insertedMessageCount;
}
