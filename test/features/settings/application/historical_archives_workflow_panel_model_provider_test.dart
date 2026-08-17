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
import 'package:remember_this_text/features/settings/application/archive_source_inspection.dart';
import 'package:remember_this_text/features/settings/application/archive_source_inspector_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_folder_chooser.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_folder_chooser_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_sources_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/archive_source_inspection_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const currentMessagesDatabasePath = '/Users/test/Library/Messages/chat.db';

  group('buildHistoricalArchivesWorkflowPanelModel', () {
    test('projects the empty workflow as the no-source narrator state', () {
      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ArchiveMutationCoordinatorState(),
        isMaintenanceLocked: false,
        workflowState: buildInitialHistoricalArchivesWorkflowState(),
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      );

      expect(
        model.narratorPresentation?.kind,
        HistoricalArchivesNarratorPresentationKind.noSource,
      );
      expect(model.narratorPresentation?.instrumentationRows, isEmpty);
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
        dryRunUnavailableReason: null,
      );
      final workflowState = buildInitialHistoricalArchivesWorkflowState()
          .copyWith(
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
        dryRunUnavailableReason: 'Graph comparison is unavailable.',
      );
      final workflowState = buildInitialHistoricalArchivesWorkflowState()
          .copyWith(
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
      'failed inspection distinguishes deterministic and retryable failure',
      () {
        HistoricalArchivesWorkflowPanelViewModel buildFailure(
          String chatDbStatus,
        ) {
          final workflowState = buildInitialHistoricalArchivesWorkflowState()
              .copyWith(
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
              (ref) async => _FakeHistoricalArchiveSources(),
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

      await graphDb.executeSql(
        "INSERT INTO messages (ss_id, guid, is_from_me) VALUES (1, 'm1', 0), (2, 'projected-only', 0)",
      );

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

final class _FakeHistoricalArchiveSources implements HistoricalArchiveSources {
  @override
  Future<List<HistoricalArchiveSourceMetadata>> readKnownSources() async => [];

  @override
  Future<void> upsertSourceMetadata(
    HistoricalArchiveSourceMetadataUpdate update,
  ) async {}
}
