import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCoordinator,
        ArchiveMutationCoordinatorState,
        archiveMutationCoordinatorProvider;
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/attachments/attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chats/chat_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/handles/handle_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_projection_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/feature_level_providers.dart'
    show
        sourceScopedArchiveGraphImportServiceProvider,
        sourceScopedArchiveGraphRemovalServiceProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/onboarding/feature_level_providers.dart'
    show onboardingMessagesDatabasePathProvider;
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/archives/source_scoped_archive_import_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/attachments/attachment_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chats/chat_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/handles/handle_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/message_attachment_joins/message_attachment_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
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
            presentationContext:
                HistoricalArchivesPresentationContext.addArchive,
            presentationStage:
                HistoricalArchivesPresentationStage.readyForImport,
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
      expect(model.removeImportedArchiveDataEnabled, isFalse);
      expect(
        model.removeImportedArchiveDataDetail,
        contains('source-scoped import rows'),
      );
    });

    test(
      'keeps a valid candidate visibly ready while gate availability refreshes',
      () {
        final workflowState = buildInitialHistoricalArchivesWorkflowState()
            .copyWith(
              presentationContext:
                  HistoricalArchivesPresentationContext.addArchive,
              presentationStage:
                  HistoricalArchivesPresentationStage.readyForImport,
              preflight: const HistoricalArchivesPreflightViewModel(
                status: HistoricalArchivesPreflightStatus.completeReadyToImport,
                statusLabel: 'Preflight complete',
                detail: 'Source checks succeeded.',
              ),
              selectedFolderPath: '/tmp/Archive-2017',
              chatDbStatusLabel: 'Found and readable',
              attachmentsStatusLabel: 'Found',
              sourceLabel: 'Archive-2017',
            );

        final available = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: workflowState,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        final busy = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(
            operation: ArchiveMutationOperation.liveGraphUpdate,
            ownerId: 'live-update#1',
            ownerLabel: 'live-update',
            holdCount: 1,
          ),
          isMaintenanceLocked: false,
          workflowState: workflowState,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );

        expect(
          available.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.readyForImport,
        );
        expect(
          busy.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.readyForImport,
        );
        expect(available.importButtonEnabled, isTrue);
        expect(busy.importButtonEnabled, isFalse);
        expect(busy.narratorPresentation?.detailsLines, isNotEmpty);
      },
    );

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

    test('maps real import progress into directed instrumentation', () {
      final workflowState = buildInitialHistoricalArchivesWorkflowState()
          .copyWith(
            presentationContext:
                HistoricalArchivesPresentationContext.importingArchive,
            presentationStage:
                HistoricalArchivesPresentationStage.importingArchive,
            selectedFolderPath: '/tmp/archive',
            importProgress: const HistoricalArchiveImportProgress(
              addingMessages: HistoricalArchiveImportStageStatus.succeeded,
              preparingConversations:
                  HistoricalArchiveImportStageStatus.running,
              verifyingImport: HistoricalArchiveImportStageStatus.waiting,
              graphProjectionProgress:
                  SourceScopedArchiveGraphProjectionProgress(
                    activeUnit: SourceScopedArchiveGraphProjectionUnit.messages,
                    completedUnitCount: 2,
                    totalUnitCount: 5,
                    completedWorkCount: 500,
                    totalWorkCount: 1000,
                  ),
            ),
          );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: true,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(
        model.narratorPresentation?.kind,
        HistoricalArchivesNarratorPresentationKind.importingArchive,
      );
      expect(
        model.narratorPresentation?.instrumentationRows
            .map((row) => (row.label, row.value))
            .toList(),
        const [
          ('Adding messages from this folder', 'Done'),
          ('Preparing conversations for browsing', 'Working'),
          ('Participants', 'Done'),
          ('Conversations', 'Done'),
          ('Messages', '500 / 1,000'),
          ('Attachments', 'Waiting'),
          ('Relationships', 'Waiting'),
          ('Checking that import finished', 'Waiting'),
        ],
      );
      expect(model.importButtonEnabled, isFalse);
    });

    test('preserves completed stages when a later import stage fails', () {
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
        earliestMessageUtc: '2012-07-25T08:00:00.000Z',
        latestMessageUtc: '2017-06-11T08:00:00.000Z',
        dateRangeUnavailableReason: null,
        dryRunNewMessages: 42,
        dryRunDuplicateMessages: 0,
        dryRunComparableMessages: 42,
        dryRunUnavailableReason: null,
      );
      final workflowState = buildInitialHistoricalArchivesWorkflowState()
          .copyWith(
            presentationContext:
                HistoricalArchivesPresentationContext.importFailed,
            presentationStage: HistoricalArchivesPresentationStage.importFailed,
            selectedFolderPath: evidence.folderPath,
            inspectionEvidence: evidence,
            importFailureDetail: 'Graph projection failed.',
            importProgress: const HistoricalArchiveImportProgress(
              addingMessages: HistoricalArchiveImportStageStatus.succeeded,
              preparingConversations: HistoricalArchiveImportStageStatus.failed,
              verifyingImport: HistoricalArchiveImportStageStatus.waiting,
            ),
          );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(
        model.narratorPresentation?.kind,
        HistoricalArchivesNarratorPresentationKind.importFailed,
      );
      expect(
        model.narratorPresentation?.instrumentationRows
            .map((row) => row.value)
            .toList(),
        const ['Done', 'Failed', 'Waiting'],
      );
      expect(model.importButtonEnabled, isTrue);
      expect(
        model.narratorPresentation?.detailsLines,
        contains('Graph projection failed.'),
      );
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

    test(
      'cancel abandons the ready candidate without starting new work',
      () async {
        final coordinator = _ImmediateArchiveMutationCoordinator();
        final folderChooser = _RecordingFolderChooser('/tmp/archive');
        final archiveSources = _RecordingHistoricalArchiveSources();
        final container = ProviderContainer(
          overrides: [
            archiveMutationCoordinatorProvider.overrideWith(() => coordinator),
            historicalArchiveFolderChooserProvider.overrideWith(
              (ref) => folderChooser,
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
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
        expect(
          container.read(historicalArchivesWorkflowProvider).presentationStage,
          HistoricalArchivesPresentationStage.readyForImport,
        );

        workflow.cancelAddArchive();

        final cancelled = container.read(historicalArchivesWorkflowProvider);
        expect(
          cancelled.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(cancelled.selectedFolderPath, isNull);
        expect(cancelled.selectedKnownSourceKey, isNull);
        expect(cancelled.knownSourceReference, isNull);
        expect(folderChooser.callCount, 1);
        expect(coordinator.runCallCount, 0);
        expect(archiveSources.upsertCallCount, 1);
      },
    );

    test(
      'authorization paints import ownership before work and dwells on real completion',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final releaseOperationPresentation = Completer<void>();
        final releaseImport = Completer<void>();
        final importedSourceLookup = _MutableImportedSourceLookup(match: null);
        final graphImportService = _ControlledArchiveGraphImportService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          await releaseImport.future;
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.completed,
            ),
          );
          _emitCompleteGraphProjection(observer);
          importedSourceLookup.match =
              const HistoricalArchiveImportedSourceMatch(
                sourceKey: sourceKey,
                sourceId: 3,
                importedMessageCount: 42,
              );
          return _successfulArchiveGraphImportResult(sourceKey: sourceKey);
        });
        final archiveSources = _RecordingHistoricalArchiveSources();
        final coordinator = _ImmediateArchiveMutationCoordinator();
        final container = ProviderContainer(
          overrides: [
            archiveMutationCoordinatorProvider.overrideWith(() => coordinator),
            sourceScopedArchiveGraphImportServiceProvider.overrideWith(
              (ref) async => graphImportService,
            ),
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
              (ref) async => importedSourceLookup,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.chooseMessagesFolder();

        final import = workflow.beginImportForSelectedSource(
          waitForOperationPresentation: () =>
              releaseOperationPresentation.future,
        );
        final duplicateAuthorization = workflow.beginImportForSelectedSource();

        final authorized = container.read(historicalArchivesWorkflowProvider);
        expect(
          authorized.presentationContext,
          HistoricalArchivesPresentationContext.importingArchive,
        );
        expect(
          authorized.presentationStage,
          HistoricalArchivesPresentationStage.importingArchive,
        );
        expect(graphImportService.callCount, 0);
        expect(archiveSources.successfulImportUpdateCount, 0);

        await duplicateAuthorization;
        await Future<void>.delayed(Duration.zero);
        expect(graphImportService.callCount, 0);
        expect(coordinator.runCallCount, 0);

        releaseOperationPresentation.complete();
        await _waitUntil(() => graphImportService.callCount == 1);
        expect(coordinator.runCallCount, 1);
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .importProgress
              ?.statusFor(HistoricalArchiveImportStage.addingMessages),
          HistoricalArchiveImportStageStatus.running,
        );

        releaseImport.complete();
        await _waitUntil(
          () =>
              container
                  .read(historicalArchivesWorkflowProvider)
                  .importProgress
                  ?.isComplete ==
              true,
        );

        final completed = container.read(historicalArchivesWorkflowProvider);
        expect(
          completed.presentationContext,
          HistoricalArchivesPresentationContext.importingArchive,
        );
        expect(
          HistoricalArchiveImportStage.values.map(
            completed.importProgress!.statusFor,
          ),
          everyElement(HistoricalArchiveImportStageStatus.succeeded),
        );
        expect(completed.knownSourceReference, isNull);
        expect(completed.selectedKnownSourceKey, isNull);
        expect(completed.importSuccessNotice, isNull);
        expect(archiveSources.successfulImportUpdateCount, 1);
        expect(
          historicalArchivesImportSuccessDwellDuration,
          const Duration(milliseconds: 750),
        );

        final dwellStopwatch = Stopwatch()..start();
        await import;
        dwellStopwatch.stop();
        expect(
          dwellStopwatch.elapsed,
          greaterThanOrEqualTo(const Duration(milliseconds: 500)),
        );
        expect(
          dwellStopwatch.elapsed,
          lessThan(const Duration(milliseconds: 1100)),
        );

        final settled = container.read(historicalArchivesWorkflowProvider);
        expect(
          settled.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(settled.importProgress, isNull);
        expect(settled.knownSourceReference, isNull);
        expect(settled.selectedKnownSourceKey, isNull);
        expect(settled.importSuccessNotice, isNotNull);
        expect(archiveSources.successfulImportUpdateCount, 1);

        final notice = settled.importSuccessNotice!;
        workflow.dismissImportSuccessNotice(
          noticeOccurrence: notice.noticeOccurrence,
          presentationSessionOccurrence: notice.presentationSessionOccurrence,
        );
        final acknowledged = container.read(historicalArchivesWorkflowProvider);
        expect(acknowledged.importSuccessNotice, isNull);
        expect(
          acknowledged.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(acknowledged.selectedKnownSourceKey, isNull);
        expect(acknowledged.knownSourceReference, isNull);
        expect(archiveSources.successfulImportUpdateCount, 1);
      },
    );

    test(
      'an older success dwell cannot clear a newer ready candidate',
      () async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final importedSourceLookup = _MutableImportedSourceLookup(match: null);
        final graphImportService = _ControlledArchiveGraphImportService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.completed,
            ),
          );
          _emitCompleteGraphProjection(observer);
          importedSourceLookup.match =
              const HistoricalArchiveImportedSourceMatch(
                sourceKey: sourceKey,
                sourceId: 3,
                importedMessageCount: 42,
              );
          return _successfulArchiveGraphImportResult(sourceKey: sourceKey);
        });
        final container = ProviderContainer(
          overrides: [
            archiveMutationCoordinatorProvider.overrideWith(
              () => _ImmediateArchiveMutationCoordinator(),
            ),
            sourceScopedArchiveGraphImportServiceProvider.overrideWith(
              (ref) async => graphImportService,
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => _RecordingHistoricalArchiveSources(),
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => importedSourceLookup,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.loadFolder(folderPath: '/tmp/archive');
        final oldImport = workflow.beginImportForSelectedSource();
        await _waitUntil(
          () =>
              container
                  .read(historicalArchivesWorkflowProvider)
                  .importProgress
                  ?.isComplete ==
              true,
        );

        importedSourceLookup.match = null;
        workflow.resetPresentationContext();
        await workflow.loadFolder(folderPath: '/tmp/new-archive');
        expect(
          container.read(historicalArchivesWorkflowProvider).presentationStage,
          HistoricalArchivesPresentationStage.readyForImport,
        );

        await oldImport;
        final newer = container.read(historicalArchivesWorkflowProvider);
        expect(
          newer.presentationContext,
          HistoricalArchivesPresentationContext.addArchive,
        );
        expect(
          newer.presentationStage,
          HistoricalArchivesPresentationStage.readyForImport,
        );
        expect(newer.selectedFolderPath, '/tmp/new-archive');
        expect(newer.importSuccessNotice, isNull);
      },
    );

    test(
      'partial graph failure preserves its last truthful unit and never dwells',
      () async {
        final graphImportService = _ControlledArchiveGraphImportService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage.importingSourceFacts,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage
                  .projectingConversationGraph,
              transition: SourceScopedArchiveGraphImportStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphImportObservation(
              stage: SourceScopedArchiveGraphImportStage
                  .projectingConversationGraph,
              transition:
                  SourceScopedArchiveGraphImportStageTransition.progressed,
              projectionProgress: SourceScopedArchiveGraphProjectionProgress(
                activeUnit: SourceScopedArchiveGraphProjectionUnit.messages,
                completedUnitCount: 2,
                totalUnitCount: 5,
                completedWorkCount: 500,
                totalWorkCount: 1000,
              ),
            ),
          );
          throw StateError('graph projection failed for testing');
        });
        final container = ProviderContainer(
          overrides: [
            archiveMutationCoordinatorProvider.overrideWith(
              () => _ImmediateArchiveMutationCoordinator(),
            ),
            sourceScopedArchiveGraphImportServiceProvider.overrideWith(
              (ref) async => graphImportService,
            ),
            archiveSourceInspectorProvider.overrideWith(
              (ref) async => const _ImmediateArchiveSourceInspector(),
            ),
            historicalArchiveSourcesProvider.overrideWith(
              (ref) async => _RecordingHistoricalArchiveSources(),
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
        await workflow.loadFolder(folderPath: '/tmp/archive');
        await workflow.beginImportForSelectedSource();

        final failed = container.read(historicalArchivesWorkflowProvider);
        expect(
          failed.presentationContext,
          HistoricalArchivesPresentationContext.importFailed,
        );
        expect(
          failed.importProgress?.statusFor(
            HistoricalArchiveImportStage.preparingConversations,
          ),
          HistoricalArchiveImportStageStatus.failed,
        );
        expect(
          failed.importProgress?.graphProjectionProgress?.activeUnit,
          SourceScopedArchiveGraphProjectionUnit.messages,
        );
        expect(
          failed.importProgress?.graphProjectionProgress?.completedUnitCount,
          2,
        );
        expect(
          failed.importProgress?.graphProjectionProgress?.totalUnitCount,
          5,
        );
        expect(
          buildHistoricalArchivesWorkflowPanelModel(
                executionGateState: const ArchiveMutationCoordinatorState(),
                isMaintenanceLocked: false,
                workflowState: failed,
                currentMessagesDatabasePath: currentMessagesDatabasePath,
              ).narratorPresentation?.instrumentationRows
              .singleWhere((row) => row.label == 'Messages')
              .value,
          'Failed · 500 / 1,000',
        );
        expect(failed.knownSourceReference, isNull);
        expect(failed.selectedKnownSourceKey, isNull);
        expect(failed.importSuccessNotice, isNull);
      },
    );

    test('stale success dismissal cannot change a newer presentation', () {
      final workflow = _ControllableHistoricalArchivesWorkflow();
      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowProvider.overrideWith(() => workflow),
        ],
      );
      addTearDown(container.dispose);
      container.read(historicalArchivesWorkflowProvider);

      workflow.emitImportSuccessNotice();
      workflow.resetPresentationContext();
      workflow.emitNewCandidate();

      workflow.dismissImportSuccessNotice(
        noticeOccurrence: 1,
        presentationSessionOccurrence: 0,
      );

      final state = container.read(historicalArchivesWorkflowProvider);
      expect(
        state.presentationContext,
        HistoricalArchivesPresentationContext.addArchive,
      );
      expect(state.selectedFolderPath, '/tmp/new-archive');
    });

    testWidgets(
      'duplicate add restores hub and emits a bounded reference only after dismissal',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/tmp/archive/chat.db';
        final archiveSources = _RecordingHistoricalArchiveSources([
          _successfullyImportedArchiveSource(sourceKey: sourceKey),
        ]);
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
        expect(firstReference.knownSourceReference?.referenceOccurrence, 1);
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
              ?.referenceOccurrence,
          2,
        );

        await tester.pump(const Duration(milliseconds: 1000));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference
              ?.referenceOccurrence,
          2,
        );
        await tester.pump(const Duration(milliseconds: 2749));
        expect(
          container
              .read(historicalArchivesWorkflowProvider)
              .knownSourceReference,
          isNotNull,
        );
        await tester.pump(const Duration(milliseconds: 1));
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
              (ref) async => _FakeHistoricalArchiveSources([
                _successfullyImportedArchiveSource(sourceKey: sourceKey),
              ]),
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
      'known-source navigation uses canonical identity without a reference event',
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
                  lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
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
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: state,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(model.narratorPresentation, isNull);
        expect(
          model.existingSourcePresentation?.sourceTypeStatement,
          'This is a Mac Messages folder.',
        );
        expect(
          model.existingSourcePresentation?.importDateStatement,
          'You added it to MessageLens on Aug 10, 2026.',
        );
        expect(
          model.existingSourcePresentation?.contentsStatement,
          'It contains 42 messages sent or received between July 2012 and June 2017.',
        );
        expect(
          model.existingSourcePresentation?.detailsLines,
          contains('Folder: /tmp/archive'),
        );
        expect(model.importButtonEnabled, isFalse);
        expect(model.removeImportedArchiveDataEnabled, isTrue);
      },
    );

    test(
      'selected source removal exposes real ordered stages then returns to hub',
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
          lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final verificationCompleter =
            Completer<HistoricalArchiveImportedSourceMatch?>();
        final lookup = _FinalVerificationImportedSourceLookup(
          match: const HistoricalArchiveImportedSourceMatch(
            sourceKey: sourceKey,
            sourceId: 3,
            importedMessageCount: 42,
          ),
          verificationCompleter: verificationCompleter,
        );
        final factsRemovalCompleter = Completer<void>();
        final graphRebuildCompleter = Completer<void>();
        final removalService = _RecordingArchiveRemovalService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          await factsRemovalCompleter.future;
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          await graphRebuildCompleter.future;
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          return const SourceScopedArchiveGraphRemovalResult(
            sourceId: 3,
            deletionResult: null,
            graphReprojected: true,
          );
        });
        final coordinator = _ImmediateArchiveMutationCoordinator();
        final container = ProviderContainer(
          overrides: [
            archiveMutationCoordinatorProvider.overrideWith(() => coordinator),
            sourceScopedArchiveGraphRemovalServiceProvider.overrideWith(
              (ref) async => removalService,
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => const [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => lookup,
            ),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => currentMessagesDatabasePath,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(sourceKey: sourceKey);

        final removal = workflow.removeImportedArchiveDataForSelectedSource();
        await Future<void>.delayed(Duration.zero);

        final running = container.read(historicalArchivesWorkflowProvider);
        final runningModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: running,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          running.presentationContext,
          HistoricalArchivesPresentationContext.removingSource,
        );
        expect(running.selectedKnownSourceKey, sourceKey);
        expect(
          runningModel.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.removingSource,
        );
        expect(
          runningModel.narratorPresentation?.instrumentationRows
              .map((row) => (row.label, row.value))
              .toList(),
          const [
            ('Removing messages added from this folder', 'Working'),
            ('Updating your MessageLens history', 'Waiting'),
            ('Checking that removal finished', 'Waiting'),
          ],
        );
        expect(removalService.callCount, 1);
        expect(coordinator.runCallCount, 1);

        factsRemovalCompleter.complete();
        await Future<void>.delayed(Duration.zero);
        final rebuildingModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: container.read(historicalArchivesWorkflowProvider),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          rebuildingModel.narratorPresentation?.instrumentationRows
              .map((row) => row.value)
              .toList(),
          const ['Done', 'Working', 'Waiting'],
        );

        graphRebuildCompleter.complete();
        await Future<void>.delayed(Duration.zero);
        final verifyingModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: container.read(historicalArchivesWorkflowProvider),
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          verifyingModel.narratorPresentation?.instrumentationRows
              .map((row) => row.value)
              .toList(),
          const ['Done', 'Done', 'Working'],
        );

        verificationCompleter.complete(null);
        await removal;

        final completed = container.read(historicalArchivesWorkflowProvider);
        final completedModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: completed,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          completed.presentationContext,
          HistoricalArchivesPresentationContext.hub,
        );
        expect(completed.selectedKnownSourceKey, isNull);
        expect(completed.selectedFolderPath, isNull);
        expect(completedModel.isHub, isTrue);
        expect(completedModel.narratorPresentation, isNull);
        expect(completedModel.existingSourcePresentation, isNull);
        expect(
          await container.read(historicalArchiveSourceMetadataProvider.future),
          const [source],
        );
      },
    );

    test(
      'failed graph rebuild preserves stage truth while imported facts remain',
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
          lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final lookup = _MutableImportedSourceLookup(
          match: const HistoricalArchiveImportedSourceMatch(
            sourceKey: sourceKey,
            sourceId: 3,
            importedMessageCount: 42,
          ),
        );
        final removalService = _RecordingArchiveRemovalService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          throw StateError('projection failed');
        });
        final container = ProviderContainer(
          overrides: [
            archiveMutationCoordinatorProvider.overrideWith(
              _ImmediateArchiveMutationCoordinator.new,
            ),
            sourceScopedArchiveGraphRemovalServiceProvider.overrideWith(
              (ref) async => removalService,
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => const [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => lookup,
            ),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => currentMessagesDatabasePath,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(sourceKey: sourceKey);
        await workflow.removeImportedArchiveDataForSelectedSource();

        final failed = container.read(historicalArchivesWorkflowProvider);
        final failedModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: failed,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          failed.presentationContext,
          HistoricalArchivesPresentationContext.removingSource,
        );
        expect(failed.selectedKnownSourceKey, sourceKey);
        expect(failed.removalFailureDetail, contains('projection failed'));
        expect(
          failedModel.narratorPresentation?.instrumentationRows
              .map((row) => row.value)
              .toList(),
          const ['Done', "Couldn't finish", 'Waiting'],
        );
        expect(
          failedModel.narratorPresentation?.kind,
          HistoricalArchivesNarratorPresentationKind.removalFailed,
        );
        expect(failedModel.removeImportedArchiveDataEnabled, isFalse);
        expect(removalService.callCount, 1);
      },
    );

    test(
      'partial failure after fact deletion cannot falsely return to hub',
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
          lastImportFinishedAtUtc: '2026-08-10T18:30:00.000Z',
          lastImportSuccess: true,
          lastImportError: null,
          lastImportedMessageCount: 42,
        );
        final lookup = _MutableImportedSourceLookup(
          match: const HistoricalArchiveImportedSourceMatch(
            sourceKey: sourceKey,
            sourceId: 3,
            importedMessageCount: 42,
          ),
        );
        final removalService = _RecordingArchiveRemovalService((
          observer,
        ) async {
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          lookup.match = null;
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage.removingImportedFacts,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.completed,
            ),
          );
          observer?.call(
            const SourceScopedArchiveGraphRemovalObservation(
              stage: SourceScopedArchiveGraphRemovalStage
                  .rebuildingConversationGraph,
              transition:
                  SourceScopedArchiveGraphRemovalStageTransition.started,
            ),
          );
          throw StateError('projection failed after deletion');
        });
        final container = ProviderContainer(
          overrides: [
            archiveMutationCoordinatorProvider.overrideWith(
              _ImmediateArchiveMutationCoordinator.new,
            ),
            sourceScopedArchiveGraphRemovalServiceProvider.overrideWith(
              (ref) async => removalService,
            ),
            historicalArchiveSourceMetadataProvider.overrideWith(
              (ref) async => const [source],
            ),
            historicalArchiveImportedSourceLookupProvider.overrideWith(
              (ref) async => lookup,
            ),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => currentMessagesDatabasePath,
            ),
          ],
        );
        addTearDown(container.dispose);

        final workflow = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );
        await workflow.showKnownSource(sourceKey: sourceKey);
        await workflow.removeImportedArchiveDataForSelectedSource();

        final failed = container.read(historicalArchivesWorkflowProvider);
        final failedModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ArchiveMutationCoordinatorState(),
          isMaintenanceLocked: false,
          workflowState: failed,
          currentMessagesDatabasePath: currentMessagesDatabasePath,
        );
        expect(
          failed.presentationContext,
          HistoricalArchivesPresentationContext.removingSource,
        );
        expect(failed.selectedKnownSourceKey, sourceKey);
        expect(
          failed.removalFailureDetail,
          contains('Messages from this folder are no longer present'),
        );
        expect(
          failedModel.narratorPresentation?.instrumentationRows
              .map((row) => row.value)
              .toList(),
          const ['Done', "Couldn't finish", 'Waiting'],
        );
        expect(failedModel.isHub, isFalse);
        expect(failedModel.narratorPresentation, isNotNull);
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

final class _ControllableHistoricalArchivesWorkflow
    extends HistoricalArchivesWorkflow {
  @override
  HistoricalArchivesWorkflowState build() =>
      buildInitialHistoricalArchivesWorkflowState();

  void emitImportSuccessNotice() {
    state = buildInitialHistoricalArchivesWorkflowState().copyWith(
      importSuccessNotice: const HistoricalArchivesImportSuccessNotice(
        noticeOccurrence: 1,
        presentationSessionOccurrence: 0,
      ),
    );
  }

  void emitNewCandidate() {
    state = buildInitialHistoricalArchivesWorkflowState().copyWith(
      presentationContext: HistoricalArchivesPresentationContext.addArchive,
      presentationStage: HistoricalArchivesPresentationStage.readyForImport,
      selectedFolderPath: '/tmp/new-archive',
    );
  }
}

final class _FakeFolderChooser implements HistoricalArchiveFolderChooser {
  const _FakeFolderChooser(this.folderPath);

  final String folderPath;

  @override
  Future<String?> chooseMessagesFolder() async => folderPath;
}

final class _RecordingFolderChooser implements HistoricalArchiveFolderChooser {
  _RecordingFolderChooser(this.folderPath);

  final String folderPath;
  var callCount = 0;

  @override
  Future<String?> chooseMessagesFolder() async {
    callCount += 1;
    return folderPath;
  }
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

final class _MutableImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  _MutableImportedSourceLookup({required this.match});

  HistoricalArchiveImportedSourceMatch? match;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required String folderPath,
  }) async {
    return match;
  }

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSourceByKey({
    required String sourceKey,
  }) async {
    return match?.sourceKey == sourceKey ? match : null;
  }
}

final class _FinalVerificationImportedSourceLookup
    implements HistoricalArchiveImportedSourceLookup {
  _FinalVerificationImportedSourceLookup({
    required this.match,
    required this.verificationCompleter,
  });

  final HistoricalArchiveImportedSourceMatch match;
  final Completer<HistoricalArchiveImportedSourceMatch?> verificationCompleter;
  var _sourceKeyLookupCount = 0;

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSource({
    required String folderPath,
  }) async {
    return match;
  }

  @override
  Future<HistoricalArchiveImportedSourceMatch?> findImportedSourceByKey({
    required String sourceKey,
  }) {
    _sourceKeyLookupCount += 1;
    if (_sourceKeyLookupCount == 1) {
      return Future.value(match.sourceKey == sourceKey ? match : null);
    }
    return verificationCompleter.future;
  }
}

final class _ControlledArchiveGraphImportService
    implements SourceScopedArchiveGraphImportService {
  _ControlledArchiveGraphImportService(this._importAndProject);

  final Future<SourceScopedArchiveGraphImportResult> Function(
    SourceScopedArchiveGraphImportObserver? observer,
  )
  _importAndProject;
  var callCount = 0;

  @override
  Future<SourceScopedArchiveGraphImportResult> importAndProject({
    required String folderPath,
    String? sourceLabel,
    SourceScopedArchiveGraphImportObserver? onObservation,
  }) async {
    callCount += 1;
    return _importAndProject(onObservation);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _RecordingArchiveRemovalService
    implements SourceScopedArchiveGraphRemovalService {
  _RecordingArchiveRemovalService(this._remove);

  final Future<SourceScopedArchiveGraphRemovalResult> Function(
    SourceScopedArchiveGraphRemovalObserver? observer,
  )
  _remove;
  var callCount = 0;

  @override
  Future<SourceScopedArchiveGraphRemovalResult> removeArchiveSource({
    required String folderPath,
    SourceScopedArchiveGraphRemovalObserver? onObservation,
  }) async {
    callCount += 1;
    return _remove(onObservation);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _ImmediateArchiveMutationCoordinator
    extends ArchiveMutationCoordinator {
  var runCallCount = 0;

  @override
  ArchiveMutationCoordinatorState build() {
    return const ArchiveMutationCoordinatorState();
  }

  @override
  Future<T> run<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function() action,
  }) async {
    runCallCount += 1;
    return action();
  }
}

final class _FakeHistoricalArchiveSources implements HistoricalArchiveSources {
  const _FakeHistoricalArchiveSources([
    this.sources = const <HistoricalArchiveSourceMetadata>[],
  ]);

  final List<HistoricalArchiveSourceMetadata> sources;

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async =>
      sources;

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {}
}

final class _RecordingHistoricalArchiveSources
    implements HistoricalArchiveSources {
  _RecordingHistoricalArchiveSources([
    this.sources = const <HistoricalArchiveSourceMetadata>[],
  ]);

  final List<HistoricalArchiveSourceMetadata> sources;
  var upsertCallCount = 0;
  var successfulImportUpdateCount = 0;

  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async =>
      sources;

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {
    upsertCallCount += 1;
    if (update.lastImportSuccess == true) {
      successfulImportUpdateCount += 1;
    }
  }
}

Future<void> _waitUntil(bool Function() predicate) async {
  final stopwatch = Stopwatch()..start();
  while (!predicate()) {
    if (stopwatch.elapsed > const Duration(seconds: 2)) {
      fail('Timed out waiting for asynchronous workflow state.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void _emitCompleteGraphProjection(
  SourceScopedArchiveGraphImportObserver? observer,
) {
  observer?.call(
    const SourceScopedArchiveGraphImportObservation(
      stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
      transition: SourceScopedArchiveGraphImportStageTransition.started,
    ),
  );
  for (
    var index = 0;
    index < SourceScopedArchiveGraphProjectionUnit.values.length;
    index += 1
  ) {
    observer?.call(
      SourceScopedArchiveGraphImportObservation(
        stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
        transition: SourceScopedArchiveGraphImportStageTransition.progressed,
        projectionProgress: SourceScopedArchiveGraphProjectionProgress(
          activeUnit: SourceScopedArchiveGraphProjectionUnit.values[index],
          completedUnitCount: index,
          totalUnitCount: SourceScopedArchiveGraphProjectionUnit.values.length,
        ),
      ),
    );
  }
  observer?.call(
    const SourceScopedArchiveGraphImportObservation(
      stage: SourceScopedArchiveGraphImportStage.projectingConversationGraph,
      transition: SourceScopedArchiveGraphImportStageTransition.completed,
    ),
  );
}

SourceScopedArchiveGraphImportResult _successfulArchiveGraphImportResult({
  required String sourceKey,
}) {
  return SourceScopedArchiveGraphImportResult(
    importResult: SourceScopedArchiveImportResult(
      registration: HistoricalMessagesArchiveSourceRegistration(
        sourceId: 3,
        sourceKey: sourceKey,
        sourceKind: 'historical_messages_archive',
        sourceLabel: 'archive',
        selectedFolderPath: '/tmp/archive',
        chatDbPath: '/tmp/archive/chat.db',
      ),
      messages: const MessageImportResult(
        startedAfterSourceRowId: 0,
        insertedMessageCount: 42,
        lastImportedSourceRowId: 42,
      ),
      chats: const ChatImportResult(examinedChatCount: 4, insertedChatCount: 4),
      handles: const HandleImportResult(
        startedAfterSourceRowId: 0,
        insertedHandleCount: 7,
        lastImportedSourceRowId: 7,
      ),
      attachments: const AttachmentImportResult(
        startedAfterSourceRowId: 0,
        examinedAttachmentCount: 0,
        insertedAttachmentCount: 0,
        lastImportedSourceRowId: null,
      ),
      chatMessageEdges: const ChatMessageJoinImportResult(
        examinedJoinCount: 42,
        insertedJoinCount: 42,
      ),
      chatHandleEdges: const ChatHandleJoinImportResult(
        examinedJoinCount: 7,
        insertedJoinCount: 7,
      ),
      messageAttachmentEdges: const MessageAttachmentJoinImportResult(
        examinedJoinCount: 0,
        insertedJoinCount: 0,
      ),
      textEnrichment: const MessageRichTextEnrichmentResult(
        candidateMessageCount: 0,
        enrichedMessageCount: 0,
        missingExtractionCount: 0,
        extractorAvailable: true,
      ),
    ),
    projectionResult: const SourceScopedArchiveGraphProjectionResult(
      handles: HandleProjectionResult(
        examinedHandleCount: 7,
        insertedHandleCount: 7,
      ),
      chatHandleEdges: ChatToHandleProjectionResult(
        examinedEdgeCount: 7,
        insertedEdgeCount: 7,
      ),
      chats: ChatProjectionResult(examinedChatCount: 4, insertedChatCount: 4),
      messages: MessageProjectionResult(
        examinedMessageCount: 42,
        insertedMessageCount: 42,
      ),
      attachments: AttachmentProjectionResult(
        examinedAttachmentCount: 0,
        insertedAttachmentCount: 0,
      ),
      chatMessageEdges: ChatToMessageProjectionResult(
        examinedEdgeCount: 42,
        insertedEdgeCount: 42,
      ),
      messageAttachmentEdges: MessageToAttachmentProjectionResult(
        examinedEdgeCount: 0,
        insertedEdgeCount: 0,
      ),
    ),
  );
}

HistoricalArchiveSourceMetadata _successfullyImportedArchiveSource({
  required String sourceKey,
}) {
  return HistoricalArchiveSourceMetadata(
    sourceKey: sourceKey,
    sourceChatDb: '/tmp/archive/chat.db',
    folderPath: '/tmp/archive',
    sourceLabel: 'archive',
    chatDbStatusLabel: 'Found and readable',
    attachmentsStatusLabel: 'Not found',
    preflightStatusLabel: 'Imported successfully',
    totalMessages: 42,
    earliestMessageUtc: '2012-07-25T08:00:00.000Z',
    latestMessageUtc: '2017-06-11T08:00:00.000Z',
    dryRunNewMessages: 42,
    dryRunDuplicateMessages: 0,
    lastImportFinishedAtUtc: '2026-08-19T12:00:00.000Z',
    lastImportSuccess: true,
    lastImportError: null,
    lastImportedMessageCount: 42,
  );
}
