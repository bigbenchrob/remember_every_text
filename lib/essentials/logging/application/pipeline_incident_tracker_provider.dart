import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/pipeline_incident_report.dart';
import '../feature_level_providers.dart';
import 'app_logger.dart';
import 'pipeline_incident_log_writer.dart';
import 'pipeline_incident_store.dart';

part 'pipeline_incident_tracker_provider.g.dart';

@Riverpod(keepAlive: true)
class PipelineIncidentTracker extends _$PipelineIncidentTracker {
  late PipelineIncidentStore _storage;
  late PipelineIncidentLogWriter _logWriter;

  @override
  Future<PipelineIncidentReport?> build() async {
    _storage = ref.watch(pipelineIncidentStoreProvider);
    _logWriter = ref.watch(pipelineIncidentLogWriterProvider);
    return _storage.loadLatestReport();
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
      await _logWriter.appendReport(report: report);
      state = AsyncData(report);
    } catch (error, stackTrace) {
      _logTrackerFailure(
        'Failed to persist pipeline incident report: $error',
        stackTrace,
      );
    }
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
