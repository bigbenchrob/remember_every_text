import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_reconciliation.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  test('ready environment supplies durable completion proof', () {
    final evidence = onboardingReconciliationEvidenceFrom(
      _report(
        state: OnboardingEnvironmentState.ready,
        importRows: 120,
        graphRows: 118,
      ),
    );

    expect(evidence.state, OnboardingDurableReconciliationState.completed);
    final proof = evidence.completionProof;
    expect(proof, isA<OnboardingInstallationReadyProof>());
    if (proof is! OnboardingInstallationReadyProof) {
      fail('Ready evidence did not provide installation readiness proof.');
    }
    expect(proof.sourceScopedImportRows, 120);
    expect(proof.conversationGraphRows, 118);
  });

  test(
    'maintenance leaves interrupted work unavailable for reconciliation',
    () {
      final evidence = onboardingReconciliationEvidenceFrom(
        _report(state: OnboardingEnvironmentState.maintenanceInProgress),
      );

      expect(evidence.state, OnboardingDurableReconciliationState.unavailable);
      expect(evidence.completionProof, isNull);
    },
  );

  test('recoverable environment states preserve resumable interruption', () {
    for (final state in <OnboardingEnvironmentState>[
      OnboardingEnvironmentState.permissionBlocked,
      OnboardingEnvironmentState.sourceUnavailable,
      OnboardingEnvironmentState.sourceSparseOrUnsynced,
      OnboardingEnvironmentState.readyToImport,
    ]) {
      final evidence = onboardingReconciliationEvidenceFrom(
        _report(state: state),
      );

      expect(
        evidence.state,
        OnboardingDurableReconciliationState.resumable,
        reason: state.name,
      );
    }
  });

  test('durable pipeline failures become inconsistent evidence', () {
    final importEvidence = onboardingReconciliationEvidenceFrom(
      _report(
        state: OnboardingEnvironmentState.importFailed,
        importFailure: 'source import failed',
      ),
    );
    final graphEvidence = onboardingReconciliationEvidenceFrom(
      _report(
        state: OnboardingEnvironmentState.graphProjectionFailed,
        graphFailure: 'graph build failed',
      ),
    );

    expect(
      importEvidence.state,
      OnboardingDurableReconciliationState.inconsistent,
    );
    expect(importEvidence.failureSummary, 'source import failed');
    expect(
      graphEvidence.state,
      OnboardingDurableReconciliationState.inconsistent,
    );
    expect(graphEvidence.failureSummary, 'graph build failed');
  });
}

OnboardingEnvironmentReport _report({
  required OnboardingEnvironmentState state,
  int? importRows,
  int? graphRows,
  String? importFailure,
  String? graphFailure,
}) {
  const availableProbe = OnboardingDatabaseProbe(
    path: '/tmp/source.db',
    exists: true,
    readable: true,
    rowCount: 1,
  );
  return OnboardingEnvironmentReport(
    state: state,
    blockerKind: OnboardingBlockerKind.none,
    syncPlausibility: OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable,
    messagesDatabase: availableProbe,
    addressBookDatabase: availableProbe,
    overlayDatabase: availableProbe,
    sourceScopedImportDatabase: OnboardingDatabaseProbe(
      path: '/tmp/macos_import_ss.db',
      exists: true,
      readable: true,
      rowCount: importRows,
    ),
    conversationGraph: OnboardingDatabaseProbe(
      path: '/tmp/working_ss.db',
      exists: true,
      readable: true,
      rowCount: graphRows,
    ),
    attachmentArchiveDirectory: availableProbe,
    hasFullDiskAccess: true,
    lastImportFailure: importFailure == null
        ? null
        : OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.import,
            message: importFailure,
          ),
    lastGraphProjectionFailure: graphFailure == null
        ? null
        : OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.graphProjection,
            message: graphFailure,
          ),
  );
}
