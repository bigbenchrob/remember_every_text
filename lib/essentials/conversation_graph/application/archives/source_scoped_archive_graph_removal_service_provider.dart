import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../source_scoped_import/feature_level_providers.dart'
    show sourceScopedImportLedgerProvider;
import '../attachments/attachment_projector_provider.dart';
import '../chat_handle_joins/chat_to_handle_projector_provider.dart';
import '../chat_message_joins/chat_to_message_projector_provider.dart';
import '../chats/chat_projector_provider.dart';
import '../contacts/contact_projector_provider.dart';
import '../handles/handle_projector_provider.dart';
import '../message_attachment_joins/message_to_attachment_projector_provider.dart';
import '../messages/message_projector_provider.dart';
import 'graph_projection_resetter_provider.dart';
import 'source_scoped_archive_graph_removal_service.dart';

part 'source_scoped_archive_graph_removal_service_provider.g.dart';

@riverpod
Future<SourceScopedArchiveGraphRemovalService>
sourceScopedArchiveGraphRemovalService(Ref ref) async {
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final graphProjectionResetter = await ref.watch(
    graphProjectionResetterProvider.future,
  );
  final handleProjector = await ref.watch(handleProjectorProvider.future);
  final contactProjector = await ref.watch(contactProjectorProvider.future);
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

  return SourceScopedArchiveGraphRemovalService(
    importLedger: importLedger,
    graphProjectionResetter: graphProjectionResetter,
    handleProjector: handleProjector,
    contactProjector: contactProjector,
    chatToHandleProjector: chatToHandleProjector,
    chatProjector: chatProjector,
    messageProjector: messageProjector,
    attachmentProjector: attachmentProjector,
    chatToMessageProjector: chatToMessageProjector,
    messageToAttachmentProjector: messageToAttachmentProjector,
  );
}
