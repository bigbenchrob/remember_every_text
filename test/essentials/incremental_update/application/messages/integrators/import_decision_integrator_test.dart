import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/import_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/sync_state.dart';

void main() {
  final integrator = ImportDecisionIntegrator();

  group('ImportDecisionIntegrator', () {
    test('maps cursors-match state to do-nothing decision', () {
      final decision = integrator.integrate(
        const MessageSyncState.sourceAndLedgerCursorsMatch(),
      );

      expect(decision, const ImportDecision.doNothing());
    });

    test('maps source-ahead state to incremental import consideration', () {
      final decision = integrator.integrate(
        const MessageSyncState.sourceAheadOfLedger(),
      );

      expect(decision, const ImportDecision.considerIncrementalImport());
    });

    test('maps ledger-ahead state to blocked decision', () {
      final decision = integrator.integrate(
        const MessageSyncState.ledgerAheadOfSource(),
      );

      expect(decision, const ImportDecision.blockAndReportLedgerAhead());
    });
  });
}
