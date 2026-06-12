import 'dart:io';

import '../../../../essentials/source_scoped_import/domain/ports/source_database_port.dart';
import '../../application/current_messages_attachment_path_lookup.dart';

final class SourceDatabaseAttachmentPathLookup
    implements CurrentMessagesAttachmentPathLookup {
  const SourceDatabaseAttachmentPathLookup({
    required String databasePath,
    required SourceDatabaseOpener sourceDatabaseOpener,
  }) : _databasePath = databasePath,
       _sourceDatabaseOpener = sourceDatabaseOpener;

  final String _databasePath;
  final SourceDatabaseOpener _sourceDatabaseOpener;

  @override
  Future<String?> attachmentPathForSourceRowId(int sourceRowId) async {
    if (!File(_databasePath).existsSync()) {
      return null;
    }

    final database = await _sourceDatabaseOpener.openReadOnly(_databasePath);
    try {
      final rows = await database.rawQuery(
        'SELECT filename FROM attachment WHERE ROWID = ? LIMIT 1;',
        <Object?>[sourceRowId],
      );
      if (rows.isEmpty) {
        return null;
      }

      final value = rows.first['filename'];
      if (value == null) {
        return null;
      }

      final path = '$value'.trim();
      if (path.isEmpty) {
        return null;
      }

      return path;
    } finally {
      await database.close();
    }
  }
}
