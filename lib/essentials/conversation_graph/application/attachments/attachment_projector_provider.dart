import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'attachment_projection_repository_provider.dart';
import 'attachment_projector.dart';

part 'attachment_projector_provider.g.dart';

@riverpod
Future<AttachmentProjector> attachmentProjector(Ref ref) async {
  final repository = await ref.watch(
    attachmentProjectionRepositoryProvider.future,
  );
  return AttachmentProjector(repository: repository);
}
