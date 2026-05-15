import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/comparison_outcome.dart';
import '../../../domain/sealed_unions/import_decision.dart';
import '../integrators/import_decision_integrator.dart';
import '../integrators/import_decision_provider.dart';
import '../integrators/incremental_update_comparison_provider.dart';
import '../integrators/migration_decision_integrator.dart';
import '../integrators/migration_delta_integrator_provider.dart';
import '../integrators/migration_state_integrator.dart';
import '../integrators/snapshot_delta_integrator_provider.dart';
import '../integrators/sync_assessment_integrator.dart';
import '../integrators/sync_assessment_integrator_provider.dart';
import '../readers/import_ledger_message_snapshot_provider.dart';
import '../readers/live_chat_db_message_snapshot_provider.dart';
import '../status/shadow_polling_endurance_log_writer.dart';
import 'comparative_validation_orchestrator_provider.dart';
import 'shadow_import_execution_orchestrator_provider.dart';
import 'shadow_migration_refresh_orchestrator_provider.dart';

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
    return _refreshOnceWithTickEvents();
  }

  Future<ImportDecision> _refreshOnceWithTickEvents({
    List<String>? tickEvents,
  }) async {
    try {
      _ref.invalidate(liveChatDbMessageSnapshotProvider);
      _ref.invalidate(importLedgerMessageSnapshotProvider);
      tickEvents?.add('reader refresh started');
      tickEvents?.add('import observation boundary invalidated');
      final importDelta = await _ref.read(
        snapshotDeltaIntegratorProvider.future,
      );
      tickEvents?.add(
        'import delta observed: '
        'rowIdDelta=${importDelta.rowIdDelta}, '
        'messageCountDelta=${importDelta.messageCountDelta}',
      );
      final decision = await _ref.read(importDecisionProvider.future);
      tickEvents?.add(
        'import decision observed: ${_formatImportDecision(decision)}',
      );
      final executionOrchestrator = await _ref.read(
        shadowImportExecutionOrchestratorProvider.future,
      );
      final result = await executionOrchestrator.runForDecision(decision);
      if (result != null) {
        tickEvents?.add(
          'shadow import executed: '
          'insertedMessageCount=${result.insertedMessageCount}, '
          'lastImportedSourceRowId=${result.lastImportedSourceRowId}',
        );
        _ref.invalidate(liveChatDbMessageSnapshotProvider);
        _ref.invalidate(importLedgerMessageSnapshotProvider);
      } else {
        tickEvents?.add(
          'shadow import skipped: ${_importSkipReason(decision)}',
        );
      }
      await _ref
          .read(shadowMigrationRefreshOrchestratorProvider)
          .refreshOnce(tickEvents: tickEvents);
      final comparisonReport = await _ref
          .read(comparativeValidationOrchestratorProvider)
          .refreshOnce();
      tickEvents?.add(
        'comparison observed: '
        'import=${_formatComparisonOutcome(comparisonReport.importComparison)}, '
        'migration=${_formatComparisonOutcome(comparisonReport.migrationComparison)}',
      );
      return result == null
          ? decision
          : _ref.read(importDecisionProvider.future);
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
    final tickEvents = <String>['tick started'];

    try {
      final decision = await _refreshOnceWithTickEvents(tickEvents: tickEvents);
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
    Object? refreshError,
    StackTrace? refreshStackTrace,
  }) async {
    try {
      final status = await _buildEnduranceLogSnapshot();
      await _enduranceLogWriter.appendStatus(
        status,
        tickEvents: tickEvents,
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
    final migrationOrchestrator = _ref.read(
      shadowMigrationRefreshOrchestratorProvider,
    );
    final comparisonOrchestrator = _ref.read(
      comparativeValidationOrchestratorProvider,
    );

    return ShadowPollingEnduranceSnapshot(
      pollingActive: isPollingActive,
      lastRefreshTime: lastRefreshTime,
      lastTransitionTime: _latestDateTime([
        lastImportDecisionTransitionTime,
        migrationOrchestrator.lastMigrationDecisionTransitionTime,
        comparisonOrchestrator.lastComparisonTransitionTime,
      ]),
      importDecision: importDecision,
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

String _formatImportDecision(ImportDecision decision) {
  return switch (decision) {
    ImportDecisionDoNothing() => 'ImportDecision.doNothing',
    ImportDecisionConsiderIncrementalImport() =>
      'ImportDecision.considerIncrementalImport',
    ImportDecisionBlockAndReportLedgerAhead() =>
      'ImportDecision.blockAndReportLedgerAhead',
  };
}

String _importSkipReason(ImportDecision decision) {
  return switch (decision) {
    ImportDecisionDoNothing() => 'decision doNothing',
    ImportDecisionBlockAndReportLedgerAhead() =>
      'decision blockAndReportLedgerAhead',
    ImportDecisionConsiderIncrementalImport() => 'execution returned no result',
  };
}

String _formatComparisonOutcome(ComparisonOutcome outcome) {
  return switch (outcome) {
    ComparisonOutcomeMatch(:final legacy, :final shadow) =>
      'MATCH legacy=$legacy shadow=$shadow',
    ComparisonOutcomePhaseSkew(:final legacy, :final shadow, :final reason) =>
      'PHASE SKEW legacy=$legacy shadow=$shadow reason=$reason',
    ComparisonOutcomeMismatch(:final legacy, :final shadow, :final reason) =>
      'MISMATCH legacy=$legacy shadow=$shadow reason=$reason',
    ComparisonOutcomeNotComparable(
      :final legacy,
      :final shadow,
      :final reason,
    ) =>
      'NOT COMPARABLE legacy=$legacy shadow=$shadow reason=$reason',
  };
}
