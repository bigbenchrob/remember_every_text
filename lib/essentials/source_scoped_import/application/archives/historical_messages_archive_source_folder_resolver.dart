final class HistoricalMessagesArchiveSourceFolder {
  const HistoricalMessagesArchiveSourceFolder({
    required this.selectedFolderPath,
    required this.chatDbPath,
    required this.sourceKey,
    required this.defaultSourceLabel,
  });

  final String selectedFolderPath;
  final String chatDbPath;
  final String sourceKey;
  final String defaultSourceLabel;
}

abstract interface class HistoricalMessagesArchiveSourceFolderResolver {
  HistoricalMessagesArchiveSourceFolder resolveFolder(String folderPath);
}
