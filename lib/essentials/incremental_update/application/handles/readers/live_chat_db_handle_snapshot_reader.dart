import '../../../domain/models/handle_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/chat_db_handle_repository.dart';

class LiveChatDbHandleSnapshotReader implements Reader<HandleSnapshot> {
  const LiveChatDbHandleSnapshotReader({
    required ChatDbHandleRepository repository,
  }) : _repository = repository;

  final ChatDbHandleRepository _repository;

  @override
  Future<HandleSnapshot> read() async {
    return _repository.readHandleSnapshot();
  }
}
