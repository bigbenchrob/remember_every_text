import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

Future<void> createExactLegacyTesterInstall(Directory root) async {
  await root.create(recursive: true);
  await _createDatabase(
    path.join(root.path, 'macos_import.db'),
    version: 4,
    tables: legacyImportTables,
  );
  await _createDatabase(
    path.join(root.path, 'working.db'),
    version: 3,
    tables: legacyWorkingTables,
  );
  await _createDatabase(
    path.join(root.path, 'user_overlays.db'),
    version: 3,
    tables: legacyOverlayTables,
  );
}

Future<void> _createDatabase(
  String databasePath, {
  required int version,
  required Set<String> tables,
}) async {
  final database = sqlite3.open(databasePath);
  try {
    database.execute('PRAGMA user_version = $version');
    for (final table in tables) {
      database.execute('CREATE TABLE "$table" (id INTEGER)');
    }
  } finally {
    database.dispose();
  }
}

const Set<String> legacyImportTables = {
  'schema_migrations',
  'import_batches',
  'source_files',
  'import_logs',
  'contacts',
  'contact_phone_email',
  'handles',
  'chats',
  'chat_to_handle',
  'messages',
  'recovered_unlinked_messages',
  'chat_to_message',
  'attachments',
  'message_attachments',
  'recovered_unlinked_message_attachments',
  'reactions',
  'message_links',
  'contact_to_chat_handle',
};

const Set<String> legacyWorkingTables = {
  'schema_migrations',
  'projection_state',
  'app_settings',
  'handles_canonical',
  'participants',
  'handle_to_participant',
  'handles_canonical_to_alias',
  'chats',
  'chat_to_handle',
  'messages',
  'recovered_unlinked_messages',
  'global_message_index',
  'message_index',
  'contact_message_index',
  'attachments',
  'recovered_unlinked_attachments',
  'reactions',
  'reaction_counts',
  'read_state',
  'message_read_marks',
  'supabase_sync_state',
  'supabase_sync_logs',
};

const Set<String> legacyOverlayTables = {
  'participant_overrides',
  'chat_overrides',
  'message_annotations',
  'message_user_flags',
  'message_user_tags',
  'handle_to_participant_overrides',
  'virtual_participants',
  'overlay_settings',
  'favorite_contacts',
  'dismissed_handles',
  'handle_visibility_overrides',
  'archived_attachments',
};
