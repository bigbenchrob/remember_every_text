import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/message_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/message_import_prerequisite_assessment_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/prerequisite_aware_message_import_decision_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/message_import_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/message_import_stage_controller_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/shadow_import_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/shadow_import_execution_orchestrator_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/readers/import_ledger_message_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/readers/live_chat_db_message_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/import_ledger_message_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/live_chat_db_message_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_blocker.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_prerequisite_assessment.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/prerequisite_aware_message_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/sync_state.dart';

void main() {
  group('MessageImportStageController', () {
    test('reports do-nothing path without invoking execution', () async {
      var importerInvocationCount = 0;
      final container = _container(
        source: const LiveChatDbMessageSnapshot(
          maxRowId: 100,
          totalMessageCount: 50,
        ),
        ledger: const ImportLedgerMessageSnapshot(
          maxRowId: 100,
          totalMessageCount: 50,
        ),
        importNewMessages: () async {
          importerInvocationCount += 1;
          return const MessageImportResult(
            startedAfterSourceRowId: 100,
            lastImportedSourceRowId: 100,
            insertedMessageCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(messageImportStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const MessageSnapshotDelta(rowIdDelta: 0, messageCountDelta: 0),
      );
      expect(
        report.preExecutionState,
        const MessageSyncState.sourceAndLedgerCursorsMatch(),
      );
      expect(report.decision, const ImportDecision.doNothing());
      expect(report.prerequisiteAssessment.isSatisfied, isTrue);
      expect(
        report.prerequisiteAwareDecision,
        const PrerequisiteAwareMessageImportDecision.doNothing(),
      );
      expect(
        report.executionOutcome,
        MessageImportStageExecutionOutcome.skipped,
      );
      expect(report.importResult, isNull);
      expect(report.postExecutionDelta, isNull);
      expect(report.postExecutionState, isNull);
      expect(report.diagnosticEvents, <String>[
        'reader refresh started',
        'import observation boundary invalidated',
        'import delta observed: rowIdDelta=0, messageCountDelta=0',
        'import decision observed: ImportDecision.doNothing',
        'prerequisite assessment observed: satisfied blockers=[]',
        'prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.doNothing',
        'shadow import skipped: decision doNothing',
      ]);
    });

    test('reports ledger-ahead path as blocked without execution', () async {
      var importerInvocationCount = 0;
      final container = _container(
        source: const LiveChatDbMessageSnapshot(
          maxRowId: 100,
          totalMessageCount: 50,
        ),
        ledger: const ImportLedgerMessageSnapshot(
          maxRowId: 105,
          totalMessageCount: 55,
        ),
        importNewMessages: () async {
          importerInvocationCount += 1;
          return const MessageImportResult(
            startedAfterSourceRowId: 105,
            lastImportedSourceRowId: 105,
            insertedMessageCount: 0,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(messageImportStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const MessageSnapshotDelta(rowIdDelta: -5, messageCountDelta: -5),
      );
      expect(
        report.preExecutionState,
        const MessageSyncState.ledgerAheadOfSource(),
      );
      expect(report.decision, const ImportDecision.blockAndReportLedgerAhead());
      expect(
        report.executionOutcome,
        MessageImportStageExecutionOutcome.blocked,
      );
      expect(report.importResult, isNull);
      expect(report.diagnosticEvents, <String>[
        'reader refresh started',
        'import observation boundary invalidated',
        'import delta observed: rowIdDelta=-5, messageCountDelta=-5',
        'import decision observed: ImportDecision.blockAndReportLedgerAhead',
        'prerequisite assessment observed: satisfied blockers=[]',
        'prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.blockAndReportLedgerAhead',
        'shadow import skipped: decision blockAndReportLedgerAhead',
      ]);
    });

    test('reports execution and post-execution convergence', () async {
      var ledger = const ImportLedgerMessageSnapshot(
        maxRowId: 100,
        totalMessageCount: 50,
      );
      var sourceReadCount = 0;
      var ledgerReadCount = 0;
      var importerInvocationCount = 0;
      final container = _container(
        source: const LiveChatDbMessageSnapshot(
          maxRowId: 103,
          totalMessageCount: 53,
        ),
        ledger: () => ledger,
        onSourceRead: () {
          sourceReadCount += 1;
        },
        onLedgerRead: () {
          ledgerReadCount += 1;
        },
        importNewMessages: () async {
          importerInvocationCount += 1;
          ledger = const ImportLedgerMessageSnapshot(
            maxRowId: 103,
            totalMessageCount: 53,
          );
          return const MessageImportResult(
            startedAfterSourceRowId: 100,
            lastImportedSourceRowId: 103,
            insertedMessageCount: 3,
            batchId: 1,
          );
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(messageImportStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(importerInvocationCount, 1);
      expect(sourceReadCount, greaterThanOrEqualTo(2));
      expect(ledgerReadCount, greaterThanOrEqualTo(2));
      expect(
        report.preExecutionDelta,
        const MessageSnapshotDelta(rowIdDelta: 3, messageCountDelta: 3),
      );
      expect(
        report.preExecutionState,
        const MessageSyncState.sourceAheadOfLedger(),
      );
      expect(report.decision, const ImportDecision.considerIncrementalImport());
      expect(
        report.executionOutcome,
        MessageImportStageExecutionOutcome.executed,
      );
      expect(report.importResult?.insertedMessageCount, 3);
      expect(report.importResult?.lastImportedSourceRowId, 103);
      expect(
        report.postExecutionDelta,
        const MessageSnapshotDelta(rowIdDelta: 0, messageCountDelta: 0),
      );
      expect(
        report.postExecutionState,
        const MessageSyncState.sourceAndLedgerCursorsMatch(),
      );
      expect(report.diagnosticEvents, <String>[
        'reader refresh started',
        'import observation boundary invalidated',
        'import delta observed: rowIdDelta=3, messageCountDelta=3',
        'import decision observed: ImportDecision.considerIncrementalImport',
        'prerequisite assessment observed: satisfied blockers=[]',
        'prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.considerIncrementalImport',
        'shadow import executed: insertedMessageCount=3, lastImportedSourceRowId=103',
      ]);
    });

    test(
      'reports prerequisite blockers without giving them execution authority',
      () async {
        var importerInvocationCount = 0;
        final container = _container(
          source: const LiveChatDbMessageSnapshot(
            maxRowId: 103,
            totalMessageCount: 53,
          ),
          ledger: const ImportLedgerMessageSnapshot(
            maxRowId: 100,
            totalMessageCount: 50,
          ),
          prerequisiteAssessment: const MessageImportPrerequisiteAssessment(
            blockers: <MessageImportBlocker>[
              MessageImportBlocker.handlesNotReady,
              MessageImportBlocker.chatsNotReady,
            ],
          ),
          prerequisiteAwareDecision:
              const PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(
                blockers: <MessageImportBlocker>[
                  MessageImportBlocker.handlesNotReady,
                  MessageImportBlocker.chatsNotReady,
                ],
              ),
          importNewMessages: () async {
            importerInvocationCount += 1;
            return const MessageImportResult(
              startedAfterSourceRowId: 100,
              lastImportedSourceRowId: 103,
              insertedMessageCount: 3,
              batchId: 1,
            );
          },
        );
        addTearDown(container.dispose);

        final report = await container
            .read(messageImportStageControllerProvider)
            .refreshAndMaybeExecute();

        expect(importerInvocationCount, 1);
        expect(
          report.decision,
          const ImportDecision.considerIncrementalImport(),
        );
        expect(report.prerequisiteAssessment.isBlocked, isTrue);
        expect(
          report.prerequisiteAwareDecision,
          const PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(
            blockers: <MessageImportBlocker>[
              MessageImportBlocker.handlesNotReady,
              MessageImportBlocker.chatsNotReady,
            ],
          ),
        );
        expect(
          report.executionOutcome,
          MessageImportStageExecutionOutcome.executed,
        );
        expect(
          report.diagnosticEvents,
          contains(
            'prerequisite assessment observed: blocked blockers=[handlesNotReady, chatsNotReady]',
          ),
        );
        expect(
          report.diagnosticEvents,
          contains(
            'prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites([handlesNotReady, chatsNotReady])',
          ),
        );
        expect(
          report.diagnosticEvents,
          contains(
            'shadow import executed: insertedMessageCount=3, lastImportedSourceRowId=103',
          ),
        );
      },
    );
  });
}

ProviderContainer _container({
  required LiveChatDbMessageSnapshot source,
  required Object ledger,
  required Future<MessageImportResult> Function() importNewMessages,
  MessageImportPrerequisiteAssessment prerequisiteAssessment =
      const MessageImportPrerequisiteAssessment(
        blockers: <MessageImportBlocker>[],
      ),
  PrerequisiteAwareMessageImportDecision? prerequisiteAwareDecision,
  VoidCallback? onSourceRead,
  VoidCallback? onLedgerRead,
}) {
  ImportLedgerMessageSnapshot readLedger() {
    final value = ledger;
    if (value is ImportLedgerMessageSnapshot Function()) {
      return value();
    }
    return value as ImportLedgerMessageSnapshot;
  }

  final overrides = <Override>[
    liveChatDbMessageSnapshotProvider.overrideWith((ref) async {
      onSourceRead?.call();
      return source;
    }),
    importLedgerMessageSnapshotProvider.overrideWith((ref) async {
      onLedgerRead?.call();
      return readLedger();
    }),
    messageImportPrerequisiteAssessmentProvider.overrideWith(
      (ref) async => prerequisiteAssessment,
    ),
    shadowImportExecutionOrchestratorProvider.overrideWith(
      (ref) async => ShadowImportExecutionOrchestrator.withImportCallback(
        importNewMessages: importNewMessages,
      ),
    ),
  ];

  if (prerequisiteAwareDecision != null) {
    overrides.add(
      prerequisiteAwareMessageImportDecisionProvider.overrideWith(
        (ref) async => prerequisiteAwareDecision,
      ),
    );
  }

  return ProviderContainer(overrides: overrides);
}
