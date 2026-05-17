import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/comparative_validation_stage_report.dart';
import 'comparative_validation_orchestrator_provider.dart';

class ComparativeValidationStageController {
  const ComparativeValidationStageController(this._ref);

  final Ref _ref;

  DateTime? get lastComparisonTransitionTime => _ref
      .read(comparativeValidationOrchestratorProvider)
      .lastComparisonTransitionTime;

  Future<ComparativeValidationStageReport> refreshAndReport() async {
    final startedAt = DateTime.now();
    final comparisonReport = await _ref
        .read(comparativeValidationOrchestratorProvider)
        .refreshOnce();
    final diagnosticEvent =
        'comparison observed: '
        'import=${formatComparisonOutcome(comparisonReport.importComparison)}, '
        'migration=${formatComparisonOutcome(comparisonReport.migrationComparison)}';
    final diagnosticEvents = <String>[diagnosticEvent];

    return ComparativeValidationStageReport(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      importComparison: comparisonReport.importComparison,
      migrationComparison: comparisonReport.migrationComparison,
      diagnosticEvents: diagnosticEvents,
    );
  }
}
