import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCoordinatorState;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/settings/application/archive_source_inspection.dart';
import 'package:remember_this_text/features/settings/application/archive_source_inspector_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_folder_chooser.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_folder_chooser_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/archive_source_inspection_repository.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const currentMessagesDatabasePath = '/Users/test/Library/Messages/chat.db';

  group('buildHistoricalArchivesWorkflowPanelModel', () {
    test('projects the empty workflow as a silent hub', () {
      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: buildInitialHistoricalArchivesWorkflowState(),
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(model.isHub, isTrue);
      expect(model.narratorPresentation, isNull);
    });

    test(
      'reports available execution gate when no shared pipeline owns it',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.executionGate.status,
          HistoricalArchivesExecutionGateStatus.available,
        );
        expect(model.executionGate.statusLabel, 'Available');
        expect(model.statusLabel, 'No archive selected');
        expect(model.importButtonEnabled, isFalse);
        expect(model.importButtonDetail, contains('folder is selected'));
        expect(model.activityLog.last.label, 'Waiting');
      },
    );

    test(
      'reports busy execution gate when source-scoped import pipeline owns it',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(
            operation: ArchiveMutationOperation.graphBuild,
            ownerId: 'db-import-control#1',
            ownerLabel: 'db-import-control',
            holdCount: 1,
          ),
          isMaintenanceLocked: false,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.executionGate.status,
          HistoricalArchivesExecutionGateStatus.busy,
        );
        expect(
          model.executionGate.detail,
          contains('Source import or graph projection'),
        );
        expect(model.statusLabel, 'Execution Gate Busy');
        expect(
          model.summaryText,
          contains('already importing or preparing message data'),
        );
        expect(
          model.importButtonDetail,
          contains('source import or graph projection'),
        );
        expect(model.activityLog.last.label, 'Execution gate busy');
      },
    );

    test(
      'reports blocked execution gate when maintenance lock is active without gate ownership',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: true,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.executionGate.status,
          HistoricalArchivesExecutionGateStatus.blocked,
        );
        expect(model.executionGate.statusLabel, 'Blocked');
        expect(model.statusLabel, 'Execution Gate Blocked');
        expect(model.importButtonDetail, contains('maintenance operation'));
        expect(model.activityLog.last.label, 'Maintenance lock active');
      },
    );

    test('reports ready source state after successful preflight', () {
      final workflowState = buildInitialHistoricalArchivesWorkflowState()
          .copyWith(
            preflight: const HistoricalArchivesPreflightViewModel(
              status: HistoricalArchivesPreflightStatus.completeReadyToImport,
              statusLabel: 'Preflight complete',
              detail: 'Source checks succeeded.',
            ),
            selectedFolderPath: '/tmp/Archive-2017',
            chatDbStatusLabel: 'Found and readable',
            attachmentsStatusLabel: 'Found',
            sourceLabel: 'Archive-2017',
            archiveRemovalTargetChatDbPath: '/tmp/Archive-2017/chat.db',
            preflightSummaryLines: const ['Total messages: 42'],
            dryRunSummaryLines: const ['Estimated new messages: unavailable'],
            activityLog: const [
              HistoricalArchivesLogEntryViewModel(
                label: 'Preflight complete',
                message: 'Ready for the next slice.',
              ),
            ],
          );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(model.statusLabel, 'Archive Source Ready');
      expect(model.summaryText, contains('completed source preflight'));
      expect(model.selectedFolderPath, '/tmp/Archive-2017');
      expect(model.preflightSummaryLines.single, 'Total messages: 42');
      expect(model.importButtonEnabled, isTrue);
      expect(
        model.importButtonDetail,
        contains('Archive rows remain isolated'),
      );
      expect(
        model.importSafetySummaryLines,
        contains(
          'Begin Import adds messages from "Archive-2017" without replacing current message data.',
        ),
      );
      expect(
        model.importSafetySummaryLines,
        contains('The live Messages database is not modified.'),
      );
      expect(
        model.importSafetySummaryLines,
        contains(
          'User settings, favourites, and manual labels remain in the overlay database.',
        ),
      );
      expect(
        model.importSafetySummaryLines,
        contains(
          'Archive messages keep separate source identity even when GUIDs overlap with live messages.',
        ),
      );
      expect(
        model.archiveManagementSummaryLines,
        contains('Removal target chat.db: /tmp/Archive-2017/chat.db'),
      );
      expect(
        model.archiveManagementSummaryLines,
        contains('Source-scoped archive removal: available after preflight'),
      );
      expect(model.removeImportedArchiveDataEnabled, isTrue);
      expect(
        model.removeImportedArchiveDataDetail,
        contains('source-scoped import rows'),
      );
    });

    test('projects typed ready evidence without summary-string parsing', () {
      const evidence = HistoricalArchivesInspectionEvidence(
        folderPath: '/tmp/archive',
        chatDbPath: '/tmp/archive/chat.db',
        sourceLabel: 'archive',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Found',
        totalMessages: 8882,
        totalChats: 140,
        totalHandles: 220,
        missingGuids: 0,
        earliestMessageUtc: '2012-07-25T08:00:00.000Z',
        latestMessageUtc: '2017-06-11T08:00:00.000Z',
        dateRangeUnavailableReason: null,
        dryRunNewMessages: 2369,
        dryRunDuplicateMessages: 6513,
        dryRunComparableMessages: 8882,
        dryRunUnavailableReason: null,
      );
      final workflowState = buildInitialHistoricalArchivesWorkflowState()
          .copyWith(
            presentationContext:
                HistoricalArchivesPresentationContext.addArchive,
            presentationStage:
                HistoricalArchivesPresentationStage.readyForImport,
            inspectionEvidence: evidence,
            preflight: const HistoricalArchivesPreflightViewModel(
              status: HistoricalArchivesPreflightStatus.completeReadyToImport,
              statusLabel: 'Preflight complete',
              detail: 'Source checks succeeded.',
            ),
            selectedFolderPath: evidence.folderPath,
            archiveRemovalTargetChatDbPath: evidence.chatDbPath,
            chatDbStatusLabel: evidence.chatDbStatusLabel,
            attachmentsStatusLabel: evidence.attachmentsStatusLabel,
            sourceLabel: evidence.sourceLabel,
          );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      final presentation = model.narratorPresentation!;
      expect(
        presentation.kind,
        HistoricalArchivesNarratorPresentationKind.readyForImport,
      );
      expect(presentation.narratorText, contains('July 2012'));
      expect(
        presentation.instrumentationRows.map((row) => row.value),
        containsAll(['8,882', 'Jul 2012 – Jun 2017', '2,369', '6,513']),
      );
      expect(model.importButtonEnabled, isTrue);
    });

    test('ready projection reports an unavailable comparison honestly', () {
      const evidence = HistoricalArchivesInspectionEvidence(
        folderPath: '/tmp/archive',
        chatDbPath: '/tmp/archive/chat.db',
        sourceLabel: 'archive',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Not found',
        totalMessages: 42,
        totalChats: 4,
        totalHandles: 7,
        missingGuids: 0,
        earliestMessageUtc: null,
        latestMessageUtc: null,
        dateRangeUnavailableReason: 'No usable dates were found.',
        dryRunNewMessages: null,
        dryRunDuplicateMessages: null,
        dryRunComparableMessages: null,
        dryRunUnavailableReason: 'Graph comparison is unavailable.',
      );
      final workflowState = buildInitialHistoricalArchivesWorkflowState()
          .copyWith(
            presentationContext:
                HistoricalArchivesPresentationContext.addArchive,
            presentationStage:
                HistoricalArchivesPresentationStage.readyForImport,
            inspectionEvidence: evidence,
            preflight: const HistoricalArchivesPreflightViewModel(
              status: HistoricalArchivesPreflightStatus.completeReadyToImport,
              statusLabel: 'Preflight complete',
              detail: 'Source checks succeeded without comparison.',
            ),
            selectedFolderPath: evidence.folderPath,
            archiveRemovalTargetChatDbPath: evidence.chatDbPath,
            chatDbStatusLabel: evidence.chatDbStatusLabel,
            attachmentsStatusLabel: evidence.attachmentsStatusLabel,
            sourceLabel: evidence.sourceLabel,
          );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(
        model.narratorPresentation!.instrumentationRows,
        contains(
          isA<HistoricalArchivesInstrumentationRowViewModel>()
              .having((row) => row.label, 'label', 'Message comparison')
              .having((row) => row.value, 'value', 'Unavailable'),
        ),
      );
      expect(model.importButtonEnabled, isTrue);
    });

    test(
      'ready projection refuses internally incoherent comparison evidence',
      () {
        const evidence = HistoricalArchivesInspectionEvidence(
          folderPath: '/tmp/archive',
          chatDbPath: '/tmp/archive/chat.db',
          sourceLabel: 'archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Not found',
          totalMessages: 8882,
          totalChats: 4,
          totalHandles: 7,
          missingGuids: 0,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          dateRangeUnavailableReason: null,
          dryRunNewMessages: -6513,
          dryRunDuplicateMessages: 15395,
          dryRunComparableMessages: 8882,
          dryRunUnavailableReason: null,
        );
        final workflowState = buildInitialHistoricalArchivesWorkflowState()
            .copyWith(
              presentationContext:
                  HistoricalArchivesPresentationContext.addArchive,
              presentationStage:
                  HistoricalArchivesPresentationStage.readyForImport,
              inspectionEvidence: evidence,
              preflight: const HistoricalArchivesPreflightViewModel(
                status: HistoricalArchivesPreflightStatus.completeReadyToImport,
                statusLabel: 'Preflight complete',
                detail: 'Source checks succeeded.',
              ),
              selectedFolderPath: evidence.folderPath,
              archiveRemovalTargetChatDbPath: evidence.chatDbPath,
              chatDbStatusLabel: evidence.chatDbStatusLabel,
              sourceLabel: evidence.sourceLabel,
            );

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: workflowState,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          model.narratorPresentation?.instrumentationRows,
          contains(
            isA<HistoricalArchivesInstrumentationRowViewModel>()
                .having((row) => row.label, 'label', 'Message comparison')
                .having((row) => row.value, 'value', 'Unavailable'),
          ),
        );
        expect(
          model.narratorPresentation?.instrumentationRows.map(
            (row) => row.value,
          ),
          isNot(contains('-6,513')),
        );
        expect(
          model.narratorPresentation?.instrumentationRows.map(
            (row) => row.value,
          ),
          isNot(contains('15,395')),
        );
      },
    );

    test(
      'failed inspection distinguishes deterministic and retryable failure',
      () {
        HistoricalArchivesWorkflowPanelViewModel buildFailure(
          String chatDbStatus,
        ) {
          final workflowState = buildInitialHistoricalArchivesWorkflowState()
              .copyWith(
                presentationContext:
                    HistoricalArchivesPresentationContext.addArchive,
                presentationStage:
                    HistoricalArchivesPresentationStage.inspectionFailed,
                selectedFolderPath: '/tmp/archive',
                archiveRemovalTargetChatDbPath: '/tmp/archive/chat.db',
                chatDbStatusLabel: chatDbStatus,
                sourceLabel: 'archive',
                preflight: const HistoricalArchivesPreflightViewModel(
                  status: HistoricalArchivesPreflightStatus.failed,
                  statusLabel: 'Preflight failed',
                  detail: 'Inspection failed for testing.',
                ),
              );
          return buildHistoricalArchivesWorkflowPanelModel(
            executionGateState: const ArchiveMutationCoordinatorState(),
            isMaintenanceLocked: false,
            workflowState: workflowState,
            currentMessagesDatabasePath: currentMessagesDatabasePath,
          );
        }

        expect(
          buildFailure('Missing').narratorPresentation!.retryInspectionEnabled,
          isFalse,
        );
        expect(
          buildFailure(
            'Read failed',
          ).narratorPresentation!.retryInspectionEnabled,
          isTrue,
        );
      },
    );
  });

  group('HistoricalArchivesWorkflow narrator lifecycle', () {
    test(
      'folder choice enters real inspection and resolves automatically',
      () async {
        final inspectionCompleter = Completer<ArchiveSourceInspection>();
        final container = ProviderContainer(
          overrides: [
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async =>
                  _CompletingArchiveSourceInspector(inspectionCompleter.future),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final operation = container
            .read(historicalArchivesWorkflowProvider.notifier)
            .chooseMessagesFolder();
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(historicalArchivesWorkflowProvider).presentationStage,
          HistoricalArchivesPresentationStage.inspectingSource,
        );

        inspectionCompleter.complete(
          const ArchiveSourceInspection(
            folderPath: '/tmp/archive',
            sourceLabel: 'archive',
            chatDbPath: '/tmp/archive/chat.db',
            chatDbStatusLabel: 'Found and readable',
            attachmentsStatusLabel: 'Not found',
            isReadable: true,
            detail: 'Archive source is readable.',
            dryRunEstimate: ArchiveSourceDryRunEstimate.available(
              comparableGuidCount: 42,
              duplicateGuidCount: 10,
              newGuidCount: 32,
            ),
            totalMessages: 42,
            totalChats: 4,
            totalHandles: 7,
            missingGuids: 0,
            earliestMessageUtc: '2012-07-25T08:00:00.000Z',
            latestMessageUtc: '2017-06-11T08:00:00.000Z',
          ),
        );
        await operation;

        final resolvedState = container.read(
          historicalArchivesWorkflowProvider,
        );
        expect(
          resolvedState.presentationStage,
          HistoricalArchivesPresentationStage.readyForImport,
        );
        expect(resolvedState.inspectionEvidence?.totalMessages, 42);
      },
    );

    testWidgets(
      'duplicate add restores hub and emits a bounded reference only after dismissal',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final archiveSources = _RecordingHistoricalArchiveSources();
        final container = ProviderContainer(
          overrides: [
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => archiveSources,
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(
                matchingFolderPath: '/tmp/archive',
                match: HistoricalArchiveImportedSourceMatch(
                  sourceKey: sourceKey,
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();

        final recognized = container.read(historicalArchivesWorkflowProvider);
        expect(
          recognized.presentationStage,
          HistoricalArchivesPresentationStage.noSource,
        );
        expect(
          recognized.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(recognized.duplicateFolderNotice?.sourceKey, sourceKey);
        expect(recognized.duplicateFolderNotice?.noticeOccurrence, 1);
        expect(recognized.knownSourceReference, isNull);
        expect(recognized.selectedKnownSourceKey, isNull);
        expect(recognized.selectedFolderPath, isNull);
        expect(archiveSources.upsertCallCount, 0);

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: recognized,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(model.isHub, isTrue);
        expect(model.narratorPresentation, isNull);
        expect(model.importButtonEnabled, isFalse);

        final firstNotice = recognized.duplicateFolderNotice!;
        workflow.dismissDuplicateFolderNotice(
          noticeOccurrence: firstNotice.noticeOccurrence,
          presentationSessionOccurrence:
              firstNotice.presentationSessionOccurrence,
        );
        final firstReference = container.read(
          historicalArchivesWorkflowProvider,
        );
        expect(firstReference.duplicateFolderNotice, isNull);
        expect(firstReference.knownSourceReference?.sourceKey, sourceKey);
        expect(firstReference.knownSourceReference?.pulseOccurrence, 1);
        expect(
          firstReference.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        await tester.pump(const Duration(milliseconds: 2000));

        await workflow.chooseMessagesFolder();
        final repeated = container.read(historicalArchivesWorkflowProvider);
        expect(repeated.duplicateFolderNotice?.noticeOccurrence, 2);
        expect(repeated.knownSourceReference, isNull);

        final repeatedNotice = repeated.duplicateFolderNotice!;
        workflow.dismissDuplicateFolderNotice(
          noticeOccurrence: repeatedNotice.noticeOccurrence,
          presentationSessionOccurrence:
              repeatedNotice.presentationSessionOccurrence,
        );
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference
              ?.pulseOccurrence,
          2,
        );

        await tester.pump(const Duration(milliseconds: 1000));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference
              ?.pulseOccurrence,
          2,
        );
        await tester.pump(const Duration(milliseconds: 1960));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference,
          isNull,
        );
      },
    );

    test(
      'missing chat db rejects the add before persistence and restores the hub',
      () async {
        final archiveSources = _RecordingHistoricalArchiveSources();
        final container = ProviderContainer(
          overrides: [
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/not-an-archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _MissingArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => archiveSources,
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();

        final rejected = container.read(historicalArchivesWorkflowProvider);
        expect(
          rejected.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(
          rejected.presentationStage,
          HistoricalArchivesPresentationStage.noSource,
        );
        expect(rejected.invalidFolderNotice?.noticeOccurrence, 1);
        expect(rejected.selectedFolderPath, isNull);
        expect(rejected.inspectionEvidence, isNull);
        expect(rejected.duplicateFolderNotice, isNull);
        expect(rejected.knownSourceReference, isNull);
        expect(rejected.selectedKnownSourceKey, isNull);
        expect(archiveSources.upsertCallCount, 0);

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: rejected,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(model.isHub, isTrue);
        expect(model.narratorPresentation, isNull);
        expect(model.importButtonEnabled, isFalse);

        final notice = rejected.invalidFolderNotice!;
        workflow.dismissInvalidFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );

        final dismissed = container.read(historicalArchivesWorkflowProvider);
        expect(dismissed.invalidFolderNotice, isNull);
        expect(
          dismissed.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(dismissed.knownSourceReference, isNull);
        expect(dismissed.selectedKnownSourceKey, isNull);
        expect(archiveSources.upsertCallCount, 0);
      },
    );

    test(
      'late invalid-folder dismissal cannot revive an abandoned session',
      () async {
        final container = ProviderContainer(
          overrides: [
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _MissingArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.loadFolder(folderPath: '/tmp/not-an-archive');
        final notice = container
            .read(historicalArchivesWorkflowProvider)
            .invalidFolderNotice!;

        workflow.resetPresentationContext();
        workflow.dismissInvalidFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(state.invalidFolderNotice, isNull);
        expect(state.knownSourceReference, isNull);
        expect(state.selectedKnownSourceKey, isNull);
      },
    );

    test(
      'read failure remains an inspection failure, not invalid folder',
      () async {
        final container = ProviderContainer(
          overrides: [
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ReadFailedArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .loadFolder(folderPath: '/tmp/unreadable-archive');

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentationContext,
          HistoricalArchivesPresentationContext.addArchive,
        );
        expect(
          state.presentationStage,
          HistoricalArchivesPresentationStage.inspectionFailed,
        );
        expect(state.invalidFolderNotice, isNull);
        expect(state.chatDbStatusLabel, 'Read failed');
      },
    );

    test(
      'late duplicate dismissal cannot create a reference after navigation reset',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final container = ProviderContainer(
          overrides: [
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(
                matchingFolderPath: '/tmp/archive',
                match: HistoricalArchiveImportedSourceMatch(
                  sourceKey: sourceKey,
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.loadFolder(folderPath: '/tmp/archive');
        final notice = container
            .read(historicalArchivesWorkflowProvider)
            .duplicateFolderNotice!;

        workflow.resetPresentationContext();
        workflow.dismissDuplicateFolderNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(state.duplicateFolderNotice, isNull);
        expect(state.knownSourceReference, isNull);
      },
    );

    test(
      'remembered source with no imported messages remains eligible for add flow',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        const source = HistoricalArchiveSourceMetadata(
          sourceKey: sourceKey,
          sourceChatDb: '/tmp/archive/chat.db',
          folderPath: '/tmp/archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Not found',
          totalMessages: 42,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          preflightStatusLabel: 'Previously inspected',
          dryRunNewMessages: 42,
          dryRunDuplicateMessages: 0,
          lastImportFinishedAtUtc: null,
          lastImportSuccess: null,
          lastImportError: null,
          lastImportedMessageCount: null,
        );
        final container = ProviderContainer(
          overrides: [
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => const [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .chooseMessagesFolder();

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentationContext,
          HistoricalArchivesPresentationContext.addArchive,
        );
        expect(
          state.presentationStage,
          HistoricalArchivesPresentationStage.readyForImport,
        );
        expect(state.knownSourceReference, isNull);
        expect(
          await container.read(historicalArchiveSourceMetadataProvider.future),
          const [source],
        );
      },
    );

    test(
      'known-source navigation uses canonical identity without recognition pulse',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final container = ProviderContainer(
          overrides: [
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => const [
                HistoricalArchiveSourceMetadata(
                  sourceKey: sourceKey,
                  sourceChatDb: '/tmp/archive/chat.db',
                  folderPath: '/tmp/archive',
                  sourceLabel: 'Archive',
                  chatDbStatusLabel: 'Found and readable',
                  attachmentsStatusLabel: 'Found',
                  totalMessages: 42,
                  earliestMessageUtc: '2012-07-25T08:00:00.000Z',
                  latestMessageUtc: '2017-06-11T08:00:00.000Z',
                  preflightStatusLabel: 'Preflight complete',
                  dryRunNewMessages: 0,
                  dryRunDuplicateMessages: 42,
                  lastImportFinishedAtUtc: null,
                  lastImportSuccess: true,
                  lastImportError: null,
                  lastImportedMessageCount: 42,
                ),
              ],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(
                match: HistoricalArchiveImportedSourceMatch(
                  sourceKey: sourceKey,
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .showKnownSource(sourceKey: sourceKey);

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentationStage,
          HistoricalArchivesPresentationStage.existingSource,
        );
        expect(
          state.presentationContext,
          HistoricalArchivesPresentationContext.existingSource,
        );
        expect(state.selectedFolderPath, '/tmp/archive');
        expect(state.selectedKnownSourceKey, sourceKey);
        expect(state.knownSourceReference, isNull);
        final rows = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: state,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        ).narratorPresentation?.instrumentationRows;
        expect(rows?.map((row) => row.label), ['Messages', 'Dates']);
        expect(rows?.first.value, '42');
        expect(
          buildHistoricalArchivesWorkflowPanelModel(
            executionGateState: const ArchiveMutationCoordinatorState(),
            isMaintenanceLocked: false,
            workflowState: state,
            currentMessagesDatabasePath: currentMessagesDatabasePath,
          ).importButtonEnabled,
          isFalse,
        );
      },
    );

    test(
      'remembered unimported source cannot establish selected context',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final container = ProviderContainer(
          overrides: [
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => const [
                HistoricalArchiveSourceMetadata(
                  sourceKey: sourceKey,
                  sourceChatDb: '/tmp/archive/chat.db',
                  folderPath: '/tmp/archive',
                  sourceLabel: 'Archive',
                  chatDbStatusLabel: 'Found and readable',
                  attachmentsStatusLabel: 'Found',
                  totalMessages: 42,
                  earliestMessageUtc: '2012-07-25T08:00:00.000Z',
                  latestMessageUtc: '2017-06-11T08:00:00.000Z',
                  preflightStatusLabel: 'Preflight complete',
                  dryRunNewMessages: 32,
                  dryRunDuplicateMessages: 10,
                  lastImportFinishedAtUtc: null,
                  lastImportSuccess: null,
                  lastImportError: null,
                  lastImportedMessageCount: null,
                ),
              ],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(historicalArchivesWorkflowProvider.notifier)
            .showKnownSource(sourceKey: sourceKey);

        final state = container.read(historicalArchivesWorkflowProvider);
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: state,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          state.presentationStage,
          HistoricalArchivesPresentationStage.noSource,
        );
        expect(
          state.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(state.selectedKnownSourceKey, isNull);
        expect(model.isHub, isTrue);
        expect(model.narratorPresentation, isNull);
        expect(model.importButtonEnabled, isFalse);
      },
    );

    test(
      'leaving Historical Archives clears transient selection but not source facts',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        const source = HistoricalArchiveSourceMetadata(
          sourceKey: sourceKey,
          sourceChatDb: '/tmp/archive/chat.db',
          folderPath: '/tmp/archive',
          sourceLabel: 'Archive',
          chatDbStatusLabel: 'Found and readable',
          attachmentsStatusLabel: 'Found',
          totalMessages: 42,
          earliestMessageUtc: '2012-07-25T08:00:00.000Z',
          latestMessageUtc: '2017-06-11T08:00:00.000Z',
          preflightStatusLabel: 'Imported successfully',
          dryRunNewMessages: 0,
          dryRunDuplicateMessages: 42,
          lastImportFinishedAtUtc: null,
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final container = ProviderContainer(
          overrides: [
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => const [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(
                match: HistoricalArchiveImportedSourceMatch(
                  sourceKey: sourceKey,
                  sourceId: 3,
                  importedMessageCount: 42,
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(
              SettingsMenuActionId.historicalArchives,
            );

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(sourceKey: sourceKey);
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .selectedKnownSourceKey,
          sourceKey,
        );

        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.messages);

        final reset = container.read(historicalArchivesWorkflowProvider);
        expect(
          reset.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(reset.selectedKnownSourceKey, isNull);
        expect(reset.knownSourceReference, isNull);
        expect(
          await container.read(historicalArchiveSourceMetadataProvider.future),
          const [source],
        );

        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
      },
    );

    test(
      'late folder inspection cannot revive an abandoned add context',
      () async {
        final inspectionCompleter = Completer<ArchiveSourceInspection>();
        final container = ProviderContainer(
          overrides: [
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => const _FakeFolderChooser('/tmp/archive'),
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async =>
                  _CompletingArchiveSourceInspector(inspectionCompleter.future),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => const _FakeHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => const _FakeImportedSourceLookup(),
            ),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.settings);
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(
              SettingsMenuActionId.historicalArchives,
            );

        final operation = container
            .read(historicalArchivesWorkflowProvider.notifier)
            .chooseMessagesFolder();
        await Future<void>.delayed(Duration.zero);
        container
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.messages);

        inspectionCompleter.complete(
          const ArchiveSourceInspection(
            folderPath: '/tmp/archive',
            sourceLabel: 'archive',
            chatDbPath: '/tmp/archive/chat.db',
            chatDbStatusLabel: 'Found and readable',
            attachmentsStatusLabel: 'Not found',
            isReadable: true,
            detail: 'Archive source is readable.',
            dryRunEstimate: ArchiveSourceDryRunEstimate.available(
              comparableGuidCount: 42,
              duplicateGuidCount: 10,
              newGuidCount: 32,
            ),
            totalMessages: 42,
            totalChats: 4,
            totalHandles: 7,
            missingGuids: 0,
            earliestMessageUtc: '2012-07-25T08:00:00.000Z',
            latestMessageUtc: '2017-06-11T08:00:00.000Z',
          ),
        );
        await operation;

        final state = container.read(historicalArchivesWorkflowProvider);
        expect(
          state.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(state.selectedKnownSourceKey, isNull);
        expect(state.knownSourceReference, isNull);
      },
    );
  });

  group('preflightHistoricalArchivesFolder', () {
    late ConversationGraphDatabase graphDb;

    setUp(() {
      graphDb = ConversationGraphDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await graphDb.close();
    });

    test('reads source counts from a selected archive folder', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'historical-archives-preflight-',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final chatDbPath = '${tempDirectory.path}/chat.db';
      final database = sqlite3.open(chatDbPath);
      try {
        database.execute('CREATE TABLE message (guid TEXT);');
        database.execute('CREATE TABLE chat (id INTEGER PRIMARY KEY);');
        database.execute('CREATE TABLE handle (id INTEGER PRIMARY KEY);');
        database.execute(
          "INSERT INTO message (guid) VALUES ('m1'), ('m2'), (NULL);",
        );
        database.execute('INSERT INTO chat (id) VALUES (1), (2);');
        database.execute('INSERT INTO handle (id) VALUES (1), (2), (3);');
      } finally {
        database.dispose();
      }

      Directory('${tempDirectory.path}/Attachments').createSync();

      await graphDb.executeSql('''
INSERT INTO messages (ss_id, guid, is_from_me) VALUES
           (1, 'm1', 0), (2, 'm1', 0), (3, 'projected-only', 0)''');

      final result = await preflightHistoricalArchivesFolder(
        folderPath: tempDirectory.path,
        archiveSourceInspector: ArchiveSourceInspectionRepository(
          graphDb: graphDb,
        ),
      );

      expect(
        result.preflight.status,
        HistoricalArchivesPreflightStatus.completeReadyToImport,
      );
      expect(result.chatDbStatusLabel, 'Found and readable');
      expect(result.attachmentsStatusLabel, 'Found');
      expect(result.preflightSummaryLines, contains('Total messages: 3'));
      expect(result.preflightSummaryLines, contains('Total chats: 2'));
      expect(result.preflightSummaryLines, contains('Total handles: 3'));
      expect(
        result.preflightSummaryLines,
        contains('Rows with missing GUIDs: 1'),
      );
      expect(
        result.preflightSummaryLines,
        contains('Likely already imported: 1 comparable source rows'),
      );
      expect(
        result.preflightSummaryLines,
        contains('Likely new rows: 1 comparable source rows'),
      );
      expect(
        result.dryRunSummaryLines,
        contains(
          'Estimated new messages: 1 comparable source rows not already imported',
        ),
      );
      expect(
        result.dryRunSummaryLines,
        contains(
          'Estimated duplicates: 1 comparable source rows already imported',
        ),
      );
      expect(result.activityLog[1].label, 'Dry run ready');
    });

    test(
      'reports date range diagnostic when source date column is absent',
      () async {
        final tempDirectory = await Directory.systemTemp.createTemp(
          'historical-archives-preflight-no-date-',
        );
        addTearDown(() async {
          if (tempDirectory.existsSync()) {
            await tempDirectory.delete(recursive: true);
          }
        });

        final chatDbPath = '${tempDirectory.path}/chat.db';
        final database = sqlite3.open(chatDbPath);
        try {
          database.execute('CREATE TABLE message (guid TEXT);');
          database.execute('CREATE TABLE chat (id INTEGER PRIMARY KEY);');
          database.execute('CREATE TABLE handle (id INTEGER PRIMARY KEY);');
          database.execute("INSERT INTO message (guid) VALUES ('m1');");
        } finally {
          database.dispose();
        }

        final result = await preflightHistoricalArchivesFolder(
          folderPath: tempDirectory.path,
          archiveSourceInspector: ArchiveSourceInspectionRepository(
            graphDb: graphDb,
          ),
        );

        expect(
          result.preflight.status,
          HistoricalArchivesPreflightStatus.completeReadyToImport,
        );
        expect(
          result.preflightSummaryLines,
          contains('Earliest message: unavailable'),
        );
        expect(
          result.preflightSummaryLines,
          contains('Latest message: unavailable'),
        );
        expect(
          result.preflightSummaryLines.any(
            (line) => line.startsWith('Date range diagnostic:'),
          ),
          isTrue,
        );
      },
    );

    test('fails preflight when the selected folder has no chat db', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'historical-archives-preflight-missing-',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final result = await preflightHistoricalArchivesFolder(
        folderPath: tempDirectory.path,
        archiveSourceInspector: ArchiveSourceInspectionRepository(
          graphDb: graphDb,
        ),
      );

      expect(result.preflight.status, HistoricalArchivesPreflightStatus.failed);
      expect(result.chatDbStatusLabel, 'Missing');
      expect(result.preflight.detail, contains('does not contain chat.db'));
      expect(result.activityLog.single.label, 'Preflight failed');
    });
  });
}

final class _FakeFolderChooser implements HistoricalArchiveFolderChooser {
  const _FakeFolderChooser(this.folderPath);

  final String folderPath;

  @override
  Future<String?> chooseMessagesFolder() async => folderPath;
}

final class _CompletingArchiveSourceInspector
    implements ArchiveSourceInspector {
  const _CompletingArchiveSourceInspector(this.inspection);

  final Future<ArchiveSourceInspection> inspection;

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return inspection;
  }
}

final class _ImmediateArchiveSourceInspector implements ArchiveSourceInspector {
  const _ImmediateArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return Future.value(
      ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: 'archive',
        chatDbPath: '$folderPath/chat.db',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Not found',
        isReadable: true,
        detail: 'Archive source is readable.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.available(
          comparableGuidCount: 42,
          duplicateGuidCount: 42,
          newGuidCount: 0,
        ),
        totalMessages: 42,
        totalChats: 4,
        totalHandles: 7,
        missingGuids: 0,
        earliestMessageUtc: '2012-07-25T08:00:00.000Z',
        latestMessageUtc: '2017-06-11T08:00:00.000Z',
      ),
    );
  }
}

final class _MissingArchiveSourceInspector implements ArchiveSourceInspector {
  const _MissingArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return Future.value(
      ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: 'not-an-archive',
        chatDbPath: '$folderPath/chat.db',
        chatDbStatusLabel: 'Missing',
        attachmentsStatusLabel: 'Not found',
        isReadable: false,
        detail: 'The selected folder does not contain chat.db.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
          unavailableReason: 'source chat.db is missing.',
        ),
      ),
    );
  }
}

final class _ReadFailedArchiveSourceInspector
    implements ArchiveSourceInspector {
  const _ReadFailedArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({required String folderPath}) {
    return Future.value(
      ArchiveSourceInspection(
        folderPath: folderPath,
        sourceLabel: 'unreadable-archive',
        chatDbPath: '$folderPath/chat.db',
        chatDbStatusLabel: 'Read failed',
        attachmentsStatusLabel: 'Not found',
        isReadable: false,
        detail: 'MessageLens could not safely read chat.db.',
        dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
          unavailableReason: 'source chat.db could not be read safely.',
        ),
      ),
    );
  }
}

final class _FakeImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  const _FakeImportedSourceLookup({this.matchingFolderPath, this.match});

  final String? matchingFolderPath;
  final HistoricalArchiveImportedSourceMatch? match;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required String folderPath,
  }) async {
    if (matchingFolderPath != null && folderPath != matchingFolderPath) {
      return null;
    }
    return match;
  }

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSourceByKey({
    required String sourceKey,
  }) async {
    return match?.sourceKey == sourceKey ? match : null;
  }
}

final class _FakeHistoricalArchiveSources implements HistoricalArchiveSources {
  const _FakeHistoricalArchiveSources();

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async =>
      const [];

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {}
}

final class _RecordingHistoricalArchiveSources
    implements HistoricalArchiveSources {
  var upsertCallCount = 0;

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async =>
      const [];

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {
    upsertCallCount += 1;
  }
}
