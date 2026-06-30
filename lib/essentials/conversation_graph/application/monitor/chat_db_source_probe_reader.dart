abstract interface class ChatDbSourceProbeReader {
  int readMaxRowId(String chatDbPath);

  int readImportableMessageCount(String chatDbPath);
}
