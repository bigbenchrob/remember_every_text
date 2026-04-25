import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

Future<void> validateSourceChatHandleJoinIntegrity(IImportContext ctx) async {
  final diagnosticSql =
      '''
SELECT j.chat_id, j.handle_id
FROM chat_handle_join AS j
LEFT JOIN chat AS c
  ON c.ROWID = j.chat_id
LEFT JOIN handle AS h
  ON h.ROWID = j.handle_id
WHERE ${_boundedJoinPredicate(leftColumn: 'j.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'j.handle_id', rightMaxInclusive: ctx.sourceMaxHandleRowIdAtBatchStart)}
  AND (c.ROWID IS NULL
   OR h.ROWID IS NULL);
''';

  await _validateSourceJoinIntegrity(
    ctx: ctx,
    query:
        '''
SELECT j.chat_id AS left_id, j.handle_id AS right_id
FROM chat_handle_join AS j
LEFT JOIN chat AS c
  ON c.ROWID = j.chat_id
LEFT JOIN handle AS h
  ON h.ROWID = j.handle_id
WHERE ${_boundedJoinPredicate(leftColumn: 'j.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'j.handle_id', rightMaxInclusive: ctx.sourceMaxHandleRowIdAtBatchStart)}
  AND (c.ROWID IS NULL
   OR h.ROWID IS NULL)
LIMIT 5
''',
    errorCode: 'chat-to-handle-source-fk-broken',
    joinLabel: 'chat_handle_join',
    leftColumnLabel: 'chat_id',
    rightColumnLabel: 'handle_id',
    diagnosticSql: diagnosticSql,
  );
}

Future<void> validateLedgerChatHandleJoinCoverage(IImportContext ctx) async {
  final diagnosticSql = _buildAttachedImportDiagnosticSql(
    messagesDbPath: ctx.messagesDbPath,
    alias: 'source_chat',
    body:
        '''
SELECT join_rows.chat_id, join_rows.handle_id
FROM source_chat.chat_handle_join AS join_rows
LEFT JOIN chats AS ledger_chats
  ON ledger_chats.id = join_rows.chat_id
LEFT JOIN handles AS ledger_handles
  ON ledger_handles.id = join_rows.handle_id
WHERE ${_boundedJoinPredicate(leftColumn: 'join_rows.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'join_rows.handle_id', rightMaxInclusive: ctx.sourceMaxHandleRowIdAtBatchStart)}
  AND (ledger_chats.id IS NULL
   OR ledger_handles.id IS NULL);
''',
  );

  await _validateLedgerJoinCoverage(
    ctx: ctx,
    attachAlias: 'source_chat',
    query:
        '''
SELECT join_rows.chat_id AS left_id, join_rows.handle_id AS right_id
FROM source_chat.chat_handle_join AS join_rows
LEFT JOIN chats AS ledger_chats
  ON ledger_chats.id = join_rows.chat_id
LEFT JOIN handles AS ledger_handles
  ON ledger_handles.id = join_rows.handle_id
WHERE ${_boundedJoinPredicate(leftColumn: 'join_rows.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'join_rows.handle_id', rightMaxInclusive: ctx.sourceMaxHandleRowIdAtBatchStart)}
  AND (ledger_chats.id IS NULL
   OR ledger_handles.id IS NULL)
LIMIT 5
''',
    errorCode: 'chat-to-handle-ledger-parent-missing',
    joinLabel: 'chat_handle_join',
    leftColumnLabel: 'chat_id',
    rightColumnLabel: 'handle_id',
    diagnosticSql: diagnosticSql,
  );
}

Future<void> validateSourceChatMessageJoinIntegrity(IImportContext ctx) async {
  final diagnosticSql =
      '''
SELECT j.chat_id, j.message_id
FROM chat_message_join AS j
LEFT JOIN chat AS c
  ON c.ROWID = j.chat_id
LEFT JOIN message AS m
  ON m.ROWID = j.message_id
WHERE ${_boundedJoinPredicate(leftColumn: 'j.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'j.message_id', rightMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart)}
  AND (c.ROWID IS NULL
   OR m.ROWID IS NULL);
''';

  await _validateSourceJoinIntegrity(
    ctx: ctx,
    query:
        '''
SELECT j.chat_id AS left_id, j.message_id AS right_id
FROM chat_message_join AS j
LEFT JOIN chat AS c
  ON c.ROWID = j.chat_id
LEFT JOIN message AS m
  ON m.ROWID = j.message_id
WHERE ${_boundedJoinPredicate(leftColumn: 'j.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'j.message_id', rightMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart)}
  AND (c.ROWID IS NULL
   OR m.ROWID IS NULL)
LIMIT 5
''',
    errorCode: 'chat-to-message-source-fk-broken',
    joinLabel: 'chat_message_join',
    leftColumnLabel: 'chat_id',
    rightColumnLabel: 'message_id',
    diagnosticSql: diagnosticSql,
  );
}

Future<void> validateLedgerChatMessageJoinCoverage(IImportContext ctx) async {
  final diagnosticSql = _buildAttachedImportDiagnosticSql(
    messagesDbPath: ctx.messagesDbPath,
    alias: 'source_chat',
    body:
        '''
SELECT join_rows.chat_id, join_rows.message_id
FROM source_chat.chat_message_join AS join_rows
LEFT JOIN chats AS ledger_chats
  ON ledger_chats.id = join_rows.chat_id
LEFT JOIN messages AS ledger_messages
  ON ledger_messages.id = join_rows.message_id
WHERE ${_boundedJoinPredicate(leftColumn: 'join_rows.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'join_rows.message_id', rightMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart)}
  AND (ledger_chats.id IS NULL
   OR ledger_messages.id IS NULL);
''',
  );

  await _validateLedgerJoinCoverage(
    ctx: ctx,
    attachAlias: 'source_chat',
    query:
        '''
SELECT join_rows.chat_id AS left_id, join_rows.message_id AS right_id
FROM source_chat.chat_message_join AS join_rows
LEFT JOIN chats AS ledger_chats
  ON ledger_chats.id = join_rows.chat_id
LEFT JOIN messages AS ledger_messages
  ON ledger_messages.id = join_rows.message_id
WHERE ${_boundedJoinPredicate(leftColumn: 'join_rows.chat_id', leftMaxInclusive: ctx.sourceMaxChatRowIdAtBatchStart, rightColumn: 'join_rows.message_id', rightMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart)}
  AND (ledger_chats.id IS NULL
   OR ledger_messages.id IS NULL)
LIMIT 5
''',
    errorCode: 'chat-to-message-ledger-parent-missing',
    joinLabel: 'chat_message_join',
    leftColumnLabel: 'chat_id',
    rightColumnLabel: 'message_id',
    diagnosticSql: diagnosticSql,
  );
}

Future<void> validateSourceMessageAttachmentJoinIntegrity(
  IImportContext ctx,
) async {
  final diagnosticSql =
      '''
SELECT j.message_id, j.attachment_id
FROM message_attachment_join AS j
LEFT JOIN message AS m
  ON m.ROWID = j.message_id
LEFT JOIN attachment AS a
  ON a.ROWID = j.attachment_id
WHERE ${_boundedJoinPredicate(leftColumn: 'j.message_id', leftMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart, rightColumn: 'j.attachment_id', rightMaxInclusive: ctx.sourceMaxAttachmentRowIdAtBatchStart)}
  AND (m.ROWID IS NULL
   OR a.ROWID IS NULL);
''';

  await _validateSourceJoinIntegrity(
    ctx: ctx,
    query:
        '''
SELECT j.message_id AS left_id, j.attachment_id AS right_id
FROM message_attachment_join AS j
LEFT JOIN message AS m
  ON m.ROWID = j.message_id
LEFT JOIN attachment AS a
  ON a.ROWID = j.attachment_id
WHERE ${_boundedJoinPredicate(leftColumn: 'j.message_id', leftMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart, rightColumn: 'j.attachment_id', rightMaxInclusive: ctx.sourceMaxAttachmentRowIdAtBatchStart)}
  AND (m.ROWID IS NULL
   OR a.ROWID IS NULL)
LIMIT 5
''',
    errorCode: 'message-attachments-source-fk-broken',
    joinLabel: 'message_attachment_join',
    leftColumnLabel: 'message_id',
    rightColumnLabel: 'attachment_id',
    diagnosticSql: diagnosticSql,
  );
}

Future<void> validateLedgerMessageAttachmentJoinCoverage(
  IImportContext ctx,
) async {
  final diagnosticSql = _buildAttachedImportDiagnosticSql(
    messagesDbPath: ctx.messagesDbPath,
    alias: 'source_chat',
    body:
        '''
SELECT join_rows.message_id, join_rows.attachment_id
FROM source_chat.message_attachment_join AS join_rows
LEFT JOIN messages AS ledger_messages
  ON ledger_messages.id = join_rows.message_id
LEFT JOIN recovered_unlinked_messages AS ledger_recovered_messages
  ON ledger_recovered_messages.id = join_rows.message_id
LEFT JOIN attachments AS ledger_attachments
  ON ledger_attachments.id = join_rows.attachment_id
WHERE ${_boundedJoinPredicate(leftColumn: 'join_rows.message_id', leftMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart, rightColumn: 'join_rows.attachment_id', rightMaxInclusive: ctx.sourceMaxAttachmentRowIdAtBatchStart)}
  AND ((ledger_messages.id IS NULL AND ledger_recovered_messages.id IS NULL)
   OR ledger_attachments.id IS NULL);
''',
  );

  await _validateLedgerJoinCoverage(
    ctx: ctx,
    attachAlias: 'source_chat',
    query:
        '''
SELECT join_rows.message_id AS left_id, join_rows.attachment_id AS right_id
FROM source_chat.message_attachment_join AS join_rows
LEFT JOIN messages AS ledger_messages
  ON ledger_messages.id = join_rows.message_id
LEFT JOIN recovered_unlinked_messages AS ledger_recovered_messages
  ON ledger_recovered_messages.id = join_rows.message_id
LEFT JOIN attachments AS ledger_attachments
  ON ledger_attachments.id = join_rows.attachment_id
WHERE ${_boundedJoinPredicate(leftColumn: 'join_rows.message_id', leftMaxInclusive: ctx.sourceMaxMessageRowIdAtBatchStart, rightColumn: 'join_rows.attachment_id', rightMaxInclusive: ctx.sourceMaxAttachmentRowIdAtBatchStart)}
  AND ((ledger_messages.id IS NULL AND ledger_recovered_messages.id IS NULL)
   OR ledger_attachments.id IS NULL)
LIMIT 5
''',
    errorCode: 'message-attachments-ledger-parent-missing',
    joinLabel: 'message_attachment_join',
    leftColumnLabel: 'message_id',
    rightColumnLabel: 'attachment_id',
    diagnosticSql: diagnosticSql,
  );
}

Future<void> _validateSourceJoinIntegrity({
  required IImportContext ctx,
  required String query,
  required String errorCode,
  required String joinLabel,
  required String leftColumnLabel,
  required String rightColumnLabel,
  required String diagnosticSql,
}) async {
  final rows = await ctx.messagesDb.rawQuery(query);
  if (rows.isEmpty) {
    return;
  }

  final preview = rows
      .map(
        (row) =>
            '$leftColumnLabel=${row['left_id']}, $rightColumnLabel=${row['right_id']}',
      )
      .join('; ');
  throw ImportException(
    code: errorCode,
    message:
        'Source join table $joinLabel contains rows referencing missing parents. '
        'Example broken rows: $preview '
        'Diagnostic SQL to run against chat.db:\n$diagnosticSql',
  );
}

Future<void> _validateLedgerJoinCoverage({
  required IImportContext ctx,
  required String attachAlias,
  required String query,
  required String errorCode,
  required String joinLabel,
  required String leftColumnLabel,
  required String rightColumnLabel,
  required String diagnosticSql,
}) async {
  final db = await ctx.importDb.database;
  final escapedPath = ctx.messagesDbPath.replaceAll("'", "''");
  try {
    await db.execute("ATTACH DATABASE '$escapedPath' AS $attachAlias");
    final rows = await db.rawQuery(query);
    if (rows.isEmpty) {
      return;
    }

    final preview = rows
        .map(
          (row) =>
              '$leftColumnLabel=${row['left_id']}, $rightColumnLabel=${row['right_id']}',
        )
        .join('; ');
    throw ImportException(
      code: errorCode,
      message:
          'Import ledger is missing parent rows required by source join table '
          '$joinLabel. Example missing ledger coverage: $preview '
          'Diagnostic SQL to run against macos_import.db:\n$diagnosticSql',
    );
  } finally {
    try {
      await db.execute('DETACH DATABASE $attachAlias');
    } catch (_) {}
  }
}

String _buildAttachedImportDiagnosticSql({
  required String messagesDbPath,
  required String alias,
  required String body,
}) {
  final escapedPath = messagesDbPath.replaceAll("'", "''");
  return '''
ATTACH DATABASE '$escapedPath' AS $alias;
$body
DETACH DATABASE $alias;
''';
}

String _boundedJoinPredicate({
  required String leftColumn,
  required int? leftMaxInclusive,
  required String rightColumn,
  required int? rightMaxInclusive,
}) {
  final predicates = <String>[];

  if (leftMaxInclusive != null) {
    predicates.add('$leftColumn <= $leftMaxInclusive');
  }
  if (rightMaxInclusive != null) {
    predicates.add('$rightColumn <= $rightMaxInclusive');
  }

  if (predicates.isEmpty) {
    return '1 = 1';
  }

  return predicates.join(' AND ');
}
