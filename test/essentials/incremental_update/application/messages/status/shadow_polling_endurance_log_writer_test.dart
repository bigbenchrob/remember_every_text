import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chat_message_joins/models/chat_message_join_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/models/chat_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/models/handle_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/shadow_message_migration_executor.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/comparative_validation_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/message_import_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/message_migration_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer.dart';
import 'package:remember_this_text/essentials/incremental_update/application/pipeline/models/pipeline_run_report.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_message_join_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/chat_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/handle_snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_blocker.dart';
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
  group('ShadowPollingEnduranceLogWriter', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'shadow_polling_endurance_log_writer_test_',
      );
    });

    tearDown(() {
      if (tempDirectory.existsSync()) {
        tempDirectory.deleteSync(recursive: true);
      }
    });

    test('renders tick events before end-of-tick summary', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(),
        tickEvents: const <String>[
          'tick started',
          'import delta observed: rowIdDelta=2, messageCountDelta=2',
        ],
      );

      final content = await _readActiveLog(writer);

      expect(content, contains('## Tick Events'));
      expect(content, contains('### Behavioral assessment'));
      expect(
        content.indexOf('## Tick Events'),
        lessThan(content.indexOf('### Behavioral assessment')),
      );
      expect(
        content.indexOf('### Behavioral assessment'),
        lessThan(content.indexOf('### Shadow import')),
      );
    });

    test('renders empty tick events explicitly', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(_snapshot());

      final content = await _readActiveLog(writer);

      expect(content, contains('## Tick Events'));
      expect(content, contains('- no tick events recorded'));
    });

    test('renders execution events clearly', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(),
        tickEvents: const <String>[
          'shadow import executed: insertedMessageCount=2, lastImportedSourceRowId=136001',
          'shadow migration executed: insertedMessageCount=2',
        ],
      );

      final content = await _readActiveLog(writer);

      expect(
        content,
        contains(
          '- shadow import executed: insertedMessageCount=2, '
          'lastImportedSourceRowId=136001',
        ),
      );
      expect(
        content,
        contains('- shadow migration executed: insertedMessageCount=2'),
      );
    });

    test('renders handle import status', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(
          handleImportDecision:
              const HandleImportDecision.considerIncrementalImport(),
          handleSyncState: const HandleSyncState.sourceAheadOfLedger(),
          handleSnapshotDelta: const HandleSnapshotDelta(
            rowIdDelta: 4,
            handleCountDelta: 4,
          ),
        ),
      );

      final content = await _readActiveLog(writer);

      expect(
        content,
        contains(
          '- HandleImportDecision: '
          'HandleImportDecision.considerIncrementalImport',
        ),
      );
      expect(
        content,
        contains('- HandleSyncState: HandleSyncState.sourceAheadOfLedger'),
      );
      expect(content, contains('- handleCountDelta: 4'));
    });

    test('renders chat import status', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(
          chatImportDecision:
              const ChatImportDecision.considerIncrementalImport(),
          chatSyncState: const ChatSyncState.sourceAheadOfLedger(),
          chatSnapshotDelta: const ChatSnapshotDelta(
            rowIdDelta: 3,
            chatCountDelta: 3,
          ),
        ),
      );

      final content = await _readActiveLog(writer);

      expect(
        content,
        contains(
          '- ChatImportDecision: '
          'ChatImportDecision.considerIncrementalImport',
        ),
      );
      expect(
        content,
        contains('- ChatSyncState: ChatSyncState.sourceAheadOfLedger'),
      );
      expect(content, contains('- chatCountDelta: 3'));
    });

    test('renders prerequisite-aware message import status', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(
          prerequisiteAwareMessageImportDecision:
              const PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(
                blockers: <MessageImportBlocker>[
                  MessageImportBlocker.handlesNotReady,
                  MessageImportBlocker.chatsNotReady,
                ],
              ),
          messageImportPrerequisiteAssessment:
              const MessageImportPrerequisiteAssessment(
                blockers: <MessageImportBlocker>[
                  MessageImportBlocker.handlesNotReady,
                  MessageImportBlocker.chatsNotReady,
                ],
              ),
        ),
        tickEvents: const <String>[
          'prerequisite assessment observed: blocked blockers=[handlesNotReady, chatsNotReady]',
          'prerequisite-aware message import decision observed: PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites([handlesNotReady, chatsNotReady])',
        ],
      );

      final content = await _readActiveLog(writer);

      expect(
        content,
        contains(
          '- Prerequisite-aware message import decision: '
          'PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites'
          '([handlesNotReady, chatsNotReady])',
        ),
      );
      expect(
        content,
        contains('- Message import prerequisite assessment: blocked'),
      );
      expect(
        content,
        contains(
          '- Message import prerequisite blockers: '
          '[handlesNotReady, chatsNotReady]',
        ),
      );
      expect(
        content,
        contains(
          '- prerequisite assessment observed: blocked '
          'blockers=[handlesNotReady, chatsNotReady]',
        ),
      );
    });

    test('labels message count divergence as diagnostic only', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(
          snapshotDelta: const MessageSnapshotDelta(
            rowIdDelta: 0,
            messageCountDelta: -4,
          ),
        ),
      );

      final content = await _readActiveLog(writer);

      expect(content, contains('- Message cursor state: current'));
      expect(content, contains('- cursor_rowIdDelta: 0'));
      expect(content, contains('- diagnostic_messageCountDelta: -4'));
      expect(
        content,
        contains(
          '- count divergence: ledger ahead by 4 row(s); diagnostic only',
        ),
      );
    });

    test(
      'detects same-tick migration convergence from pipeline report',
      () async {
        final writer = ShadowPollingEnduranceLogWriter(
          logsDirectory: tempDirectory,
        );
        writer.startSession();

        await writer.appendStatus(
          _snapshot(),
          tickEvents: const <String>[
            'migration delta observed: messageIdDelta=2, messageCountDelta=2',
            'shadow migration executed: insertedMessageCount=2',
          ],
          pipelineRunReport: _pipelineRunReportWithSameTickMigration(),
        );

        final content = await _readActiveLog(writer);

        expect(
          content,
          contains('- shadow_migration_convergence_duration: 2000ms'),
        );
        expect(content, contains('- shadow_migration_ticks_to_convergence: 0'));
      },
    );
  });
}

Future<String> _readActiveLog(ShadowPollingEnduranceLogWriter writer) async {
  final path = writer.activeLogPath;
  expect(path, isNotNull);
  return File(path!).readAsString();
}

ShadowPollingEnduranceSnapshot _snapshot({
  ChatImportDecision? chatImportDecision,
  ChatSyncState? chatSyncState,
  ChatSnapshotDelta? chatSnapshotDelta,
  HandleImportDecision? handleImportDecision,
  HandleSyncState? handleSyncState,
  HandleSnapshotDelta? handleSnapshotDelta,
  PrerequisiteAwareMessageImportDecision?
  prerequisiteAwareMessageImportDecision,
  MessageImportPrerequisiteAssessment? messageImportPrerequisiteAssessment,
  MessageSnapshotDelta? snapshotDelta,
}) {
  return ShadowPollingEnduranceSnapshot(
    pollingActive: true,
    lastRefreshTime: DateTime(2026, 5, 15, 9),
    lastTransitionTime: DateTime(2026, 5, 15, 9, 0, 1),
    chatImportDecision:
        chatImportDecision ?? const ChatImportDecision.doNothing(),
    chatSyncState:
        chatSyncState ?? const ChatSyncState.sourceAndLedgerCursorsMatch(),
    chatSnapshotDelta:
        chatSnapshotDelta ??
        const ChatSnapshotDelta(rowIdDelta: 0, chatCountDelta: 0),
    handleImportDecision:
        handleImportDecision ?? const HandleImportDecision.doNothing(),
    handleSyncState:
        handleSyncState ?? const HandleSyncState.sourceAndLedgerCursorsMatch(),
    handleSnapshotDelta:
        handleSnapshotDelta ??
        const HandleSnapshotDelta(rowIdDelta: 0, handleCountDelta: 0),
    importDecision: const ImportDecision.doNothing(),
    prerequisiteAwareMessageImportDecision:
        prerequisiteAwareMessageImportDecision ??
        const PrerequisiteAwareMessageImportDecision.doNothing(),
    messageImportPrerequisiteAssessment:
        messageImportPrerequisiteAssessment ??
        const MessageImportPrerequisiteAssessment(
          blockers: <MessageImportBlocker>[],
        ),
    messageSyncState: const MessageSyncState.sourceAndLedgerCursorsMatch(),
    snapshotDelta:
        snapshotDelta ??
        const MessageSnapshotDelta(rowIdDelta: 0, messageCountDelta: 0),
    migrationDecision: const MigrationDecision.doNothing(),
    messageMigrationState: const MessageMigrationState.projectionCaughtUp(),
    migrationDelta: const MessageMigrationDelta(
      messageIdDelta: 0,
      messageCountDelta: 0,
    ),
    importComparisonOutcome: const ComparisonOutcome.match(
      legacy: 'incremental import not required',
      shadow: 'incremental import not required',
    ),
    migrationComparisonOutcome: const ComparisonOutcome.match(
      legacy: 'projection current',
      shadow: 'projection current',
    ),
  );
}

PipelineRunReport _pipelineRunReportWithSameTickMigration() {
  final startedAt = DateTime(2026, 5, 17, 10);
  final finishedAt = startedAt.add(const Duration(seconds: 2));
  final handleReport = HandleStageReport(
    startedAt: startedAt,
    finishedAt: startedAt,
    preExecutionDelta: const HandleSnapshotDelta(
      rowIdDelta: 0,
      handleCountDelta: 0,
    ),
    preExecutionState: const HandleSyncState.sourceAndLedgerCursorsMatch(),
    decision: const HandleImportDecision.doNothing(),
    executionOutcome: HandleStageExecutionOutcome.skipped,
  );
  final chatReport = ChatStageReport(
    startedAt: startedAt,
    finishedAt: startedAt,
    preExecutionDelta: const ChatSnapshotDelta(
      rowIdDelta: 0,
      chatCountDelta: 0,
    ),
    preExecutionState: const ChatSyncState.sourceAndLedgerCursorsMatch(),
    decision: const ChatImportDecision.doNothing(),
    executionOutcome: ChatStageExecutionOutcome.skipped,
  );
  final importReport = MessageImportStageReport(
    startedAt: startedAt,
    finishedAt: startedAt,
    preExecutionDelta: const MessageSnapshotDelta(
      rowIdDelta: 0,
      messageCountDelta: 0,
    ),
    preExecutionState: const MessageSyncState.sourceAndLedgerCursorsMatch(),
    decision: const ImportDecision.doNothing(),
    prerequisiteAssessment: const MessageImportPrerequisiteAssessment(
      blockers: <MessageImportBlocker>[],
    ),
    prerequisiteAwareDecision:
        const PrerequisiteAwareMessageImportDecision.doNothing(),
    executionOutcome: MessageImportStageExecutionOutcome.skipped,
  );
  const topologySnapshot = ChatMessageJoinSnapshot(
    maxRowId: 0,
    totalJoinCount: 0,
    maxMessageRowId: 0,
    maxChatRowId: 0,
    sourceScopedObservationAvailable: true,
  );
  final topologyReport = ChatMessageJoinStageReport(
    startedAt: startedAt,
    finishedAt: startedAt,
    preExecutionSourceSnapshot: topologySnapshot,
    preExecutionLedgerSnapshot: topologySnapshot,
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
  );
  final migrationReport = MessageMigrationStageReport(
    startedAt: startedAt,
    finishedAt: finishedAt,
    preExecutionDelta: const MessageMigrationDelta(
      messageIdDelta: 2,
      messageCountDelta: 2,
    ),
    preExecutionState: const MessageMigrationState.ledgerAheadOfProjection(),
    decision: const MigrationDecision.considerShadowMigration(),
    executionOutcome: MessageMigrationStageExecutionOutcome.executed,
    migrationResult: const ShadowMessageMigrationResult(
      insertedMessageCount: 2,
    ),
    postExecutionDelta: const MessageMigrationDelta(
      messageIdDelta: 0,
      messageCountDelta: 0,
    ),
    postExecutionState: const MessageMigrationState.projectionCaughtUp(),
  );
  final comparisonReport = ComparativeValidationStageReport(
    startedAt: finishedAt,
    finishedAt: finishedAt,
    importComparison: const ComparisonOutcome.match(
      legacy: 'incremental import not required',
      shadow: 'incremental import not required',
    ),
    migrationComparison: const ComparisonOutcome.match(
      legacy: 'projection current',
      shadow: 'projection current',
    ),
  );

  return PipelineRunReport(
    startedAt: startedAt,
    finishedAt: finishedAt,
    handleStageReport: handleReport,
    chatStageReport: chatReport,
    messageImportStageReport: importReport,
    chatMessageJoinStageReport: topologyReport,
    messageMigrationStageReport: migrationReport,
    comparativeValidationStageReport: comparisonReport,
    importDecisionAfterRun: const ImportDecision.doNothing(),
  );
}
