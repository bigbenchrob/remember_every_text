import 'chat_to_message_projection_repository.dart';

class ChatToMessageProjector {
  const ChatToMessageProjector({required this.repository});

  final ChatToMessageProjectionRepository repository;

  Future<ChatToMessageProjectionResult> projectEdges() =>
      repository.projectEdges();
}
