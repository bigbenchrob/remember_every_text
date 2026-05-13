import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/migration_decision.dart';
import '../executors/shadow_message_migration_executor.dart';

class ShadowMigrationExecutionOrchestrator {
  ShadowMigrationExecutionOrchestrator({
    required ShadowMessageMigrationExecutor executor,
  }) : _migrateMessages = executor.migrateMessages;

  @visibleForTesting
  ShadowMigrationExecutionOrchestrator.withMigrationCallback({
    required Future<ShadowMessageMigrationResult> Function() migrateMessages,
  }) : _migrateMessages = migrateMessages;

  final Future<ShadowMessageMigrationResult> Function() _migrateMessages;
  bool _executionInFlight = false;

  Future<ShadowMessageMigrationResult?> runForDecision(
    MigrationDecision decision,
  ) async {
    return switch (decision) {
      MigrationDecisionDoNothing() => null,
      MigrationDecisionBlockAndReportProjectionAhead() => null,
      MigrationDecisionConsiderShadowMigration() => _runShadowMigration(),
    };
  }

  Future<ShadowMessageMigrationResult?> _runShadowMigration() async {
    if (_executionInFlight) {
      debugPrint('Shadow message migration skipped: execution in flight.');
      return null;
    }

    _executionInFlight = true;
    try {
      return await _migrateMessages();
    } finally {
      _executionInFlight = false;
    }
  }
}
