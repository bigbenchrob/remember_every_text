import 'dart:io';

import 'package:path/path.dart' as path;

import '../../domain/known_sources.dart';
import '../../infrastructure/import_database_provider.dart';

final class HistoricalMessagesArchiveSourceRegistration {
  const HistoricalMessagesArchiveSourceRegistration({
    required this.sourceId,
    required this.sourceKey,
    required this.sourceKind,
    required this.sourceLabel,
    required this.selectedFolderPath,
    required this.chatDbPath,
  });

  final int sourceId;
  final String sourceKey;
  final String sourceKind;
  final String sourceLabel;
  final String selectedFolderPath;
  final String chatDbPath;
}

class HistoricalMessagesArchiveSourceRegistrar {
  const HistoricalMessagesArchiveSourceRegistrar({
    required this.importDatabase,
  });

  final ImportDatabase importDatabase;

  Future<HistoricalMessagesArchiveSourceRegistration> registerFolder({
    required String folderPath,
    String? sourceLabel,
  }) async {
    final normalizedFolderPath = _normalizeFolderPath(folderPath);
    final chatDbPath = path.join(normalizedFolderPath, 'chat.db');

    if (!File(chatDbPath).existsSync()) {
      throw FileSystemException(
        'Historical Messages archive folder must contain chat.db',
        chatDbPath,
      );
    }

    final normalizedSourceLabel = _normalizeSourceLabel(
      sourceLabel: sourceLabel,
      folderPath: normalizedFolderPath,
    );
    final sourceKey = buildSourceKey(chatDbPath: chatDbPath);
    final sourceId = await importDatabase.getOrCreateSource(
      sourceKey: sourceKey,
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: normalizedSourceLabel,
    );

    return HistoricalMessagesArchiveSourceRegistration(
      sourceId: sourceId,
      sourceKey: sourceKey,
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: normalizedSourceLabel,
      selectedFolderPath: normalizedFolderPath,
      chatDbPath: chatDbPath,
    );
  }

  static String buildSourceKey({required String chatDbPath}) {
    final normalizedChatDbPath = File(chatDbPath).absolute.path;
    return '$historicalMessagesArchiveSourceKeyPrefix$normalizedChatDbPath';
  }

  static String _normalizeFolderPath(String folderPath) {
    final trimmed = folderPath.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(folderPath, 'folderPath', 'must not be empty');
    }
    return Directory(trimmed).absolute.path;
  }

  static String _normalizeSourceLabel({
    required String? sourceLabel,
    required String folderPath,
  }) {
    final trimmedLabel = sourceLabel?.trim();
    if (trimmedLabel != null && trimmedLabel.isNotEmpty) {
      return trimmedLabel;
    }

    final basename = path.basename(folderPath);
    if (basename.isNotEmpty) {
      return basename;
    }

    return folderPath;
  }
}
