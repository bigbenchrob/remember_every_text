import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import 'historical_messages_archive_source_folder_resolver.dart';

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
    required this.importLedger,
    required this.folderResolver,
  });

  final ImportLedger importLedger;
  final HistoricalMessagesArchiveSourceFolderResolver folderResolver;

  Future<HistoricalMessagesArchiveSourceRegistration> registerFolder({
    required String folderPath,
    String? sourceLabel,
  }) async {
    final sourceFolder = folderResolver.resolveFolder(folderPath);
    final normalizedSourceLabel = _normalizeSourceLabel(
      sourceLabel: sourceLabel,
      defaultSourceLabel: sourceFolder.defaultSourceLabel,
    );
    final sourceId = await importLedger.getOrCreateSource(
      sourceKey: sourceFolder.sourceKey,
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: normalizedSourceLabel,
    );

    return HistoricalMessagesArchiveSourceRegistration(
      sourceId: sourceId,
      sourceKey: sourceFolder.sourceKey,
      sourceKind: historicalMessagesArchiveSourceKind,
      sourceLabel: normalizedSourceLabel,
      selectedFolderPath: sourceFolder.selectedFolderPath,
      chatDbPath: sourceFolder.chatDbPath,
    );
  }

  static String buildSourceKey({required String chatDbPath}) {
    return '$historicalMessagesArchiveSourceKeyPrefix$chatDbPath';
  }

  static String _normalizeSourceLabel({
    required String? sourceLabel,
    required String defaultSourceLabel,
  }) {
    final trimmedLabel = sourceLabel?.trim();
    if (trimmedLabel != null && trimmedLabel.isNotEmpty) {
      return trimmedLabel;
    }

    return defaultSourceLabel;
  }
}
