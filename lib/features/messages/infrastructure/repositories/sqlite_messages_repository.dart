// Concrete infrastructure repository skeleton for messages.
// Location: lib/features/messages/infrastructure/repositories/sqlite_messages_repository.dart

import '../../../chats/domain/value_objects/chat_id.dart' as chats show ChatId;
import '../../../reactions/domain/entities/reaction.dart';
import '../../domain/entities/message.dart';
import '../../domain/i_repositories/repository_interface.dart';
import '../../domain/value_objects/message_id.dart';

/// Example SQLite-backed repository for Messages.
/// Replace constructor params with your actual deps (e.g., Drift database).
class SqliteMessagesRepository implements MessagesRepository {
  // final YourDriftDb db;
  SqliteMessagesRepository();

  @override
  Future<Message?> getById(MessageId id) async {
    // TODO: SELECT ... WHERE message_id = :id
    // Map row -> Message (use your safe value-accessor mapping)
    throw UnimplementedError();
  }

  @override
  Stream<List<Message>> streamByChat(
    chats.ChatId chatId, {
    int? limit,
    MessageId? before,
  }) async* {
    // TODO: Reactive query for messages in a chat.
    // Suggested ordering: sentAt DESC, messageId DESC (stable)
    // If `before` is provided, apply keyset pagination.
    // If `limit` is provided, cap results.
    throw UnimplementedError();
  }

  @override
  Future<void> append(Message message) async {
    // TODO: INSERT only (fail if id exists) to preserve monotonic history semantics.
    // Useful for import or when receiving new messages.
    throw UnimplementedError();
  }

  @override
  Future<void> save(Message message) async {
    // TODO: UPSERT by primary key (idempotent for edits/delivery state)
    throw UnimplementedError();
  }

  @override
  Future<void> toggleReaction({
    required MessageId messageId,
    required Reaction reaction,
  }) async {
    // TODO:
    // If (actor,key) exists for messageId -> DELETE (toggle off)
    // else INSERT (toggle on)
    throw UnimplementedError();
  }

  @override
  Future<void> upsertAll(List<Message> messages) async {
    // TODO: Transactional bulk UPSERT for import
    throw UnimplementedError();
  }

  @override
  Future<void> deleteById(MessageId id) async {
    // TODO: DELETE or soft-delete by id
    throw UnimplementedError();
  }
}
