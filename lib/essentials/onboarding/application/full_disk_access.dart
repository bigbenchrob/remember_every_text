abstract interface class FullDiskAccess {
  String get messagesDatabasePath;

  bool canReadMessagesDatabase();

  Future<void> openSettings();
}
