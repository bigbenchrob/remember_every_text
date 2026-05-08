import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart';
import 'chat_db_message_repository.dart';

part 'chat_db_message_repository_provider.g.dart';

@riverpod
Future<ChatDbMessageRepository> chatDbMessageRepository(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return ChatDbMessageRepository(chatDbPath: pathsHelper.chatDBPath);
}
