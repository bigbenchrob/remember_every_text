import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/settings/presentation/view/historical_archives_panel.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart';

void main() {
  group('HistoricalArchivesPanel', () {
    testWidgets('renders execution gate, preflight-ready, dry run, and log state', (
      tester,
    ) async {
      const model = HistoricalArchivesWorkflowPanelViewModel(
        statusLabel: 'Ready For Import',
        summaryText:
            'A previously selected archive has completed preflight and is ready for canonical import.',
        executionGate: HistoricalArchivesExecutionGateViewModel(
          status: HistoricalArchivesExecutionGateStatus.available,
          statusLabel: 'Available',
          detail: 'No other operation currently owns the execution gate.',
        ),
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.completeReadyToImport,
          statusLabel: 'Preflight complete — ready to import',
          detail:
              'Source checks succeeded, dry-run estimates are available, and the import action can proceed.',
        ),
        selectedFolderPath: '/Users/rob/Library/Messages/Archive-2017/messages',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Found and readable',
        sourceLabel: 'archive-2017-macbook',
        preflightSummaryLines: [
          'Total messages: 8,882',
          'Total chats: 142',
          'Total handles: 311',
        ],
        dryRunSummaryLines: [
          'Estimated new messages: 8,120',
          'Estimated duplicates: 762',
        ],
        importButtonEnabled: true,
        importButtonDetail:
            'Preflight is complete and the execution gate is available.',
        archiveRemovalTargetChatDbPath:
            '/Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        matchedImportedArchiveBatchCount: 2,
        archiveManagementSummaryLines: [
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          'Matched imported archive batches in db-import: 2',
        ],
        removeImportedArchiveDataEnabled: true,
        removeImportedArchiveDataDetail:
            'Removing imported archive data will delete 2 matched batches for this selected source from db-import, then rebuild the app timeline.',
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Reading archive…',
            message: 'chat.db and Attachments metadata were read successfully.',
          ),
          HistoricalArchivesLogEntryViewModel(
            label: 'Migration started…',
            message:
                'Canonical migration has been requested and is awaiting execution ownership.',
          ),
        ],
        resultSummaryLines: ['The previous import completed successfully.'],
        phases: [
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Reading archive source',
            status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
            detail: 'Archive source metadata was read successfully.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Normalizing records into canonical ledger format',
            status: HistoricalArchivesWorkflowPhaseStatus.running,
            detail: 'Normalization is in progress.',
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowPanelModelProvider.overrideWith(
            (ref) => model,
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CupertinoApp(home: HistoricalArchivesPanel()),
        ),
      );
      await tester.pump();

      expect(find.text('Execution Gate'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Preflight complete — ready to import'), findsWidgets);
      expect(find.text('Dry Run Summary'), findsOneWidget);
      expect(find.text('Estimated new messages: 8,120'), findsOneWidget);
      expect(find.text('Estimated duplicates: 762'), findsOneWidget);
      expect(find.text('Clear Selected Folder'), findsOneWidget);
      expect(
        find.text('Clear Imported Archive Data for This Source'),
        findsOneWidget,
      );
      expect(
        find.text(
          'This only clears the currently selected folder from the workflow UI. It does not delete imported archive records or reset MessageLens data.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Developer/testing only. This deletes previously imported archive records from MessageLens for the selected archive source, then rebuilds the app timeline.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Matched imported archive batches in db-import: 2'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Removing imported archive data will delete 2 matched batches for this selected source from db-import, then rebuild the app timeline.',
        ),
        findsOneWidget,
      );
      expect(find.text('Activity Log'), findsOneWidget);
      expect(find.text('Reading archive…'), findsOneWidget);
      expect(find.text('Migration started…'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog before removing imported archive data', (
      tester,
    ) async {
      const model = HistoricalArchivesWorkflowPanelViewModel(
        statusLabel: 'Ready For Import',
        summaryText: 'Archive testing controls are available.',
        executionGate: HistoricalArchivesExecutionGateViewModel(
          status: HistoricalArchivesExecutionGateStatus.available,
          statusLabel: 'Available',
          detail: 'No other operation currently owns the execution gate.',
        ),
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.completeReadyToImport,
          statusLabel: 'Preflight complete',
          detail: 'Source checks succeeded.',
        ),
        selectedFolderPath: '/Users/rob/Library/Messages/Archive-2017/messages',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Found and readable',
        sourceLabel: 'archive-2017-macbook',
        preflightSummaryLines: ['Total messages: 8,882'],
        dryRunSummaryLines: ['Estimated new messages: 8,120'],
        importButtonEnabled: false,
        importButtonDetail: 'Disabled in this shell.',
        archiveRemovalTargetChatDbPath:
            '/Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        matchedImportedArchiveBatchCount: 2,
        archiveManagementSummaryLines: [
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          'Matched imported archive batches in db-import: 2',
        ],
        removeImportedArchiveDataEnabled: true,
        removeImportedArchiveDataDetail:
            'Removing imported archive data will delete 2 matched batches for this selected source from db-import, then rebuild the app timeline.',
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Ready',
            message: 'Awaiting confirmation.',
          ),
        ],
        resultSummaryLines: ['No archive import has run yet.'],
        phases: [
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Reading archive source',
            status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
            detail: 'Archive source metadata was read successfully.',
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowPanelModelProvider.overrideWith(
            (ref) => model,
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CupertinoApp(home: HistoricalArchivesPanel()),
        ),
      );
      await tester.pump();

      final clearImportedArchiveDataButton = find.text(
        'Clear Imported Archive Data for This Source',
      );
      await tester.ensureVisible(clearImportedArchiveDataButton);
      await tester.tap(clearImportedArchiveDataButton);
      await tester.pumpAndSettle();

      final confirmationDialog = find.byType(CupertinoAlertDialog);

      expect(find.text('Remove Imported Archive Data?'), findsOneWidget);
      expect(
        find.descendant(
          of: confirmationDialog,
          matching: find.textContaining(
            'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: confirmationDialog,
          matching: find.textContaining(
            'Matched imported archive batches in db-import: 2',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Remove Imported Archive Data'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
