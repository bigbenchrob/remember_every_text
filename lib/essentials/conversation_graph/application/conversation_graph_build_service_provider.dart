import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../source_scoped_import/application/chat_handle_joins/chat_handle_join_importer_provider.dart';
import '../../source_scoped_import/application/chat_message_joins/chat_message_join_importer_provider.dart';
import '../../source_scoped_import/application/chats/chat_importer_provider.dart';
import '../../source_scoped_import/application/handles/handle_importer_provider.dart';
import '../../source_scoped_import/application/messages/message_importer_provider.dart';
import '../../source_scoped_import/application/messages/message_rich_text_enricher_provider.dart';
import 'chat_handle_joins/chat_to_handle_projector_provider.dart';
import 'chat_message_joins/chat_to_message_projector_provider.dart';
import 'chats/chat_projector_provider.dart';
import 'handles/handle_projector_provider.dart';
import 'messages/message_projector_provider.dart';
import 'orchestrators/conversation_graph_build_orchestrator.dart';

part 'conversation_graph_build_service_provider.g.dart';

class ConversationGraphBuildService {
  const ConversationGraphBuildService({
    required ConversationGraphBuildOrchestrator orchestrator,
  }) : _orchestrator = orchestrator;

  final ConversationGraphBuildOrchestrator _orchestrator;

  Future<ConversationGraphBuildReport> runOnce() {
    return _orchestrator.runOnce();
  }
}

@riverpod
Future<ConversationGraphBuildService> conversationGraphBuildService(
  Ref ref,
) async {
  final chatImporter = await ref.watch(chatImporterProvider.future);
  final handleImporter = await ref.watch(handleImporterProvider.future);
  final messageImporter = await ref.watch(messageImporterProvider.future);
  final richTextEnricher = await ref.watch(
    messageRichTextEnricherProvider.future,
  );
  final chatMessageJoinImporter = await ref.watch(
    chatMessageJoinImporterProvider.future,
  );
  final chatHandleJoinImporter = await ref.watch(
    chatHandleJoinImporterProvider.future,
  );
  final handleProjector = await ref.watch(handleProjectorProvider.future);
  final chatToHandleProjector = await ref.watch(
    chatToHandleProjectorProvider.future,
  );
  final chatProjector = await ref.watch(chatProjectorProvider.future);
  final messageProjector = await ref.watch(messageProjectorProvider.future);
  final chatToMessageProjector = await ref.watch(
    chatToMessageProjectorProvider.future,
  );

  return ConversationGraphBuildService(
    orchestrator: ConversationGraphBuildOrchestrator(
      importChats: () async {
        await chatImporter.importChats();
      },
      importHandles: () async {
        await handleImporter.importNewHandles();
      },
      importMessages: messageImporter.importNewMessages,
      enrichMissingText: richTextEnricher.enrichMissingText,
      importChatMessageJoins: () async {
        await chatMessageJoinImporter.importJoins();
      },
      importChatHandleJoins: () async {
        await chatHandleJoinImporter.importJoins();
      },
      projectHandles: () async {
        await handleProjector.projectHandles();
      },
      projectChatHandleEdges: () async {
        await chatToHandleProjector.projectEdges();
      },
      projectChats: () async {
        await chatProjector.projectChats();
      },
      projectMessages: messageProjector.projectMessages,
      projectChatMessageEdges: () async {
        await chatToMessageProjector.projectEdges();
      },
    ),
  );
}
