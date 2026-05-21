import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projector.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';

void main() {
  test('runs conversation graph build stages in fixed order', () async {
    final calls = <String>[];
    final orchestrator = ConversationGraphBuildOrchestrator(
      importChats: _record(calls, 'import_chats'),
      importHandles: _record(calls, 'import_handles'),
      importMessages: () async {
        calls.add('import_messages');
        return const MessageImportResult(
          startedAfterSourceRowId: 10,
          insertedMessageCount: 2,
          lastImportedSourceRowId: 12,
        );
      },
      enrichMissingText: () async {
        calls.add('enrich_missing_text');
        return const MessageRichTextEnrichmentResult(
          candidateMessageCount: 3,
          enrichedMessageCount: 2,
          missingExtractionCount: 1,
          extractorAvailable: true,
        );
      },
      importChatMessageJoins: _record(calls, 'import_chat_message_joins'),
      importChatHandleJoins: _record(calls, 'import_chat_handle_joins'),
      projectHandles: _record(calls, 'project_handles'),
      projectChatHandleEdges: _record(calls, 'project_chat_handle_edges'),
      projectChats: _record(calls, 'project_chats'),
      projectMessages: () async {
        calls.add('project_messages');
        return const MessageProjectionResult(
          examinedMessageCount: 5,
          insertedMessageCount: 4,
        );
      },
      projectChatMessageEdges: _record(calls, 'project_chat_message_edges'),
    );

    final report = await orchestrator.runOnce();

    expect(calls, <String>[
      'import_chats',
      'import_handles',
      'import_messages',
      'enrich_missing_text',
      'import_chat_message_joins',
      'import_chat_handle_joins',
      'project_handles',
      'project_chat_handle_edges',
      'project_chats',
      'project_messages',
      'project_chat_message_edges',
    ]);
    expect(report.completedStageNames, calls);
    expect(report.messageImportResult.insertedMessageCount, 2);
    expect(report.richTextEnrichmentResult.enrichedMessageCount, 2);
    expect(report.messageProjectionResult.insertedMessageCount, 4);
    expect(report.finishedAt.isBefore(report.startedAt), isFalse);
  });
}

GraphBuildStep _record(List<String> calls, String name) {
  return () async {
    calls.add(name);
  };
}
