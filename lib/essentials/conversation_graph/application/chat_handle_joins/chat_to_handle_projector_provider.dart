import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chat_to_handle_projection_repository_provider.dart';
import 'chat_to_handle_projector.dart';

part 'chat_to_handle_projector_provider.g.dart';

@riverpod
Future<ChatToHandleProjector> chatToHandleProjector(Ref ref) async {
  final repository = await ref.watch(
    chatToHandleProjectionRepositoryProvider.future,
  );
  return ChatToHandleProjector(repository: repository);
}
