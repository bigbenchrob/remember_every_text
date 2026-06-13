import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature_level_providers.dart';
import 'chat_to_message_projector.dart';

part 'chat_to_message_projector_provider.g.dart';

@riverpod
Future<ChatToMessageProjector> chatToMessageProjector(Ref ref) async {
  final repository = await ref.watch(
    chatToMessageProjectionRepositoryProvider.future,
  );
  return ChatToMessageProjector(repository: repository);
}
