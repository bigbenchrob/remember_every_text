import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart';
import 'chat_db_chat_repository.dart';

part 'chat_db_chat_repository_provider.g.dart';

@riverpod
Future<ChatDbChatRepository> chatDbChatRepository(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return ChatDbChatRepository(chatDbPath: pathsHelper.chatDBPath);
}
