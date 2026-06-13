import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature_level_providers.dart';
import 'chat_projector.dart';

part 'chat_projector_provider.g.dart';

@riverpod
Future<ChatProjector> chatProjector(Ref ref) async {
  final repository = await ref.watch(chatProjectionRepositoryProvider.future);
  return ChatProjector(repository: repository);
}
