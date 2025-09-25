// Concrete infrastructure repository skeleton for chats.
// Location: lib/features/chats/infrastructure/repositories/sqlite_chats_repository.dart

import '../../domain/entities/chat.dart';
import '../../domain/i_repositories/repository_interface.dart';
import '../../domain/value_objects/chat_id.dart';

/// Example SQLite-backed repository.
/// Replace constructor params with your actual deps (e.g., Drift database).
class SqliteChatsRepository implements ChatsRepository {
  // final YourDriftDb db;
  SqliteChatsRepository();

  @override
  Future<Chat?> getById(ChatId id) async {
    // TODO: query by id and map to Chat
    throw UnimplementedError();
  }

  @override
  Stream<List<Chat>> streamAll() async* {
    // TODO: return a reactive query stream
    throw UnimplementedError();
  }

  @override
  Stream<Chat?> streamById(ChatId id) async* {
    // TODO: reactive single-chat stream
    throw UnimplementedError();
  }

  @override
  Future<void> upsert(Chat chat) async {
    // TODO: insert or update by primary key
    throw UnimplementedError();
  }

  @override
  Future<void> upsertAll(List<Chat> chats) async {
    // TODO: transactionally upsert all
    throw UnimplementedError();
  }

  @override
  Future<void> deleteById(ChatId id) async {
    // TODO: delete by id (or soft-delete)
    throw UnimplementedError();
  }
}
