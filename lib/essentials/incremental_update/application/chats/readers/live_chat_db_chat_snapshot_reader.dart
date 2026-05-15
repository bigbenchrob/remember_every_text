import '../../../domain/models/chat_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/chat_db_chat_repository.dart';

class LiveChatDbChatSnapshotReader implements Reader<ChatSnapshot> {
  const LiveChatDbChatSnapshotReader({required ChatDbChatRepository repository})
    : _repository = repository;

  final ChatDbChatRepository _repository;

  @override
  Future<ChatSnapshot> read() async {
    return _repository.readChatSnapshot();
  }
}
