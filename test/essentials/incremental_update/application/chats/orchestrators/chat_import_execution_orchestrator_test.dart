import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/importers/chat_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_import_decision.dart';

void main() {
  group('ChatImportExecutionOrchestrator', () {
    test('does not invoke importer for do-nothing decision', () async {
      final fakeImporter = _FakeChatImporter();
      final orchestrator = ChatImportExecutionOrchestrator.withImportCallback(
        importNewChats: fakeImporter.importNewChats,
      );

      final result = await orchestrator.runForDecision(
        const ChatImportDecision.doNothing(),
      );

      expect(result, isNull);
      expect(fakeImporter.invocationCount, 0);
    });

    test(
      'does not invoke importer for ledger-ahead blocked decision',
      () async {
        final fakeImporter = _FakeChatImporter();
        final orchestrator = ChatImportExecutionOrchestrator.withImportCallback(
          importNewChats: fakeImporter.importNewChats,
        );

        final result = await orchestrator.runForDecision(
          const ChatImportDecision.blockAndReportLedgerAhead(),
        );

        expect(result, isNull);
        expect(fakeImporter.invocationCount, 0);
      },
    );

    test(
      'invokes importer exactly once for incremental import decision',
      () async {
        final fakeImporter = _FakeChatImporter();
        final orchestrator = ChatImportExecutionOrchestrator.withImportCallback(
          importNewChats: fakeImporter.importNewChats,
        );

        final result = await orchestrator.runForDecision(
          const ChatImportDecision.considerIncrementalImport(),
        );

        expect(result, isNotNull);
        expect(fakeImporter.invocationCount, 1);
      },
    );
  });
}

class _FakeChatImporter {
  int invocationCount = 0;

  Future<ChatImportResult> importNewChats() async {
    invocationCount += 1;
    return const ChatImportResult(
      startedAfterSourceRowId: 10,
      lastImportedSourceRowId: 12,
      insertedChatCount: 2,
      batchId: 1,
    );
  }
}
