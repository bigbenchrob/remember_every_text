import 'dart:async';

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

  test('coalesces concurrent graph build requests', () async {
    final gate = Completer<void>();
    var importChatsCallCount = 0;
    final report = _report();
    final container = ProviderContainer(
      overrides: [
        conversationGraphBuildServiceProvider.overrideWith(
          (ref) async => ConversationGraphBuildService(
            orchestrator: _orchestrator(
              report: report,
              importChats: () async {
                importChatsCallCount += 1;
                await gate.future;
              },
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(
      conversationGraphBuildControllerProvider.notifier,
    );
    final first = notifier.runOnce(owner: 'first-owner');
    await Future<void>.delayed(Duration.zero);
    final second = notifier.runOnce(owner: 'second-owner');

    expect(identical(first, second), isTrue);
    expect(
      container.read(conversationGraphBuildControllerProvider).status,
      ConversationGraphBuildStatus.running,
    );

    gate.complete();
    final results = await Future.wait([first, second]);

    expect(importChatsCallCount, 1);
    expect(results[0], same(results[1]));
    final state = container.read(conversationGraphBuildControllerProvider);
    expect(state.status, ConversationGraphBuildStatus.succeeded);
    expect(state.owner, 'first-owner');
  });
}

ConversationGraphBuildOrchestrator _orchestrator({
  ConversationGraphBuildReport? report,
  Object? error,
  GraphBuildStep? importChats,
}) {
  Future<void> step() async {
    if (error != null) {
      throw error;
    }
  }

  return ConversationGraphBuildOrchestrator(
    importChats: importChats ?? step,
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
    enrichMissingText: (messageImportResult) async {
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
    projectMessages: (messageImportResult) async {
      await step();
      return report?.messageProjectionResult ??
          const MessageProjectionResult(
            examinedMessageCount: 0,
            insertedMessageCount: 0,
          );
    },
    projectAttachments: step,
    projectChatMessageEdges: (messageImportResult) async {
      await step();
    },
    projectMessageAttachmentEdges: step,
  );
}

ConversationGraphBuildReport _report() {
  return ConversationGraphBuildReport(
    startedAt: DateTime.utc(2026, 5, 30, 12),
    finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 1),
    completedStageNames: const <String>['import_messages', 'project_messages'],
    stageTimings: [
      ConversationGraphBuildStageTiming(
        stageName: 'import_messages',
        startedAt: DateTime.utc(2026, 5, 30, 12, 0),
        finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 0, 400),
      ),
      ConversationGraphBuildStageTiming(
        stageName: 'project_messages',
        startedAt: DateTime.utc(2026, 5, 30, 12, 0, 0, 400),
        finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 1),
      ),
    ],
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
