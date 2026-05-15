import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/incremental_update_comparison_integrator.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/legacy_incremental_update_snapshot.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_migration_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/comparison_outcome.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/migration_decision.dart';

void main() {
  const integrator = IncrementalUpdateComparisonIntegrator();
  const noImportDelta = MessageSnapshotDelta(
    rowIdDelta: 0,
    messageCountDelta: 0,
  );

  group('IncrementalUpdateComparisonIntegrator', () {
    test('classifies import-not-required agreement as match', () {
      final report = integrator.integrate(
        legacy: _legacySnapshot(),
        shadowImportDecision: const ImportDecision.doNothing(),
        shadowImportDelta: noImportDelta,
        shadowMigrationDecision: const MigrationDecision.doNothing(),
        shadowMigrationDelta: const MessageMigrationDelta(
          messageIdDelta: 0,
          messageCountDelta: 0,
        ),
      );

      expect(
        report.importComparison,
        const ComparisonOutcome.match(
          legacy: 'incremental import not required',
          shadow: 'incremental import not required',
        ),
      );
    });

    test('classifies import-required agreement as match', () {
      final report = integrator.integrate(
        legacy: _legacySnapshot(
          importProbeDecision: const LegacyImportProbeDecision(
            shouldSchedule: true,
            reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
          ),
          liveMaxRowId: 101,
          importedMaxSourceRowId: 100,
        ),
        shadowImportDecision: const ImportDecision.considerIncrementalImport(),
        shadowImportDelta: const MessageSnapshotDelta(
          rowIdDelta: 1,
          messageCountDelta: 1,
        ),
        shadowMigrationDecision: const MigrationDecision.doNothing(),
        shadowMigrationDelta: const MessageMigrationDelta(
          messageIdDelta: 0,
          messageCountDelta: 0,
        ),
      );

      expect(
        report.importComparison,
        const ComparisonOutcome.match(
          legacy: 'incremental import required',
          shadow: 'incremental import required',
        ),
      );
    });

    test('classifies projection-current agreement as match', () {
      final report = integrator.integrate(
        legacy: _legacySnapshot(
          productionImportMaxMessageId: 100,
          productionWorkingMaxMessageId: 100,
        ),
        shadowImportDecision: const ImportDecision.doNothing(),
        shadowImportDelta: noImportDelta,
        shadowMigrationDecision: const MigrationDecision.doNothing(),
        shadowMigrationDelta: const MessageMigrationDelta(
          messageIdDelta: 0,
          messageCountDelta: 0,
        ),
      );

      expect(
        report.migrationComparison,
        const ComparisonOutcome.match(
          legacy: 'projection current',
          shadow: 'projection current',
        ),
      );
    });

    test(
      'classifies shadow projection lag while production is current as phase skew',
      () {
        final report = integrator.integrate(
          legacy: _legacySnapshot(
            productionImportMaxMessageId: 100,
            productionWorkingMaxMessageId: 100,
          ),
          shadowImportDecision: const ImportDecision.doNothing(),
          shadowImportDelta: noImportDelta,
          shadowMigrationDecision:
              const MigrationDecision.considerShadowMigration(),
          shadowMigrationDelta: const MessageMigrationDelta(
            messageIdDelta: 1,
            messageCountDelta: 1,
          ),
        );

        final outcome =
            report.migrationComparison as ComparisonOutcomePhaseSkew;

        expect(outcome.legacy, 'projection current');
        expect(outcome.shadow, 'migration required');
        expect(
          outcome.reason,
          contains('shadow projection lagging import by 1'),
        );
        expect(
          outcome.reason,
          contains('production projection already caught up'),
        );
      },
    );

    test(
      'classifies production projection lag while shadow is current as phase skew',
      () {
        final report = integrator.integrate(
          legacy: _legacySnapshot(
            productionImportMaxMessageId: 101,
            productionWorkingMaxMessageId: 100,
            productionImportMessageCount: 101,
            productionWorkingMessageCount: 100,
          ),
          shadowImportDecision: const ImportDecision.doNothing(),
          shadowImportDelta: noImportDelta,
          shadowMigrationDecision: const MigrationDecision.doNothing(),
          shadowMigrationDelta: const MessageMigrationDelta(
            messageIdDelta: 0,
            messageCountDelta: 0,
          ),
        );

        final outcome =
            report.migrationComparison as ComparisonOutcomePhaseSkew;

        expect(outcome.legacy, 'migration required');
        expect(outcome.shadow, 'projection current');
        expect(
          outcome.reason,
          contains('production projection lagging import by 1'),
        );
        expect(outcome.reason, contains('shadow projection already caught up'));
      },
    );

    test(
      'classifies import disagreement without phase explanation as mismatch',
      () {
        final report = integrator.integrate(
          legacy: _legacySnapshot(),
          shadowImportDecision:
              const ImportDecision.considerIncrementalImport(),
          shadowImportDelta: noImportDelta,
          shadowMigrationDecision: const MigrationDecision.doNothing(),
          shadowMigrationDelta: const MessageMigrationDelta(
            messageIdDelta: 0,
            messageCountDelta: 0,
          ),
        );

        final outcome = report.importComparison as ComparisonOutcomeMismatch;

        expect(outcome.legacy, 'incremental import not required');
        expect(outcome.shadow, 'incremental import required');
        expect(outcome.reason, contains('legacyReason='));
        expect(outcome.reason, contains('liveMaxRowId=100'));
      },
    );

    test(
      'classifies shadow import lag while production ledger is current as phase skew',
      () {
        final report = integrator.integrate(
          legacy: _legacySnapshot(
            liveMaxRowId: 135989,
            importedMaxSourceRowId: 135989,
            importProbeDecision: const LegacyImportProbeDecision(
              shouldSchedule: false,
              reason: 'ledger cursor and importable message count are current',
            ),
          ),
          shadowImportDecision:
              const ImportDecision.considerIncrementalImport(),
          shadowImportDelta: const MessageSnapshotDelta(
            rowIdDelta: 2,
            messageCountDelta: 2,
          ),
          shadowMigrationDecision: const MigrationDecision.doNothing(),
          shadowMigrationDelta: const MessageMigrationDelta(
            messageIdDelta: 0,
            messageCountDelta: 0,
          ),
        );

        final outcome = report.importComparison as ComparisonOutcomePhaseSkew;

        expect(outcome.legacy, 'incremental import not required');
        expect(outcome.shadow, 'incremental import required');
        expect(
          outcome.reason,
          contains('shadow ledger lagging live source by 2'),
        );
        expect(outcome.reason, contains('production ledger already caught up'));
      },
    );

    test(
      'classifies production import lag while shadow ledger is current as phase skew',
      () {
        final report = integrator.integrate(
          legacy: _legacySnapshot(
            importProbeDecision: const LegacyImportProbeDecision(
              shouldSchedule: true,
              reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
            ),
            liveMaxRowId: 102,
            importedMaxSourceRowId: 100,
          ),
          shadowImportDecision: const ImportDecision.doNothing(),
          shadowImportDelta: noImportDelta,
          shadowMigrationDecision: const MigrationDecision.doNothing(),
          shadowMigrationDelta: const MessageMigrationDelta(
            messageIdDelta: 0,
            messageCountDelta: 0,
          ),
        );

        final outcome = report.importComparison as ComparisonOutcomePhaseSkew;

        expect(outcome.legacy, 'incremental import required');
        expect(outcome.shadow, 'incremental import not required');
        expect(
          outcome.reason,
          contains('production ledger lagging live source by 2'),
        );
        expect(outcome.reason, contains('shadow ledger already caught up'));
      },
    );

    test(
      'classifies projection disagreement without explainable lag as mismatch',
      () {
        final report = integrator.integrate(
          legacy: _legacySnapshot(
            productionImportMaxMessageId: 100,
            productionWorkingMaxMessageId: 100,
          ),
          shadowImportDecision: const ImportDecision.doNothing(),
          shadowImportDelta: noImportDelta,
          shadowMigrationDecision:
              const MigrationDecision.considerShadowMigration(),
          shadowMigrationDelta: const MessageMigrationDelta(
            messageIdDelta: 0,
            messageCountDelta: 0,
          ),
        );

        final outcome = report.migrationComparison as ComparisonOutcomeMismatch;

        expect(outcome.legacy, 'projection current');
        expect(outcome.shadow, 'migration required');
        expect(outcome.reason, contains('productionImportMaxMessageId=100'));
        expect(outcome.reason, contains('productionWorkingMaxMessageId=100'));
      },
    );

    test('classifies missing production import cursor as not comparable', () {
      final report = integrator.integrate(
        legacy: _legacySnapshot(
          importedMaxSourceRowId: null,
          importProbeDecision: const LegacyImportProbeDecision(
            shouldSchedule: false,
            reason: 'no imported cursor available',
          ),
        ),
        shadowImportDecision: const ImportDecision.doNothing(),
        shadowImportDelta: noImportDelta,
        shadowMigrationDecision: const MigrationDecision.doNothing(),
        shadowMigrationDelta: const MessageMigrationDelta(
          messageIdDelta: 0,
          messageCountDelta: 0,
        ),
      );

      final outcome = report.importComparison as ComparisonOutcomeNotComparable;

      expect(outcome.legacy, 'incremental import not required');
      expect(outcome.shadow, 'incremental import not required');
      expect(outcome.reason, 'no imported cursor available');
    });
  });
}

LegacyIncrementalUpdateSnapshot _legacySnapshot({
  int liveMaxRowId = 100,
  int? importedMaxSourceRowId = 100,
  int liveImportableMessageCount = 100,
  int importedMessageCount = 100,
  LegacyImportProbeDecision importProbeDecision =
      const LegacyImportProbeDecision(
        shouldSchedule: false,
        reason: 'ledger cursor and importable message count are current',
      ),
  int productionImportMaxMessageId = 100,
  int productionWorkingMaxMessageId = 100,
  int productionImportMessageCount = 100,
  int productionWorkingMessageCount = 100,
}) {
  return LegacyIncrementalUpdateSnapshot(
    liveMaxRowId: liveMaxRowId,
    importedMaxSourceRowId: importedMaxSourceRowId,
    liveImportableMessageCount: liveImportableMessageCount,
    importedMessageCount: importedMessageCount,
    importProbeDecision: importProbeDecision,
    productionImportMaxMessageId: productionImportMaxMessageId,
    productionWorkingMaxMessageId: productionWorkingMaxMessageId,
    productionImportMessageCount: productionImportMessageCount,
    productionWorkingMessageCount: productionWorkingMessageCount,
  );
}
