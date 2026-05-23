import 'chat_to_handle_projection_repository.dart';

class ChatToHandleProjector {
  const ChatToHandleProjector({required this.repository});

  final ChatToHandleProjectionRepository repository;

  Future<ChatToHandleProjectionResult> projectEdges() =>
      repository.projectEdges();
}
