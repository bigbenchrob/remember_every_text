import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/integrators/handle_import_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_sync_state.dart';

void main() {
  const integrator = HandleImportDecisionIntegrator();

  group('HandleImportDecisionIntegrator', () {
    test('maps cursors-match state to do-nothing decision', () {
      final decision = integrator.integrate(
        const HandleSyncState.sourceAndLedgerCursorsMatch(),
      );

      expect(decision, const HandleImportDecision.doNothing());
    });

    test('maps source-ahead state to incremental import consideration', () {
      final decision = integrator.integrate(
        const HandleSyncState.sourceAheadOfLedger(),
      );

      expect(decision, const HandleImportDecision.considerIncrementalImport());
    });

    test('maps ledger-ahead state to blocked decision', () {
      final decision = integrator.integrate(
        const HandleSyncState.ledgerAheadOfSource(),
      );

      expect(decision, const HandleImportDecision.blockAndReportLedgerAhead());
    });
  });
}
