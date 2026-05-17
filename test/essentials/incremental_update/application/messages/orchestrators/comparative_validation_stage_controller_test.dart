import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/incremental_update_comparison_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/incremental_update_comparison_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/comparative_validation_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/comparative_validation_stage_controller_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/comparison_outcome.dart';

void main() {
  group('ComparativeValidationStageController', () {
    test('captures import and migration comparison outcomes', () async {
      const report = IncrementalUpdateComparisonReport(
        importComparison: ComparisonOutcome.match(
          legacy: 'incremental import not required',
          shadow: 'incremental import not required',
        ),
        migrationComparison: ComparisonOutcome.phaseSkew(
          legacy: 'migration required',
          shadow: 'projection current',
          reason: 'production projection catching up asynchronously',
        ),
      );
      final container = _container(report);
      addTearDown(container.dispose);

      final stageReport = await container
          .read(comparativeValidationStageControllerProvider)
          .refreshAndReport();

      expect(stageReport.importComparison, report.importComparison);
      expect(stageReport.migrationComparison, report.migrationComparison);
      expect(
        stageReport.executionOutcome,
        ComparativeValidationStageExecutionOutcome.noMutation,
      );
    });

    test('renders the stable diagnostic tick event', () async {
      const report = IncrementalUpdateComparisonReport(
        importComparison: ComparisonOutcome.mismatch(
          legacy: 'incremental import not required',
          shadow: 'incremental import required',
          reason: 'no recognized transient explanation',
        ),
        migrationComparison: ComparisonOutcome.notComparable(
          legacy: 'projection unknown',
          shadow: 'projection current',
          reason: 'missing production facts',
        ),
      );
      final container = _container(report);
      addTearDown(container.dispose);

      final stageReport = await container
          .read(comparativeValidationStageControllerProvider)
          .refreshAndReport();

      const expectedEvent =
          'comparison observed: '
          'import=MISMATCH legacy=incremental import not required shadow=incremental import required reason=no recognized transient explanation, '
          'migration=NOT COMPARABLE legacy=projection unknown shadow=projection current reason=missing production facts';
      expect(stageReport.diagnosticEvents, <String>[expectedEvent]);
    });
  });
}

ProviderContainer _container(IncrementalUpdateComparisonReport report) {
  return ProviderContainer(
    overrides: <Override>[
      incrementalUpdateComparisonProvider.overrideWith((ref) async => report),
    ],
  );
}
