import '../../../domain/models/chat_message_join_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/chat_db_chat_message_join_repository.dart';

class LiveChatDbChatMessageJoinSnapshotReader
    implements Reader<ChatMessageJoinSnapshot> {
  const LiveChatDbChatMessageJoinSnapshotReader({
    required ChatDbChatMessageJoinRepository repository,
  }) : _repository = repository;

  final ChatDbChatMessageJoinRepository _repository;

  @override
  Future<ChatMessageJoinSnapshot> read() async {
    return _repository.readChatMessageJoinSnapshot();
  }
}
