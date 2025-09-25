// Repository port (interface) for Messages.
// Location: lib/features/messages/domain/i_repositories/repository_interface.dart

import '../../../chats/domain/value_objects/chat_id.dart' as chats show ChatId;
import '../../../reactions/domain/entities/reaction.dart';
import '../entities/message.dart';
import '../value_objects/message_id.dart';

/// Domain-facing contract for message persistence/streams.
///
/// Guidance:
/// - Use a stable ordering (e.g., sentAt, then id) for pagination.
/// - `append` should enforce monotonic insert semantics.
/// - `save` is for edits (idempotent upsert).
abstract class MessagesRepository {
  Future<Message?> getById(MessageId id);

  /// Stream messages in a chat in descending or ascending order.
  /// Implementations may choose ascending by default; document it.
  Stream<List<Message>> streamByChat(
    chats.ChatId chatId, {
    int? limit,
    MessageId? before, // for infinite scroll pagination
  });

  /// Append a new message (should not reorder history).
  Future<void> append(Message message);

  /// Save/update an existing message idempotently (e.g., edits, delivery state).
  Future<void> save(Message message);

  /// Toggle or set a reaction on a message.
  Future<void> toggleReaction({
    required MessageId messageId,
    required Reaction reaction,
  });

  /// Optional: bulk upsert during import.
  Future<void> upsertAll(List<Message> messages);

  /// Optional: delete by id.
  Future<void> deleteById(MessageId id);
}
