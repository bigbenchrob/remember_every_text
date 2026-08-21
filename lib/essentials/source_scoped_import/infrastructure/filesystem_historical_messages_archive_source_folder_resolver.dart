import 'dart:io';

import 'package:path/path.dart' as path;

import '../application/archives/historical_messages_archive_source_folder_resolver.dart';
import '../domain/historical_archive_source_identity.dart';

final class FilesystemHistoricalMessagesArchiveSourceFolderResolver
    implements HistoricalMessagesArchiveSourceFolderResolver {
  const FilesystemHistoricalMessagesArchiveSourceFolderResolver();

  @override
  HistoricalMessagesArchiveSourceFolder resolveFolder(String folderPath) {
    final normalizedFolderPath = _normalizeFolderPath(folderPath);
    final chatDbPath = path.join(normalizedFolderPath, 'chat.db');

    if (!File(chatDbPath).existsSync()) {
      throw FileSystemException(
        'Historical Messages archive folder must contain chat.db',
        chatDbPath,
      );
    }

    final defaultSourceLabel = path.basename(normalizedFolderPath).isNotEmpty
        ? path.basename(normalizedFolderPath)
        : normalizedFolderPath;

    return HistoricalMessagesArchiveSourceFolder(
      selectedFolderPath: normalizedFolderPath,
      chatDbPath: chatDbPath,
      identity: HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
        chatDbPath,
      ),
      defaultSourceLabel: defaultSourceLabel,
    );
  }

  static String _normalizeFolderPath(String folderPath) {
    final trimmed = folderPath.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(folderPath, 'folderPath', 'must not be empty');
    }
    return path.normalize(Directory(trimmed).absolute.path);
  }
}
