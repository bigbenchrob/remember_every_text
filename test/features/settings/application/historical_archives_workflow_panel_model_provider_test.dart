import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/orchestration/graph_maintenance_execution_gate_provider.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/archive_source_inspection_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const currentMessagesDatabasePath = '/Users/test/Library/Messages/chat.db';

  group('buildHistoricalArchivesWorkflowPanelModel', () {
    test(
      'reports available execution gate when no shared pipeline owns it',
      () {
        final model = buildHistoricalArchivesWorkflowPanelModel(
          executionGateState: const GraphMaintenanceExecutionGateState(),
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
          executionGateState: const GraphMaintenanceExecutionGateState(
            owner: 'db-import-control',
            holdCount: 1,
          ),
          isMaintenanceLocked: true,
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
          executionGateState: const GraphMaintenanceExecutionGateState(),
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
        executionGateState: const GraphMaintenanceExecutionGateState(),
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
