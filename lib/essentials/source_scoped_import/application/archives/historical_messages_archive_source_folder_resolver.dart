import '../../domain/historical_archive_source_identity.dart';

final class HistoricalMessagesArchiveSourceFolder {
  const HistoricalMessagesArchiveSourceFolder({
    required this.selectedFolderPath,
    required this.chatDbPath,
    required this.identity,
    required this.defaultSourceLabel,
  });

  final String selectedFolderPath;
  final String chatDbPath;
  final HistoricalArchiveSourceIdentity identity;
  final String defaultSourceLabel;

  String get sourceKey => identity.value;
}

abstract interface class HistoricalMessagesArchiveSourceFolderResolver {
  HistoricalMessagesArchiveSourceFolder resolveFolder(String folderPath);
}
