import '../../../domain/models/chat_message_join_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/import_ledger_chat_message_join_repository.dart';

class ImportLedgerChatMessageJoinSnapshotReader
    implements Reader<ChatMessageJoinSnapshot> {
  const ImportLedgerChatMessageJoinSnapshotReader({
    required ImportLedgerChatMessageJoinRepository repository,
  }) : _repository = repository;

  final ImportLedgerChatMessageJoinRepository _repository;

  @override
  Future<ChatMessageJoinSnapshot> read() async {
    return _repository.readChatMessageJoinSnapshot();
  }
}
