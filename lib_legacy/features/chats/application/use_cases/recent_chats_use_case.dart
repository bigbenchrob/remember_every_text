import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/chat_with_latest_message.dart';
import '../../infrastructure/chats_repository.dart';

part 'recent_chats_use_case.g.dart';

/// Use case for getting recent chats ordered by latest message
/// Application layer - orchestrates business logic
@riverpod
Future<List<ChatWithLatestMessage>> recentChats(
  RecentChatsRef ref, {
  int limit = 5,
}) async {
  final repository = ref.read(chatsRepositoryProvider);
  return repository.getChatsByLatestMessage(limit: limit);
}
