import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../source_scoped_import/application/attachments/attachment_importer_provider.dart';
import '../../source_scoped_import/application/chat_handle_joins/chat_handle_join_importer_provider.dart';
import '../../source_scoped_import/application/chat_message_joins/chat_message_join_importer_provider.dart';
import '../../source_scoped_import/application/chats/chat_importer_provider.dart';
import '../../source_scoped_import/application/contacts/contact_importer_provider.dart';
import '../../source_scoped_import/application/handles/handle_importer_provider.dart';
import '../../source_scoped_import/application/message_attachment_joins/message_attachment_join_importer_provider.dart';
import '../../source_scoped_import/application/messages/message_importer.dart';
import '../../source_scoped_import/application/messages/message_importer_provider.dart';
import '../../source_scoped_import/application/messages/message_rich_text_enricher.dart';
import '../../source_scoped_import/application/messages/message_rich_text_enricher_provider.dart';
import '../../source_scoped_import/domain/known_sources.dart';
import 'attachments/attachment_projector_provider.dart';
import 'chat_handle_joins/chat_to_handle_projector_provider.dart';
import 'chat_message_joins/chat_to_message_projector_provider.dart';
import 'chats/chat_projector_provider.dart';
import 'contacts/contact_projector_provider.dart';
import 'conversation_graph_build_report.dart';
import 'handles/handle_projector_provider.dart';
import 'message_attachment_joins/message_to_attachment_projector_provider.dart';
import 'messages/message_projector_provider.dart';
import 'orchestrators/conversation_graph_build_orchestrator.dart';

part 'conversation_graph_build_service_provider.g.dart';

class ConversationGraphBuildService {
  const ConversationGraphBuildService({
    required ConversationGraphBuildOrchestrator orchestrator,
    Future<LocalAccountHandleIdentityReconciliationReport> Function()?
    reconcileLocalAccountHandleIdentity,
  }) : _orchestrator = orchestrator,
       _reconcileLocalAccountHandleIdentity =
           reconcileLocalAccountHandleIdentity;

  final ConversationGraphBuildOrchestrator _orchestrator;
  final Future<LocalAccountHandleIdentityReconciliationReport> Function()?
  _reconcileLocalAccountHandleIdentity;

  Future<ConversationGraphBuildReport> runOnce() {
    return _orchestrator.runOnce();
  }

  Future<LocalAccountHandleIdentityReconciliationReport>
  reconcileLocalAccountHandleIdentity() async {
    final reconcile = _reconcileLocalAccountHandleIdentity;
    if (reconcile == null) {
      return const LocalAccountHandleIdentityReconciliationReport();
    }
    return reconcile();
  }
}

class LocalAccountHandleIdentityReconciliationReport {
  const LocalAccountHandleIdentityReconciliationReport({
    this.examinedHandleCount = 0,
    this.localAccountHandleCount = 0,
    this.updatedImportHandleCount = 0,
    this.updatedGraphHandleCount = 0,
  });

  final int examinedHandleCount;
  final int localAccountHandleCount;
  final int updatedImportHandleCount;
  final int updatedGraphHandleCount;
}

@visibleForTesting
Future<MessageRichTextEnrichmentResult> runGraphBuildRichTextEnrichment({
  required MessageImportResult messageImportResult,
  required Future<MessageRichTextEnrichmentResult> Function()
  enrichAllMissingText,
  required Future<MessageRichTextEnrichmentResult> Function({
    required int sourceId,
    required int startedAfterSourceRowId,
  })
  enrichMissingTextAfterSourceRowId,
}) {
  if (messageImportResult.insertedMessageCount == 0) {
    return enrichAllMissingText();
  }
  return enrichMissingTextAfterSourceRowId(
    sourceId: liveChatDbSourceId,
    startedAfterSourceRowId: messageImportResult.startedAfterSourceRowId,
  );
}

@riverpod
Future<ConversationGraphBuildService> conversationGraphBuildService(
  Ref ref,
) async {
  final chatImporter = await ref.watch(chatImporterProvider.future);
  final handleImporter = await ref.watch(handleImporterProvider.future);
  final contactImporter = await ref.watch(contactImporterProvider.future);
  final messageImporter = await ref.watch(messageImporterProvider.future);
  final richTextEnricher = await ref.watch(
    messageRichTextEnricherProvider.future,
  );
  final attachmentImporter = await ref.watch(attachmentImporterProvider.future);
  final chatMessageJoinImporter = await ref.watch(
    chatMessageJoinImporterProvider.future,
  );
  final chatHandleJoinImporter = await ref.watch(
    chatHandleJoinImporterProvider.future,
  );
  final messageAttachmentJoinImporter = await ref.watch(
    messageAttachmentJoinImporterProvider.future,
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

  return ConversationGraphBuildService(
    reconcileLocalAccountHandleIdentity: () async {
      final importResult = await handleImporter.reconcileLocalAccountIdentity();
      final projectionResult = await handleProjector
          .projectLocalAccountIdentity();
      return LocalAccountHandleIdentityReconciliationReport(
        examinedHandleCount: importResult.examinedHandleCount,
        localAccountHandleCount: importResult.localAccountHandleCount,
        updatedImportHandleCount: importResult.updatedHandleCount,
        updatedGraphHandleCount: projectionResult.updatedHandleCount,
      );
    },
    orchestrator: ConversationGraphBuildOrchestrator(
      importChats: () async {
        await chatImporter.importChats();
      },
      importHandles: () async {
        await handleImporter.importNewHandles();
      },
      importContacts: () async {
        await contactImporter.importContacts();
      },
      importMessages: messageImporter.importNewMessages,
      enrichMissingText: (messageImportResult) {
        return runGraphBuildRichTextEnrichment(
          messageImportResult: messageImportResult,
          enrichAllMissingText: richTextEnricher.enrichMissingText,
          enrichMissingTextAfterSourceRowId:
              richTextEnricher.enrichMissingTextAfterSourceRowId,
        );
      },
      importAttachments: attachmentImporter.importAttachments,
      importChatMessageJoins: (messageImportResult) async {
        if (messageImportResult.insertedMessageCount == 0) {
          await chatMessageJoinImporter.importJoins();
          return;
        }
        await chatMessageJoinImporter.importJoinsAfterSourceMessageRowId(
          startedAfterSourceRowId: messageImportResult.startedAfterSourceRowId,
        );
      },
      importChatHandleJoins: () async {
        await chatHandleJoinImporter.importJoins();
      },
      importMessageAttachmentJoins: (messageImportResult) async {
        if (messageImportResult.insertedMessageCount == 0) {
          await messageAttachmentJoinImporter.importJoins();
          return;
        }
        await messageAttachmentJoinImporter.importJoinsAfterSourceMessageRowId(
          startedAfterSourceRowId: messageImportResult.startedAfterSourceRowId,
        );
      },
      projectHandles: () async {
        await handleProjector.projectHandles();
      },
      projectContacts: contactProjector.projectContacts,
      projectChatHandleEdges: () async {
        await chatToHandleProjector.projectEdges();
      },
      projectChats: () async {
        await chatProjector.projectChats();
      },
      projectMessages: (messageImportResult) {
        if (messageImportResult.insertedMessageCount == 0) {
          return messageProjector.projectMessages();
        }
        return messageProjector.projectMessagesAfterSourceRowId(
          sourceId: liveChatDbSourceId,
          startedAfterSourceRowId: messageImportResult.startedAfterSourceRowId,
        );
      },
      projectAttachments: (messageImportResult, attachmentImportResult) async {
        if (messageImportResult.insertedMessageCount == 0) {
          await attachmentProjector.projectAttachments();
          return;
        }
        if (attachmentImportResult.insertedAttachmentCount == 0) {
          return;
        }
        await attachmentProjector.projectAttachmentsAfterSourceRowId(
          sourceId: liveChatDbSourceId,
          startedAfterSourceRowId:
              attachmentImportResult.startedAfterSourceRowId,
        );
      },
      projectChatMessageEdges: (messageImportResult) async {
        if (messageImportResult.insertedMessageCount == 0) {
          await chatToMessageProjector.projectEdges();
          return;
        }
        await chatToMessageProjector.projectEdgesAfterSourceMessageRowId(
          sourceId: liveChatDbSourceId,
          startedAfterSourceRowId: messageImportResult.startedAfterSourceRowId,
        );
      },
      projectMessageAttachmentEdges: (messageImportResult) async {
        if (messageImportResult.insertedMessageCount == 0) {
          await messageToAttachmentProjector.projectEdges();
          return;
        }
        await messageToAttachmentProjector.projectEdgesAfterSourceMessageRowId(
          sourceId: liveChatDbSourceId,
          startedAfterSourceRowId: messageImportResult.startedAfterSourceRowId,
        );
      },
    ),
  );
}
