import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/migration_state_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_migration_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/message_migration_state.dart';

void main() {
  const integrator = MessageMigrationStateIntegrator();

  group('MessageMigrationStateIntegrator', () {
    test('maps zero message id delta to projection-caught-up state', () {
      final state = integrator.integrate(
        const MessageMigrationDelta(messageIdDelta: 0, messageCountDelta: 0),
      );

      expect(state, const MessageMigrationState.projectionCaughtUp());
    });

    test('maps positive message id delta to ledger-ahead state', () {
      final state = integrator.integrate(
        const MessageMigrationDelta(messageIdDelta: 5, messageCountDelta: 5),
      );

      expect(state, const MessageMigrationState.ledgerAheadOfProjection());
    });

    test('maps negative message id delta to projection-ahead state', () {
      final state = integrator.integrate(
        const MessageMigrationDelta(messageIdDelta: -5, messageCountDelta: -5),
      );

      expect(state, const MessageMigrationState.projectionAheadOfLedger());
    });
  });
}
