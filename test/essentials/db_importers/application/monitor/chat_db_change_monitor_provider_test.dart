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
}
