import '../../../domain/models/message_import_prerequisite_assessment.dart';
import '../../../domain/sealed_unions/import_decision.dart';
import '../../../domain/sealed_unions/prerequisite_aware_message_import_decision.dart';

class PrerequisiteAwareMessageImportDecisionIntegrator {
  const PrerequisiteAwareMessageImportDecisionIntegrator();

  PrerequisiteAwareMessageImportDecision integrate({
    required ImportDecision baseDecision,
    required MessageImportPrerequisiteAssessment prerequisites,
  }) {
    return switch (baseDecision) {
      ImportDecisionDoNothing() =>
        const PrerequisiteAwareMessageImportDecision.doNothing(),
      ImportDecisionBlockAndReportLedgerAhead() =>
        const PrerequisiteAwareMessageImportDecision.blockAndReportLedgerAhead(),
      ImportDecisionConsiderIncrementalImport() when prerequisites.isBlocked =>
        PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(
          blockers: prerequisites.blockers,
        ),
      ImportDecisionConsiderIncrementalImport() =>
        const PrerequisiteAwareMessageImportDecision.considerIncrementalImport(),
    };
  }
}
