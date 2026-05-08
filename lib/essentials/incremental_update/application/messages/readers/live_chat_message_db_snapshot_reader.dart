import '../../../domain/responsibiliity_role_interfaces.dart';
import '../models/live_chat_db_message_snapshot.dart';

class LiveChatDbMessageSnapshotReader
    implements Reader<LiveChatDbMessageSnapshot> {
  @override
  Future<LiveChatDbMessageSnapshot> read() async {
    return const LiveChatDbMessageSnapshot(
      maxRowId: 42,
      importableMessageCount: 10,
    );
  }
}
