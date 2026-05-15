import '../../../domain/models/chat_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/import_ledger_chat_repository.dart';

class ImportLedgerChatSnapshotReader implements Reader<ChatSnapshot> {
  const ImportLedgerChatSnapshotReader({
    required ImportLedgerChatRepository repository,
  }) : _repository = repository;

  final ImportLedgerChatRepository _repository;

  @override
  Future<ChatSnapshot> read() async {
    return _repository.readChatSnapshot();
  }
}
