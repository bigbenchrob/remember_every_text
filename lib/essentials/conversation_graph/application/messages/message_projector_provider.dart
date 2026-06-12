import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/repositories/message_projection_repository_provider.dart';
import 'message_projector.dart';

part 'message_projector_provider.g.dart';

@riverpod
Future<MessageProjector> messageProjector(Ref ref) async {
  final repository = await ref.watch(
    messageProjectionRepositoryProvider.future,
  );
  return MessageProjector(repository: repository);
}
