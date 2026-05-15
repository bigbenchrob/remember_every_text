import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers.dart';
import 'chat_db_handle_repository.dart';

part 'chat_db_handle_repository_provider.g.dart';

@riverpod
Future<ChatDbHandleRepository> chatDbHandleRepository(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return ChatDbHandleRepository(chatDbPath: pathsHelper.chatDBPath);
}
