import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/importers/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/orchestrators/chat_message_join_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_message_join_import_decision.dart';

void main() {
  test('doNothing skips topology import execution', () async {
    var invocationCount = 0;
    final orchestrator =
        ChatMessageJoinImportExecutionOrchestrator.withImportCallback(
          importNewChatMessageJoins: () async {
            invocationCount += 1;
            return const ChatMessageJoinImportResult(
              startedAfterSourceRowId: 0,
              lastImportedSourceRowId: 0,
              insertedJoinCount: 0,
              batchId: 1,
            );
          },
        );

    final result = await orchestrator.runForDecision(
      const ChatMessageJoinImportDecision.doNothing(),
    );

    expect(result, isNull);
    expect(invocationCount, 0);
  });

  test('ledger-ahead decision blocks topology import execution', () async {
    var invocationCount = 0;
    final orchestrator =
        ChatMessageJoinImportExecutionOrchestrator.withImportCallback(
          importNewChatMessageJoins: () async {
            invocationCount += 1;
            return const ChatMessageJoinImportResult(
              startedAfterSourceRowId: 0,
              lastImportedSourceRowId: 0,
              insertedJoinCount: 0,
              batchId: 1,
            );
          },
        );

    final result = await orchestrator.runForDecision(
      const ChatMessageJoinImportDecision.blockAndReportLedgerAhead(),
    );

    expect(result, isNull);
    expect(invocationCount, 0);
  });

  test('considerTopologyImport invokes topology import exactly once', () async {
    var invocationCount = 0;
    final orchestrator =
        ChatMessageJoinImportExecutionOrchestrator.withImportCallback(
          importNewChatMessageJoins: () async {
            invocationCount += 1;
            return const ChatMessageJoinImportResult(
              startedAfterSourceRowId: 10,
              lastImportedSourceRowId: 12,
              insertedJoinCount: 2,
              batchId: 1,
            );
          },
        );

    final result = await orchestrator.runForDecision(
      const ChatMessageJoinImportDecision.considerTopologyImport(),
    );

    expect(result?.startedAfterSourceRowId, 10);
    expect(result?.lastImportedSourceRowId, 12);
    expect(result?.insertedJoinCount, 2);
    expect(invocationCount, 1);
  });
}
