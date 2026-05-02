import '../../../../core/util/date_converter.dart';
import '../../domain/base_table_migrator.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

String _unixSecondsToWorkingTimestamp(String columnName) {
  return DateConverter.unixSecondsToIsoTextSqlExpression(columnName);
}

class AttachmentsMigrator extends BaseTableMigrator {
  const AttachmentsMigrator();

  static const _attachAlias = 'import_attachments';

  @override
  String get name => 'attachments';

  @override
  List<String> get dependsOn => const ['messages'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final joinable = await _countJoinableAttachments(ctx);
    ctx.log('[attachments] joinable import count = $joinable');

    if (joinable == 0) {
      ctx.log('[attachments] no joinable rows; skipping copy');
      return;
    }

    final projectedMessages = await count(ctx.workingDb, 'messages');
    await expectTrueOrThrow(
      ok: projectedMessages > 0,
      errorCode: 'ATTACHMENTS_REQUIRES_MESSAGES',
      message:
          'attachments: import has $joinable rows but working database has no messages',
    );
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[attachments] dry run – skipping copy');
      return;
    }

    if (ctx.incrementalMode) {
      final removedDuplicates = await _removeDuplicateProjectedAttachments(ctx);
      if (removedDuplicates > 0) {
        ctx.log(
          '[attachments] removed $removedDuplicates duplicate projected attachment row(s) before incremental copy',
        );
      }
    }

    final inserted = await _withAttachedImport(ctx, () async {
      final missingMessages = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.message_attachments ma
        LEFT JOIN messages wm ON wm.id = ma.message_id
        WHERE wm.id IS NULL
      ''').get();
      final missingMessagesCount = _extractCount(missingMessages, 'c');
      if (missingMessagesCount > 0) {
        ctx.log(
          '[attachments] skipping $missingMessagesCount attachment link(s); message not projected',
        );
      }

      await ctx.workingDb.customStatement('''
        INSERT INTO attachments (
          message_guid,
          import_attachment_id,
          local_path,
          mime_type,
          uti,
          transfer_name,
          size_bytes,
          is_sticker,
          thumb_path,
          created_at_utc,
          is_outgoing,
          sha256_hex,
          batch_id
        )
        SELECT
          wm.guid AS message_guid,
          a.id AS import_attachment_id,
          a.local_path,
          a.mime_type,
          a.uti,
          a.transfer_name,
          a.total_bytes,
          COALESCE(a.is_sticker, 0) AS is_sticker,
          NULL AS thumb_path,
          ${_unixSecondsToWorkingTimestamp('a.created_at_utc')},
          CASE
            WHEN a.is_outgoing IS NULL THEN 0
            WHEN a.is_outgoing = 1 THEN 1
            ELSE 0
          END AS is_outgoing,
          a.sha256_hex,
          a.batch_id
        FROM $_attachAlias.message_attachments ma
        JOIN $_attachAlias.attachments a ON a.id = ma.attachment_id
        JOIN messages wm ON wm.id = ma.message_id
        LEFT JOIN attachments existing
          ON existing.message_guid = wm.guid
         AND existing.import_attachment_id = a.id
        WHERE wm.guid IS NOT NULL
          AND LENGTH(TRIM(wm.guid)) > 0
          AND existing.id IS NULL;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      return _extractCount(rows, 'c');
    });

    ctx.log('[attachments] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final expected = await _countProjectableAttachments(ctx);
    final projected = await count(ctx.workingDb, 'attachments');
    ctx.log('[attachments] expected=$expected projected=$projected');

    if (expected == 0) {
      await expectTrueOrThrow(
        ok: projected == 0,
        errorCode: 'ATTACHMENTS_UNEXPECTED_ROWS',
        message: 'attachments: working has $projected rows but import had none',
      );
      return;
    }

    await expectTrueOrThrow(
      ok: projected == expected,
      errorCode: 'ATTACHMENTS_ROW_MISMATCH',
      message:
          'attachments: working has $projected rows but expected $expected',
    );
  }

  Future<int> _countJoinableAttachments(IMigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM message_attachments ma '
      'JOIN attachments a ON a.id = ma.attachment_id '
      'JOIN messages m ON m.id = ma.message_id '
      'WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0',
    );
    if (rows.isEmpty) {
      return 0;
    }
    return _coerceToInt(rows.first['c']);
  }

  Future<int> _countProjectableAttachments(IMigrationContext ctx) async {
    return _withAttachedImport(ctx, () async {
      final rows = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.message_attachments ma
        JOIN $_attachAlias.attachments a ON a.id = ma.attachment_id
        JOIN messages wm ON wm.id = ma.message_id
        WHERE wm.guid IS NOT NULL AND LENGTH(TRIM(wm.guid)) > 0
      ''').get();
      return _extractCount(rows, 'c');
    });
  }

  Future<int> _removeDuplicateProjectedAttachments(
    IMigrationContext ctx,
  ) async {
    final duplicateRows = await ctx.workingDb.customSelect('''
      SELECT COUNT(*) AS c
      FROM attachments duplicate
      WHERE duplicate.import_attachment_id IS NOT NULL
        AND EXISTS (
          SELECT 1
          FROM attachments keeper
          WHERE keeper.message_guid = duplicate.message_guid
            AND keeper.import_attachment_id = duplicate.import_attachment_id
            AND keeper.id < duplicate.id
        )
    ''').get();
    final duplicatesToRemove = _extractCount(duplicateRows, 'c');
    if (duplicatesToRemove == 0) {
      return 0;
    }

    await ctx.workingDb.customStatement('''
      DELETE FROM attachments
      WHERE id IN (
        SELECT duplicate.id
        FROM attachments duplicate
        WHERE duplicate.import_attachment_id IS NOT NULL
          AND EXISTS (
            SELECT 1
            FROM attachments keeper
            WHERE keeper.message_guid = duplicate.message_guid
              AND keeper.import_attachment_id = duplicate.import_attachment_id
              AND keeper.id < duplicate.id
          )
      )
    ''');

    final rows = await ctx.workingDb
        .customSelect('SELECT changes() AS c')
        .get();
    return _extractCount(rows, 'c');
  }

  Future<T> _withAttachedImport<T>(
    IMigrationContext ctx,
    Future<T> Function() run,
  ) async {
    final importSqlite = await ctx.importDb.database;
    final escapedPath = importSqlite.path.replaceAll("'", "''");
    await ctx.workingDb.customStatement(
      "ATTACH DATABASE '$escapedPath' AS $_attachAlias",
    );
    try {
      return await run();
    } finally {
      await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
    }
  }

  int _extractCount(List<dynamic> rows, String key) {
    if (rows.isEmpty) {
      return 0;
    }
    final first = rows.first;
    if (first is Map<String, Object?>) {
      return _coerceToInt(first[key]);
    }
    final data = (first as dynamic).data as Map<String, Object?>;
    return _coerceToInt(data[key]);
  }

  int _coerceToInt(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }
}
