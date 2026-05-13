import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/shadow_message_migration_executor.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/migration_decision_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/migration_state_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/shadow_migration_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_migration_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/message_migration_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/migration_decision.dart';

void main() {
  group('ShadowMigrationExecutionOrchestrator', () {
    test('does not invoke executor for do-nothing decision', () async {
      final fakeExecutor = _FakeShadowMessageMigrationExecutor();
      final orchestrator =
          ShadowMigrationExecutionOrchestrator.withMigrationCallback(
            migrateMessages: fakeExecutor.migrateMessages,
          );

      final result = await orchestrator.runForDecision(
        const MigrationDecision.doNothing(),
      );

      expect(result, isNull);
      expect(fakeExecutor.invocationCount, 0);
    });

    test(
      'does not invoke executor for projection-ahead blocked decision',
      () async {
        final fakeExecutor = _FakeShadowMessageMigrationExecutor();
        final orchestrator =
            ShadowMigrationExecutionOrchestrator.withMigrationCallback(
              migrateMessages: fakeExecutor.migrateMessages,
            );

        final result = await orchestrator.runForDecision(
          const MigrationDecision.blockAndReportProjectionAhead(),
        );

        expect(result, isNull);
        expect(fakeExecutor.invocationCount, 0);
      },
    );

    test(
      'invokes executor exactly once for shadow migration decision',
      () async {
        final fakeExecutor = _FakeShadowMessageMigrationExecutor();
        final orchestrator =
            ShadowMigrationExecutionOrchestrator.withMigrationCallback(
              migrateMessages: fakeExecutor.migrateMessages,
            );

        final result = await orchestrator.runForDecision(
          const MigrationDecision.considerShadowMigration(),
        );

        expect(result, isNotNull);
        expect(fakeExecutor.invocationCount, 1);
      },
    );

    test('blocks execution for explicit projection-ahead scenario', () async {
      const ledgerMaxMessageId = 100;
      const projectionMaxMessageId = 105;
      const messageIdDelta = ledgerMaxMessageId - projectionMaxMessageId;

      final migrationState = const MessageMigrationStateIntegrator().integrate(
        const MessageMigrationDelta(
          messageIdDelta: messageIdDelta,
          messageCountDelta: -5,
        ),
      );
      final decision = const MigrationDecisionIntegrator().integrate(
        migrationState,
      );

      final fakeExecutor = _FakeShadowMessageMigrationExecutor();
      final orchestrator =
          ShadowMigrationExecutionOrchestrator.withMigrationCallback(
            migrateMessages: fakeExecutor.migrateMessages,
          );

      final result = await orchestrator.runForDecision(decision);

      expect(messageIdDelta, -5);
      expect(
        migrationState,
        const MessageMigrationState.projectionAheadOfLedger(),
      );
      expect(decision, const MigrationDecision.blockAndReportProjectionAhead());
      expect(result, isNull);
      expect(fakeExecutor.invocationCount, 0);
    });
  });
}

class _FakeShadowMessageMigrationExecutor {
  int invocationCount = 0;

  Future<ShadowMessageMigrationResult> migrateMessages() async {
    invocationCount += 1;
    return const ShadowMessageMigrationResult(insertedMessageCount: 5);
  }
}
