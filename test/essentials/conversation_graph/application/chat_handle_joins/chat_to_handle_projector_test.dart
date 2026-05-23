import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector.dart';

void main() {
  test('delegates edge projection to repository', () async {
    final repository = _FakeChatToHandleProjectionRepository(
      result: const ChatToHandleProjectionResult(
        examinedEdgeCount: 4,
        insertedEdgeCount: 1,
      ),
    );
    final result = await ChatToHandleProjector(
      repository: repository,
    ).projectEdges();

    expect(repository.callCount, 1);
    expect(result.examinedEdgeCount, 4);
    expect(result.insertedEdgeCount, 1);
  });
}

class _FakeChatToHandleProjectionRepository
    implements ChatToHandleProjectionRepository {
  _FakeChatToHandleProjectionRepository({required this.result});

  final ChatToHandleProjectionResult result;
  int callCount = 0;

  @override
  Future<ChatToHandleProjectionResult> projectEdges() async {
    callCount += 1;
    return result;
  }
}
