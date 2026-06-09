import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../source_scoped_import/application/archives/source_scoped_archive_import_service_provider.dart';
import '../attachments/attachment_projector_provider.dart';
import '../chat_handle_joins/chat_to_handle_projector_provider.dart';
import '../chat_message_joins/chat_to_message_projector_provider.dart';
import '../chats/chat_projector_provider.dart';
import '../handles/handle_projector_provider.dart';
import '../message_attachment_joins/message_to_attachment_projector_provider.dart';
import '../messages/message_projector_provider.dart';
import 'source_scoped_archive_graph_import_service.dart';

part 'source_scoped_archive_graph_import_service_provider.g.dart';

@riverpod
Future<SourceScopedArchiveGraphImportService>
sourceScopedArchiveGraphImportService(Ref ref) async {
  final importService = await ref.watch(
    sourceScopedArchiveImportServiceProvider.future,
  );
  final handleProjector = await ref.watch(handleProjectorProvider.future);
  final chatToHandleProjector = await ref.watch(
    chatToHandleProjectorProvider.future,
  );
  final chatProjector = await ref.watch(chatProjectorProvider.future);
  final messageProjector = await ref.watch(messageProjectorProvider.future);
  final attachmentProjector = await ref.watch(
    attachmentProjectorProvider.future,
  );
  final chatToMessageProjector = await ref.watch(
    chatToMessageProjectorProvider.future,
  );
  final messageToAttachmentProjector = await ref.watch(
    messageToAttachmentProjectorProvider.future,
  );

  return SourceScopedArchiveGraphImportService(
    importService: importService,
    handleProjector: handleProjector,
    chatToHandleProjector: chatToHandleProjector,
    chatProjector: chatProjector,
    messageProjector: messageProjector,
    attachmentProjector: attachmentProjector,
    chatToMessageProjector: chatToMessageProjector,
    messageToAttachmentProjector: messageToAttachmentProjector,
  );
}
