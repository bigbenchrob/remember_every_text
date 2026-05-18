import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/import_decision.dart';
import '../../chats/integrators/chat_import_decision_provider.dart';
import '../../chats/integrators/chat_snapshot_delta_integrator_provider.dart';
import '../../chats/integrators/chat_sync_state_provider.dart';
import '../../handles/integrators/handle_import_decision_provider.dart';
import '../../handles/integrators/handle_snapshot_delta_integrator_provider.dart';
import '../../handles/integrators/handle_sync_state_provider.dart';
import '../../pipeline/models/pipeline_run_report.dart';
import '../../pipeline/orchestrators/pipeline_orchestrator_provider.dart';
import '../integrators/import_decision_integrator.dart';
import '../integrators/incremental_update_comparison_provider.dart';
import '../integrators/message_import_prerequisite_assessment_provider.dart';
import '../integrators/migration_decision_integrator.dart';
import '../integrators/migration_delta_integrator_provider.dart';
import '../integrators/migration_state_integrator.dart';
import '../integrators/prerequisite_aware_message_import_decision_provider.dart';
import '../integrators/snapshot_delta_integrator_provider.dart';
import '../integrators/sync_assessment_integrator.dart';
import '../integrators/sync_assessment_integrator_provider.dart';
import '../status/shadow_polling_endurance_log_writer.dart';
import 'comparative_validation_stage_controller_provider.dart';
import 'message_migration_stage_controller_provider.dart';

class SyncStatePollingOrchestrator {
  SyncStatePollingOrchestrator(this._ref);

  final Ref _ref;
  Timer? _pollingTimer;
  final ShadowPollingEnduranceLogWriter _enduranceLogWriter =
      ShadowPollingEnduranceLogWriter();

  //“A refresh cycle has started but has not yet completed.”
  bool _refreshInFlight = false;
  ImportDecision? _lastObservedDecision;
  DateTime? _lastRefreshTime;
  DateTime? _lastImportDecisionTransitionTime;

  bool get isPollingActive => _pollingTimer != null;
  DateTime? get lastRefreshTime => _lastRefreshTime;
  DateTime? get lastImportDecisionTransitionTime =>
      _lastImportDecisionTransitionTime;

  Future<ImportDecision> refreshOnce() async {
    final report = await _refreshOnceWithTickEvents();
    return report.importDecisionAfterRun;
  }

  Future<PipelineRunReport> _refreshOnceWithTickEvents({
    List<String>? tickEvents,
  }) async {
    try {
      final pipelineReport = await _ref
          .read(pipelineOrchestratorProvider)
          .runOnce();
      tickEvents?.addAll(pipelineReport.diagnosticEvents);
      return pipelineReport;
    } finally {
      _lastRefreshTime = DateTime.now();
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    if (_pollingTimer != null) {
      debugPrint('Shadow message snapshot polling already running.');
      return;
    }

    try {
      _enduranceLogWriter.startSession();
      debugPrint(
        'Shadow polling endurance log started: '
        '${_enduranceLogWriter.activeLogPath}',
      );
    } catch (error, stackTrace) {
      debugPrint('Shadow polling endurance log failed to start: $error');
      debugPrint(stackTrace.toString());
    }

    debugPrint(
      'Shadow message snapshot polling started: '
      'interval=${interval.inSeconds}s',
    );
    unawaited(_appendEnduranceLogSnapshot(note: 'polling started'));

    // every [interval], trigger a refresh of the message snapshot delta,
    // but only if a refresh isn't already in flight.
    _pollingTimer = Timer.periodic(interval, (_) {
      unawaited(_runPollingTick());
    });
  }

  void stopPolling() {
    if (_pollingTimer == null) {
      debugPrint('Shadow message snapshot polling already stopped.');
      return;
    }

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _enduranceLogWriter.stopSession();
    debugPrint('Shadow message snapshot polling stopped.');
  }

  void dispose() {
    stopPolling();
  }

  Future<void> _runPollingTick() async {
    if (_refreshInFlight) {
      debugPrint('Shadow message snapshot polling skipped: refresh in flight.');
      await _appendEnduranceLogEvent('poll tick skipped: refresh in flight');
      return;
    }

    _refreshInFlight = true;
    Object? refreshError;
    StackTrace? refreshStackTrace;
    PipelineRunReport? pipelineRunReport;
    final tickEvents = <String>['tick started'];

    try {
      pipelineRunReport = await _refreshOnceWithTickEvents(
        tickEvents: tickEvents,
      );
      final decision = pipelineRunReport.importDecisionAfterRun;
      await _logImportDecisionTransition(decision);
      _lastObservedDecision = decision;
    } catch (error, stackTrace) {
      refreshError = error;
      refreshStackTrace = stackTrace;
      debugPrint('Shadow message snapshot polling tick failed: $error');
      debugPrint(stackTrace.toString());
    } finally {
      await _appendEnduranceLogSnapshot(
        note: refreshError == null ? 'poll tick completed' : 'poll tick failed',
        tickEvents: tickEvents,
        pipelineRunReport: pipelineRunReport,
        refreshError: refreshError,
        refreshStackTrace: refreshStackTrace,
      );
      _refreshInFlight = false;
    }
  }

  Future<void> _logImportDecisionTransition(ImportDecision decision) async {
    if (decision == _lastObservedDecision) {
      return;
    }

    _lastImportDecisionTransitionTime = DateTime.now();
    final syncState = await _ref.read(messageSyncStateProvider.future);
    final delta = await _ref.read(snapshotDeltaIntegratorProvider.future);
    debugPrint(
      'Shadow import decision transition: \n'
      'Previous: ${_extractSemanticImportDecisionMeaning(_lastObservedDecision)}, '
      'Current: ${_extractSemanticImportDecisionMeaning(decision)}\n'
      'decision=$decision, '
      'syncState=$syncState, '
      'rowIdDelta=${delta.rowIdDelta}, '
      'messageCountDelta=${delta.messageCountDelta}',
    );
  }

  Future<void> _appendEnduranceLogSnapshot({
    String? note,
    List<String> tickEvents = const <String>[],
    PipelineRunReport? pipelineRunReport,
    Object? refreshError,
    StackTrace? refreshStackTrace,
  }) async {
    try {
      final status = await _buildEnduranceLogSnapshot();
      await _enduranceLogWriter.appendStatus(
        status,
        tickEvents: tickEvents,
        pipelineRunReport: pipelineRunReport,
        note: note,
        refreshError: refreshError,
        refreshStackTrace: refreshStackTrace,
      );
    } catch (error, stackTrace) {
      await _appendEnduranceLogEvent(
        'status snapshot failed: $error\n\n$stackTrace',
      );
      debugPrint('Shadow polling endurance log append failed: $error');
      debugPrint(stackTrace.toString());
    }
  }

  Future<ShadowPollingEnduranceSnapshot> _buildEnduranceLogSnapshot() async {
    final snapshotDelta = await _ref.read(
      snapshotDeltaIntegratorProvider.future,
    );
    final syncState = const MessageSyncAssessmentIntegrator().integrate(
      snapshotDelta,
    );
    final importDecision = ImportDecisionIntegrator().integrate(syncState);
    final handleDelta = await _ref.read(
      handleSnapshotDeltaIntegratorProvider.future,
    );
    final handleSyncState = await _ref.read(handleSyncStateProvider.future);
    final handleImportDecision = await _ref.read(
      handleImportDecisionProvider.future,
    );
    final chatDelta = await _ref.read(
      chatSnapshotDeltaIntegratorProvider.future,
    );
    final chatSyncState = await _ref.read(chatSyncStateProvider.future);
    final chatImportDecision = await _ref.read(
      chatImportDecisionProvider.future,
    );
    final prerequisiteAssessment = await _ref.read(
      messageImportPrerequisiteAssessmentProvider.future,
    );
    final prerequisiteAwareDecision = await _ref.read(
      prerequisiteAwareMessageImportDecisionProvider.future,
    );
    final migrationDelta = await _ref.read(
      messageMigrationDeltaProvider.future,
    );
    final migrationState = const MessageMigrationStateIntegrator().integrate(
      migrationDelta,
    );
    final migrationDecision = const MigrationDecisionIntegrator().integrate(
      migrationState,
    );
    final comparisonReport = await _ref.read(
      incrementalUpdateComparisonProvider.future,
    );
    final migrationStageController = _ref.read(
      messageMigrationStageControllerProvider,
    );
    final comparisonStageController = _ref.read(
      comparativeValidationStageControllerProvider,
    );

    return ShadowPollingEnduranceSnapshot(
      pollingActive: isPollingActive,
      lastRefreshTime: lastRefreshTime,
      lastTransitionTime: _latestDateTime([
        lastImportDecisionTransitionTime,
        migrationStageController.lastMigrationDecisionTransitionTime,
        comparisonStageController.lastComparisonTransitionTime,
      ]),
      chatImportDecision: chatImportDecision,
      chatSyncState: chatSyncState,
      chatSnapshotDelta: chatDelta,
      handleImportDecision: handleImportDecision,
      handleSyncState: handleSyncState,
      handleSnapshotDelta: handleDelta,
      importDecision: importDecision,
      prerequisiteAwareMessageImportDecision: prerequisiteAwareDecision,
      messageImportPrerequisiteAssessment: prerequisiteAssessment,
      messageSyncState: syncState,
      snapshotDelta: snapshotDelta,
      migrationDecision: migrationDecision,
      messageMigrationState: migrationState,
      migrationDelta: migrationDelta,
      importComparisonOutcome: comparisonReport.importComparison,
      migrationComparisonOutcome: comparisonReport.migrationComparison,
    );
  }

  Future<void> _appendEnduranceLogEvent(String message) async {
    try {
      await _enduranceLogWriter.appendEvent(message);
    } catch (error, stackTrace) {
      debugPrint('Shadow polling endurance log event append failed: $error');
      debugPrint(stackTrace.toString());
    }
  }
}

DateTime? _latestDateTime(List<DateTime?> values) {
  DateTime? latest;
  for (final value in values) {
    if (value == null) {
      continue;
    }
    if (latest == null || value.isAfter(latest)) {
      latest = value;
    }
  }
  return latest;
}

String _extractSemanticImportDecisionMeaning(ImportDecision? decision) {
  return switch (decision) {
    null => 'No previous import decision observed.',
    ImportDecisionDoNothing() => 'doNothing',
    ImportDecisionConsiderIncrementalImport() => 'considerIncrementalImport',
    ImportDecisionBlockAndReportLedgerAhead() => 'blockAndReportLedgerAhead',
  };
}
