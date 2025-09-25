// Repository port (interface) for Chats.
// Location: lib/features/chats/domain/i_repositories/repository_interface.dart

import '../entities/chat.dart';
import '../value_objects/chat_id.dart';

/// Domain-facing contract for chat persistence/streams.
///
/// Notes:
/// - `streamAll` powers sidebar/live lists.
/// - `streamById` is handy for a single-chat screen reacting to changes.
/// - `upsert`/`upsertAll` are import/projection-safe and idempotent.
abstract class ChatsRepository {
  Future<Chat?> getById(ChatId id);

  /// Stream all chats; implementation should emit on inserts/updates.
  Stream<List<Chat>> streamAll();

  /// Stream a single chat by id; emit null if deleted or not found.
  Stream<Chat?> streamById(ChatId id);

  /// Idempotent create/update.
  Future<void> upsert(Chat chat);

  /// Bulk idempotent create/update; useful for import.
  Future<void> upsertAll(List<Chat> chats);

  /// Optional: delete by id (keep if you plan soft-deletes elsewhere).
  Future<void> deleteById(ChatId id);
}
