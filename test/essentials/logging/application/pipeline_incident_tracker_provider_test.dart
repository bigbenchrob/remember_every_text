import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/logging/application/pipeline_incident_log_writer.dart';
import 'package:remember_this_text/essentials/logging/application/pipeline_incident_storage_provider.dart';
import 'package:remember_this_text/essentials/logging/application/pipeline_incident_store.dart';
import 'package:remember_this_text/essentials/logging/application/pipeline_incident_tracker_provider.dart';
import 'package:remember_this_text/essentials/logging/domain/pipeline_incident_report.dart';

void main() {
  test('migration enum renders as retired projection compatibility', () {
    expect(
      PipelineIncidentStage.migration.displayLabel,
      equals('Retired projection compatibility'),
    );
  });

  test('graph projection enum renders as current graph projection stage', () {
    expect(
      PipelineIncidentStage.graphProjection.displayLabel,
      equals('Graph projection'),
    );
  });

  test('pipeline incident report parses current graph projection stage', () {
    final report = PipelineIncidentReport.fromJson({
      'report_id': 'report-graph',
      'stage': 'graphProjection',
      'headline': 'Graph issue',
      'summary': 'Graph summary',
      'recorded_at_utc': '2026-06-13T00:00:00.000Z',
      'entries': const [],
    });

    expect(report, isNotNull);
    expect(report!.stage, PipelineIncidentStage.graphProjection);
  });

  test('pipeline incident report still parses historical migration stage', () {
    final report = PipelineIncidentReport.fromJson({
      'report_id': 'report-retired',
      'stage': 'migration',
      'headline': 'Historical issue',
      'summary': 'Historical summary',
      'recorded_at_utc': '2026-06-13T00:00:00.000Z',
      'entries': [
        {
          'severity': 'blocking',
          'stage': 'migration',
          'summary': 'Entry summary',
          'recorded_at_utc': '2026-06-13T00:00:00.000Z',
        },
      ],
    });

    expect(report, isNotNull);
    expect(report!.stage, PipelineIncidentStage.migration);
    expect(report.entries.single.stage, PipelineIncidentStage.migration);
  });

  test('activeBlockingPipelineIncident reads through store boundary', () async {
    final store = _FakePipelineIncidentStore(
      initialReport: _report(hasBlockingEntry: true),
    );
    final container = _container(store);
    addTearDown(container.dispose);

    final report = await container.read(
      activeBlockingPipelineIncidentProvider.future,
    );

    expect(report?.reportId, 'report-1');
    expect(store.loadCount, 1);
  });

  test('activeBlockingPipelineIncident hides dismissed reports', () async {
    final store = _FakePipelineIncidentStore(
      initialReport: _report(hasBlockingEntry: true, dismissed: true),
    );
    final container = _container(store);
    addTearDown(container.dispose);

    final report = await container.read(
      activeBlockingPipelineIncidentProvider.future,
    );

    expect(report, isNull);
  });

  test('activeBlockingPipelineIncident hides nonblocking reports', () async {
    final store = _FakePipelineIncidentStore(
      initialReport: _report(hasBlockingEntry: false),
    );
    final container = _container(store);
    addTearDown(container.dispose);

    final report = await container.read(
      activeBlockingPipelineIncidentProvider.future,
    );

    expect(report, isNull);
  });

  test('dismissActiveReport delegates to store boundary', () async {
    final store = _FakePipelineIncidentStore(
      initialReport: _report(hasBlockingEntry: true),
    );
    final container = _container(store);
    addTearDown(container.dispose);

    await container.read(pipelineIncidentTrackerProvider.future);
    await container
        .read(pipelineIncidentTrackerProvider.notifier)
        .dismissActiveReport();

    expect(store.dismissCount, 1);
    expect(
      container.read(pipelineIncidentTrackerProvider).valueOrNull?.dismissed,
      isTrue,
    );
  });
}

ProviderContainer _container(_FakePipelineIncidentStore store) {
  return ProviderContainer(
    overrides: [
      pipelineIncidentStoreProvider.overrideWithValue(store),
      pipelineIncidentLogWriterProvider.overrideWithValue(
        const _NoopPipelineIncidentLogWriter(),
      ),
    ],
  );
}

PipelineIncidentReport _report({
  required bool hasBlockingEntry,
  bool dismissed = false,
}) {
  return PipelineIncidentReport(
    reportId: 'report-1',
    stage: PipelineIncidentStage.import,
    headline: 'Import issue',
    summary: 'Import summary',
    recordedAtUtc: DateTime.utc(2026, 6, 13),
    dismissed: dismissed,
    entries: [
      PipelineIncidentEntry(
        severity: hasBlockingEntry
            ? PipelineIncidentSeverity.blocking
            : PipelineIncidentSeverity.warning,
        stage: PipelineIncidentStage.import,
        summary: 'Entry summary',
        recordedAtUtc: DateTime.utc(2026, 6, 13),
      ),
    ],
  );
}

class _FakePipelineIncidentStore implements PipelineIncidentStore {
  _FakePipelineIncidentStore({PipelineIncidentReport? initialReport})
    : _report = initialReport;

  PipelineIncidentReport? _report;
  int loadCount = 0;
  int dismissCount = 0;

  @override
  Future<void> clearLatestReport() async {
    _report = null;
  }

  @override
  Future<void> dismissLatestReport() async {
    dismissCount++;
    final report = _report;
    if (report != null) {
      _report = report.copyWith(dismissed: true);
    }
  }

  @override
  Future<PipelineIncidentReport?> loadLatestReport() async {
    loadCount++;
    return _report;
  }

  @override
  Future<void> saveLatestReport(PipelineIncidentReport report) async {
    _report = report;
  }
}

class _NoopPipelineIncidentLogWriter implements PipelineIncidentLogWriter {
  const _NoopPipelineIncidentLogWriter();

  @override
  Future<void> appendReport({required PipelineIncidentReport report}) async {}
}
