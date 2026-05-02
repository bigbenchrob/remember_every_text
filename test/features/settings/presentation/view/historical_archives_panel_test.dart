import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/features/settings/presentation/view/historical_archives_panel.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart';

void main() {
  group('HistoricalArchivesPanel', () {
    testWidgets('shows a calm empty state before any folder is selected', (
      tester,
    ) async {
      const model = HistoricalArchivesWorkflowPanelViewModel(
        statusLabel: 'No archive selected',
        summaryText:
            'Historical archive import is available when a folder is selected.',
        executionGate: HistoricalArchivesExecutionGateViewModel(
          status: HistoricalArchivesExecutionGateStatus.available,
          statusLabel: 'Available',
          detail: 'No other operation currently owns the execution gate.',
        ),
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.waitingForFolder,
          statusLabel: 'Waiting for folder selection',
          detail:
              'Choose an older Messages folder to unlock preflight checks and dry-run estimates.',
        ),
        selectedFolderPath: null,
        chatDbStatusLabel: 'Not checked yet',
        attachmentsStatusLabel: 'Not checked yet',
        sourceLabel: 'Not proposed yet',
        preflightSummaryLines: ['Total messages: waiting for folder selection'],
        dryRunSummaryLines: ['Estimated new messages: waiting for preflight'],
        importButtonEnabled: false,
        importButtonDetail:
            'Import stays disabled until a folder is selected and preflight completes.',
        archiveRemovalTargetChatDbPath: null,
        matchedImportedArchiveBatchCount: null,
        archiveManagementSummaryLines: [],
        removeImportedArchiveDataEnabled: false,
        removeImportedArchiveDataDetail:
            'Removing imported archive data is unavailable.',
        activityLog: [],
        resultSummaryLines: [],
        phases: [],
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

      expect(find.text('Import Historical Messages'), findsOneWidget);
      expect(find.text('Step 1: Choose Messages Folder'), findsOneWidget);
      expect(find.text('Step 2: Review Archive Contents'), findsOneWidget);
      expect(find.text('Step 3: Begin Import'), findsOneWidget);
      expect(
        find.text(
          'Choose an older Messages folder. MessageLens will check what it contains before importing anything.',
        ),
        findsWidgets,
      );
      expect(
        find.text('Choose a folder to see message counts and date range.'),
        findsOneWidget,
      );
      expect(find.text('Import Preview'), findsNothing);
      expect(
        find.text('Total messages: waiting for folder selection'),
        findsNothing,
      );
      expect(
        find.text('Estimated new messages: waiting for preflight'),
        findsNothing,
      );
      expect(find.text('Details:'), findsNothing);
      expect(find.text('Activity Log'), findsNothing);
      expect(find.text('Progress'), findsNothing);
      expect(find.text('Result Summary'), findsNothing);
    });

    testWidgets('shows import preview and collapsible details after folder selection', (
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
          'Rows with missing GUIDs: 19',
          'Already in current Mac import: 762',
          'Already in historical archive imports: 0',
          'Earliest message: 2017-05-06',
          'Latest message: 2018-11-10',
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
        activityLog: [],
        resultSummaryLines: [],
        phases: [],
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

      expect(find.text('Import Preview'), findsOneWidget);
      expect(find.text('Already in current Mac data: 762'), findsOneWidget);
      expect(
        find.text('Already imported from historical archives: 0'),
        findsOneWidget,
      );
      expect(
        find.text('Will be added from this archive: 8,120'),
        findsOneWidget,
      );
      expect(find.text('Missing identifiers: 19'), findsOneWidget);
      expect(find.text('Details:'), findsOneWidget);
      expect(find.text('Total messages: 8,882'), findsNothing);
      expect(find.text('Date range: 2017-05-06 to 2018-11-10'), findsNothing);
      expect(find.text('Dry Run Summary'), findsNothing);
      expect(
        find.text(
          'When you begin, MessageLens will import this archive and then update your timeline, search, and heatmap.',
        ),
        findsOneWidget,
      );

      final detailsButton = find.widgetWithText(GestureDetector, 'Details:');
      await tester.ensureVisible(detailsButton);
      await tester.tap(detailsButton);
      await tester.pump();

      expect(find.text('Total messages: 8,882'), findsOneWidget);
      expect(find.text('Total chats: 142'), findsOneWidget);
      expect(find.text('Total handles: 311'), findsOneWidget);
      expect(find.text('Date range: 2017-05-06 to 2018-11-10'), findsOneWidget);
    });

    testWidgets('opens a blocking modal for live import progress', (
      tester,
    ) async {
      _FakeHistoricalArchivesWorkflow.cancelRequestCount = 0;
      _FakeHistoricalArchivesWorkflow.initialState =
          _readyWorkflowStateForWidgetTest();

      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowProvider.overrideWith(
            _FakeHistoricalArchivesWorkflow.new,
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

      final beginImportButton = find.widgetWithText(
        GestureDetector,
        'Begin Import',
      );
      await tester.ensureVisible(beginImportButton);
      await tester.tap(beginImportButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Importing Historical Messages'), findsOneWidget);
      expect(find.textContaining('Current step:'), findsOneWidget);
      expect(find.textContaining('Elapsed:'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.text('Completed'), findsNothing);
      expect(find.text('Waiting'), findsNothing);
      expect(find.text('Reading archive source'), findsOneWidget);
      expect(find.text('Normalizing archive rows'), findsOneWidget);
      expect(find.textContaining('Status: Running'), findsOneWidget);
      expect(find.text('Cancel Import'), findsOneWidget);
      expect(find.text('Done'), findsNothing);

      final notifier =
          container.read(historicalArchivesWorkflowProvider.notifier)
              as _FakeHistoricalArchivesWorkflow;
      notifier.completeSuccess();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Import Complete'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('New messages added: 2,369'), findsOneWidget);
      expect(find.text('Already in current Mac data: 6,513'), findsWidgets);
      expect(find.text('Already imported from archives: 0'), findsWidgets);
      expect(find.text('Missing identifiers: 0'), findsWidgets);
      expect(find.text('Date range: 2012-07-25 -> 2017-06-11'), findsOneWidget);
      expect(
        find.text('Your timeline, search, and heatmap have been updated.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Import Complete'), findsNothing);
    });

    testWidgets(
      'shows watchdog escalation actions for a stalled running step',
      (tester) async {
        var fakeNowUnixSeconds = 1700000000;
        DateConverter.overrideNowUnixSecondsForTesting(
          () => fakeNowUnixSeconds,
        );
        addTearDown(() {
          DateConverter.overrideNowUnixSecondsForTesting(null);
        });

        _FakeHistoricalArchivesWorkflow.cancelRequestCount = 0;
        _FakeHistoricalArchivesWorkflow.initialState =
            _readyWorkflowStateForWidgetTest();

        final container = ProviderContainer(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(
              _FakeHistoricalArchivesWorkflow.new,
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

        final beginImportButton = find.widgetWithText(
          GestureDetector,
          'Begin Import',
        );
        await tester.ensureVisible(beginImportButton);
        await tester.tap(beginImportButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        fakeNowUnixSeconds += const Duration(minutes: 3, seconds: 1).inSeconds;
        await tester.pump(const Duration(minutes: 3, seconds: 1));

        expect(find.textContaining('may be stuck'), findsWidgets);
        expect(find.text('Wait'), findsOneWidget);
        expect(find.text('Send Report'), findsOneWidget);
        expect(find.text('Cancel Import'), findsOneWidget);
      },
    );

    testWidgets('cancel import exits the running modal', (tester) async {
      const fakeNowUnixSeconds = 1700000000;
      DateConverter.overrideNowUnixSecondsForTesting(() => fakeNowUnixSeconds);
      addTearDown(() {
        DateConverter.overrideNowUnixSecondsForTesting(null);
      });

      _FakeHistoricalArchivesWorkflow.cancelRequestCount = 0;
      _FakeHistoricalArchivesWorkflow.initialState =
          _readyWorkflowStateForWidgetTest();

      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowProvider.overrideWith(
            _FakeHistoricalArchivesWorkflow.new,
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

      final beginImportButton = find.widgetWithText(
        GestureDetector,
        'Begin Import',
      );
      await tester.ensureVisible(beginImportButton);
      await tester.tap(beginImportButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cancel Import'), findsOneWidget);

      final cancelImportButton = find.widgetWithText(
        CupertinoButton,
        'Cancel Import',
      );
      final cancelButtonWidget = tester.widget<CupertinoButton>(
        cancelImportButton,
      );
      cancelButtonWidget.onPressed!.call();
      await tester.pumpAndSettle();

      expect(_FakeHistoricalArchivesWorkflow.cancelRequestCount, 1);
      expect(find.text('Importing Historical Messages'), findsNothing);
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

      final deleteImportedRecordsButton = find.text(
        'Delete Imported Records for This Folder',
      );
      await tester.ensureVisible(deleteImportedRecordsButton);
      await tester.tap(deleteImportedRecordsButton);
      await tester.pumpAndSettle();

      final confirmationDialog = find.byType(CupertinoAlertDialog);

      expect(find.text('Delete Imported Records?'), findsOneWidget);
      expect(
        find.descendant(
          of: confirmationDialog,
          matching: find.textContaining(
            'Folder source: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: confirmationDialog,
          matching: find.textContaining(
            'Matched imported batches in MessageLens: 2',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Delete Imported Records'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}

HistoricalArchivesWorkflowState _readyWorkflowStateForWidgetTest() {
  return buildInitialHistoricalArchivesWorkflowState().copyWith(
    preflight: const HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.completeReadyToImport,
      statusLabel: 'Preflight complete',
      detail: 'Source checks succeeded.',
    ),
    selectedFolderPath: '/tmp/Archive-2017',
    archiveRemovalTargetChatDbPath: '/tmp/Archive-2017/chat.db',
    matchedImportedArchiveBatchCount: 1,
    chatDbStatusLabel: 'Found and readable',
    attachmentsStatusLabel: 'Found',
    sourceLabel: 'Archive-2017',
    resultSummaryLines: const [
      'No archive import has run yet.',
      'User-facing success will appear only after canonical migration and required rebuild steps complete.',
    ],
  );
}

class _FakeHistoricalArchivesWorkflow extends HistoricalArchivesWorkflow {
  static HistoricalArchivesWorkflowState initialState =
      buildInitialHistoricalArchivesWorkflowState();
  static int cancelRequestCount = 0;

  Completer<void>? _importCompleter;

  @override
  HistoricalArchivesWorkflowState build() {
    return initialState;
  }

  @override
  Future<void> beginImportForSelectedSource() async {
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.running,
        statusLabel: 'Import running',
        detail:
            'Running canonical ledger import for the selected archive source, then starting the normal canonical migration orchestrator.',
      ),
      resultSummaryLines: const [
        'Archive import is running.',
        'Success in this slice requires both canonical ledger import and canonical migration to complete.',
      ],
      phases: const [
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Reading archive source',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail:
              'Selected archive metadata was already validated in preflight.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Normalizing archive rows',
          status: HistoricalArchivesWorkflowPhaseStatus.running,
          detail: 'Canonical importers are reading archive source tables now.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Writing rows to macos_import.db',
          status: HistoricalArchivesWorkflowPhaseStatus.running,
          detail: 'Archive rows are being written into the canonical ledger.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Running canonical migration',
          status: HistoricalArchivesWorkflowPhaseStatus.waiting,
          detail: 'Migration starts after the ledger import succeeds.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Rebuilding indexes/search/heatmap data',
          status: HistoricalArchivesWorkflowPhaseStatus.waiting,
          detail: 'Waiting for canonical migration to complete.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Refreshing app-visible data',
          status: HistoricalArchivesWorkflowPhaseStatus.waiting,
          detail: 'Waiting for canonical migration to complete.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Complete',
          status: HistoricalArchivesWorkflowPhaseStatus.waiting,
          detail: 'Archive import is still running.',
        ),
      ],
    );

    _importCompleter = Completer<void>();
    await _importCompleter!.future;
  }

  @override
  void requestCancelRunningImport() {
    cancelRequestCount += 1;
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.failed,
        statusLabel: 'Archive import canceled',
        detail: 'Canceled in widget test.',
      ),
    );
    _importCompleter?.complete();
    _importCompleter = null;
  }

  void completeSuccess() {
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.migrationCompleted,
        statusLabel: 'Archive Import Complete',
        detail:
            'Archive rows were written to db-import, migrated into working.db, and refreshed through the normal timeline, search, and heatmap surfaces.',
      ),
      preflightSummaryLines: const [
        'Rows with missing GUIDs: 0',
        'Already in current Mac import: 6,513',
        'Already in historical archive imports: 0',
        'Earliest message: 2012-07-25',
        'Latest message: 2017-06-11',
      ],
      dryRunSummaryLines: const ['Estimated new messages: 2,369'],
      resultSummaryLines: const [
        'Archive source metadata, canonical ledger rows, and working.db projections are all up to date.',
        'Archive rows are now visible through the normal timeline, search, and heatmap surfaces.',
      ],
      phases: const [
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Reading archive source',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail:
              'Selected archive metadata was already validated in preflight.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Normalizing archive rows',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail:
              'Archive source rows were normalized through the canonical import path.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Writing rows to macos_import.db',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail: 'Archive rows were written into the canonical ledger.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Running canonical migration',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail:
              'The normal canonical migration orchestrator completed successfully.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Rebuilding indexes/search/heatmap data',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail:
              'The normal migration rebuild refreshed indexes and support tables.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Refreshing app-visible data',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail: 'Message-dependent providers were refreshed after migration.',
        ),
        HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Complete',
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail:
              'Archive import and canonical migration completed successfully.',
        ),
      ],
    );

    _importCompleter?.complete();
    _importCompleter = null;
  }
}
