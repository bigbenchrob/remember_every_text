import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector.dart';

void main() {
  test('delegates edge projection to repository', () async {
    final repository = _FakeChatToMessageProjectionRepository(
      result: const ChatToMessageProjectionResult(
        examinedEdgeCount: 3,
        insertedEdgeCount: 2,
      ),
    );
    final result = await ChatToMessageProjector(
      repository: repository,
    ).projectEdges();

    expect(repository.callCount, 1);
    expect(result.examinedEdgeCount, 3);
    expect(result.insertedEdgeCount, 2);
  });

  test('delegates bounded edge projection to repository', () async {
    final repository = _FakeChatToMessageProjectionRepository(
      result: const ChatToMessageProjectionResult(
        examinedEdgeCount: 1,
        insertedEdgeCount: 1,
      ),
    );
    final result = await ChatToMessageProjector(repository: repository)
        .projectEdgesAfterSourceMessageRowId(
          sourceId: 7,
          startedAfterSourceRowId: 40,
        );

    expect(repository.boundedCallCount, 1);
    expect(repository.lastSourceId, 7);
    expect(repository.lastStartedAfterSourceRowId, 40);
    expect(result.examinedEdgeCount, 1);
    expect(result.insertedEdgeCount, 1);
  });
}

class _FakeChatToMessageProjectionRepository
    implements ChatToMessageProjectionRepository {
  _FakeChatToMessageProjectionRepository({required this.result});

  final ChatToMessageProjectionResult result;
  int callCount = 0;
  int boundedCallCount = 0;
  int? lastSourceId;
  int? lastStartedAfterSourceRowId;

  @override
  Future<ChatToMessageProjectionResult> projectEdges() async {
    callCount += 1;
    return result;
  }

  @override
  Future<ChatToMessageProjectionResult> projectEdgesAfterSourceMessageRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) async {
    boundedCallCount += 1;
    lastSourceId = sourceId;
    lastStartedAfterSourceRowId = startedAfterSourceRowId;
    return result;
  }
}
