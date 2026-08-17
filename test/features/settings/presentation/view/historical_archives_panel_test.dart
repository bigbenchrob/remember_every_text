import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/debug/feature_level_providers.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/presentation/view/historical_archives_panel.dart';

void main() {
  group('HistoricalArchivesPanel', () {
    testWidgets('no-source narrator shows only the truthful invitation', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.noSource,
            narratorText:
                'Add an older Messages archive to extend your history.',
            instrumentationRows: [],
            detailsLines: ['No archive selected.'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('Historical Archives'), findsOneWidget);
      expect(
        find.text('Add an older Messages archive to extend your history.'),
        findsOneWidget,
      );
      expect(find.text('Choose Messages Folder...'), findsOneWidget);
      expect(find.text('Execution Gate'), findsNothing);
      expect(find.text('Preflight Summary'), findsNothing);
      expect(find.text('Activity Log'), findsNothing);
      expect(find.text('Progress'), findsNothing);
      expect(find.textContaining('Next'), findsNothing);
    });

    testWidgets('inspection shows one current truthful instrumentation row', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.inspectingSource,
            narratorText: 'Let’s see what’s in this Messages folder.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Inspecting archive source',
                value: 'Working',
                status: HistoricalArchivesInstrumentationStatus.working,
              ),
            ],
            detailsLines: ['Folder: /tmp/archive'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('Inspecting archive source'), findsOneWidget);
      expect(find.text('Working'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.text('Importing archive messages'), findsNothing);
      expect(find.text('Preparing archive records'), findsNothing);
      expect(find.textContaining('Next'), findsNothing);
    });

    testWidgets('ready state presents typed evidence and hides diagnostics', (
      tester,
    ) async {
      const path = '/tmp/archive/chat.db';
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          importButtonEnabled: true,
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.readyForImport,
            narratorText:
                'Good. This archive can extend your history back to July 2012.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages database',
                value: 'Found',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages',
                value: '8,882',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Dates',
                value: 'Jul 2012 – Jun 2017',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'New to MessageLens',
                value: '2,369',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Already represented',
                value: '6,513',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
            ],
            detailsLines: ['Messages database: $path'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('8,882'), findsOneWidget);
      expect(find.text('Jul 2012 – Jun 2017'), findsOneWidget);
      expect(find.text('2,369'), findsOneWidget);
      expect(find.text('6,513'), findsOneWidget);
      expect(find.text('Import Archive'), findsOneWidget);
      expect(find.text('Choose Another Folder'), findsOneWidget);
      expect(find.text('Messages database: $path'), findsNothing);

      await tester.tap(
        find.byKey(const Key('historical-archives-details-toggle')),
      );
      await tester.pump();

      expect(find.text('Messages database: $path'), findsOneWidget);
    });

    testWidgets('ready evidence does not expose unavailable import authority', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.readyForImport,
            narratorText: 'Good. This archive is understood.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages database',
                value: 'Found',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
            ],
            detailsLines: ['Import authorization: not currently available'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('Import Archive'), findsNothing);
      expect(find.text('Choose Another Folder'), findsOneWidget);
    });

    testWidgets(
      'already-imported state states the truth and offers no import action',
      (tester) async {
        await _pumpPanel(
          tester,
          model: _narratorPanelModel(
            presentation: const HistoricalArchivesNarratorPresentationViewModel(
              kind: HistoricalArchivesNarratorPresentationKind.alreadyImported,
              narratorText: 'This archive is already part of MessageLens.',
              instrumentationRows: [
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Messages',
                  value: '8,882',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Dates',
                  value: 'Jul 2012 – Jun 2017',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Status',
                  value: 'Already imported',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
              ],
              detailsLines: ['Source identity: archive-3'],
              retryInspectionEnabled: false,
            ),
          ),
        );

        expect(
          find.text('This archive is already part of MessageLens.'),
          findsOneWidget,
        );
        expect(find.text('8,882'), findsOneWidget);
        expect(find.text('Jul 2012 – Jun 2017'), findsOneWidget);
        expect(find.text('Already imported'), findsOneWidget);
        expect(find.text('New to MessageLens'), findsNothing);
        expect(find.text('Already represented'), findsNothing);
        expect(find.text('Import Archive'), findsNothing);
        expect(find.text('Choose Another Folder'), findsOneWidget);
      },
    );

    testWidgets('failed inspection offers only the truthful recovery action', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.inspectionFailed,
            narratorText: 'This folder does not contain a Messages database.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages database',
                value: 'Missing',
                status: HistoricalArchivesInstrumentationStatus.failed,
              ),
            ],
            detailsLines: ['Folder: /tmp/not-an-archive'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(
        find.text('This folder does not contain a Messages database.'),
        findsOneWidget,
      );
      expect(find.text('Missing'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Choose Another Folder'), findsOneWidget);
      expect(find.text('Import Archive'), findsNothing);
    });

    testWidgets('renders execution gate, preflight-ready, dry run, and log state', (
      tester,
    ) async {
      const model = HistoricalArchivesWorkflowPanelViewModel(
        statusLabel: 'Ready For Import',
        summaryText:
            'A previously selected archive has completed preflight and is ready for source-scoped import.',
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
        importSafetySummaryLines: [
          'Begin Import adds messages from "archive-2017-macbook" without replacing current message data.',
          'The live Messages database is not modified.',
        ],
        importButtonEnabled: true,
        importButtonDetail:
            'Preflight is complete and the execution gate is available.',
        archiveRemovalTargetChatDbPath:
            '/Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        archiveManagementSummaryLines: [
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          'Source-scoped archive removal: available after preflight',
        ],
        removeImportedArchiveDataEnabled: true,
        removeImportedArchiveDataDetail:
            'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.',
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Reading archive…',
            message: 'chat.db and Attachments metadata were read successfully.',
          ),
          HistoricalArchivesLogEntryViewModel(
            label: 'Source-scoped graph import started…',
            message:
                'Source-scoped archive import and graph projection have been requested and are awaiting execution ownership.',
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
            label: 'Normalizing records for source-scoped import',
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
          developerModeProvider.overrideWith(
            () => _FakeDeveloperMode(DeveloperModeValue.user),
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

      expect(
        find.text(
          'Import historical Messages folders without replacing current message data.',
        ),
        findsOneWidget,
      );
      expect(find.text('Execution Gate'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Preflight complete — ready to import'), findsWidgets);
      expect(find.text('Dry Run Summary'), findsOneWidget);
      expect(find.text('Estimated new messages: 8,120'), findsOneWidget);
      expect(find.text('Estimated duplicates: 762'), findsOneWidget);
      expect(find.text('Import safety'), findsOneWidget);
      expect(
        find.text(
          'Begin Import adds messages from "archive-2017-macbook" without replacing current message data.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('The live Messages database is not modified.'),
        findsOneWidget,
      );
      expect(find.text('Clear Selected Folder'), findsOneWidget);
      expect(
        find.text('Clear Imported Archive Data for This Source'),
        findsNothing,
      );
      expect(
        find.text(
          'This only clears the currently selected folder from the workflow UI. It does not delete imported archive records or reset MessageLens data.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Developer/testing only. This deletes source-scoped import rows from MessageLens for the selected archive source, then reprojects the conversation graph.',
        ),
        findsNothing,
      );
      expect(
        find.text(
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        ),
        findsNothing,
      );
      expect(
        find.text('Source-scoped archive removal: available after preflight'),
        findsNothing,
      );
      expect(
        find.text(
          'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.',
        ),
        findsNothing,
      );
      expect(find.text('Activity Log'), findsOneWidget);
      expect(find.text('Reading archive…'), findsOneWidget);
      expect(find.text('Source-scoped graph import started…'), findsOneWidget);
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
        importSafetySummaryLines: ['Import safety fixture line.'],
        importButtonEnabled: false,
        importButtonDetail: 'Disabled in this shell.',
        archiveRemovalTargetChatDbPath:
            '/Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        archiveManagementSummaryLines: [
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          'Source-scoped archive removal: available after preflight',
        ],
        removeImportedArchiveDataEnabled: true,
        removeImportedArchiveDataDetail:
            'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.',
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
          developerModeProvider.overrideWith(
            () => _FakeDeveloperMode(DeveloperModeValue.developer),
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
            'This deletes source-scoped import rows from MessageLens for this selected source, then reprojects the conversation graph from the remaining import facts.',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Remove Imported Archive Data'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required HistoricalArchivesWorkflowPanelViewModel model,
}) async {
  final container = ProviderContainer(
    overrides: [
      historicalArchivesWorkflowPanelModelProvider.overrideWith((ref) => model),
      developerModeProvider.overrideWith(
        () => _FakeDeveloperMode(DeveloperModeValue.user),
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
}

HistoricalArchivesWorkflowPanelViewModel _narratorPanelModel({
  required HistoricalArchivesNarratorPresentationViewModel presentation,
  bool importButtonEnabled = false,
}) {
  return HistoricalArchivesWorkflowPanelViewModel(
    statusLabel: 'Unused legacy status',
    summaryText: 'Unused legacy summary',
    executionGate: const HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.available,
      statusLabel: 'Available',
      detail: 'No other operation owns mutation authority.',
    ),
    preflight: const HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.waitingForFolder,
      statusLabel: 'Waiting',
      detail: 'Waiting.',
    ),
    selectedFolderPath: null,
    chatDbStatusLabel: 'Not checked yet',
    attachmentsStatusLabel: 'Not checked yet',
    sourceLabel: 'Not proposed yet',
    preflightSummaryLines: const [],
    dryRunSummaryLines: const [],
    importSafetySummaryLines: const [],
    importButtonEnabled: importButtonEnabled,
    importButtonDetail: 'Unused legacy detail',
    archiveRemovalTargetChatDbPath: null,
    archiveManagementSummaryLines: const [],
    removeImportedArchiveDataEnabled: false,
    removeImportedArchiveDataDetail: 'Unused legacy detail',
    activityLog: const [],
    resultSummaryLines: const [],
    phases: const [],
    narratorPresentation: presentation,
  );
}

final class _FakeDeveloperMode extends DeveloperMode {
  _FakeDeveloperMode(this._value);

  final DeveloperModeValue _value;

  @override
  Future<DeveloperModeValue> build() async => _value;
}
