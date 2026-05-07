import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart';

void main() {
  group('resolveStartupProbeDecision', () {
    test(
      'max rowid equal but imported count lower schedules incremental work',
      () {
        final decision = resolveStartupProbeDecision(
          liveMaxRowId: 135533,
          importedMaxSourceRowId: 135533,
          liveImportableMessageCount: 119351,
          importedMessageCount: 109742,
        );

        expect(decision.shouldSchedule, isTrue);
        expect(decision.trigger, StartupProbeTrigger.ledgerCountLagging);
        expect(
          decision.reason,
          'live importable message count exceeds imported message count',
        );
      },
    );

    test('max rowid equal and counts equal schedules no work', () {
      final decision = resolveStartupProbeDecision(
        liveMaxRowId: 135533,
        importedMaxSourceRowId: 135533,
        liveImportableMessageCount: 119351,
        importedMessageCount: 119351,
      );

      expect(decision.shouldSchedule, isFalse);
      expect(decision.trigger, isNull);
      expect(
        decision.reason,
        'ledger cursor and importable message count are current',
      );
    });

    test('max rowid greater schedules incremental work', () {
      final decision = resolveStartupProbeDecision(
        liveMaxRowId: 135534,
        importedMaxSourceRowId: 135533,
        liveImportableMessageCount: 119352,
        importedMessageCount: 119351,
      );

      expect(decision.shouldSchedule, isTrue);
      expect(decision.trigger, StartupProbeTrigger.rowIdAdvanced);
      expect(
        decision.reason,
        'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
      );
    });
  });

  group('shouldAllowAutomaticIncrementalWork', () {
    test(
      'blocks automatic import and migration when projection is not ready',
      () {
        expect(
          shouldAllowAutomaticIncrementalWork(workingProjectionReady: false),
          isFalse,
        );
      },
    );

    test(
      'preserves automatic import and migration when projection is ready',
      () {
        expect(
          shouldAllowAutomaticIncrementalWork(workingProjectionReady: true),
          isTrue,
        );
      },
    );
  });

  group('gateStartupProbeDecisionForProjectionReadiness', () {
    test(
      'suppresses startup import and migration when projection is not ready',
      () {
        const wouldSchedule = StartupProbeDecision(
          shouldSchedule: true,
          trigger: StartupProbeTrigger.rowIdAdvanced,
          reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
        );

        final gated = gateStartupProbeDecisionForProjectionReadiness(
          decision: wouldSchedule,
          workingProjectionReady: false,
        );

        expect(gated.shouldSchedule, isFalse);
        expect(gated.trigger, isNull);
        expect(
          gated.reason,
          'working projection is not ready; skipping automatic incremental import/migration',
        );
      },
    );

    test('preserves startup import and migration when projection is ready', () {
      const wouldSchedule = StartupProbeDecision(
        shouldSchedule: true,
        trigger: StartupProbeTrigger.rowIdAdvanced,
        reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
      );

      final gated = gateStartupProbeDecisionForProjectionReadiness(
        decision: wouldSchedule,
        workingProjectionReady: true,
      );

      expect(gated.shouldSchedule, isTrue);
      expect(gated.trigger, StartupProbeTrigger.rowIdAdvanced);
    });
  });
}
