import '../../domain/historical_archive_source_identity.dart';
import '../../domain/ports/import_ledger_port.dart';
import 'historical_messages_archive_source_folder_resolver.dart';

final class HistoricalMessagesArchiveSourceRegistration {
  const HistoricalMessagesArchiveSourceRegistration({
    required this.sourceId,
    required this.identity,
    required this.sourceLabel,
    required this.selectedFolderPath,
    required this.chatDbPath,
  });

  final int sourceId;
  final HistoricalArchiveSourceIdentity identity;
  final String sourceLabel;
  final String selectedFolderPath;
  final String chatDbPath;

  String get sourceKey => identity.value;
  String get sourceKind => identity.sourceKind;
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
      sourceKey: sourceFolder.identity.value,
      sourceKind: sourceFolder.identity.sourceKind,
      sourceLabel: normalizedSourceLabel,
    );

    return HistoricalMessagesArchiveSourceRegistration(
      sourceId: sourceId,
      identity: sourceFolder.identity,
      sourceLabel: normalizedSourceLabel,
      selectedFolderPath: sourceFolder.selectedFolderPath,
      chatDbPath: sourceFolder.chatDbPath,
    );
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
