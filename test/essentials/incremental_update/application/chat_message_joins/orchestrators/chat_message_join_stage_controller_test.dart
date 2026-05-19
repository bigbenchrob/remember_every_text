import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/importers/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/models/chat_message_join_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/orchestrators/chat_message_join_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/orchestrators/chat_message_join_import_execution_orchestrator_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/orchestrators/chat_message_join_stage_controller_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/readers/import_ledger_chat_message_join_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/readers/live_chat_db_chat_message_join_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_message_join_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_message_join_sync_state.dart';

void main() {
  group('ChatMessageJoinStageController', () {
    test('reports do-nothing path without invoking execution', () async {
      var importerInvocationCount = 0;
      final source = _snapshot(maxRowId: 20, count: 8);
      final container = _container(
        source: source,
        ledger: _snapshot(maxRowId: 20, count: 8),
        importNewChatMessageJoins: () async {
          importerInvocationCount += 1;
          return const ChatMessageJoinImportResult(
            startedAfterSourceRowId: 20,
            lastImportedSourceRowId: 20,
            insertedJoinCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(chatMessageJoinStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(report.preExecutionSourceSnapshot, source);
      expect(
        report.preExecutionDelta,
        const ChatMessageJoinSnapshotDelta(
          rowIdDelta: 0,
          joinCountDelta: 0,
          messageRowIdDelta: 0,
          chatRowIdDelta: 0,
          ledgerSourceScopedObservationAvailable: true,
        ),
      );
      expect(
        report.preExecutionSyncState,
        const ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch(),
      );
      expect(
        report.preExecutionDecision,
        const ChatMessageJoinImportDecision.doNothing(),
      );
      expect(
        report.executionOutcome,
        ChatMessageJoinStageExecutionOutcome.skipped,
      );
      expect(report.importResult, isNull);
      expect(report.postExecutionDelta, isNull);
      expect(report.postExecutionSyncState, isNull);
      expect(report.diagnosticEvents, <String>[
        'topology observation boundary invalidated',
        'topology delta observed: rowIdDelta=0, joinCountDelta=0, messageRowIdDelta=0, chatRowIdDelta=0',
        'topology import decision observed: ChatMessageJoinImportDecision.doNothing',
        'shadow topology import skipped: decision doNothing',
      ]);
    });

    test('reports ledger-ahead path as blocked without execution', () async {
      var importerInvocationCount = 0;
      final container = _container(
        source: _snapshot(maxRowId: 20, count: 8),
        ledger: _snapshot(maxRowId: 22, count: 9),
        importNewChatMessageJoins: () async {
          importerInvocationCount += 1;
          return const ChatMessageJoinImportResult(
            startedAfterSourceRowId: 22,
            lastImportedSourceRowId: 22,
            insertedJoinCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(chatMessageJoinStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(report.preExecutionDelta.rowIdDelta, -2);
      expect(
        report.preExecutionSyncState,
        const ChatMessageJoinSyncState.ledgerTopologyAheadOfSource(),
      );
      expect(
        report.preExecutionDecision,
        const ChatMessageJoinImportDecision.blockAndReportLedgerAhead(),
      );
      expect(
        report.executionOutcome,
        ChatMessageJoinStageExecutionOutcome.blocked,
      );
      expect(report.importResult, isNull);
      expect(report.diagnosticEvents, <String>[
        'topology observation boundary invalidated',
        'topology delta observed: rowIdDelta=-2, joinCountDelta=-1, messageRowIdDelta=-20, chatRowIdDelta=-2',
        'topology import decision observed: ChatMessageJoinImportDecision.blockAndReportLedgerAhead',
        'shadow topology import skipped: decision blockAndReportLedgerAhead',
      ]);
    });

    test('reports execution and post-execution topology convergence', () async {
      final source = _snapshot(maxRowId: 12, count: 7);
      var ledger = _snapshot(maxRowId: 10, count: 5);
      var importerInvocationCount = 0;
      final container = _container(
        source: source,
        ledger: () => ledger,
        importNewChatMessageJoins: () async {
          importerInvocationCount += 1;
          ledger = source;
          return const ChatMessageJoinImportResult(
            startedAfterSourceRowId: 10,
            lastImportedSourceRowId: 12,
            insertedJoinCount: 2,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(chatMessageJoinStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 1);
      expect(
        report.preExecutionDelta,
        const ChatMessageJoinSnapshotDelta(
          rowIdDelta: 2,
          joinCountDelta: 2,
          messageRowIdDelta: 20,
          chatRowIdDelta: 2,
          ledgerSourceScopedObservationAvailable: true,
        ),
      );
      expect(
        report.preExecutionSyncState,
        const ChatMessageJoinSyncState.sourceTopologyAheadOfLedger(),
      );
      expect(
        report.preExecutionDecision,
        const ChatMessageJoinImportDecision.considerTopologyImport(),
      );
      expect(
        report.executionOutcome,
        ChatMessageJoinStageExecutionOutcome.executed,
      );
      expect(report.importResult?.insertedJoinCount, 2);
      expect(report.importResult?.lastImportedSourceRowId, 12);
      expect(report.postExecutionSourceSnapshot, source);
      expect(report.postExecutionLedgerSnapshot, source);
      expect(
        report.postExecutionDelta,
        const ChatMessageJoinSnapshotDelta(
          rowIdDelta: 0,
          joinCountDelta: 0,
          messageRowIdDelta: 0,
          chatRowIdDelta: 0,
          ledgerSourceScopedObservationAvailable: true,
        ),
      );
      expect(
        report.postExecutionSyncState,
        const ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch(),
      );
      expect(report.diagnosticEvents, <String>[
        'topology observation boundary invalidated',
        'topology delta observed: rowIdDelta=2, joinCountDelta=2, messageRowIdDelta=20, chatRowIdDelta=2',
        'topology import decision observed: ChatMessageJoinImportDecision.considerTopologyImport',
        'shadow topology import executed: insertedJoinCount=2, lastImportedSourceRowId=12',
      ]);
    });
  });
}

ProviderContainer _container({
  required ChatMessageJoinSnapshot source,
  required Object ledger,
  required Future<ChatMessageJoinImportResult> Function()
  importNewChatMessageJoins,
}) {
  ChatMessageJoinSnapshot readLedger() {
    final value = ledger;
    if (value is ChatMessageJoinSnapshot Function()) {
      return value();
    }
    return value as ChatMessageJoinSnapshot;
  }

  return ProviderContainer(
    overrides: <Override>[
      liveChatDbChatMessageJoinSnapshotProvider.overrideWith(
        (ref) async => source,
      ),
      importLedgerChatMessageJoinSnapshotProvider.overrideWith(
        (ref) async => readLedger(),
      ),
      chatMessageJoinImportExecutionOrchestratorProvider.overrideWith(
        (ref) async =>
            ChatMessageJoinImportExecutionOrchestrator.withImportCallback(
              importNewChatMessageJoins: importNewChatMessageJoins,
            ),
      ),
    ],
  );
}

ChatMessageJoinSnapshot _snapshot({required int maxRowId, required int count}) {
  return ChatMessageJoinSnapshot(
    maxRowId: maxRowId,
    totalJoinCount: count,
    maxMessageRowId: maxRowId * 10,
    maxChatRowId: maxRowId,
    sourceScopedObservationAvailable: true,
  );
}
