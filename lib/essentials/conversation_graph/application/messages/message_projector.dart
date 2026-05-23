import 'message_projection_repository.dart';

class MessageProjector {
  const MessageProjector({required this.repository});

  final MessageProjectionRepository repository;

  Future<MessageProjectionResult> projectMessages() =>
      repository.projectMessages();
}
