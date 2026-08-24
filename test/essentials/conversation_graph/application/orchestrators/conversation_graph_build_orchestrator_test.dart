import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_observation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/projection_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';

void main() {
  test('runs conversation graph build stages in fixed order', () async {
    final calls = <String>[];
    final observations = <ConversationGraphBuildObservation>[];
    final orchestrator = ConversationGraphBuildOrchestrator(
      importChats: (_) => _record(calls, 'import_chats')(),
      importHandles: (onProgress) async {
        calls.add('import_handles');
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.handles,
            completedWorkCount: 0,
            totalWorkCount: 2,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.handles,
            completedWorkCount: 2,
            totalWorkCount: 2,
            lastCompletedSourceRowId: 12,
            preservedUnnormalizedCount: 1,
          ),
        );
      },
      importContacts: (onProgress) async {
        calls.add('import_contacts');
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.contacts,
            completedWorkCount: 0,
            totalWorkCount: 1,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.contacts,
            completedWorkCount: 1,
            totalWorkCount: 1,
            lastCompletedSourceRowId: 20,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.contactEmailChannels,
            completedWorkCount: 0,
            totalWorkCount: 1,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.contactEmailChannels,
            completedWorkCount: 1,
            totalWorkCount: 1,
            lastCompletedSourceRowId: 20,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.contactPhoneChannels,
            completedWorkCount: 0,
            totalWorkCount: 1,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.contactPhoneChannels,
            completedWorkCount: 1,
            totalWorkCount: 1,
            lastCompletedSourceRowId: 20,
          ),
        );
      },
      importMessages: (_) async {
        calls.add('import_messages');
        return const MessageImportResult(
          startedAfterSourceRowId: 10,
          insertedMessageCount: 2,
          lastImportedSourceRowId: 12,
        );
      },
      enrichMissingText: (messageImportResult, onProgress) async {
        calls.add('enrich_missing_text');
        expect(messageImportResult.insertedMessageCount, 2);
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.richTextExtraction,
            completedWorkCount: 0,
            totalWorkCount: 2,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.richTextExtraction,
            completedWorkCount: 2,
            totalWorkCount: 2,
            lastCompletedSourceRowId: 12,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.richTextPersistence,
            completedWorkCount: 0,
            totalWorkCount: 2,
          ),
        );
        onProgress?.call(
          const SourceImportWorkProgress(
            unit: SourceImportWorkUnit.richTextPersistence,
            completedWorkCount: 2,
            totalWorkCount: 2,
            lastCompletedSourceRowId: 12,
          ),
        );
        return const MessageRichTextEnrichmentResult(
          candidateMessageCount: 3,
          enrichedMessageCount: 2,
          missingExtractionCount: 1,
          extractorAvailable: true,
        );
      },
      importAttachments: (_) async {
        calls.add('import_attachments');
        return const AttachmentImportResult(
          startedAfterSourceRowId: 20,
          examinedAttachmentCount: 1,
          insertedAttachmentCount: 1,
          lastImportedSourceRowId: 21,
        );
      },
      importChatMessageJoins: (messageImportResult, _) async {
        calls.add('import_chat_message_joins');
        expect(messageImportResult.startedAfterSourceRowId, 10);
      },
      importChatHandleJoins: (_) =>
          _record(calls, 'import_chat_handle_joins')(),
      importMessageAttachmentJoins: (messageImportResult, _) async {
        calls.add('import_message_attachment_joins');
        expect(messageImportResult.startedAfterSourceRowId, 10);
      },
      projectHandles: _record(calls, 'project_handles'),
      projectContacts: () async {
        calls.add('project_contacts');
        return const ContactProjectionResult(
          examinedContactCount: 0,
          insertedContactCount: 0,
          insertedContactHandleEdgeCount: 0,
        );
      },
      projectChatHandleEdges: _record(calls, 'project_chat_handle_edges'),
      projectChats: (_) => _record(calls, 'project_chats')(),
      projectMessages: (messageImportResult, onProgress) async {
        calls.add('project_messages');
        expect(messageImportResult.startedAfterSourceRowId, 10);
        for (final completed in <int>[0, 250, 1000, 1250]) {
          onProgress?.call(
            GraphProjectionWorkProgress(
              completedWorkCount: completed,
              totalWorkCount: 1250,
            ),
          );
        }
        return const MessageProjectionResult(
          examinedMessageCount: 5,
          insertedMessageCount: 4,
        );
      },
      projectAttachments:
          (messageImportResult, attachmentImportResult, _) async {
            calls.add('project_attachments');
            expect(messageImportResult.startedAfterSourceRowId, 10);
            expect(attachmentImportResult.startedAfterSourceRowId, 20);
          },
      projectChatMessageEdges: (messageImportResult) async {
        calls.add('project_chat_message_edges');
        expect(messageImportResult.startedAfterSourceRowId, 10);
      },
      projectMessageAttachmentEdges: (messageImportResult) async {
        calls.add('project_message_attachment_edges');
        expect(messageImportResult.startedAfterSourceRowId, 10);
      },
    );

    final report = await orchestrator.runOnce(onObservation: observations.add);

    expect(calls, <String>[
      'import_chats',
      'import_handles',
      'import_contacts',
      'import_messages',
      'enrich_missing_text',
      'import_attachments',
      'import_chat_message_joins',
      'import_chat_handle_joins',
      'import_message_attachment_joins',
      'project_handles',
      'project_contacts',
      'project_chat_handle_edges',
      'project_chats',
      'project_messages',
      'project_attachments',
      'project_chat_message_edges',
      'project_message_attachment_edges',
    ]);
    expect(report.completedStageNames, calls);
    expect(report.messageImportResult.insertedMessageCount, 2);
    expect(report.richTextEnrichmentResult.enrichedMessageCount, 2);
    expect(report.messageProjectionResult.insertedMessageCount, 4);
    expect(report.finishedAt.isBefore(report.startedAt), isFalse);
    expect(
      observations
          .where(
            (item) =>
                item.suboperation ==
                ConversationGraphBuildSuboperation.importHandles,
          )
          .map((item) => item.kind),
      <ConversationGraphBuildObservationKind>[
        ConversationGraphBuildObservationKind.started,
        ConversationGraphBuildObservationKind.progress,
        ConversationGraphBuildObservationKind.progress,
        ConversationGraphBuildObservationKind.completed,
      ],
    );
    final finalHandleProgress = observations.lastWhere(
      (item) =>
          item.suboperation ==
              ConversationGraphBuildSuboperation.importHandles &&
          item.kind == ConversationGraphBuildObservationKind.progress,
    );
    expect(finalHandleProgress.completedWorkCount, 2);
    expect(finalHandleProgress.totalWorkCount, 2);
    expect(finalHandleProgress.lastCompletedSourceRowId, 12);
    expect(finalHandleProgress.preservedUnnormalizedCount, 1);
    expect(
      observations
          .where(
            (item) =>
                item.kind == ConversationGraphBuildObservationKind.progress,
          )
          .last
          .preservedUnnormalizedCount,
      1,
    );
    expect(
      observations
          .where(
            (item) =>
                item.suboperation ==
                    ConversationGraphBuildSuboperation.projectMessages &&
                item.kind == ConversationGraphBuildObservationKind.progress,
          )
          .map((item) => item.completedWorkCount),
      <int?>[0, 1000, 1250],
    );
    expect(
      observations.any(
        (item) =>
            item.suboperation ==
                ConversationGraphBuildSuboperation.persistRichText &&
            item.kind == ConversationGraphBuildObservationKind.progress &&
            item.completedWorkCount == 2,
      ),
      isTrue,
    );
    for (final nestedSuboperation in <ConversationGraphBuildSuboperation>{
      ConversationGraphBuildSuboperation.importContactEmailChannels,
      ConversationGraphBuildSuboperation.importContactPhoneChannels,
      ConversationGraphBuildSuboperation.persistRichText,
    }) {
      expect(
        observations.any(
          (item) =>
              item.suboperation == nestedSuboperation &&
              item.kind == ConversationGraphBuildObservationKind.progress,
        ),
        isTrue,
        reason: '$nestedSuboperation must publish real nested progress.',
      );
    }
    for (final suboperation in ConversationGraphBuildSuboperation.values) {
      if (<ConversationGraphBuildSuboperation>{
        ConversationGraphBuildSuboperation.importContactEmailChannels,
        ConversationGraphBuildSuboperation.importContactPhoneChannels,
        ConversationGraphBuildSuboperation.persistRichText,
      }.contains(suboperation)) {
        continue;
      }
      expect(
        observations.any(
          (item) =>
              item.suboperation == suboperation &&
              item.kind == ConversationGraphBuildObservationKind.started,
        ),
        isTrue,
        reason: '$suboperation must publish a typed start transition.',
      );
      expect(
        observations.any(
          (item) =>
              item.suboperation == suboperation &&
              item.kind == ConversationGraphBuildObservationKind.completed,
        ),
        isTrue,
        reason: '$suboperation must publish a typed completion transition.',
      );
    }
  });
}

GraphBuildStep _record(List<String> calls, String name) {
  return () async {
    calls.add(name);
  };
}
