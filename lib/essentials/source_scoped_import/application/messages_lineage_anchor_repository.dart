import '../domain/messages_lineage_anchor.dart';

abstract interface class MessagesLineageAnchorRepository {
  Future<MessagesLineageAnchorEvidence> readMacMessagesDatabase({
    required String databasePath,
  });

  Future<MessagesLineageAnchorEvidence> readMessageLensImportLedger({
    required String databasePath,
  });
}
