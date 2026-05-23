import 'chat_projection_repository.dart';

class ChatProjector {
  const ChatProjector({required this.repository});

  final ChatProjectionRepository repository;

  Future<ChatProjectionResult> projectChats() => repository.projectChats();
}
