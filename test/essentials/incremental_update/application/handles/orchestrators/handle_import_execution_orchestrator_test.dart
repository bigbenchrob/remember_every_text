import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/importers/handle_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/orchestrators/handle_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_import_decision.dart';

void main() {
  group('HandleImportExecutionOrchestrator', () {
    test('does not invoke importer for do-nothing decision', () async {
      final fakeImporter = _FakeHandleImporter();
      final orchestrator = HandleImportExecutionOrchestrator.withImportCallback(
        importNewHandles: fakeImporter.importNewHandles,
      );

      final result = await orchestrator.runForDecision(
        const HandleImportDecision.doNothing(),
      );

      expect(result, isNull);
      expect(fakeImporter.invocationCount, 0);
    });

    test(
      'does not invoke importer for ledger-ahead blocked decision',
      () async {
        final fakeImporter = _FakeHandleImporter();
        final orchestrator =
            HandleImportExecutionOrchestrator.withImportCallback(
              importNewHandles: fakeImporter.importNewHandles,
            );

        final result = await orchestrator.runForDecision(
          const HandleImportDecision.blockAndReportLedgerAhead(),
        );

        expect(result, isNull);
        expect(fakeImporter.invocationCount, 0);
      },
    );

    test(
      'invokes importer exactly once for incremental import decision',
      () async {
        final fakeImporter = _FakeHandleImporter();
        final orchestrator =
            HandleImportExecutionOrchestrator.withImportCallback(
              importNewHandles: fakeImporter.importNewHandles,
            );

        final result = await orchestrator.runForDecision(
          const HandleImportDecision.considerIncrementalImport(),
        );

        expect(result, isNotNull);
        expect(fakeImporter.invocationCount, 1);
      },
    );
  });
}

class _FakeHandleImporter {
  int invocationCount = 0;

  Future<HandleImportResult> importNewHandles() async {
    invocationCount += 1;
    return const HandleImportResult(
      startedAfterSourceRowId: 10,
      lastImportedSourceRowId: 12,
      insertedHandleCount: 2,
      batchId: 1,
    );
  }
}
