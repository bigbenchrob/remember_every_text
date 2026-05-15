import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/integrators/chat_import_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_sync_state.dart';

void main() {
  const integrator = ChatImportDecisionIntegrator();

  group('ChatImportDecisionIntegrator', () {
    test('maps cursors-match state to do-nothing decision', () {
      final decision = integrator.integrate(
        const ChatSyncState.sourceAndLedgerCursorsMatch(),
      );

      expect(decision, const ChatImportDecision.doNothing());
    });

    test('maps source-ahead state to incremental import consideration', () {
      final decision = integrator.integrate(
        const ChatSyncState.sourceAheadOfLedger(),
      );

      expect(decision, const ChatImportDecision.considerIncrementalImport());
    });

    test('maps ledger-ahead state to blocked decision', () {
      final decision = integrator.integrate(
        const ChatSyncState.ledgerAheadOfSource(),
      );

      expect(decision, const ChatImportDecision.blockAndReportLedgerAhead());
    });
  });
}
