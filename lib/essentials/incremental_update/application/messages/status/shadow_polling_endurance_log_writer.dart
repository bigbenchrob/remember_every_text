import 'dart:io';

import 'package:path/path.dart' as path;

import '../../../domain/models/message_migration_delta.dart';
import '../../../domain/models/snapshot_delta.dart';
import '../../../domain/sealed_unions/comparison_outcome.dart';
import '../../../domain/sealed_unions/import_decision.dart';
import '../../../domain/sealed_unions/message_migration_state.dart';
import '../../../domain/sealed_unions/migration_decision.dart';
import '../../../domain/sealed_unions/sync_state.dart';

class ShadowPollingEnduranceSnapshot {
  const ShadowPollingEnduranceSnapshot({
    required this.pollingActive,
    required this.lastRefreshTime,
    required this.lastTransitionTime,
    required this.importDecision,
    required this.messageSyncState,
    required this.snapshotDelta,
    required this.migrationDecision,
    required this.messageMigrationState,
    required this.migrationDelta,
    required this.importComparisonOutcome,
    required this.migrationComparisonOutcome,
  });

  final bool pollingActive;
  final DateTime? lastRefreshTime;
  final DateTime? lastTransitionTime;
  final ImportDecision importDecision;
  final MessageSyncState messageSyncState;
  final MessageSnapshotDelta snapshotDelta;
  final MigrationDecision migrationDecision;
  final MessageMigrationState messageMigrationState;
  final MessageMigrationDelta migrationDelta;
  final ComparisonOutcome importComparisonOutcome;
  final ComparisonOutcome migrationComparisonOutcome;
}

class ShadowPollingEnduranceLogWriter {
  ShadowPollingEnduranceLogWriter({Directory? logsDirectory})
    : _logsDirectory = logsDirectory;

  final Directory? _logsDirectory;
  File? _activeLogFile;
  int _sampleNumber = 0;
  _BehavioralConvergenceTracker _convergenceTracker =
      _BehavioralConvergenceTracker();

  String? get activeLogPath => _activeLogFile?.path;

  void startSession() {
    final logsDirectory =
        _logsDirectory ?? Directory(path.join(_projectRootPath(), '_LOGS'));
    logsDirectory.createSync(recursive: true);

    final startedAt = DateTime.now();
    final fileName =
        'shadow_incremental_update_${_fileTimestamp(startedAt)}.md';
    final logFile = File(path.join(logsDirectory.path, fileName));
    logFile.writeAsStringSync(
      '# Shadow incremental-update endurance log\n\n'
      '- started_at: ${startedAt.toIso8601String()}\n'
      '- source: dev status panel polling\n\n',
      flush: true,
    );

    _activeLogFile = logFile;
    _sampleNumber = 0;
    _convergenceTracker = _BehavioralConvergenceTracker();
  }

  Future<void> appendStatus(
    ShadowPollingEnduranceSnapshot status, {
    List<String> tickEvents = const <String>[],
    String? note,
    Object? refreshError,
    StackTrace? refreshStackTrace,
  }) async {
    final logFile = _activeLogFile;
    if (logFile == null) {
      return;
    }

    _sampleNumber += 1;
    final assessment = _convergenceTracker.observe(
      sampleNumber: _sampleNumber,
      status: status,
    );
    await logFile.writeAsString(
      _formatStatusBlock(
        sampleNumber: _sampleNumber,
        status: status,
        assessment: assessment,
        tickEvents: tickEvents,
        note: note,
        refreshError: refreshError,
        refreshStackTrace: refreshStackTrace,
      ),
      mode: FileMode.append,
      flush: true,
    );
  }

  Future<void> appendEvent(String message) async {
    final logFile = _activeLogFile;
    if (logFile == null) {
      return;
    }

    _sampleNumber += 1;
    await logFile.writeAsString(
      '\n## Polling sample $_sampleNumber\n\n'
      '- captured_at: ${DateTime.now().toIso8601String()}\n'
      '- event: ${_singleLine(message)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  void stopSession() {
    final logFile = _activeLogFile;
    if (logFile == null) {
      return;
    }

    logFile.writeAsStringSync(
      '\n## Polling stopped\n\n'
      '- stopped_at: ${DateTime.now().toIso8601String()}\n',
      mode: FileMode.append,
      flush: true,
    );
    _activeLogFile = null;
    _sampleNumber = 0;
    _convergenceTracker = _BehavioralConvergenceTracker();
  }
}

class _BehavioralAssessmentSample {
  const _BehavioralAssessmentSample({
    required this.shadowConvergenceCompleted,
    required this.shadowImportConvergenceDuration,
    required this.shadowImportTicksToConvergence,
    required this.shadowMigrationConvergenceDuration,
    required this.shadowMigrationTicksToConvergence,
    required this.shadowTotalConvergenceDuration,
    required this.shadowTotalTicksToConvergence,
    required this.productionConvergencePending,
    required this.productionPendingDuration,
    required this.lastProductionConvergenceDuration,
  });

  final bool shadowConvergenceCompleted;
  final Duration? shadowImportConvergenceDuration;
  final int? shadowImportTicksToConvergence;
  final Duration? shadowMigrationConvergenceDuration;
  final int? shadowMigrationTicksToConvergence;
  final Duration? shadowTotalConvergenceDuration;
  final int? shadowTotalTicksToConvergence;
  final bool productionConvergencePending;
  final Duration? productionPendingDuration;
  final Duration? lastProductionConvergenceDuration;
}

class _BehavioralConvergenceTracker {
  DateTime? _shadowEpisodeStartedAt;
  int? _shadowEpisodeStartSample;
  DateTime? _shadowImportStartedAt;
  int? _shadowImportStartSample;
  DateTime? _shadowMigrationStartedAt;
  int? _shadowMigrationStartSample;
  DateTime? _productionPendingStartedAt;

  Duration? _lastShadowImportConvergenceDuration;
  int? _lastShadowImportTicksToConvergence;
  Duration? _lastShadowMigrationConvergenceDuration;
  int? _lastShadowMigrationTicksToConvergence;
  Duration? _lastShadowTotalConvergenceDuration;
  int? _lastShadowTotalTicksToConvergence;
  Duration? _lastProductionConvergenceDuration;

  _BehavioralAssessmentSample observe({
    required int sampleNumber,
    required ShadowPollingEnduranceSnapshot status,
  }) {
    final now = DateTime.now();
    final shadowImportPending = _shadowImportPending(status);
    final shadowMigrationPending = _shadowMigrationPending(status);
    final shadowPending = shadowImportPending || shadowMigrationPending;
    final shadowConvergenceCompleted = !shadowPending;
    final productionPending = _productionConvergencePending(status);

    if (shadowPending && _shadowEpisodeStartedAt == null) {
      _shadowEpisodeStartedAt = now;
      _shadowEpisodeStartSample = sampleNumber;
      _lastShadowTotalConvergenceDuration = null;
      _lastShadowTotalTicksToConvergence = null;
    }

    if (shadowImportPending && _shadowImportStartedAt == null) {
      _shadowImportStartedAt = now;
      _shadowImportStartSample = sampleNumber;
      _lastShadowImportConvergenceDuration = null;
      _lastShadowImportTicksToConvergence = null;
    }

    if (shadowMigrationPending && _shadowMigrationStartedAt == null) {
      _shadowMigrationStartedAt = now;
      _shadowMigrationStartSample = sampleNumber;
      _lastShadowMigrationConvergenceDuration = null;
      _lastShadowMigrationTicksToConvergence = null;
    }

    if (!shadowImportPending && _shadowImportStartedAt != null) {
      _lastShadowImportConvergenceDuration = now.difference(
        _shadowImportStartedAt!,
      );
      _lastShadowImportTicksToConvergence =
          sampleNumber - _shadowImportStartSample!;
      _shadowImportStartedAt = null;
      _shadowImportStartSample = null;
    }

    if (!shadowMigrationPending && _shadowMigrationStartedAt != null) {
      _lastShadowMigrationConvergenceDuration = now.difference(
        _shadowMigrationStartedAt!,
      );
      _lastShadowMigrationTicksToConvergence =
          sampleNumber - _shadowMigrationStartSample!;
      _shadowMigrationStartedAt = null;
      _shadowMigrationStartSample = null;
    }

    if (!shadowPending && _shadowEpisodeStartedAt != null) {
      _lastShadowTotalConvergenceDuration = now.difference(
        _shadowEpisodeStartedAt!,
      );
      _lastShadowTotalTicksToConvergence =
          sampleNumber - _shadowEpisodeStartSample!;
      _shadowEpisodeStartedAt = null;
      _shadowEpisodeStartSample = null;
    }

    if (productionPending && _productionPendingStartedAt == null) {
      _productionPendingStartedAt = now;
    }

    if (!productionPending && _productionPendingStartedAt != null) {
      _lastProductionConvergenceDuration = now.difference(
        _productionPendingStartedAt!,
      );
      _productionPendingStartedAt = null;
    }

    return _BehavioralAssessmentSample(
      shadowConvergenceCompleted: shadowConvergenceCompleted,
      shadowImportConvergenceDuration: _shadowImportStartedAt == null
          ? _lastShadowImportConvergenceDuration
          : now.difference(_shadowImportStartedAt!),
      shadowImportTicksToConvergence: _shadowImportStartedAt == null
          ? _lastShadowImportTicksToConvergence
          : sampleNumber - _shadowImportStartSample!,
      shadowMigrationConvergenceDuration: _shadowMigrationStartedAt == null
          ? _lastShadowMigrationConvergenceDuration
          : now.difference(_shadowMigrationStartedAt!),
      shadowMigrationTicksToConvergence: _shadowMigrationStartedAt == null
          ? _lastShadowMigrationTicksToConvergence
          : sampleNumber - _shadowMigrationStartSample!,
      shadowTotalConvergenceDuration: _shadowEpisodeStartedAt == null
          ? _lastShadowTotalConvergenceDuration
          : now.difference(_shadowEpisodeStartedAt!),
      shadowTotalTicksToConvergence: _shadowEpisodeStartedAt == null
          ? _lastShadowTotalTicksToConvergence
          : sampleNumber - _shadowEpisodeStartSample!,
      productionConvergencePending: productionPending,
      productionPendingDuration: _productionPendingStartedAt == null
          ? null
          : now.difference(_productionPendingStartedAt!),
      lastProductionConvergenceDuration: _lastProductionConvergenceDuration,
    );
  }

  bool _shadowImportPending(ShadowPollingEnduranceSnapshot status) {
    return switch (status.importDecision) {
      ImportDecisionDoNothing() => false,
      ImportDecisionConsiderIncrementalImport() => true,
      ImportDecisionBlockAndReportLedgerAhead() => true,
    };
  }

  bool _shadowMigrationPending(ShadowPollingEnduranceSnapshot status) {
    return switch (status.migrationDecision) {
      MigrationDecisionDoNothing() => false,
      MigrationDecisionConsiderShadowMigration() => true,
      MigrationDecisionBlockAndReportProjectionAhead() => true,
    };
  }

  bool _productionConvergencePending(ShadowPollingEnduranceSnapshot status) {
    return _comparisonShowsProductionPending(status.importComparisonOutcome) ||
        _comparisonShowsProductionPending(status.migrationComparisonOutcome);
  }

  bool _comparisonShowsProductionPending(ComparisonOutcome outcome) {
    return switch (outcome) {
      ComparisonOutcomePhaseSkew(:final legacy, :final shadow) =>
        legacy.contains('required') && !shadow.contains('required'),
      ComparisonOutcomeMismatch(:final legacy, :final shadow) =>
        legacy.contains('required') && !shadow.contains('required'),
      ComparisonOutcomeMatch() => false,
      ComparisonOutcomeNotComparable() => false,
    };
  }
}

String _projectRootPath() {
  var directory = Directory.current;

  while (true) {
    final pubspec = File(path.join(directory.path, 'pubspec.yaml'));
    final agentInstructions = Directory(
      path.join(directory.path, '_AGENT_INSTRUCTIONS'),
    );
    if (pubspec.existsSync() && agentInstructions.existsSync()) {
      return directory.path;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      return Directory.current.path;
    }
    directory = parent;
  }
}

String _formatStatusBlock({
  required int sampleNumber,
  required ShadowPollingEnduranceSnapshot status,
  required _BehavioralAssessmentSample assessment,
  required List<String> tickEvents,
  String? note,
  Object? refreshError,
  StackTrace? refreshStackTrace,
}) {
  final noteLine = note == null ? '' : '- note: $note\n';
  final errorLines = refreshError == null
      ? ''
      : '- refresh_error: ${_singleLine(refreshError.toString())}\n'
            '- refresh_stack_trace: ${_singleLine(refreshStackTrace.toString())}\n';
  final tickEventsBlock = tickEvents.isEmpty
      ? '## Tick Events\n\n- no tick events recorded\n\n'
      : '## Tick Events\n\n${tickEvents.map((event) => '- $event').join('\n')}\n\n';

  return '\n## Polling sample $sampleNumber\n\n'
      '- captured_at: ${DateTime.now().toIso8601String()}\n'
      '$noteLine'
      '$errorLines'
      '- polling_status: ${status.pollingActive ? 'active' : 'inactive'}\n'
      '- last_refresh: ${_formatDateTime(status.lastRefreshTime)}\n'
      '- last_transition: ${_formatDateTime(status.lastTransitionTime)}\n\n'
      '$tickEventsBlock'
      '### Behavioral assessment\n\n'
      '- shadow_convergence_completed: ${assessment.shadowConvergenceCompleted}\n'
      '- shadow_import_convergence_duration: ${_formatDuration(assessment.shadowImportConvergenceDuration)}\n'
      '- shadow_import_ticks_to_convergence: ${_formatInt(assessment.shadowImportTicksToConvergence)}\n'
      '- shadow_migration_convergence_duration: ${_formatDuration(assessment.shadowMigrationConvergenceDuration)}\n'
      '- shadow_migration_ticks_to_convergence: ${_formatInt(assessment.shadowMigrationTicksToConvergence)}\n'
      '- shadow_total_convergence_duration: ${_formatDuration(assessment.shadowTotalConvergenceDuration)}\n'
      '- shadow_total_ticks_to_convergence: ${_formatInt(assessment.shadowTotalTicksToConvergence)}\n'
      '- production_convergence_pending: ${assessment.productionConvergencePending}\n'
      '- production_pending_duration: ${_formatDuration(assessment.productionPendingDuration)}\n'
      '- last_production_convergence_duration: ${_formatDuration(assessment.lastProductionConvergenceDuration)}\n\n'
      '### Shadow import\n\n'
      '- ImportDecision: ${_formatImportDecision(status.importDecision)}\n'
      '- MessageSyncState: ${_formatMessageSyncState(status.messageSyncState)}\n'
      '- rowIdDelta: ${status.snapshotDelta.rowIdDelta}\n'
      '- messageCountDelta: ${status.snapshotDelta.messageCountDelta}\n\n'
      '### Shadow migration\n\n'
      '- MigrationDecision: ${_formatMigrationDecision(status.migrationDecision)}\n'
      '- MessageMigrationState: ${_formatMigrationState(status.messageMigrationState)}\n'
      '- messageIdDelta: ${status.migrationDelta.messageIdDelta}\n'
      '- messageCountDelta: ${status.migrationDelta.messageCountDelta}\n\n'
      '### Comparative validation\n\n'
      '- Import comparison: ${_formatComparison(status.importComparisonOutcome)}\n'
      '- Migration comparison: ${_formatComparison(status.migrationComparisonOutcome)}\n';
}

String _formatInt(int? value) {
  if (value == null) {
    return 'not observed';
  }
  return '$value';
}

String _singleLine(String value) {
  return value.replaceAll('\n', r'\n');
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return 'not observed';
  }

  return value.toLocal().toIso8601String();
}

String _formatDuration(Duration? value) {
  if (value == null) {
    return 'not observed';
  }

  return '${value.inMilliseconds}ms';
}

String _fileTimestamp(DateTime value) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '${year}_${month}_${day}_${hour}_${minute}_$second';
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

String _formatMessageSyncState(MessageSyncState state) {
  return switch (state) {
    MessageSyncCursorsMatch() => 'MessageSyncState.sourceAndLedgerCursorsMatch',
    MessageSyncSourceAheadOfLedger() => 'MessageSyncState.sourceAheadOfLedger',
    MessageSyncLedgerAheadOfSource() => 'MessageSyncState.ledgerAheadOfSource',
  };
}

String _formatMigrationDecision(MigrationDecision decision) {
  return switch (decision) {
    MigrationDecisionDoNothing() => 'MigrationDecision.doNothing',
    MigrationDecisionConsiderShadowMigration() =>
      'MigrationDecision.considerShadowMigration',
    MigrationDecisionBlockAndReportProjectionAhead() =>
      'MigrationDecision.blockAndReportProjectionAhead',
  };
}

String _formatMigrationState(MessageMigrationState state) {
  return switch (state) {
    MessageMigrationProjectionCaughtUp() =>
      'MessageMigrationState.projectionCaughtUp',
    MessageMigrationLedgerAheadOfProjection() =>
      'MessageMigrationState.ledgerAheadOfProjection',
    MessageMigrationProjectionAheadOfLedger() =>
      'MessageMigrationState.projectionAheadOfLedger',
  };
}

String _formatComparison(ComparisonOutcome outcome) {
  return switch (outcome) {
    ComparisonOutcomeMatch(:final legacy, :final shadow) =>
      'MATCH: legacy=$legacy; shadow=$shadow',
    ComparisonOutcomePhaseSkew(:final legacy, :final shadow, :final reason) =>
      'PHASE SKEW: legacy=$legacy; shadow=$shadow; reason=$reason',
    ComparisonOutcomeMismatch(:final legacy, :final shadow, :final reason) =>
      'MISMATCH: legacy=$legacy; shadow=$shadow; reason=$reason',
    ComparisonOutcomeNotComparable(
      :final legacy,
      :final shadow,
      :final reason,
    ) =>
      'NOT COMPARABLE: legacy=$legacy; shadow=$shadow; reason=$reason',
  };
}
