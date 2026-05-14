import '../../../domain/models/legacy_incremental_update_snapshot.dart';
import '../../../domain/models/message_migration_delta.dart';
import '../../../domain/sealed_unions/comparison_outcome.dart';
import '../../../domain/sealed_unions/import_decision.dart';
import '../../../domain/sealed_unions/migration_decision.dart';

class IncrementalUpdateComparisonReport {
  const IncrementalUpdateComparisonReport({
    required this.importComparison,
    required this.migrationComparison,
  });

  final ComparisonOutcome importComparison;
  final ComparisonOutcome migrationComparison;
}

class IncrementalUpdateComparisonIntegrator {
  const IncrementalUpdateComparisonIntegrator();

  IncrementalUpdateComparisonReport integrate({
    required LegacyIncrementalUpdateSnapshot legacy,
    required ImportDecision shadowImportDecision,
    required MigrationDecision shadowMigrationDecision,
    required MessageMigrationDelta shadowMigrationDelta,
  }) {
    return IncrementalUpdateComparisonReport(
      importComparison: _compareImport(
        legacy: legacy,
        shadow: shadowImportDecision,
      ),
      migrationComparison: _compareMigration(
        legacy: legacy,
        shadow: shadowMigrationDecision,
        shadowDelta: shadowMigrationDelta,
      ),
    );
  }

  ComparisonOutcome _compareImport({
    required LegacyIncrementalUpdateSnapshot legacy,
    required ImportDecision shadow,
  }) {
    final legacyMeaning = legacy.importProbeDecision.shouldSchedule
        ? 'incremental import required'
        : 'incremental import not required';
    final shadowMeaning = switch (shadow) {
      ImportDecisionDoNothing() => 'incremental import not required',
      ImportDecisionConsiderIncrementalImport() =>
        'incremental import required',
      ImportDecisionBlockAndReportLedgerAhead() => 'import blocked',
    };

    if (legacy.importedMaxSourceRowId == null) {
      return ComparisonOutcome.notComparable(
        legacy: legacyMeaning,
        shadow: shadowMeaning,
        reason: legacy.importProbeDecision.reason,
      );
    }

    if (legacyMeaning == shadowMeaning) {
      return ComparisonOutcome.match(
        legacy: legacyMeaning,
        shadow: shadowMeaning,
      );
    }

    return ComparisonOutcome.mismatch(
      legacy: legacyMeaning,
      shadow: shadowMeaning,
      reason:
          'legacyReason=${legacy.importProbeDecision.reason}; '
          'liveMaxRowId=${legacy.liveMaxRowId}; '
          'importedMaxSourceRowId=${legacy.importedMaxSourceRowId}; '
          'liveImportableMessageCount=${legacy.liveImportableMessageCount}; '
          'importedMessageCount=${legacy.importedMessageCount}',
    );
  }

  ComparisonOutcome _compareMigration({
    required LegacyIncrementalUpdateSnapshot legacy,
    required MigrationDecision shadow,
    required MessageMigrationDelta shadowDelta,
  }) {
    final legacyMeaning = _legacyMigrationMeaning(legacy);
    final shadowMeaning = switch (shadow) {
      MigrationDecisionDoNothing() => 'projection current',
      MigrationDecisionConsiderShadowMigration() => 'migration required',
      MigrationDecisionBlockAndReportProjectionAhead() => 'migration blocked',
    };

    if (legacyMeaning == shadowMeaning) {
      return ComparisonOutcome.match(
        legacy: legacyMeaning,
        shadow: shadowMeaning,
      );
    }

    final phaseSkewReason = _detectMigrationPhaseSkew(
      legacy: legacy,
      legacyMeaning: legacyMeaning,
      shadowMeaning: shadowMeaning,
      shadowDelta: shadowDelta,
    );
    if (phaseSkewReason != null) {
      return ComparisonOutcome.phaseSkew(
        legacy: legacyMeaning,
        shadow: shadowMeaning,
        reason: phaseSkewReason,
      );
    }

    return ComparisonOutcome.mismatch(
      legacy: legacyMeaning,
      shadow: shadowMeaning,
      reason:
          'productionImportMaxMessageId=${legacy.productionImportMaxMessageId}; '
          'productionWorkingMaxMessageId=${legacy.productionWorkingMaxMessageId}; '
          'productionImportMessageCount=${legacy.productionImportMessageCount}; '
          'productionWorkingMessageCount=${legacy.productionWorkingMessageCount}',
    );
  }

  String? _detectMigrationPhaseSkew({
    required LegacyIncrementalUpdateSnapshot legacy,
    required String legacyMeaning,
    required String shadowMeaning,
    required MessageMigrationDelta shadowDelta,
  }) {
    final productionProjectionLag =
        legacy.productionImportMaxMessageId -
        legacy.productionWorkingMaxMessageId;
    final shadowProjectionLag = shadowDelta.messageIdDelta;

    if (productionProjectionLag > 0 && shadowMeaning == 'projection current') {
      return 'production projection lagging import by '
          '$productionProjectionLag message(s); shadow projection already caught up';
    }

    if (shadowProjectionLag > 0 && legacyMeaning == 'projection current') {
      return 'shadow projection lagging import by '
          '$shadowProjectionLag message(s); production projection already caught up';
    }

    if (productionProjectionLag > 0 && shadowProjectionLag <= 0) {
      return 'production projection catching up asynchronously';
    }

    if (shadowProjectionLag > 0 && productionProjectionLag <= 0) {
      return 'shadow projection catching up asynchronously';
    }

    return null;
  }

  String _legacyMigrationMeaning(LegacyIncrementalUpdateSnapshot legacy) {
    if (legacy.productionImportMaxMessageId >
        legacy.productionWorkingMaxMessageId) {
      return 'migration required';
    }
    if (legacy.productionImportMaxMessageId <
        legacy.productionWorkingMaxMessageId) {
      return 'migration blocked';
    }
    return 'projection current';
  }
}
