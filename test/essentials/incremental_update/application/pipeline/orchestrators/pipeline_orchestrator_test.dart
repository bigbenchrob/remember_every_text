import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/models/chat_message_join_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/models/chat_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/models/handle_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/message_importer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/comparative_validation_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/message_import_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/message_migration_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/pipeline/orchestrators/pipeline_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_prerequisite_assessment.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_migration_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_message_join_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_message_join_sync_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_sync_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/comparison_outcome.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_sync_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/message_migration_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/migration_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/prerequisite_aware_message_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/sync_state.dart';

void main() {
  group('PipelineOrchestrator', () {
    test('executes every stage in the intended manual order', () async {
      final calls = <String>[];
      final orchestrator = PipelineOrchestrator(
        runHandleStage: () async {
          calls.add('handle');
          return _handleReport('handle event');
        },
        runChatStage: () async {
          calls.add('chat');
          return _chatReport('chat event');
        },
        runMessageImportStage: () async {
          calls.add('message import');
          return _messageImportReport('message import event');
        },
        runChatMessageJoinStage: () async {
          calls.add('topology');
          return _topologyReport('topology event');
        },
        runMessageMigrationStage: () async {
          calls.add('message migration');
          return _messageMigrationReport('message migration event');
        },
        runComparativeValidationStage: () async {
          calls.add('comparative validation');
          return _comparisonReport('comparison event');
        },
        readCurrentImportDecision: () async {
          calls.add('read current import decision');
          return const ImportDecision.doNothing();
        },
      );

      final report = await orchestrator.runOnce();

      expect(calls, <String>[
        'handle',
        'chat',
        'message import',
        'topology',
        'message migration',
        'comparative validation',
      ]);
      expect(report.orderedStageReports, <Object>[
        report.handleStageReport,
        report.chatStageReport,
        report.messageImportStageReport,
        report.chatMessageJoinStageReport,
        report.messageMigrationStageReport,
        report.comparativeValidationStageReport,
      ]);
      expect(report.importDecisionAfterRun, const ImportDecision.doNothing());
    });

    test('aggregates diagnostic events in stage order', () async {
      final orchestrator = PipelineOrchestrator(
        runHandleStage: () async => _handleReport('handle event'),
        runChatStage: () async => _chatReport('chat event'),
        runMessageImportStage: () async =>
            _messageImportReport('message import event'),
        runChatMessageJoinStage: () async => _topologyReport('topology event'),
        runMessageMigrationStage: () async =>
            _messageMigrationReport('message migration event'),
        runComparativeValidationStage: () async =>
            _comparisonReport('comparison event'),
        readCurrentImportDecision: () async =>
            const ImportDecision.blockAndReportLedgerAhead(),
      );

      final report = await orchestrator.runOnce();

      expect(report.diagnosticEvents, <String>[
        'handle event',
        'chat event',
        'message import event',
        'topology event',
        'message migration event',
        'comparison event',
      ]);
    });

    test(
      'reads current import decision after message import executes',
      () async {
        var readCurrentDecisionCount = 0;
        final orchestrator = PipelineOrchestrator(
          runHandleStage: () async => _handleReport('handle event'),
          runChatStage: () async => _chatReport('chat event'),
          runMessageImportStage: () async => _messageImportReport(
            'message import event',
            importResult: const MessageImportResult(
              startedAfterSourceRowId: 10,
              lastImportedSourceRowId: 12,
              insertedMessageCount: 2,
              batchId: 1,
            ),
          ),
          runChatMessageJoinStage: () async =>
              _topologyReport('topology event'),
          runMessageMigrationStage: () async =>
              _messageMigrationReport('message migration event'),
          runComparativeValidationStage: () async =>
              _comparisonReport('comparison event'),
          readCurrentImportDecision: () async {
            readCurrentDecisionCount += 1;
            return const ImportDecision.doNothing();
          },
        );

        final report = await orchestrator.runOnce();

        expect(readCurrentDecisionCount, 1);
        expect(report.importDecisionAfterRun, const ImportDecision.doNothing());
      },
    );
  });
}

HandleStageReport _handleReport(String event) {
  final now = DateTime(2026);
  return HandleStageReport(
    startedAt: now,
    finishedAt: now,
    preExecutionDelta: const HandleSnapshotDelta(
      rowIdDelta: 0,
      handleCountDelta: 0,
    ),
    preExecutionState: const HandleSyncState.sourceAndLedgerCursorsMatch(),
    decision: const HandleImportDecision.doNothing(),
    executionOutcome: HandleStageExecutionOutcome.skipped,
    diagnosticEvents: <String>[event],
  );
}

ChatStageReport _chatReport(String event) {
  final now = DateTime(2026);
  return ChatStageReport(
    startedAt: now,
    finishedAt: now,
    preExecutionDelta: const ChatSnapshotDelta(
      rowIdDelta: 0,
      chatCountDelta: 0,
    ),
    preExecutionState: const ChatSyncState.sourceAndLedgerCursorsMatch(),
    decision: const ChatImportDecision.doNothing(),
    executionOutcome: ChatStageExecutionOutcome.skipped,
    diagnosticEvents: <String>[event],
  );
}

ChatMessageJoinStageReport _topologyReport(String event) {
  final now = DateTime(2026);
  const snapshot = ChatMessageJoinSnapshot(
    maxRowId: 0,
    totalJoinCount: 0,
    maxMessageRowId: 0,
    maxChatRowId: 0,
    sourceScopedObservationAvailable: true,
  );
  return ChatMessageJoinStageReport(
    startedAt: now,
    finishedAt: now,
    preExecutionSourceSnapshot: snapshot,
    preExecutionLedgerSnapshot: snapshot,
    preExecutionDelta: const ChatMessageJoinSnapshotDelta(
      rowIdDelta: 0,
      joinCountDelta: 0,
      messageRowIdDelta: 0,
      chatRowIdDelta: 0,
      ledgerSourceScopedObservationAvailable: true,
    ),
    preExecutionSyncState:
        const ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch(),
    preExecutionDecision: const ChatMessageJoinImportDecision.doNothing(),
    executionOutcome: ChatMessageJoinStageExecutionOutcome.skipped,
    diagnosticEvents: <String>[event],
  );
}

MessageImportStageReport _messageImportReport(
  String event, {
  MessageImportResult? importResult,
}) {
  final now = DateTime(2026);
  return MessageImportStageReport(
    startedAt: now,
    finishedAt: now,
    preExecutionDelta: const MessageSnapshotDelta(
      rowIdDelta: 0,
      messageCountDelta: 0,
    ),
    preExecutionState: const MessageSyncState.sourceAndLedgerCursorsMatch(),
    decision: importResult == null
        ? const ImportDecision.doNothing()
        : const ImportDecision.considerIncrementalImport(),
    prerequisiteAssessment: const MessageImportPrerequisiteAssessment(
      blockers: <Never>[],
    ),
    prerequisiteAwareDecision:
        const PrerequisiteAwareMessageImportDecision.doNothing(),
    executionOutcome: importResult == null
        ? MessageImportStageExecutionOutcome.skipped
        : MessageImportStageExecutionOutcome.executed,
    importResult: importResult,
    diagnosticEvents: <String>[event],
  );
}

MessageMigrationStageReport _messageMigrationReport(String event) {
  final now = DateTime(2026);
  return MessageMigrationStageReport(
    startedAt: now,
    finishedAt: now,
    preExecutionDelta: const MessageMigrationDelta(
      messageIdDelta: 0,
      messageCountDelta: 0,
    ),
    preExecutionState: const MessageMigrationState.projectionCaughtUp(),
    decision: const MigrationDecision.doNothing(),
    executionOutcome: MessageMigrationStageExecutionOutcome.skipped,
    diagnosticEvents: <String>[event],
  );
}

ComparativeValidationStageReport _comparisonReport(String event) {
  final now = DateTime(2026);
  return ComparativeValidationStageReport(
    startedAt: now,
    finishedAt: now,
    importComparison: const ComparisonOutcome.match(
      legacy: 'incremental import not required',
      shadow: 'incremental import not required',
    ),
    migrationComparison: const ComparisonOutcome.match(
      legacy: 'projection current',
      shadow: 'projection current',
    ),
    diagnosticEvents: <String>[event],
  );
}
