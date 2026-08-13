enum ChatDbSourceProbeFailureKind {
  databaseMissing,
  sqliteOpenFailed,
  expectedSchemaUnavailable,
  queryFailed,
}

final class ChatDbSourceProbeException extends StateError {
  ChatDbSourceProbeException({
    required this.kind,
    required this.databasePath,
    required String operation,
    this.cause,
  }) : super(
         'chat.db source probe failed during $operation '
         '(${kind.name}) for $databasePath'
         '${cause == null ? '' : ': $cause'}',
       );

  final ChatDbSourceProbeFailureKind kind;
  final String databasePath;
  final Object? cause;
}

abstract interface class ChatDbSourceProbeReader {
  int readMaxRowId(String chatDbPath);

  int readImportableMessageCount(String chatDbPath);
}
