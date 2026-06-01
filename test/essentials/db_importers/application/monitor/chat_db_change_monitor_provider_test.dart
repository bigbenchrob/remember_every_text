import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/orchestrators/conversation_graph_build_orchestrator.dart';
import 'package:remember_this_text/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';

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
      'blocks automatic import and migration when app data is not ready',
      () {
        expect(
          shouldAllowAutomaticIncrementalWork(appDataReady: false),
          isFalse,
        );
      },
    );

    test('preserves automatic import and migration when app data is ready', () {
      expect(shouldAllowAutomaticIncrementalWork(appDataReady: true), isTrue);
    });
  });

  group('shouldRestoreCursorAfterIncrementalGraphUpdate', () {
    test('does not restore cursor when graph update succeeds', () {
      expect(
        shouldRestoreCursorAfterIncrementalGraphUpdate(
          importSucceeded: true,
          graphBuildSucceeded: true,
          legacyMigrationSucceeded: true,
        ),
        isFalse,
      );
    });

    test(
      'does not treat legacy migration failure as app-facing graph failure',
      () {
        expect(
          shouldRestoreCursorAfterIncrementalGraphUpdate(
            importSucceeded: true,
            graphBuildSucceeded: true,
            legacyMigrationSucceeded: false,
          ),
          isFalse,
        );
      },
    );

    test('restores cursor when import or graph build fails', () {
      expect(
        shouldRestoreCursorAfterIncrementalGraphUpdate(
          importSucceeded: false,
          graphBuildSucceeded: false,
          legacyMigrationSucceeded: false,
        ),
        isTrue,
      );
      expect(
        shouldRestoreCursorAfterIncrementalGraphUpdate(
          importSucceeded: true,
          graphBuildSucceeded: false,
          legacyMigrationSucceeded: true,
        ),
        isTrue,
      );
    });
  });

  group('gateStartupProbeDecisionForAppDataReadiness', () {
    test(
      'suppresses startup import and migration when app data is not ready',
      () {
        const wouldSchedule = StartupProbeDecision(
          shouldSchedule: true,
          trigger: StartupProbeTrigger.rowIdAdvanced,
          reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
        );

        final gated = gateStartupProbeDecisionForAppDataReadiness(
          decision: wouldSchedule,
          appDataReady: false,
        );

        expect(gated.shouldSchedule, isFalse);
        expect(gated.trigger, isNull);
        expect(
          gated.reason,
          'app data graph is not ready; skipping automatic incremental import/migration',
        );
      },
    );

    test('preserves startup import and migration when projection is ready', () {
      const wouldSchedule = StartupProbeDecision(
        shouldSchedule: true,
        trigger: StartupProbeTrigger.rowIdAdvanced,
        reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
      );

      final gated = gateStartupProbeDecisionForAppDataReadiness(
        decision: wouldSchedule,
        appDataReady: true,
      );

      expect(gated.shouldSchedule, isTrue);
      expect(gated.trigger, StartupProbeTrigger.rowIdAdvanced);
    });
  });

  group('buildConversationGraphBuildSummaryLog', () {
    test('summarizes graph import enrichment and projection counts', () {
      final report = ConversationGraphBuildReport(
        startedAt: DateTime.utc(2026, 5, 30, 12, 0),
        finishedAt: DateTime.utc(2026, 5, 30, 12, 0, 2),
        completedStageNames: const <String>[
          'import_messages',
          'enrich_missing_text',
          'project_messages',
        ],
        messageImportResult: const MessageImportResult(
          startedAfterSourceRowId: 100,
          insertedMessageCount: 2,
          lastImportedSourceRowId: 102,
        ),
        richTextEnrichmentResult: const MessageRichTextEnrichmentResult(
          candidateMessageCount: 3,
          enrichedMessageCount: 1,
          missingExtractionCount: 2,
          extractorAvailable: true,
        ),
        messageProjectionResult: const MessageProjectionResult(
          examinedMessageCount: 4,
          insertedMessageCount: 2,
        ),
      );

      final summary = buildConversationGraphBuildSummaryLog(report: report);

      expect(summary, contains('completed in 2000ms'));
      expect(summary, contains('3 stage(s)'));
      expect(summary, contains('2 imported graph message(s)'));
      expect(summary, contains('1 enriched text row(s)'));
      expect(summary, contains('2 projected graph message row(s)'));
    });
  });
}
