import '../../../domain/models/live_chat_db_message_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/chat_db_message_repository.dart';

class LiveChatDbMessageSnapshotReader
    implements Reader<LiveChatDbMessageSnapshot> {
  const LiveChatDbMessageSnapshotReader({
    required ChatDbMessageRepository repository,
  }) : _repository = repository;

  final ChatDbMessageRepository _repository;

  @override
  Future<LiveChatDbMessageSnapshot> read() async {
    return _repository.readMessageSnapshot();
  }
}
