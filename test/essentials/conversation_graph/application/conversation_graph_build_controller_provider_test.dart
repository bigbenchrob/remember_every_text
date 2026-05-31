import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_controller_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_service_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';

void main() {
  test('records successful graph build lifecycle state', () async {
    final report = _report();
    final container = ProviderContainer(
      overrides: [
        conversationGraphBuildServiceProvider.overrideWith(
          (ref) async => ConversationGraphBuildService(
            orchestrator: _orchestrator(report: report),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(conversationGraphBuildControllerProvider.notifier)
        .runOnce(owner: 'test-owner');

    expect(result.messageImportResult.insertedMessageCount, 1);
    final state = container.read(conversationGraphBuildControllerProvider);
    expect(state.status, ConversationGraphBuildStatus.succeeded);
    expect(state.owner, 'test-owner');
    expect(state.lastReport?.messageProjectionResult.insertedMessageCount, 1);
    expect(state.lastError, isNull);
  });

  test('records failed graph build lifecycle state', () async {
    final container = ProviderContainer(
      overrides: [
        conversationGraphBuildServiceProvider.overrideWith(
          (ref) async => ConversationGraphBuildService(
            orchestrator: _orchestrator(error: StateError('boom')),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(conversationGraphBuildControllerProvider.notifier)
          .runOnce(owner: 'test-owner'),
      throwsStateError,
    );

    final state = container.read(conversationGraphBuildControllerProvider);
    expect(state.status, ConversationGraphBuildStatus.failed);
    expect(state.owner, 'test-owner');
    expect(state.lastReport, isNull);
    expect(state.lastError, contains('boom'));
  });
}

ConversationGraphBuildOrchestrator _orchestrator({
  ConversationGraphBuildReport? report,
  Object? error,
}) {
  Future<void> step() async {
    if (error != null) {
      throw error;
    }
  }

  return ConversationGraphBuildOrchestrator(
    importChats: step,
    importHandles: step,
    importContacts: step,
    importMessages: () async {
      await step();
      return report?.messageImportResult ??
          const MessageImportResult(
            startedAfterSourceRowId: 0,
            insertedMessageCount: 0,
            lastImportedSourceRowId: null,
          );
    },
    enrichMissingText: () async {
      await step();
      return report?.richTextEnrichmentResult ??
          const MessageRichTextEnrichmentResult(
            candidateMessageCount: 0,
            enrichedMessageCount: 0,
            missingExtractionCount: 0,
            extractorAvailable: true,
          );
    },
    importAttachments: step,
    importChatMessageJoins: step,
    importChatHandleJoins: step,
    importMessageAttachmentJoins: step,
    projectHandles: step,
    projectContacts: () async {
      await step();
      return const ContactProjectionResult(
        examinedContactCount: 0,
        insertedContactCount: 0,
        insertedContactHandleEdgeCount: 0,
      );
    },
    projectChatHandleEdges: step,
    projectChats: step,
    projectMessages: () async {
      await step();
      return report?.messageProjectionResult ??
          const MessageProjectionResult(
            examinedMessageCount: 0,
            insertedMessageCount: 0,
          );
    },
    projectAttachments: step,
    projectChatMessageEdges: step,
    projectMessageAttachmentEdges: step,
  );
}

ConversationGraphBuildReport _report() {
  return ConversationGraphBuildReport(
    startedAt: DateTime.utc(2026, 5, 30, 12),
    finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 1),
    completedStageNames: const <String>['import_messages', 'project_messages'],
    messageImportResult: const MessageImportResult(
      startedAfterSourceRowId: 10,
      insertedMessageCount: 1,
      lastImportedSourceRowId: 11,
    ),
    richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
      candidateMessageCount: 0,
      enrichedMessageCount: 0,
      missingExtractionCount: 0,
      extractorAvailable: true,
    ),
    messageProjectionResult: const MessageProjectionResult(
      examinedMessageCount: 1,
      insertedMessageCount: 1,
    ),
  );
}
