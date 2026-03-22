import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';

Future<bool> hasMissingChatMembershipParents({
  required SqfliteImportDatabase ledgerDb,
  required String messagesDbPath,
}) async {
  final db = await ledgerDb.database;
  const attachAlias = 'source_chat_membership_check';
  final escapedPath = messagesDbPath.replaceAll("'", "''");

  try {
    await db.execute("ATTACH DATABASE '$escapedPath' AS $attachAlias");
    final rows = await db.rawQuery('''
SELECT
  join_rows.chat_id AS chat_id,
  join_rows.handle_id AS handle_id
FROM $attachAlias.chat_handle_join AS join_rows
LEFT JOIN chats AS ledger_chats
  ON ledger_chats.id = join_rows.chat_id
LEFT JOIN handles AS ledger_handles
  ON ledger_handles.id = join_rows.handle_id
WHERE ledger_chats.id IS NULL
   OR ledger_handles.id IS NULL
LIMIT 1
''');

    return rows.isNotEmpty;
  } finally {
    try {
      await db.execute('DETACH DATABASE $attachAlias');
    } catch (_) {}
  }
}
