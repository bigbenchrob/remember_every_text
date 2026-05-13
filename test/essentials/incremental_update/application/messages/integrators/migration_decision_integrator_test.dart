import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/migration_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/message_migration_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/migration_decision.dart';

void main() {
  const integrator = MigrationDecisionIntegrator();

  group('MigrationDecisionIntegrator', () {
    test('maps caught-up projection state to do-nothing decision', () {
      final decision = integrator.integrate(
        const MessageMigrationState.projectionCaughtUp(),
      );

      expect(decision, const MigrationDecision.doNothing());
    });

    test('maps ledger-ahead state to shadow migration consideration', () {
      final decision = integrator.integrate(
        const MessageMigrationState.ledgerAheadOfProjection(),
      );

      expect(decision, const MigrationDecision.considerShadowMigration());
    });

    test('maps projection-ahead state to blocked decision', () {
      final decision = integrator.integrate(
        const MessageMigrationState.projectionAheadOfLedger(),
      );

      expect(decision, const MigrationDecision.blockAndReportProjectionAhead());
    });
  });
}
