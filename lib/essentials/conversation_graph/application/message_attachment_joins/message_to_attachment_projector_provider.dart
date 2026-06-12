import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/repositories/message_to_attachment_projection_repository_provider.dart';
import 'message_to_attachment_projector.dart';

part 'message_to_attachment_projector_provider.g.dart';

@riverpod
Future<MessageToAttachmentProjector> messageToAttachmentProjector(
  Ref ref,
) async {
  final repository = await ref.watch(
    messageToAttachmentProjectionRepositoryProvider.future,
  );
  return MessageToAttachmentProjector(repository: repository);
}
