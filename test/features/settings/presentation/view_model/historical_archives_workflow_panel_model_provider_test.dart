import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_importers/application/debug_settings_provider.dart';
import 'package:remember_this_text/essentials/db_importers/application/import_execution_gate_provider.dart';
import 'package:remember_this_text/essentials/db_importers/application/services/orchestrated_ledger_import_service.dart';
import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_importers/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/db_importers/domain/states/table_import_progress.dart';
import 'package:remember_this_text/essentials/db_importers/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db_importers/presentation/view_model/db_import_control_provider.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';
import 'package:remember_this_text/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('buildHistoricalArchivesWorkflowPanelModel', () {
    test(
      'reports available execution gate when no shared pipeline owns it',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ImportExecutionGateState(),
          isMaintenanceLocked: false,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
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
      'reports busy execution gate when canonical import pipeline owns it',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ImportExecutionGateState(
            owner: 'db-import-control',
            holdCount: 1,
          ),
          isMaintenanceLocked: true,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
        );

        expect(
          model.executionGate.status,
          HistoricalArchivesExecutionGateStatus.busy,
        );
        expect(model.executionGate.detail, contains('Import or migration'));
        expect(model.statusLabel, 'Execution Gate Busy');
        expect(
          model.summaryText,
          contains('canonical import pipeline is currently busy'),
        );
        expect(model.importButtonDetail, contains('import or migration'));
        expect(model.activityLog.last.label, 'Execution gate busy');
      },
    );

    test(
      'reports blocked execution gate when maintenance lock is active without gate ownership',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ImportExecutionGateState(),
          isMaintenanceLocked: true,
          workflowState: buildInitialHistoricalArchivesWorkflowState(),
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
            matchedImportedArchiveBatchCount: 2,
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
        executionGateState: const ImportExecutionGateState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
      );

      expect(model.statusLabel, 'Archive Source Ready');
      expect(model.summaryText, contains('completed source preflight'));
      expect(model.selectedFolderPath, '/tmp/Archive-2017');
      expect(model.preflightSummaryLines.single, 'Total messages: 42');
      expect(model.importButtonEnabled, isTrue);
      expect(
        model.importButtonDetail,
        contains('run the normal canonical migration orchestrator'),
      );
      expect(
        model.archiveManagementSummaryLines,
        contains('Removal target chat.db: /tmp/Archive-2017/chat.db'),
      );
      expect(
        model.archiveManagementSummaryLines,
        contains('Matched imported archive batches in db-import: 2'),
      );
      expect(model.removeImportedArchiveDataEnabled, isTrue);
      expect(
        model.removeImportedArchiveDataDetail,
        contains('2 matched batches'),
      );
    });

    test(
      'maps live migration stages into sequential archive phases with exactly one running step',
      () {
        final workflowState = buildInitialHistoricalArchivesWorkflowState()
            .copyWith(
              preflight: const HistoricalArchivesPreflightViewModel(
                status: HistoricalArchivesPreflightStatus.running,
                statusLabel: 'Migration running',
                detail:
                    'Archive rows were written to db-import. Running the normal canonical migration orchestrator now.',
              ),
              selectedFolderPath: '/tmp/Archive-2017',
              chatDbStatusLabel: 'Found and readable',
              attachmentsStatusLabel: 'Found',
              sourceLabel: 'Archive-2017',
            );

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ImportExecutionGateState(),
          isMaintenanceLocked: false,
          workflowState: workflowState,
          dbImportControlState: const DbImportControlState(
            isProcessing: true,
            stages: <UiStageProgress>[
              UiStageProgress(
                name: 'handles',
                displayName: 'Handles',
                sortIndex: 0,
                isComplete: true,
                progress: 1.0,
              ),
              UiStageProgress(
                name: 'messages',
                displayName: 'Messages',
                sortIndex: 1,
                isActive: true,
                progress: 0.42,
                current: 42,
                total: 100,
              ),
              UiStageProgress(
                name: 'rebuild_indexes',
                displayName: 'Rebuild Indexes',
                sortIndex: 2,
              ),
            ],
          ),
        );

        final runningPhases = model.phases
            .where(
              (phase) =>
                  phase.status == HistoricalArchivesWorkflowPhaseStatus.running,
            )
            .toList(growable: false);

        expect(runningPhases, hasLength(1));
        expect(runningPhases.single.label, 'Build working messages');
        expect(runningPhases.single.progress, 0.42);
        expect(
          runningPhases.single.detail,
          'Processed: 42 / 100 messages (42%)',
        );
        final rebuildIndexesPhase = model.phases.firstWhere(
          (phase) => phase.label == 'Rebuild indexes',
        );
        expect(
          rebuildIndexesPhase.status,
          HistoricalArchivesWorkflowPhaseStatus.waiting,
        );
      },
    );

    test(
      'reports import-and-migration-complete state after archive ingestion',
      () {
        final workflowState = buildInitialHistoricalArchivesWorkflowState()
            .copyWith(
              preflight: const HistoricalArchivesPreflightViewModel(
                status: HistoricalArchivesPreflightStatus.migrationCompleted,
                statusLabel: 'Archive Import Complete',
                detail:
                    'Archive rows were written to db-import, migrated into working.db, and refreshed through the normal timeline, search, and heatmap surfaces.',
              ),
              selectedFolderPath: '/tmp/Archive-2017',
              chatDbStatusLabel: 'Found and readable',
              attachmentsStatusLabel: 'Found',
              sourceLabel: 'Archive-2017',
              archiveRemovalTargetChatDbPath: '/tmp/Archive-2017/chat.db',
              activityLog: const [
                HistoricalArchivesLogEntryViewModel(
                  label: 'Archive import and migration complete',
                  message: 'Ledger rows were written and migration finished.',
                ),
              ],
            );

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ImportExecutionGateState(),
          isMaintenanceLocked: false,
          workflowState: workflowState,
        );

        expect(model.statusLabel, 'Archive Import Complete');
        expect(
          model.summaryText,
          contains(
            'Archive rows are now visible through the normal app surfaces',
          ),
        );
        expect(model.importButtonEnabled, isFalse);
        expect(
          model.importButtonDetail,
          contains('already completed for this source'),
        );
      },
    );

    test('reports migration-failed-after-import state clearly', () {
      final workflowState = buildInitialHistoricalArchivesWorkflowState().copyWith(
        preflight: const HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.failed,
          statusLabel: 'Migration failed after archive import',
          detail:
              'Archive ledger import succeeded, but the canonical migration did not report success.',
        ),
        selectedFolderPath: '/tmp/Archive-2017',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Found',
        sourceLabel: 'Archive-2017',
        archiveRemovalTargetChatDbPath: '/tmp/Archive-2017/chat.db',
      );

      final model = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ImportExecutionGateState(),
        isMaintenanceLocked: false,
        workflowState: workflowState,
      );

      expect(model.statusLabel, 'Migration failed after archive import');
      expect(model.summaryText, contains('Archive ledger import succeeded'));
      expect(model.importButtonEnabled, isFalse);
      expect(model.importButtonDetail, contains('canonical migration failed'));
    });

    test(
      'clarifies when duplicates come from current Mac data and no archive batches remain to delete',
      () {
        final workflowState = buildInitialHistoricalArchivesWorkflowState().copyWith(
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
          matchedImportedArchiveBatchCount: 0,
          preflightSummaryLines: const [
            'Total messages: 6513',
            'Already in current Mac import: 6513 GUID-backed source rows',
            'Already in historical archive imports: 0 GUID-backed source rows',
          ],
          dryRunSummaryLines: const [
            'Estimated duplicates: 6513 GUID-backed source rows already projected',
          ],
        );

        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ImportExecutionGateState(),
          isMaintenanceLocked: false,
          workflowState: workflowState,
        );

        expect(model.removeImportedArchiveDataEnabled, isFalse);
        expect(
          model.removeImportedArchiveDataDetail,
          contains(
            'duplicate count is coming from messages already present in your current MessageLens data',
          ),
        );
        expect(
          model.archiveManagementSummaryLines,
          contains('Matching GUIDs already in current Mac import: 6513'),
        );
        expect(
          model.archiveManagementSummaryLines,
          contains('Matching GUIDs already in historical archive imports: 0'),
        );
      },
    );
  });

  group('buildHistoricalArchivesImportDialogViewModel', () {
    test('maps migration-completed state to terminal success dialog', () {
      final panelModel = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ImportExecutionGateState(),
        isMaintenanceLocked: false,
        workflowState: buildInitialHistoricalArchivesWorkflowState().copyWith(
          preflight: const HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.migrationCompleted,
            statusLabel: 'Archive Import Complete',
            detail:
                'Archive rows were written to db-import, migrated into working.db, and refreshed through the normal timeline, search, and heatmap surfaces.',
          ),
          selectedFolderPath: '/tmp/Archive-2017',
          sourceLabel: 'Archive-2017',
          preflightSummaryLines: const [
            'Rows with missing GUIDs: 0',
            'Already in current Mac import: 6,513',
            'Already in historical archive imports: 0',
            'Earliest message: 2012-07-25',
            'Latest message: 2017-06-11',
          ],
          dryRunSummaryLines: const ['Estimated new messages: 2,369'],
        ),
      );

      final dialogModel = buildHistoricalArchivesImportDialogViewModel(
        panelModel: panelModel,
      );

      expect(dialogModel.state, HistoricalArchivesImportDialogState.success);
      expect(dialogModel.title, 'Import Complete');
      expect(dialogModel.dismissActionLabel, 'Done');
      expect(dialogModel.summaryLines, contains('New messages added: 2,369'));
      expect(
        dialogModel.summaryLines,
        contains('Already in current Mac data: 6,513'),
      );
      expect(
        dialogModel.summaryLines,
        contains('Already imported from archives: 0'),
      );
      expect(dialogModel.summaryLines, contains('Missing identifiers: 0'));
      expect(
        dialogModel.summaryLines,
        contains('Date range: 2012-07-25 -> 2017-06-11'),
      );
    });

    test(
      'maps migration-failed-after-import state to visibility failure dialog',
      () {
        final panelModel = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const ImportExecutionGateState(),
          isMaintenanceLocked: false,
          workflowState: buildInitialHistoricalArchivesWorkflowState().copyWith(
            preflight: const HistoricalArchivesPreflightViewModel(
              status: HistoricalArchivesPreflightStatus.failed,
              statusLabel: 'Migration failed after archive import',
              detail:
                  'Archive ledger import succeeded, but the canonical migration did not report success.',
            ),
            sourceLabel: 'Archive-2017',
            archiveRemovalTargetChatDbPath: '/tmp/Archive-2017/chat.db',
            matchedImportedArchiveBatchCount: 1,
            phases: const [
              HistoricalArchivesWorkflowPhaseViewModel(
                label: 'Running full canonical migration',
                status: HistoricalArchivesWorkflowPhaseStatus.failed,
                detail: 'Migration failed in test.',
              ),
            ],
          ),
        );

        final dialogModel = buildHistoricalArchivesImportDialogViewModel(
          panelModel: panelModel,
        );

        expect(dialogModel.state, HistoricalArchivesImportDialogState.failure);
        expect(dialogModel.title, 'Import Could Not Be Made Visible');
        expect(dialogModel.dismissActionLabel, 'Close');
        expect(
          dialogModel.failureStageLabel,
          'Running full canonical migration',
        );
        expect(
          dialogModel.summaryLines,
          contains('Failed stage: Running full canonical migration'),
        );
        expect(dialogModel.cleanupAvailable, isTrue);
      },
    );

    test('maps post-migration health failure to app-data-not-ready dialog', () {
      final panelModel = buildHistoricalArchivesWorkflowPanelModel(
        executionGateState: const ImportExecutionGateState(),
        isMaintenanceLocked: false,
        workflowState: buildInitialHistoricalArchivesWorkflowState().copyWith(
          preflight: const HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.failed,
            statusLabel: 'Import completed but app data is not ready',
            detail:
                'Archive rows were imported, but MessageLens could not confirm that normal app views refreshed correctly. Failed health check: contact picker has no selectable contacts.',
          ),
          sourceLabel: 'Archive-2017',
          resultSummaryLines: const [
            'Failed health check: contact picker has no selectable contacts',
          ],
          phases: const [
            HistoricalArchivesWorkflowPhaseViewModel(
              label: 'Refreshing app-visible data',
              status: HistoricalArchivesWorkflowPhaseStatus.failed,
              detail: 'Health verification failed in test.',
            ),
          ],
        ),
      );

      final dialogModel = buildHistoricalArchivesImportDialogViewModel(
        panelModel: panelModel,
      );

      expect(dialogModel.state, HistoricalArchivesImportDialogState.failure);
      expect(dialogModel.title, 'Import Completed But App Data Is Not Ready');
      expect(dialogModel.failureStageLabel, 'Refreshing app-visible data');
      expect(
        dialogModel.summaryLines,
        contains(
          'Failed health check: contact picker has no selectable contacts',
        ),
      );
    });
  });

  group('preflightHistoricalArchivesFolder', () {
    late WorkingDatabase workingDb;

    setUp(() {
      workingDb = WorkingDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await workingDb.close();
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

      await workingDb.customStatement(
        "INSERT INTO chats (id, guid, service) VALUES (1, 'chat-guid-1', 'iMessage')",
      );
      await workingDb.customStatement(
        "INSERT INTO messages (guid, chat_id, status) VALUES ('m1', 1, 'unknown'), ('projected-only', 1, 'unknown')",
      );

      final result = await preflightHistoricalArchivesFolder(
        folderPath: tempDirectory.path,
        workingDb: workingDb,
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
        contains(
          'Likely duplicates already in working.db: 1 GUID-backed source rows',
        ),
      );
      expect(
        result.preflightSummaryLines,
        contains('Likely new rows: 1 GUID-backed source rows'),
      );
      expect(
        result.dryRunSummaryLines,
        contains(
          'Estimated new messages: 1 GUID-backed source rows not present in working.db',
        ),
      );
      expect(
        result.dryRunSummaryLines,
        contains(
          'Estimated duplicates: 1 GUID-backed source rows already projected',
        ),
      );
      expect(result.activityLog[1].label, 'Dry run ready');
    });

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
        workingDb: workingDb,
      );

      expect(result.preflight.status, HistoricalArchivesPreflightStatus.failed);
      expect(result.chatDbStatusLabel, 'Missing');
      expect(result.preflight.detail, contains('does not contain chat.db'));
      expect(result.activityLog.single.label, 'Preflight failed');
    });
  });

  group('HistoricalArchivesWorkflow notifier', () {
    late Directory tempDirectory;
    late WorkingDatabase workingDb;
    late SqfliteImportDatabase importDb;
    late ProviderContainer container;

    setUp(() async {
      _FakeHistoricalArchiveDbImportControlViewModel.resetCounters();
      _FakeHistoricalArchiveImportService.resetCounters();
      tempDirectory = await Directory.systemTemp.createTemp(
        'historical-archives-workflow-notifier-',
      );

      final chatDbPath = '${tempDirectory.path}/chat.db';
      final sourceDatabase = sqlite3.open(chatDbPath);
      try {
        sourceDatabase.execute('CREATE TABLE message (guid TEXT);');
        sourceDatabase.execute('CREATE TABLE chat (id INTEGER PRIMARY KEY);');
        sourceDatabase.execute('CREATE TABLE handle (id INTEGER PRIMARY KEY);');
        sourceDatabase.execute(
          "INSERT INTO message (guid) VALUES ('archive-guid-1');",
        );
        sourceDatabase.execute('INSERT INTO chat (id) VALUES (1);');
        sourceDatabase.execute('INSERT INTO handle (id) VALUES (1);');
      } finally {
        sourceDatabase.dispose();
      }

      Directory('${tempDirectory.path}/Attachments').createSync();

      workingDb = WorkingDatabase(NativeDatabase.memory());
      importDb = SqfliteImportDatabase(
        databaseDirectory: tempDirectory.path,
        databaseName: 'import_test.db',
        debugSettings: const ImportDebugSettingsState(),
      );
      await importDb.database;

      container = ProviderContainer(
        overrides: [
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
          sqfliteImportDatabaseProvider.overrideWith((ref) async => importDb),
          orchestratedLedgerImportServiceProvider.overrideWith(
            (ref) => _FakeHistoricalArchiveImportService(
              ref: ref,
              importDb: importDb,
            ),
          ),
          dbImportControlViewModelProvider.overrideWith(
            _FakeHistoricalArchiveDbImportControlViewModel.new,
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await workingDb.close();
      await importDb.close();
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
      _FakeHistoricalArchiveDbImportControlViewModel.resetCounters();
      _FakeHistoricalArchiveImportService.resetCounters();
    });

    test(
      'begin import runs archive import and migration success path',
      () async {
        final notifier = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );

        await notifier.loadFolder(folderPath: tempDirectory.path);

        final sourceRecordsBefore = await importDb
            .listHistoricalArchiveSources();
        final rowCountsBefore = await _archiveEntityRowCounts(importDb);
        final sourceRecordBefore = sourceRecordsBefore.single;

        expect(sourceRecordsBefore, hasLength(1));
        expect(sourceRecordBefore.ledgerSourceId, isNotNull);
        expect(sourceRecordBefore.lastImportBatchId, isNull);
        expect(rowCountsBefore.values, everyElement(0));

        await notifier.beginImportForSelectedSource();

        final workflowState = container.read(
          historicalArchivesWorkflowProvider,
        );
        final panelModel = container.read(
          historicalArchivesWorkflowPanelModelProvider,
        );
        final sourceRecordsAfter = await importDb
            .listHistoricalArchiveSources();
        final rowCountsAfter = await _archiveEntityRowCounts(importDb);
        final batchRows = await importDb.rawQuery(
          'SELECT id, source_chat_db, chat_source_id, chat_source_kind, status '
          'FROM import_batches ORDER BY id ASC',
        );

        expect(
          _FakeHistoricalArchiveDbImportControlViewModel.startImportCallCount,
          0,
        );
        expect(_FakeHistoricalArchiveImportService.runImportCallCount, 1);
        expect(
          _FakeHistoricalArchiveDbImportControlViewModel
              .startMigrationCallCount,
          1,
        );

        expect(sourceRecordsAfter, hasLength(1));
        expect(
          sourceRecordsAfter.single.ledgerSourceId,
          sourceRecordBefore.ledgerSourceId,
        );
        expect(sourceRecordsAfter.single.lastImportBatchId, isNotNull);
        expect(sourceRecordsAfter.single.lastImportSuccess, isTrue);

        expect(batchRows, hasLength(1));
        expect(batchRows.single['status'], 'succeeded');
        expect(batchRows.single['chat_source_kind'], 'historical_archive');
        expect(
          batchRows.single['source_chat_db'],
          '${tempDirectory.path}/chat.db',
        );
        expect(
          batchRows.single['chat_source_id'],
          sourceRecordBefore.ledgerSourceId,
        );
        expect(
          sourceRecordsAfter.single.lastImportBatchId,
          batchRows.single['id'],
        );

        expect(rowCountsAfter, rowCountsBefore);
        expect(
          workflowState.preflight.status,
          HistoricalArchivesPreflightStatus.migrationCompleted,
        );
        expect(workflowState.matchedImportedArchiveBatchCount, 1);
        expect(panelModel.statusLabel, 'Archive Import Complete');
        expect(
          panelModel.summaryText,
          contains('visible through the normal app surfaces'),
        );
        expect(
          panelModel.importButtonDetail,
          contains('already completed for this source'),
        );
        expect(await _workingMessageCount(workingDb), 1);
        expect(
          workflowState.resultSummaryLines,
          contains('Selectable contacts: 1'),
        );
      },
    );

    test(
      'begin import fails when post-migration health checks show empty app-visible data',
      () async {
        _FakeHistoricalArchiveDbImportControlViewModel.seedHealthyAppData =
            false;

        final notifier = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );

        await notifier.loadFolder(folderPath: tempDirectory.path);
        await notifier.beginImportForSelectedSource();

        final workflowState = container.read(
          historicalArchivesWorkflowProvider,
        );
        final sourceRecord =
            (await importDb.listHistoricalArchiveSources()).single;

        expect(
          workflowState.preflight.status,
          HistoricalArchivesPreflightStatus.failed,
        );
        expect(
          workflowState.preflight.statusLabel,
          'Import completed but app data is not ready',
        );
        expect(
          workflowState.preflight.detail,
          contains('working.db has no projected messages'),
        );
        expect(
          workflowState.resultSummaryLines,
          contains('Failed health check: working.db has no projected messages'),
        );
        expect(sourceRecord.lastImportSuccess, isFalse);
        expect(
          sourceRecord.lastImportError,
          contains('working.db has no projected messages'),
        );
      },
    );

    test(
      'begin import shows migration-failed-after-import state when migration fails',
      () async {
        _FakeHistoricalArchiveDbImportControlViewModel.nextMigrationResult =
            const DbMigrationResult(batchId: -1, success: false, error: 'boom');

        final notifier = container.read(
          historicalArchivesWorkflowProvider.notifier,
        );

        await notifier.loadFolder(folderPath: tempDirectory.path);
        await notifier.beginImportForSelectedSource();

        final workflowState = container.read(
          historicalArchivesWorkflowProvider,
        );
        final panelModel = container.read(
          historicalArchivesWorkflowPanelModelProvider,
        );
        final sourceRecord =
            (await importDb.listHistoricalArchiveSources()).single;

        expect(_FakeHistoricalArchiveImportService.runImportCallCount, 1);
        expect(
          _FakeHistoricalArchiveDbImportControlViewModel
              .startMigrationCallCount,
          1,
        );
        expect(
          workflowState.preflight.status,
          HistoricalArchivesPreflightStatus.failed,
        );
        expect(
          workflowState.preflight.statusLabel,
          'Migration failed after archive import',
        );
        expect(workflowState.preflight.detail, contains('boom'));
        expect(panelModel.statusLabel, 'Migration failed after archive import');
        expect(panelModel.summaryText, contains('boom'));
        expect(panelModel.importButtonEnabled, isFalse);
        expect(
          panelModel.importButtonDetail,
          contains('canonical migration failed'),
        );
        expect(sourceRecord.lastImportSuccess, isFalse);
        expect(sourceRecord.lastImportError, contains('boom'));
      },
    );
  });
}

Future<int> _workingMessageCount(WorkingDatabase workingDb) async {
  final row = await workingDb
      .customSelect('SELECT COUNT(*) AS c FROM messages')
      .getSingle();
  return row.read<int>('c');
}

Future<void> _seedHealthyArchiveProjection(WorkingDatabase workingDb) async {
  await workingDb.customStatement(
    "INSERT INTO participants (id, original_name, display_name, short_name) VALUES (1, 'Archive Person', 'Archive Person', 'Archive Person')",
  );
  await workingDb.customStatement(
    "INSERT INTO handles_canonical (id, raw_identifier, display_name, compound_identifier, service) VALUES (1, 'archive@example.com', 'Archive Person', 'archive@example.com::iMessage', 'iMessage')",
  );
  await workingDb.customStatement(
    "INSERT INTO handle_to_participant (handle_id, participant_id, confidence, source) VALUES (1, 1, 1.0, 'addressbook')",
  );
  await workingDb.customStatement(
    "INSERT INTO chats (id, guid, service, last_message_at_utc, last_message_preview) VALUES (1, 'chat-guid-1', 'iMessage', '2017-05-06T12:00:00.000Z', 'Archive message')",
  );
  await workingDb.customStatement(
    "INSERT INTO chat_to_handle (chat_id, handle_id, role) VALUES (1, 1, 'member')",
  );
  await workingDb.customStatement(
    "INSERT INTO messages (id, guid, chat_id, sender_handle_id, is_from_me, sent_at_utc, status, text) VALUES (1, 'archive-guid-1', 1, 1, 0, '2017-05-06T12:00:00.000Z', 'delivered', 'Archive message')",
  );
  await workingDb.customStatement(
    "INSERT INTO global_message_index (ordinal, message_id, chat_id, sent_at_utc, month_key) VALUES (0, 1, 1, '2017-05-06T12:00:00.000Z', '2017-05')",
  );
  await workingDb.customStatement(
    "INSERT INTO contact_message_index (contact_id, ordinal, message_id, sent_at_utc, month_key) VALUES (1, 0, 1, '2017-05-06T12:00:00.000Z', '2017-05')",
  );
}

Future<Map<String, int>> _archiveEntityRowCounts(
  SqfliteImportDatabase importDb,
) async {
  return <String, int>{
    'handles': await importDb.countRows('handles'),
    'chats': await importDb.countRows('chats'),
    'messages': await importDb.countRows('messages'),
    'recovered_unlinked_messages': await importDb.countRows(
      'recovered_unlinked_messages',
    ),
    'attachments': await importDb.countRows('attachments'),
  };
}

class _FakeHistoricalArchiveDbImportControlViewModel
    extends DbImportControlViewModel {
  static int startImportCallCount = 0;
  static int startMigrationCallCount = 0;
  static bool seedHealthyAppData = true;
  static DbMigrationResult nextMigrationResult = const DbMigrationResult(
    batchId: 1,
    success: true,
  );

  static void resetCounters() {
    startImportCallCount = 0;
    startMigrationCallCount = 0;
    seedHealthyAppData = true;
    nextMigrationResult = const DbMigrationResult(batchId: 1, success: true);
  }

  @override
  DbImportControlState build() {
    return const DbImportControlState();
  }

  @override
  Future<void> startImport({String? sourceChatDbOverride}) async {
    startImportCallCount += 1;
  }

  @override
  Future<void> startMigration({
    bool skipImportCheck = false,
    bool Function()? shouldCancel,
  }) async {
    startMigrationCallCount += 1;
    if (nextMigrationResult.success && seedHealthyAppData) {
      final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
      await _seedHealthyArchiveProjection(workingDb);
    }
    state = state.copyWith(lastMigrationResult: nextMigrationResult);
  }
}

class _FakeHistoricalArchiveImportService
    extends OrchestratedLedgerImportService {
  _FakeHistoricalArchiveImportService({
    required super.ref,
    required this.importDb,
  }) : super(extractor: const _FakeHistoricalArchiveMessageExtractor());

  final SqfliteImportDatabase importDb;

  static int runImportCallCount = 0;

  static void resetCounters() {
    runImportCallCount = 0;
  }

  @override
  Future<DbImportResult> runImport({
    required String executionOwner,
    String? sourceChatDbOverride,
    String chatSourceKind = 'current_mac',
    String? sourceLabelOverride,
    bool includeContactImport = true,
    bool includeAttachmentImport = true,
    ExecutionPlanCallback? onExecutionPlan,
    TableImportProgressCallback? onTableProgress,
  }) async {
    runImportCallCount += 1;

    final sourceId =
        (await importDb.listHistoricalArchiveSources()).single.ledgerSourceId!;
    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    final finishedAtUtc = DateTime.now().toUtc().toIso8601String();
    final startedAt =
        DateTime.parse(startedAtUtc).millisecondsSinceEpoch ~/ 1000;
    final finishedAt =
        DateTime.parse(finishedAtUtc).millisecondsSinceEpoch ~/ 1000;

    final batchId = await importDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      finishedAtUtc: finishedAtUtc,
      sourceChatDb: sourceChatDbOverride,
      chatSourceId: sourceId,
      chatSourceKind: chatSourceKind,
      status: 'succeeded',
      startedAt: startedAt,
      finishedAt: finishedAt,
      sourceLabelSnapshot: sourceLabelOverride,
      notes: 'Fake archive import batch for workflow-state testing',
    );

    return DbImportResult(batchId: batchId, success: true, messagesImported: 1);
  }
}

class _FakeHistoricalArchiveMessageExtractor implements MessageExtractorPort {
  const _FakeHistoricalArchiveMessageExtractor();

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    return const <int, String>{};
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }
}
