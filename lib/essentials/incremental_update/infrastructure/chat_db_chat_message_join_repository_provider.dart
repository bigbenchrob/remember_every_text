import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart';
import 'chat_db_chat_message_join_repository.dart';

part 'chat_db_chat_message_join_repository_provider.g.dart';

@riverpod
Future<ChatDbChatMessageJoinRepository> chatDbChatMessageJoinRepository(
  Ref ref,
) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return ChatDbChatMessageJoinRepository(chatDbPath: pathsHelper.chatDBPath);
}
