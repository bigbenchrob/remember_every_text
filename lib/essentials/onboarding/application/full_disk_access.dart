typedef MessagesDatabaseReadProbe = int Function(String databasePath);

abstract interface class FullDiskAccess {
  String get messagesDatabasePath;

  bool canReadMessagesDatabase();

  Future<void> openSettings();
}
