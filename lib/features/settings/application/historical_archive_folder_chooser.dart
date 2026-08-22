abstract interface class HistoricalArchiveFolderChooser {
  Future<String?> chooseMessagesFolder();

  Future<String?> chooseMessageLensFolder();
}
