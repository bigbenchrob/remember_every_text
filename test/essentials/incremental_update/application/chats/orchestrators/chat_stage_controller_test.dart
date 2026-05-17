import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/importers/chat_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/models/chat_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/orchestrators/chat_import_execution_orchestrator_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/orchestrators/chat_stage_controller_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/readers/import_ledger_chat_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/readers/live_chat_db_chat_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_sync_state.dart';

void main() {
  group('ChatStageController', () {
    test('reports do-nothing path without invoking execution', () async {
      var importerInvocationCount = 0;
      final container = _container(
        source: const ChatSnapshot(maxRowId: 20, totalChatCount: 8),
        ledger: const ChatSnapshot(maxRowId: 20, totalChatCount: 8),
        importNewChats: () async {
          importerInvocationCount += 1;
          return const ChatImportResult(
            startedAfterSourceRowId: 20,
            lastImportedSourceRowId: 20,
            insertedChatCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(chatStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const ChatSnapshotDelta(rowIdDelta: 0, chatCountDelta: 0),
      );
      expect(
        report.preExecutionState,
        const ChatSyncState.sourceAndLedgerCursorsMatch(),
      );
      expect(report.decision, const ChatImportDecision.doNothing());
      expect(report.executionOutcome, ChatStageExecutionOutcome.skipped);
      expect(report.importResult, isNull);
      expect(report.postExecutionDelta, isNull);
      expect(report.postExecutionState, isNull);
      expect(report.diagnosticEvents, <String>[
        'chat observation boundary invalidated',
        'chat delta observed: rowIdDelta=0, chatCountDelta=0',
        'chat import decision observed: ChatImportDecision.doNothing',
        'shadow chat import skipped: decision doNothing',
      ]);
    });

    test('reports ledger-ahead path as blocked without execution', () async {
      var importerInvocationCount = 0;
      final container = _container(
        source: const ChatSnapshot(maxRowId: 20, totalChatCount: 8),
        ledger: const ChatSnapshot(maxRowId: 22, totalChatCount: 9),
        importNewChats: () async {
          importerInvocationCount += 1;
          return const ChatImportResult(
            startedAfterSourceRowId: 22,
            lastImportedSourceRowId: 22,
            insertedChatCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(chatStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const ChatSnapshotDelta(rowIdDelta: -2, chatCountDelta: -1),
      );
      expect(
        report.preExecutionState,
        const ChatSyncState.ledgerAheadOfSource(),
      );
      expect(
        report.decision,
        const ChatImportDecision.blockAndReportLedgerAhead(),
      );
      expect(report.executionOutcome, ChatStageExecutionOutcome.blocked);
      expect(report.importResult, isNull);
      expect(report.diagnosticEvents, <String>[
        'chat observation boundary invalidated',
        'chat delta observed: rowIdDelta=-2, chatCountDelta=-1',
        'chat import decision observed: ChatImportDecision.blockAndReportLedgerAhead',
        'shadow chat import skipped: decision blockAndReportLedgerAhead',
      ]);
    });

    test('reports execution and post-execution convergence', () async {
      var ledger = const ChatSnapshot(maxRowId: 10, totalChatCount: 5);
      var importerInvocationCount = 0;
      final container = _container(
        source: const ChatSnapshot(maxRowId: 12, totalChatCount: 7),
        ledger: () => ledger,
        importNewChats: () async {
          importerInvocationCount += 1;
          ledger = const ChatSnapshot(maxRowId: 12, totalChatCount: 7);
          return const ChatImportResult(
            startedAfterSourceRowId: 10,
            lastImportedSourceRowId: 12,
            insertedChatCount: 2,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(chatStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 1);
      expect(
        report.preExecutionDelta,
        const ChatSnapshotDelta(rowIdDelta: 2, chatCountDelta: 2),
      );
      expect(
        report.preExecutionState,
        const ChatSyncState.sourceAheadOfLedger(),
      );
      expect(
        report.decision,
        const ChatImportDecision.considerIncrementalImport(),
      );
      expect(report.executionOutcome, ChatStageExecutionOutcome.executed);
      expect(report.importResult?.insertedChatCount, 2);
      expect(report.importResult?.lastImportedSourceRowId, 12);
      expect(
        report.postExecutionDelta,
        const ChatSnapshotDelta(rowIdDelta: 0, chatCountDelta: 0),
      );
      expect(
        report.postExecutionState,
        const ChatSyncState.sourceAndLedgerCursorsMatch(),
      );
      expect(report.diagnosticEvents, <String>[
        'chat observation boundary invalidated',
        'chat delta observed: rowIdDelta=2, chatCountDelta=2',
        'chat import decision observed: ChatImportDecision.considerIncrementalImport',
        'shadow chat import executed: insertedChatCount=2, lastImportedSourceRowId=12',
      ]);
    });
  });
}

ProviderContainer _container({
  required ChatSnapshot source,
  required Object ledger,
  required Future<ChatImportResult> Function() importNewChats,
}) {
  ChatSnapshot readLedger() {
    final value = ledger;
    if (value is ChatSnapshot Function()) {
      return value();
    }
    return value as ChatSnapshot;
  }

  return ProviderContainer(
    overrides: <Override>[
      liveChatDbChatSnapshotProvider.overrideWith((ref) async => source),
      importLedgerChatSnapshotProvider.overrideWith(
        (ref) async => readLedger(),
      ),
      chatImportExecutionOrchestratorProvider.overrideWith(
        (ref) async => ChatImportExecutionOrchestrator.withImportCallback(
          importNewChats: importNewChats,
        ),
      ),
    ],
  );
}
