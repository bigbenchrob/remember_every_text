import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/historical_archives_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content.dart';

void main() {
  group('HistoricalArchivesSettingsSupplementalContent', () {
    testWidgets('renders known source last-run details', (tester) async {
      const payload = HistoricalArchivesSettingsCassettePayload(
        knownSources: [
          HistoricalArchiveSidebarSourceSummary(
            label: 'Jan 2017 MacBook Archive',
            dateRangeLabel: 'Range: Jan 2014 -> Nov 2017',
            messageCountLabel: 'Source messages: 8,882',
            statusLabel: 'Last result: Succeeded',
            lastRunSummaryLabel: 'Last run counts: 8,120 new, 762 duplicates',
            lastImportedLabel: 'Last imported: Apr 29, 2026 at 11:42 AM',
          ),
        ],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: payload,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Known Archive Sources'), findsOneWidget);
      expect(find.text('Jan 2017 MacBook Archive'), findsOneWidget);
      expect(find.text('Range: Jan 2014 -> Nov 2017'), findsOneWidget);
      expect(find.text('Source messages: 8,882'), findsOneWidget);
      expect(find.text('Last result: Succeeded'), findsOneWidget);
      expect(
        find.text('Last run counts: 8,120 new, 762 duplicates'),
        findsOneWidget,
      );
      expect(
        find.text('Last imported: Apr 29, 2026 at 11:42 AM'),
        findsOneWidget,
      );
    });

    testWidgets('tapping add archive folder triggers workflow chooser', (
      tester,
    ) async {
      final workflow = _TestHistoricalArchivesWorkflow();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(() => workflow),
          ],
          child: const CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Add an Archive Folder'));
      await tester.pump();

      expect(workflow.chooseMessagesFolderCallCount, 1);
    });
  });
}

class _TestHistoricalArchivesWorkflow extends HistoricalArchivesWorkflow {
  int chooseMessagesFolderCallCount = 0;

  @override
  HistoricalArchivesWorkflowState build() {
    return buildInitialHistoricalArchivesWorkflowState();
  }

  @override
  Future<void> chooseMessagesFolder() async {
    chooseMessagesFolderCallCount += 1;
  }
}
