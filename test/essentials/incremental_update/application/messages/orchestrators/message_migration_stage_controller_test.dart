import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/shadow_message_migration_executor.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/models/message_migration_stage_report.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/message_migration_stage_controller_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/shadow_migration_execution_orchestrator.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/orchestrators/shadow_migration_execution_orchestrator_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/readers/shadow_import_projection_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/readers/shadow_working_projection_snapshot_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_migration_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_projection_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/message_migration_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/migration_decision.dart';

void main() {
  group('MessageMigrationStageController', () {
    test('reports do-nothing path without invoking execution', () async {
      var migrationInvocationCount = 0;
      final container = _container(
        ledger: const MessageProjectionSnapshot(
          maxMessageId: 100,
          totalMessageCount: 50,
        ),
        projection: const MessageProjectionSnapshot(
          maxMessageId: 100,
          totalMessageCount: 50,
        ),
        migrateMessages: () async {
          migrationInvocationCount += 1;
          return const ShadowMessageMigrationResult(insertedMessageCount: 0);
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(messageMigrationStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(migrationInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const MessageMigrationDelta(messageIdDelta: 0, messageCountDelta: 0),
      );
      expect(
        report.preExecutionState,
        const MessageMigrationState.projectionCaughtUp(),
      );
      expect(report.decision, const MigrationDecision.doNothing());
      expect(
        report.executionOutcome,
        MessageMigrationStageExecutionOutcome.skipped,
      );
      expect(report.migrationResult, isNull);
      expect(report.postExecutionDelta, isNull);
      expect(report.postExecutionState, isNull);
      expect(report.diagnosticEvents, <String>[
        'migration reader refresh started',
        'migration delta observed: messageIdDelta=0, messageCountDelta=0',
        'migration decision observed: MigrationDecision.doNothing',
        'shadow migration skipped: decision doNothing',
      ]);
    });

    test('reports projection-ahead path as blocked without execution', () async {
      var migrationInvocationCount = 0;
      final container = _container(
        ledger: const MessageProjectionSnapshot(
          maxMessageId: 100,
          totalMessageCount: 50,
        ),
        projection: const MessageProjectionSnapshot(
          maxMessageId: 105,
          totalMessageCount: 55,
        ),
        migrateMessages: () async {
          migrationInvocationCount += 1;
          return const ShadowMessageMigrationResult(insertedMessageCount: 0);
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(messageMigrationStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(migrationInvocationCount, 0);
      expect(
        report.preExecutionDelta,
        const MessageMigrationDelta(messageIdDelta: -5, messageCountDelta: -5),
      );
      expect(
        report.preExecutionState,
        const MessageMigrationState.projectionAheadOfLedger(),
      );
      expect(
        report.decision,
        const MigrationDecision.blockAndReportProjectionAhead(),
      );
      expect(
        report.executionOutcome,
        MessageMigrationStageExecutionOutcome.blocked,
      );
      expect(report.migrationResult, isNull);
      expect(report.diagnosticEvents, <String>[
        'migration reader refresh started',
        'migration delta observed: messageIdDelta=-5, messageCountDelta=-5',
        'migration decision observed: MigrationDecision.blockAndReportProjectionAhead',
        'shadow migration skipped: decision blockAndReportProjectionAhead',
      ]);
    });

    test('reports execution and post-execution convergence', () async {
      var projection = const MessageProjectionSnapshot(
        maxMessageId: 100,
        totalMessageCount: 50,
      );
      var ledgerReadCount = 0;
      var projectionReadCount = 0;
      var migrationInvocationCount = 0;
      final container = _container(
        ledger: const MessageProjectionSnapshot(
          maxMessageId: 103,
          totalMessageCount: 53,
        ),
        projection: () => projection,
        onLedgerRead: () {
          ledgerReadCount += 1;
        },
        onProjectionRead: () {
          projectionReadCount += 1;
        },
        migrateMessages: () async {
          migrationInvocationCount += 1;
          projection = const MessageProjectionSnapshot(
            maxMessageId: 103,
            totalMessageCount: 53,
          );
          return const ShadowMessageMigrationResult(insertedMessageCount: 3);
        },
      );
      addTearDown(container.dispose);

      final report = await container
          .read(messageMigrationStageControllerProvider)
          .refreshAndMaybeExecute();

      expect(migrationInvocationCount, 1);
      expect(ledgerReadCount, greaterThanOrEqualTo(2));
      expect(projectionReadCount, greaterThanOrEqualTo(2));
      expect(
        report.preExecutionDelta,
        const MessageMigrationDelta(messageIdDelta: 3, messageCountDelta: 3),
      );
      expect(
        report.preExecutionState,
        const MessageMigrationState.ledgerAheadOfProjection(),
      );
      expect(
        report.decision,
        const MigrationDecision.considerShadowMigration(),
      );
      expect(
        report.executionOutcome,
        MessageMigrationStageExecutionOutcome.executed,
      );
      expect(report.migrationResult?.insertedMessageCount, 3);
      expect(
        report.postExecutionDelta,
        const MessageMigrationDelta(messageIdDelta: 0, messageCountDelta: 0),
      );
      expect(
        report.postExecutionState,
        const MessageMigrationState.projectionCaughtUp(),
      );
      expect(report.diagnosticEvents, <String>[
        'migration reader refresh started',
        'migration delta observed: messageIdDelta=3, messageCountDelta=3',
        'migration decision observed: MigrationDecision.considerShadowMigration',
        'shadow migration executed: insertedMessageCount=3',
      ]);
    });
  });
}

ProviderContainer _container({
  required Object ledger,
  required Object projection,
  required Future<ShadowMessageMigrationResult> Function() migrateMessages,
  VoidCallback? onLedgerRead,
  VoidCallback? onProjectionRead,
}) {
  MessageProjectionSnapshot readLedger() {
    final value = ledger;
    if (value is MessageProjectionSnapshot Function()) {
      return value();
    }
    return value as MessageProjectionSnapshot;
  }

  MessageProjectionSnapshot readProjection() {
    final value = projection;
    if (value is MessageProjectionSnapshot Function()) {
      return value();
    }
    return value as MessageProjectionSnapshot;
  }

  return ProviderContainer(
    overrides: <Override>[
      shadowImportProjectionSnapshotProvider.overrideWith((ref) async {
        onLedgerRead?.call();
        return readLedger();
      }),
      shadowWorkingProjectionSnapshotProvider.overrideWith((ref) async {
        onProjectionRead?.call();
        return readProjection();
      }),
      shadowMigrationExecutionOrchestratorProvider.overrideWith(
        (ref) async =>
            ShadowMigrationExecutionOrchestrator.withMigrationCallback(
              migrateMessages: migrateMessages,
            ),
      ),
    ],
  );
}
