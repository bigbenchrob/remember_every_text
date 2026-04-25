import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';
import '../../db_importers/domain/entities/db_import_result.dart';
import '../../db_migrate/domain/entities/db_migration_result.dart';
import '../domain/pipeline_incident_report.dart';
import '../infrastructure/pipeline_incident_storage.dart';
import 'app_logger.dart';
import 'pipeline_incident_log_writer.dart';

part 'pipeline_incident_tracker_provider.g.dart';

@Riverpod(keepAlive: true)
class PipelineIncidentTracker extends _$PipelineIncidentTracker {
  late PipelineIncidentStorage _storage;

  @override
  Future<PipelineIncidentReport?> build() async {
    _storage = PipelineIncidentStorage(
      overlayDb: ref.watch(overlayDatabaseProvider.future),
    );
    return _storage.loadLatestReport();
  }

  Future<void> recordImportResult({
    required DbImportResult result,
    required String executionOwner,
  }) async {
    final report = _buildImportReport(
      result: result,
      executionOwner: executionOwner,
    );
    await _storeReport(report);
  }

  Future<void> recordMigrationResult({
    required DbMigrationResult result,
    required bool incrementalMode,
  }) async {
    final report = _buildMigrationReport(
      result: result,
      incrementalMode: incrementalMode,
    );
    await _storeReport(report);
  }

  Future<void> dismissActiveReport() async {
    try {
      await _storage.dismissLatestReport();
      state = AsyncData(await _storage.loadLatestReport());
    } catch (error, stackTrace) {
      _logTrackerFailure(
        'Failed to dismiss pipeline incident report: $error',
        stackTrace,
      );
    }
  }

  Future<void> clear() async {
    await _storeReport(null);
  }

  Future<void> _storeReport(PipelineIncidentReport? report) async {
    try {
      if (report == null) {
        await _storage.clearLatestReport();
        state = const AsyncData(null);
        return;
      }

      await _storage.saveLatestReport(report);
      await const PipelineIncidentLogWriter().appendReport(report: report);
      state = AsyncData(report);
    } catch (error, stackTrace) {
      _logTrackerFailure(
        'Failed to persist pipeline incident report: $error',
        stackTrace,
      );
    }
  }

  PipelineIncidentReport? _buildImportReport({
    required DbImportResult result,
    required String executionOwner,
  }) {
    if (result.success) {
      return null;
    }

    final recordedAtUtc = DateTime.now().toUtc();
    return PipelineIncidentReport(
      reportId: 'import-${recordedAtUtc.microsecondsSinceEpoch}',
      stage: PipelineIncidentStage.import,
      headline: 'Import failed',
      summary:
          'The import pipeline stopped before MessageLens could finish reading source data.',
      recordedAtUtc: recordedAtUtc,
      batchId: result.batchId,
      entries: <PipelineIncidentEntry>[
        PipelineIncidentEntry(
          severity: PipelineIncidentSeverity.blocking,
          stage: PipelineIncidentStage.import,
          summary: result.error ?? 'Import failed without a detailed error.',
          recordedAtUtc: recordedAtUtc,
          detail: 'Execution owner: $executionOwner',
        ),
        for (final warning in result.warnings)
          PipelineIncidentEntry(
            severity: PipelineIncidentSeverity.context,
            stage: PipelineIncidentStage.import,
            summary: warning,
            recordedAtUtc: recordedAtUtc,
          ),
      ],
    );
  }

  PipelineIncidentReport? _buildMigrationReport({
    required DbMigrationResult result,
    required bool incrementalMode,
  }) {
    if (result.success) {
      return null;
    }

    final recordedAtUtc = DateTime.now().toUtc();
    final modeLabel = incrementalMode ? 'incremental' : 'full';
    return PipelineIncidentReport(
      reportId: 'migration-${recordedAtUtc.microsecondsSinceEpoch}',
      stage: PipelineIncidentStage.migration,
      headline: 'Migration failed',
      summary:
          'MessageLens imported data into the ledger, but it could not finish preparing app-facing tables.',
      recordedAtUtc: recordedAtUtc,
      batchId: result.batchId,
      entries: <PipelineIncidentEntry>[
        PipelineIncidentEntry(
          severity: PipelineIncidentSeverity.blocking,
          stage: PipelineIncidentStage.migration,
          summary: result.error ?? 'Migration failed without a detailed error.',
          recordedAtUtc: recordedAtUtc,
          detail: 'Mode: $modeLabel',
        ),
        for (final warning in result.warnings)
          PipelineIncidentEntry(
            severity: PipelineIncidentSeverity.context,
            stage: PipelineIncidentStage.migration,
            summary: warning,
            recordedAtUtc: recordedAtUtc,
          ),
      ],
    );
  }

  void _logTrackerFailure(String message, StackTrace stackTrace) {
    ref
        .read(appLoggerProvider.notifier)
        .error(
          message,
          source: 'PipelineIncidentTracker',
          context: {'stackTrace': '$stackTrace'},
        );
  }
}

@riverpod
Future<PipelineIncidentReport?> activeBlockingPipelineIncident(Ref ref) async {
  final report = await ref.watch(pipelineIncidentTrackerProvider.future);
  if (report == null || report.dismissed || !report.hasBlockingIncident) {
    return null;
  }

  return report;
}
