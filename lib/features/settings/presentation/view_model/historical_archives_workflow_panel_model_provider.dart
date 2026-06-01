import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../../essentials/db_importers/application/import_execution_gate_provider.dart';
import '../../../../essentials/db_importers/presentation/view_model/db_import_control_provider.dart';

part 'historical_archives_workflow_panel_model_provider.g.dart';

const _historicalArchivesTestingOwner = 'historical-archives-testing-clear';

enum HistoricalArchivesExecutionGateStatus { available, busy, blocked }

final class HistoricalArchivesExecutionGateViewModel {
  const HistoricalArchivesExecutionGateViewModel({
    required this.status,
    required this.statusLabel,
    required this.detail,
  });

  final HistoricalArchivesExecutionGateStatus status;
  final String statusLabel;
  final String detail;
}

enum HistoricalArchivesPreflightStatus {
  waitingForFolder,
  running,
  completeReadyToImport,
  failed,
}

final class HistoricalArchivesPreflightViewModel {
  const HistoricalArchivesPreflightViewModel({
    required this.status,
    required this.statusLabel,
    required this.detail,
  });

  final HistoricalArchivesPreflightStatus status;
  final String statusLabel;
  final String detail;
}

final class HistoricalArchivesLogEntryViewModel {
  const HistoricalArchivesLogEntryViewModel({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;
}

enum HistoricalArchivesWorkflowPhaseStatus {
  waiting,
  running,
  succeeded,
  failed,
  skipped,
}

final class HistoricalArchivesWorkflowPhaseViewModel {
  const HistoricalArchivesWorkflowPhaseViewModel({
    required this.label,
    required this.status,
    required this.detail,
  });

  final String label;
  final HistoricalArchivesWorkflowPhaseStatus status;
  final String detail;
}

final class HistoricalArchivesWorkflowState {
  const HistoricalArchivesWorkflowState({
    required this.preflight,
    required this.selectedFolderPath,
    required this.archiveRemovalTargetChatDbPath,
    required this.matchedImportedArchiveBatchCount,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.sourceLabel,
    required this.preflightSummaryLines,
    required this.dryRunSummaryLines,
    required this.resultSummaryLines,
    required this.activityLog,
    required this.phases,
  });

  final HistoricalArchivesPreflightViewModel preflight;
  final String? selectedFolderPath;
  final String? archiveRemovalTargetChatDbPath;
  final int? matchedImportedArchiveBatchCount;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String sourceLabel;
  final List<String> preflightSummaryLines;
  final List<String> dryRunSummaryLines;
  final List<String> resultSummaryLines;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;

  HistoricalArchivesWorkflowState copyWith({
    HistoricalArchivesPreflightViewModel? preflight,
    String? selectedFolderPath,
    String? archiveRemovalTargetChatDbPath,
    int? matchedImportedArchiveBatchCount,
    bool clearSelectedFolderPath = false,
    bool clearArchiveRemovalTargetChatDbPath = false,
    bool clearMatchedImportedArchiveBatchCount = false,
    String? chatDbStatusLabel,
    String? attachmentsStatusLabel,
    String? sourceLabel,
    List<String>? preflightSummaryLines,
    List<String>? dryRunSummaryLines,
    List<String>? resultSummaryLines,
    List<HistoricalArchivesLogEntryViewModel>? activityLog,
    List<HistoricalArchivesWorkflowPhaseViewModel>? phases,
  }) {
    return HistoricalArchivesWorkflowState(
      preflight: preflight ?? this.preflight,
      selectedFolderPath: clearSelectedFolderPath
          ? null
          : selectedFolderPath ?? this.selectedFolderPath,
      archiveRemovalTargetChatDbPath: clearArchiveRemovalTargetChatDbPath
          ? null
          : archiveRemovalTargetChatDbPath ??
                this.archiveRemovalTargetChatDbPath,
      matchedImportedArchiveBatchCount: clearMatchedImportedArchiveBatchCount
          ? null
          : matchedImportedArchiveBatchCount ??
                this.matchedImportedArchiveBatchCount,
      chatDbStatusLabel: chatDbStatusLabel ?? this.chatDbStatusLabel,
      attachmentsStatusLabel:
          attachmentsStatusLabel ?? this.attachmentsStatusLabel,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      preflightSummaryLines:
          preflightSummaryLines ?? this.preflightSummaryLines,
      dryRunSummaryLines: dryRunSummaryLines ?? this.dryRunSummaryLines,
      resultSummaryLines: resultSummaryLines ?? this.resultSummaryLines,
      activityLog: activityLog ?? this.activityLog,
      phases: phases ?? this.phases,
    );
  }
}

final class HistoricalArchivesFolderPreflightResult {
  const HistoricalArchivesFolderPreflightResult({
    required this.preflight,
    required this.selectedFolderPath,
    required this.archiveRemovalTargetChatDbPath,
    required this.matchedImportedArchiveBatchCount,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.sourceLabel,
    required this.totalMessages,
    required this.totalChats,
    required this.totalHandles,
    required this.missingGuids,
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.dryRunNewMessages,
    required this.dryRunDuplicateMessages,
    required this.preflightSummaryLines,
    required this.dryRunSummaryLines,
    required this.activityLog,
    required this.phases,
  });

  final HistoricalArchivesPreflightViewModel preflight;
  final String selectedFolderPath;
  final String archiveRemovalTargetChatDbPath;
  final int? matchedImportedArchiveBatchCount;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String sourceLabel;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final List<String> preflightSummaryLines;
  final List<String> dryRunSummaryLines;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;
}

final class HistoricalArchivesDryRunEstimate {
  const HistoricalArchivesDryRunEstimate.available({
    required this.comparableGuidCount,
    required this.duplicateGuidCount,
    required this.newGuidCount,
  }) : unavailableReason = null;

  const HistoricalArchivesDryRunEstimate.unavailable({
    required this.unavailableReason,
  }) : comparableGuidCount = 0,
       duplicateGuidCount = 0,
       newGuidCount = 0;

  final int comparableGuidCount;
  final int duplicateGuidCount;
  final int newGuidCount;
  final String? unavailableReason;

  bool get isAvailable {
    return unavailableReason == null;
  }
}

final class HistoricalArchiveDateRange {
  const HistoricalArchiveDateRange({
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
  });

  final String? earliestMessageUtc;
  final String? latestMessageUtc;
}

final class HistoricalArchivesWorkflowPanelViewModel {
  const HistoricalArchivesWorkflowPanelViewModel({
    required this.statusLabel,
    required this.summaryText,
    required this.executionGate,
    required this.preflight,
    required this.selectedFolderPath,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.sourceLabel,
    required this.preflightSummaryLines,
    required this.dryRunSummaryLines,
    required this.importButtonEnabled,
    required this.importButtonDetail,
    required this.archiveRemovalTargetChatDbPath,
    required this.matchedImportedArchiveBatchCount,
    required this.archiveManagementSummaryLines,
    required this.removeImportedArchiveDataEnabled,
    required this.removeImportedArchiveDataDetail,
    required this.activityLog,
    required this.resultSummaryLines,
    required this.phases,
  });

  final String statusLabel;
  final String summaryText;
  final HistoricalArchivesExecutionGateViewModel executionGate;
  final HistoricalArchivesPreflightViewModel preflight;
  final String? selectedFolderPath;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String sourceLabel;
  final List<String> preflightSummaryLines;
  final List<String> dryRunSummaryLines;
  final bool importButtonEnabled;
  final String importButtonDetail;
  final String? archiveRemovalTargetChatDbPath;
  final int? matchedImportedArchiveBatchCount;
  final List<String> archiveManagementSummaryLines;
  final bool removeImportedArchiveDataEnabled;
  final String removeImportedArchiveDataDetail;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<String> resultSummaryLines;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;
}

HistoricalArchivesWorkflowState buildInitialHistoricalArchivesWorkflowState() {
  return const HistoricalArchivesWorkflowState(
    preflight: HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.waitingForFolder,
      statusLabel: 'Waiting for folder selection',
      detail:
          'Choose an older Messages folder to unlock preflight checks and dry-run estimates.',
    ),
    selectedFolderPath: null,
    archiveRemovalTargetChatDbPath: null,
    matchedImportedArchiveBatchCount: null,
    chatDbStatusLabel: 'Not checked yet',
    attachmentsStatusLabel: 'Not checked yet',
    sourceLabel: 'Not proposed yet',
    preflightSummaryLines: [
      'Total messages: waiting for folder selection',
      'Total chats: waiting for folder selection',
      'Total handles: waiting for folder selection',
      'Rows with missing GUIDs: waiting for folder selection',
      'Earliest message: waiting for folder selection',
      'Latest message: waiting for folder selection',
      'Likely duplicates already in ledger: waiting for folder selection',
      'Likely new rows: waiting for folder selection',
    ],
    dryRunSummaryLines: [
      'Estimated new messages: waiting for preflight',
      'Estimated duplicates: waiting for preflight',
    ],
    resultSummaryLines: [
      'No archive import has run yet.',
      'User-facing success will appear only after canonical migration and required rebuild steps complete.',
    ],
    activityLog: [
      HistoricalArchivesLogEntryViewModel(
        label: 'Workflow shell ready',
        message:
            'Historical Archives is visible, but no folder has been selected yet.',
      ),
      HistoricalArchivesLogEntryViewModel(
        label: 'Waiting',
        message:
            'Choose a folder to begin preflight evidence and dry-run estimation.',
      ),
    ],
    phases: [
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Reading archive source',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Waiting for a folder to be selected.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Normalizing records into canonical ledger format',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'No archive source has started yet.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Writing archive rows to db-import',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Ledger ingestion is not wired in this shell phase.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Running full canonical migration',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Migration begins only after successful ledger import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Post-migration rebuild steps are still waiting.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Refreshing app-visible data',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Normal app surfaces are unchanged until refresh completes.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Complete',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'No archive workflow has completed yet.',
      ),
    ],
  );
}

@Riverpod(keepAlive: true)
class HistoricalArchivesWorkflow extends _$HistoricalArchivesWorkflow {
  @override
  HistoricalArchivesWorkflowState build() {
    return buildInitialHistoricalArchivesWorkflowState();
  }

  Future<void> chooseMessagesFolder() async {
    final folderPath = await FileSelectorPlatform.instance
        .getDirectoryPathWithOptions(
          const FileDialogOptions(confirmButtonText: 'Use This Folder'),
        );
    if (folderPath == null) {
      return;
    }

    await loadFolder(folderPath: folderPath);
  }

  Future<void> loadFolder({required String folderPath}) async {
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.running,
        statusLabel: 'Preflight running',
        detail: 'Checking archive structure and reading source message counts.',
      ),
      selectedFolderPath: folderPath,
      sourceLabel: path.basename(folderPath),
      chatDbStatusLabel: 'Checking...',
      attachmentsStatusLabel: 'Checking...',
      resultSummaryLines: const [
        'No archive import has run yet.',
        'User-facing success will appear only after canonical migration and required rebuild steps complete.',
      ],
      activityLog: [
        HistoricalArchivesLogEntryViewModel(
          label: 'Reading archive…',
          message: 'Inspecting ${path.basename(folderPath)}.',
        ),
      ],
      phases: _runningPreflightPhases(),
    );

    ConversationGraphDatabase? graphDb;
    SqfliteImportDatabase? importDb;
    try {
      graphDb = await ref.read(driftConversationGraphDatabaseProvider.future);
    } catch (_) {}
    try {
      importDb = await ref.read(sqfliteImportDatabaseProvider.future);
    } catch (_) {}

    final result = await preflightHistoricalArchivesFolder(
      folderPath: folderPath,
      graphDb: graphDb,
      importDb: importDb,
    );

    await _persistHistoricalArchiveSourceIfEligible(
      importDb: importDb,
      result: result,
    );

    state = _workflowStateFromPreflightResult(result);
  }

  void clearSelection() {
    state = buildInitialHistoricalArchivesWorkflowState();
  }

  Future<void> removeImportedArchiveDataForSelectedSource() async {
    final selectedFolderPath = state.selectedFolderPath;
    if (selectedFolderPath == null) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'No selected folder',
          message:
              'Choose a Messages folder before trying to remove imported archive data.',
        ),
      );
      return;
    }

    final selectedChatDbPath = path.join(selectedFolderPath, 'chat.db');
    if (_isCurrentMacChatDbPath(selectedChatDbPath)) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'Current Messages source protected',
          message:
              'Remove Imported Archive Data refuses to target the live ~/Library/Messages/chat.db source. Choose an archive folder instead.',
        ),
      );
      return;
    }

    final executionGate = ref.read(importExecutionGateProvider.notifier);
    if (!executionGate.tryAcquire(_historicalArchivesTestingOwner)) {
      final currentOwner = ref.read(importExecutionGateProvider).owner;
      _prependActivityLog(
        HistoricalArchivesLogEntryViewModel(
          label: 'Execution gate busy',
          message:
              '${_describeExecutionOwnerLabel(currentOwner)} currently owns the execution gate. Archive removal must wait.',
        ),
      );
      return;
    }

    ref.read(dbMaintenanceLockProvider.notifier).begin();
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.running,
        statusLabel: 'Removing imported archive data',
        detail:
            'Deleting previously imported archive ledger rows for this source and rebuilding the canonical timeline.',
      ),
      activityLog: [
        HistoricalArchivesLogEntryViewModel(
          label: 'Removing imported archive data…',
          message:
              'Deleting previously imported archive rows for ${path.basename(selectedFolderPath)} and preparing a full rebuild.',
        ),
        ...state.activityLog,
      ],
      phases: _runningArchiveRemovalPhases(),
    );

    try {
      final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
      final batchIds = await importDb.batchIdsForSourceChatDb(
        sourceChatDb: selectedChatDbPath,
      );

      if (batchIds.isEmpty) {
        await loadFolder(folderPath: selectedFolderPath);
        _prependActivityLog(
          const HistoricalArchivesLogEntryViewModel(
            label: 'No imported archive data found',
            message:
                'MessageLens did not find any imported ledger batches for the selected archive source.',
          ),
        );
        return;
      }

      for (final batchId in batchIds) {
        await importDb.deleteBatchLedgerData(batchId: batchId);
      }

      await _deleteWorkingDatabaseFiles(ref);
      await ref
          .read(dbImportControlViewModelProvider.notifier)
          .startMigration(skipImportCheck: true);

      final migrationResult = ref
          .read(dbImportControlViewModelProvider)
          .lastMigrationResult;
      if (migrationResult?.success != true) {
        final detail =
            migrationResult?.error ??
            'The canonical rebuild did not report success.';
        state = state.copyWith(
          preflight: HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.failed,
            statusLabel: 'Archive data removal failed',
            detail: detail,
          ),
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Archive removal failed',
              message: detail,
            ),
            ...state.activityLog,
          ],
          phases: _failedArchiveRemovalPhases(detail: detail),
        );
        return;
      }

      await loadFolder(folderPath: selectedFolderPath);
      _prependActivityLog(
        HistoricalArchivesLogEntryViewModel(
          label: 'Imported archive data removed',
          message:
              'Deleted archive-derived rows from ${batchIds.length} ledger batch(es) for this source and rebuilt the app timeline.',
        ),
      );
    } catch (error) {
      final detail = 'Archive data removal failed: $error';
      state = state.copyWith(
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.failed,
          statusLabel: 'Archive data removal failed',
          detail: detail,
        ),
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Archive removal failed',
            message: detail,
          ),
          ...state.activityLog,
        ],
        phases: _failedArchiveRemovalPhases(detail: detail),
      );
    } finally {
      ref.read(dbMaintenanceLockProvider.notifier).end();
      executionGate.release(_historicalArchivesTestingOwner);
    }
  }

  Future<void> beginImportForSelectedSource() async {
    final selectedFolderPath = state.selectedFolderPath;
    if (selectedFolderPath == null) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'No selected folder',
          message:
              'Choose a Messages folder before trying to begin an archive import.',
        ),
      );
      return;
    }

    final selectedChatDbPath = path.join(selectedFolderPath, 'chat.db');
    if (_isCurrentMacChatDbPath(selectedChatDbPath)) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'Current Messages source protected',
          message:
              'Historical Archives refuses to import the live ~/Library/Messages/chat.db source. Choose an archive folder instead.',
        ),
      );
      return;
    }

    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.running,
        statusLabel: 'Import running',
        detail:
            'Running canonical ledger import for the selected archive source, then rebuilding projected data.',
      ),
      activityLog: [
        HistoricalArchivesLogEntryViewModel(
          label: 'Beginning import…',
          message:
              'Starting canonical import for ${path.basename(selectedFolderPath)}.',
        ),
        ...state.activityLog,
      ],
      phases: _runningArchiveImportPhases(),
      resultSummaryLines: const [
        'Archive import is running.',
        'Canonical ledger import and migration must both finish before imported archive messages become visible in normal app surfaces.',
      ],
    );

    final importControl = ref.read(dbImportControlViewModelProvider.notifier);
    final importDb = await ref.read(sqfliteImportDatabaseProvider.future);

    await importControl.startImport(sourceChatDbOverride: selectedChatDbPath);
    final importResult = ref
        .read(dbImportControlViewModelProvider)
        .lastImportResult;

    if (importResult == null || !importResult.success) {
      final detail =
          importResult?.error ??
          'The canonical archive import did not report a success result.';
      await importDb.upsertHistoricalArchiveSource(
        sourceChatDb: selectedChatDbPath,
        folderPath: selectedFolderPath,
        sourceLabel: state.sourceLabel,
        chatDbStatusLabel: state.chatDbStatusLabel,
        attachmentsStatusLabel: state.attachmentsStatusLabel,
        preflightStatusLabel: 'Import failed',
        preflightDetail: detail,
        totalMessages: _summaryLineInt(
          state.preflightSummaryLines,
          'Total messages:',
        ),
        totalChats: _summaryLineInt(
          state.preflightSummaryLines,
          'Total chats:',
        ),
        totalHandles: _summaryLineInt(
          state.preflightSummaryLines,
          'Total handles:',
        ),
        missingGuids: _summaryLineInt(
          state.preflightSummaryLines,
          'Rows with missing GUIDs:',
        ),
        dryRunNewMessages: _summaryLineInt(
          state.dryRunSummaryLines,
          'Estimated new messages:',
        ),
        dryRunDuplicateMessages: _summaryLineInt(
          state.dryRunSummaryLines,
          'Estimated duplicates:',
        ),
        matchedImportedBatchCount: state.matchedImportedArchiveBatchCount,
        lastImportStartedAtUtc: startedAtUtc,
        lastImportFinishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        lastImportSuccess: false,
        lastImportError: detail,
        updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      state = state.copyWith(
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.failed,
          statusLabel: 'Import failed',
          detail: detail,
        ),
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Import failed',
            message: detail,
          ),
          ...state.activityLog,
        ],
        phases: _failedArchiveImportPhases(detail: detail),
        resultSummaryLines: [
          'Archive import failed before the canonical rebuild completed.',
          detail,
        ],
      );
      return;
    }

    await importControl.startMigration(skipImportCheck: true);
    final migrationResult = ref
        .read(dbImportControlViewModelProvider)
        .lastMigrationResult;

    if (migrationResult?.success != true) {
      final detail =
          migrationResult?.error ??
          'The canonical rebuild did not report success after archive import.';
      await importDb.upsertHistoricalArchiveSource(
        sourceChatDb: selectedChatDbPath,
        folderPath: selectedFolderPath,
        sourceLabel: state.sourceLabel,
        chatDbStatusLabel: state.chatDbStatusLabel,
        attachmentsStatusLabel: state.attachmentsStatusLabel,
        preflightStatusLabel: 'Migration failed after import',
        preflightDetail: detail,
        totalMessages: _summaryLineInt(
          state.preflightSummaryLines,
          'Total messages:',
        ),
        totalChats: _summaryLineInt(
          state.preflightSummaryLines,
          'Total chats:',
        ),
        totalHandles: _summaryLineInt(
          state.preflightSummaryLines,
          'Total handles:',
        ),
        missingGuids: _summaryLineInt(
          state.preflightSummaryLines,
          'Rows with missing GUIDs:',
        ),
        dryRunNewMessages: _summaryLineInt(
          state.dryRunSummaryLines,
          'Estimated new messages:',
        ),
        dryRunDuplicateMessages: _summaryLineInt(
          state.dryRunSummaryLines,
          'Estimated duplicates:',
        ),
        matchedImportedBatchCount: state.matchedImportedArchiveBatchCount,
        lastImportBatchId: importResult.batchId,
        lastImportStartedAtUtc: startedAtUtc,
        lastImportFinishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        lastImportSuccess: false,
        lastImportError: detail,
        lastImportedMessageCount: importResult.messagesImported,
        updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );
      state = state.copyWith(
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.failed,
          statusLabel: 'Migration failed after import',
          detail: detail,
        ),
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Migration failed',
            message: detail,
          ),
          ...state.activityLog,
        ],
        phases: _failedArchiveImportPhases(detail: detail),
        resultSummaryLines: [
          'Archive rows were written to db-import, but the canonical rebuild failed.',
          detail,
        ],
      );
      return;
    }

    ConversationGraphDatabase? graphDb;
    try {
      graphDb = await ref.read(driftConversationGraphDatabaseProvider.future);
    } catch (_) {}

    final refreshedResult = await preflightHistoricalArchivesFolder(
      folderPath: selectedFolderPath,
      graphDb: graphDb,
      importDb: importDb,
    );

    await importDb.upsertHistoricalArchiveSource(
      sourceChatDb: selectedChatDbPath,
      folderPath: selectedFolderPath,
      sourceLabel: refreshedResult.sourceLabel,
      chatDbStatusLabel: refreshedResult.chatDbStatusLabel,
      attachmentsStatusLabel: refreshedResult.attachmentsStatusLabel,
      preflightStatusLabel: 'Imported successfully',
      preflightDetail:
          'Canonical archive import and migration completed successfully.',
      totalMessages: refreshedResult.totalMessages,
      totalChats: refreshedResult.totalChats,
      totalHandles: refreshedResult.totalHandles,
      missingGuids: refreshedResult.missingGuids,
      earliestMessageUtc: refreshedResult.earliestMessageUtc,
      latestMessageUtc: refreshedResult.latestMessageUtc,
      dryRunNewMessages: refreshedResult.dryRunNewMessages,
      dryRunDuplicateMessages: refreshedResult.dryRunDuplicateMessages,
      matchedImportedBatchCount:
          refreshedResult.matchedImportedArchiveBatchCount,
      lastImportBatchId: importResult.batchId,
      lastImportStartedAtUtc: startedAtUtc,
      lastImportFinishedAtUtc: DateTime.now().toUtc().toIso8601String(),
      lastImportSuccess: true,
      lastImportedMessageCount: importResult.messagesImported,
      updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    state = _workflowStateFromPreflightResult(refreshedResult).copyWith(
      activityLog: [
        HistoricalArchivesLogEntryViewModel(
          label: 'Import complete',
          message:
              'Imported ${importResult.messagesImported} messages from ${path.basename(selectedFolderPath)} and rebuilt the canonical timeline.',
        ),
        ..._workflowStateFromPreflightResult(refreshedResult).activityLog,
      ],
      phases: _completedArchiveImportPhases(
        importedMessageCount: importResult.messagesImported,
      ),
      resultSummaryLines: [
        'Imported ${importResult.messagesImported} messages from ${path.basename(selectedFolderPath)}.',
        'Canonical ledger import, migration, and projected data refresh all completed successfully.',
      ],
    );
  }

  void _prependActivityLog(HistoricalArchivesLogEntryViewModel entry) {
    state = state.copyWith(activityLog: [entry, ...state.activityLog]);
  }

  Future<void> _persistHistoricalArchiveSourceIfEligible({
    required SqfliteImportDatabase? importDb,
    required HistoricalArchivesFolderPreflightResult result,
  }) async {
    if (importDb == null) {
      return;
    }
    if (result.chatDbStatusLabel != 'Found and readable') {
      return;
    }

    await importDb.upsertHistoricalArchiveSource(
      sourceChatDb: result.archiveRemovalTargetChatDbPath,
      folderPath: result.selectedFolderPath,
      sourceLabel: result.sourceLabel,
      chatDbStatusLabel: result.chatDbStatusLabel,
      attachmentsStatusLabel: result.attachmentsStatusLabel,
      preflightStatusLabel: result.preflight.statusLabel,
      preflightDetail: result.preflight.detail,
      totalMessages: result.totalMessages,
      totalChats: result.totalChats,
      totalHandles: result.totalHandles,
      missingGuids: result.missingGuids,
      earliestMessageUtc: result.earliestMessageUtc,
      latestMessageUtc: result.latestMessageUtc,
      dryRunNewMessages: result.dryRunNewMessages,
      dryRunDuplicateMessages: result.dryRunDuplicateMessages,
      matchedImportedBatchCount: result.matchedImportedArchiveBatchCount,
      updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
  }
}

@riverpod
HistoricalArchivesWorkflowPanelViewModel historicalArchivesWorkflowPanelModel(
  Ref ref,
) {
  final executionGateState = ref.watch(importExecutionGateProvider);
  final isMaintenanceLocked = ref.watch(dbMaintenanceLockProvider);
  final workflowState = ref.watch(historicalArchivesWorkflowProvider);

  return buildHistoricalArchivesWorkflowPanelModel(
    executionGateState: executionGateState,
    isMaintenanceLocked: isMaintenanceLocked,
    workflowState: workflowState,
  );
}

HistoricalArchivesWorkflowPanelViewModel
buildHistoricalArchivesWorkflowPanelModel({
  required ImportExecutionGateState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
}) {
  final executionGate = _buildExecutionGateViewModel(
    executionGateState: executionGateState,
    isMaintenanceLocked: isMaintenanceLocked,
  );

  final statusLabel = switch (executionGate.status) {
    HistoricalArchivesExecutionGateStatus.available => _availableStatusLabel(
      workflowState,
    ),
    HistoricalArchivesExecutionGateStatus.busy => 'Execution Gate Busy',
    HistoricalArchivesExecutionGateStatus.blocked => 'Execution Gate Blocked',
  };

  final summaryText = switch (executionGate.status) {
    HistoricalArchivesExecutionGateStatus.available => _availableSummaryText(
      workflowState,
    ),
    HistoricalArchivesExecutionGateStatus.busy =>
      'The canonical import pipeline is currently busy. Historical Archives stays visible so you can inspect the workflow shell, but import cannot begin until the current pipeline owner releases the execution gate.',
    HistoricalArchivesExecutionGateStatus.blocked =>
      'Message data maintenance is currently blocking new archive work. Historical Archives remains visible, but import cannot begin until maintenance completes and the execution gate becomes available again.',
  };

  final importButtonDetail = switch (executionGate.status) {
    HistoricalArchivesExecutionGateStatus.available =>
      _availableImportButtonDetail(workflowState),
    HistoricalArchivesExecutionGateStatus.busy =>
      'Import is unavailable because ${_describeExecutionOwnerPhrase(executionGateState.owner)} currently owns the execution gate.',
    HistoricalArchivesExecutionGateStatus.blocked =>
      'Import is unavailable while reset or another maintenance operation is holding the message-data lock.',
  };

  return HistoricalArchivesWorkflowPanelViewModel(
    statusLabel: statusLabel,
    summaryText: summaryText,
    executionGate: executionGate,
    preflight: workflowState.preflight,
    selectedFolderPath: workflowState.selectedFolderPath,
    chatDbStatusLabel: workflowState.chatDbStatusLabel,
    attachmentsStatusLabel: workflowState.attachmentsStatusLabel,
    sourceLabel: workflowState.sourceLabel,
    preflightSummaryLines: workflowState.preflightSummaryLines,
    dryRunSummaryLines: workflowState.dryRunSummaryLines,
    importButtonEnabled: _importButtonEnabled(
      executionGate: executionGate,
      workflowState: workflowState,
    ),
    importButtonDetail: importButtonDetail,
    archiveRemovalTargetChatDbPath:
        workflowState.archiveRemovalTargetChatDbPath,
    matchedImportedArchiveBatchCount:
        workflowState.matchedImportedArchiveBatchCount,
    archiveManagementSummaryLines: _archiveManagementSummaryLines(
      workflowState,
    ),
    removeImportedArchiveDataEnabled: _removeImportedArchiveDataEnabled(
      executionGate: executionGate,
      workflowState: workflowState,
    ),
    removeImportedArchiveDataDetail: _removeImportedArchiveDataDetail(
      executionGateState: executionGateState,
      isMaintenanceLocked: isMaintenanceLocked,
      workflowState: workflowState,
    ),
    activityLog: _buildActivityLog(
      executionGateState: executionGateState,
      isMaintenanceLocked: isMaintenanceLocked,
      workflowState: workflowState,
    ),
    resultSummaryLines: workflowState.resultSummaryLines,
    phases: workflowState.phases,
  );
}

HistoricalArchivesExecutionGateViewModel _buildExecutionGateViewModel({
  required ImportExecutionGateState executionGateState,
  required bool isMaintenanceLocked,
}) {
  if (executionGateState.isLocked) {
    return HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.busy,
      statusLabel: 'Busy',
      detail:
          '${_describeExecutionOwnerLabel(executionGateState.owner)} currently owns the execution gate.',
    );
  }

  if (isMaintenanceLocked) {
    return const HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.blocked,
      statusLabel: 'Blocked',
      detail:
          'Message data reset or another maintenance operation is currently active.',
    );
  }

  return const HistoricalArchivesExecutionGateViewModel(
    status: HistoricalArchivesExecutionGateStatus.available,
    statusLabel: 'Available',
    detail:
        'No migration, import, or reset flow currently owns the execution gate.',
  );
}

List<HistoricalArchivesLogEntryViewModel> _buildActivityLog({
  required ImportExecutionGateState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
}) {
  if (executionGateState.isLocked) {
    return [
      ...workflowState.activityLog,
      HistoricalArchivesLogEntryViewModel(
        label: 'Execution gate busy',
        message:
            '${_describeExecutionOwnerLabel(executionGateState.owner)} is running now. Historical archive import must wait until that pipeline owner finishes.',
      ),
    ];
  }

  if (isMaintenanceLocked) {
    return [
      ...workflowState.activityLog,
      const HistoricalArchivesLogEntryViewModel(
        label: 'Maintenance lock active',
        message:
            'Reset or another maintenance flow is active. Historical archive import cannot begin until that lock is released.',
      ),
    ];
  }

  return workflowState.activityLog;
}

String _availableStatusLabel(HistoricalArchivesWorkflowState workflowState) {
  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => 'No archive selected',
    HistoricalArchivesPreflightStatus.running => 'Reading Archive Source',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Archive Source Ready',
    HistoricalArchivesPreflightStatus.failed => 'Archive Preflight Failed',
  };
}

String _availableSummaryText(HistoricalArchivesWorkflowState workflowState) {
  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder =>
      'Historical archive import is a durable, step-by-step workflow. Choose an older Messages folder, review preflight evidence, then run canonical ledger import and full migration before messages become visible in normal app surfaces.',
    HistoricalArchivesPreflightStatus.running =>
      'Historical Archives is reading the selected source folder now. The shell remains visible while source checks gather basic message, chat, handle, and GUID evidence.',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Historical Archives has completed source preflight for the selected folder. The shell now shows real source metadata and message counts, while canonical archive import wiring remains a separate step.',
    HistoricalArchivesPreflightStatus.failed =>
      'Historical Archives could not validate the selected folder as a usable Messages source. Review the failure details, then choose a different folder or fix the source contents before trying again.',
  };
}

String _availableImportButtonDetail(
  HistoricalArchivesWorkflowState workflowState,
) {
  final selectedFolderPath = workflowState.selectedFolderPath;
  final selectedChatDbPath = selectedFolderPath == null
      ? null
      : path.join(selectedFolderPath, 'chat.db');

  if (selectedChatDbPath != null &&
      _isCurrentMacChatDbPath(selectedChatDbPath)) {
    return 'Historical Archives does not import the live current_mac Messages source. Choose an archive folder instead.';
  }

  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder =>
      'Import stays disabled until a folder is selected and preflight completes.',
    HistoricalArchivesPreflightStatus.running =>
      'Import stays disabled while Historical Archives is reading source structure and counts.',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Source checks are complete. Begin Import will run the canonical ledger import and then rebuild projected data. Mixed-source ledger states are still rejected until the rowid identity refactor lands.',
    HistoricalArchivesPreflightStatus.failed =>
      'Import stays disabled until the selected folder passes source preflight.',
  };
}

bool _importButtonEnabled({
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required HistoricalArchivesWorkflowState workflowState,
}) {
  if (executionGate.status != HistoricalArchivesExecutionGateStatus.available) {
    return false;
  }

  final selectedFolderPath = workflowState.selectedFolderPath;
  if (selectedFolderPath == null) {
    return false;
  }

  if (_isCurrentMacChatDbPath(path.join(selectedFolderPath, 'chat.db'))) {
    return false;
  }

  return workflowState.preflight.status ==
      HistoricalArchivesPreflightStatus.completeReadyToImport;
}

List<String> _archiveManagementSummaryLines(
  HistoricalArchivesWorkflowState workflowState,
) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
  final batchCount = workflowState.matchedImportedArchiveBatchCount;

  if (targetPath == null) {
    return const [
      'Removal target chat.db: waiting for folder selection',
      'Matched imported archive batches in db-import: waiting for folder selection',
    ];
  }

  final batchSummary = switch (batchCount) {
    null => 'Matched imported archive batches in db-import: unavailable',
    0 => 'Matched imported archive batches in db-import: 0',
    1 => 'Matched imported archive batches in db-import: 1',
    _ => 'Matched imported archive batches in db-import: $batchCount',
  };

  return ['Removal target chat.db: $targetPath', batchSummary];
}

bool _removeImportedArchiveDataEnabled({
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required HistoricalArchivesWorkflowState workflowState,
}) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
  final batchCount = workflowState.matchedImportedArchiveBatchCount;

  if (executionGate.status != HistoricalArchivesExecutionGateStatus.available) {
    return false;
  }
  if (workflowState.preflight.status ==
      HistoricalArchivesPreflightStatus.running) {
    return false;
  }
  if (targetPath == null) {
    return false;
  }
  if (_isCurrentMacChatDbPath(targetPath)) {
    return false;
  }
  return batchCount != null && batchCount > 0;
}

String _removeImportedArchiveDataDetail({
  required ImportExecutionGateState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
}) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
  final batchCount = workflowState.matchedImportedArchiveBatchCount;

  if (executionGateState.isLocked) {
    return 'Removal is unavailable because ${_describeExecutionOwnerPhrase(executionGateState.owner)} currently owns the execution gate.';
  }
  if (isMaintenanceLocked) {
    return 'Removal is unavailable while reset or another maintenance operation is holding the message-data lock.';
  }
  if (workflowState.preflight.status ==
      HistoricalArchivesPreflightStatus.running) {
    return 'Removal stays disabled while Historical Archives is still reading source state.';
  }
  if (targetPath == null) {
    return 'Choose an archive folder first so MessageLens can identify which imported archive batches would be removed.';
  }
  if (_isCurrentMacChatDbPath(targetPath)) {
    return 'Removal is unavailable for the live current_mac Messages source.';
  }
  if (batchCount == null) {
    return 'MessageLens could not determine whether db-import contains archive batches for this source yet.';
  }
  if (batchCount == 0) {
    return 'No imported archive batches are currently recorded for this selected source.';
  }
  final batchLabel = batchCount == 1
      ? '1 matched batch'
      : '$batchCount matched batches';
  return 'Removing imported archive data will delete $batchLabel for this selected source from db-import, then rebuild the app timeline.';
}

Future<HistoricalArchivesFolderPreflightResult>
preflightHistoricalArchivesFolder({
  required String folderPath,
  ConversationGraphDatabase? graphDb,
  SqfliteImportDatabase? importDb,
}) async {
  final selectedDirectory = Directory(folderPath);
  if (!selectedDirectory.existsSync()) {
    return _failedPreflightResult(
      folderPath: folderPath,
      sourceLabel: path.basename(folderPath),
      detail: 'The selected folder no longer exists.',
      archiveRemovalTargetChatDbPath: path.join(folderPath, 'chat.db'),
      matchedImportedArchiveBatchCount: null,
      chatDbStatusLabel: 'Missing',
      attachmentsStatusLabel: 'Missing',
    );
  }

  final chatDbPath = path.join(folderPath, 'chat.db');
  final attachmentsPath = path.join(folderPath, 'Attachments');
  final chatDbFile = File(chatDbPath);
  final attachmentsDirectory = Directory(attachmentsPath);
  final sourceLabel = path.basename(folderPath);
  final matchedImportedArchiveBatchCount =
      await _readMatchedImportedArchiveBatchCount(
        importDb: importDb,
        sourceChatDbPath: chatDbPath,
      );

  if (!chatDbFile.existsSync()) {
    return _failedPreflightResult(
      folderPath: folderPath,
      sourceLabel: sourceLabel,
      detail: 'The selected folder does not contain chat.db.',
      archiveRemovalTargetChatDbPath: chatDbPath,
      matchedImportedArchiveBatchCount: matchedImportedArchiveBatchCount,
      chatDbStatusLabel: 'Missing',
      attachmentsStatusLabel: attachmentsDirectory.existsSync()
          ? 'Found'
          : 'Not found',
    );
  }

  try {
    final database = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');

      final totalMessages = _readCount(
        database,
        'SELECT COUNT(*) AS total_count FROM message',
      );
      final totalChats = _readCount(
        database,
        'SELECT COUNT(*) AS total_count FROM chat',
      );
      final totalHandles = _readCount(
        database,
        'SELECT COUNT(*) AS total_count FROM handle',
      );
      final missingGuids = _readCount(
        database,
        "SELECT COUNT(*) AS total_count FROM message WHERE guid IS NULL OR TRIM(guid) = ''",
      );
      final dateRange = _readArchiveDateRange(database);
      final dryRunEstimate = await _estimateDryRunAgainstConversationGraph(
        sourceDatabase: database,
        graphDb: graphDb,
      );

      return HistoricalArchivesFolderPreflightResult(
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.completeReadyToImport,
          statusLabel: 'Preflight complete',
          detail: dryRunEstimate.isAvailable
              ? 'Source checks succeeded and GUID-based dry-run estimates are now visible. Canonical import wiring is still pending.'
              : 'Source checks succeeded, but conversation graph dry-run comparison is unavailable right now. Canonical import wiring is still pending.',
        ),
        selectedFolderPath: folderPath,
        archiveRemovalTargetChatDbPath: chatDbPath,
        matchedImportedArchiveBatchCount: matchedImportedArchiveBatchCount,
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: attachmentsDirectory.existsSync()
            ? 'Found'
            : 'Not found',
        sourceLabel: sourceLabel,
        totalMessages: totalMessages,
        totalChats: totalChats,
        totalHandles: totalHandles,
        missingGuids: missingGuids,
        earliestMessageUtc: dateRange.earliestMessageUtc,
        latestMessageUtc: dateRange.latestMessageUtc,
        dryRunNewMessages: dryRunEstimate.isAvailable
            ? dryRunEstimate.newGuidCount
            : null,
        dryRunDuplicateMessages: dryRunEstimate.isAvailable
            ? dryRunEstimate.duplicateGuidCount
            : null,
        preflightSummaryLines: [
          'Total messages: $totalMessages',
          'Total chats: $totalChats',
          'Total handles: $totalHandles',
          'Rows with missing GUIDs: $missingGuids',
          'Earliest message: ${_dateSummaryLabel(dateRange.earliestMessageUtc)}',
          'Latest message: ${_dateSummaryLabel(dateRange.latestMessageUtc)}',
          if (dryRunEstimate.isAvailable)
            'Likely duplicates already in conversation graph: ${dryRunEstimate.duplicateGuidCount} GUID-backed source rows'
          else
            'Likely duplicates already in conversation graph: unavailable',
          if (dryRunEstimate.isAvailable)
            'Likely new rows: ${dryRunEstimate.newGuidCount} GUID-backed source rows'
          else
            'Likely new rows: unavailable',
        ],
        dryRunSummaryLines: [
          if (dryRunEstimate.isAvailable)
            'Estimated new messages: ${dryRunEstimate.newGuidCount} GUID-backed source rows not present in conversation graph'
          else
            'Estimated new messages: conversation graph comparison unavailable',
          if (dryRunEstimate.isAvailable)
            'Estimated duplicates: ${dryRunEstimate.duplicateGuidCount} GUID-backed source rows already projected'
          else
            'Estimated duplicates: conversation graph comparison unavailable',
        ],
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Reading archive…',
            message: 'Read source counts from $sourceLabel.',
          ),
          HistoricalArchivesLogEntryViewModel(
            label: dryRunEstimate.isAvailable
                ? 'Dry run ready'
                : 'Dry run unavailable',
            message: dryRunEstimate.isAvailable
                ? 'Compared ${dryRunEstimate.comparableGuidCount} GUID-backed source rows against the conversation graph.'
                : dryRunEstimate.unavailableReason!,
          ),
          const HistoricalArchivesLogEntryViewModel(
            label: 'Preflight complete',
            message:
                'The selected archive folder passed source checks and is ready for the next implementation slice.',
          ),
        ],
        phases: const [
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Reading archive source',
            status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
            detail:
                'Archive source metadata and counts were read successfully.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Normalizing records into canonical ledger format',
            status: HistoricalArchivesWorkflowPhaseStatus.waiting,
            detail:
                'Normalization begins when canonical archive import wiring lands.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Writing archive rows to db-import',
            status: HistoricalArchivesWorkflowPhaseStatus.waiting,
            detail: 'Ledger ingestion is not wired in this slice.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Running full canonical migration',
            status: HistoricalArchivesWorkflowPhaseStatus.waiting,
            detail: 'Migration begins only after successful ledger import.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Rebuilding indexes/search/heatmap support tables',
            status: HistoricalArchivesWorkflowPhaseStatus.waiting,
            detail: 'Rebuild steps are still waiting.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Refreshing app-visible data',
            status: HistoricalArchivesWorkflowPhaseStatus.waiting,
            detail:
                'Normal app surfaces are unchanged until refresh completes.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Complete',
            status: HistoricalArchivesWorkflowPhaseStatus.waiting,
            detail: 'No archive workflow has completed yet.',
          ),
        ],
      );
    } finally {
      database.dispose();
    }
  } catch (error) {
    return _failedPreflightResult(
      folderPath: folderPath,
      sourceLabel: sourceLabel,
      detail: 'MessageLens could not safely read chat.db: $error',
      archiveRemovalTargetChatDbPath: chatDbPath,
      matchedImportedArchiveBatchCount: matchedImportedArchiveBatchCount,
      chatDbStatusLabel: 'Read failed',
      attachmentsStatusLabel: attachmentsDirectory.existsSync()
          ? 'Found'
          : 'Not found',
    );
  }
}

HistoricalArchivesWorkflowState _workflowStateFromPreflightResult(
  HistoricalArchivesFolderPreflightResult result,
) {
  return HistoricalArchivesWorkflowState(
    preflight: result.preflight,
    selectedFolderPath: result.selectedFolderPath,
    archiveRemovalTargetChatDbPath: result.archiveRemovalTargetChatDbPath,
    matchedImportedArchiveBatchCount: result.matchedImportedArchiveBatchCount,
    chatDbStatusLabel: result.chatDbStatusLabel,
    attachmentsStatusLabel: result.attachmentsStatusLabel,
    sourceLabel: result.sourceLabel,
    preflightSummaryLines: result.preflightSummaryLines,
    dryRunSummaryLines: result.dryRunSummaryLines,
    resultSummaryLines:
        buildInitialHistoricalArchivesWorkflowState().resultSummaryLines,
    activityLog: result.activityLog,
    phases: result.phases,
  );
}

HistoricalArchivesFolderPreflightResult _failedPreflightResult({
  required String folderPath,
  required String sourceLabel,
  required String detail,
  required String archiveRemovalTargetChatDbPath,
  required int? matchedImportedArchiveBatchCount,
  required String chatDbStatusLabel,
  required String attachmentsStatusLabel,
}) {
  return HistoricalArchivesFolderPreflightResult(
    preflight: HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.failed,
      statusLabel: 'Preflight failed',
      detail: detail,
    ),
    selectedFolderPath: folderPath,
    archiveRemovalTargetChatDbPath: archiveRemovalTargetChatDbPath,
    matchedImportedArchiveBatchCount: matchedImportedArchiveBatchCount,
    chatDbStatusLabel: chatDbStatusLabel,
    attachmentsStatusLabel: attachmentsStatusLabel,
    sourceLabel: sourceLabel,
    totalMessages: null,
    totalChats: null,
    totalHandles: null,
    missingGuids: null,
    earliestMessageUtc: null,
    latestMessageUtc: null,
    dryRunNewMessages: null,
    dryRunDuplicateMessages: null,
    preflightSummaryLines: const [
      'Total messages: unavailable',
      'Total chats: unavailable',
      'Total handles: unavailable',
      'Rows with missing GUIDs: unavailable',
      'Earliest message: unavailable',
      'Latest message: unavailable',
      'Likely duplicates already in ledger: unavailable',
      'Likely new rows: unavailable',
    ],
    dryRunSummaryLines: const [
      'Estimated new messages: unavailable',
      'Estimated duplicates: unavailable',
    ],
    activityLog: [
      HistoricalArchivesLogEntryViewModel(
        label: 'Preflight failed',
        message: detail,
      ),
    ],
    phases: const [
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Reading archive source',
        status: HistoricalArchivesWorkflowPhaseStatus.failed,
        detail: 'Archive source validation failed.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Normalizing records into canonical ledger format',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Writing archive rows to db-import',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Running full canonical migration',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Refreshing app-visible data',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Complete',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'No archive workflow has completed yet.',
      ),
    ],
  );
}

int _readCount(Database database, String sql) {
  final result = database.select(sql);
  if (result.isEmpty) {
    return 0;
  }

  return _readIntegerValue(result.first['total_count']);
}

int _readIntegerValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value') ?? 0;
}

HistoricalArchiveDateRange _readArchiveDateRange(Database database) {
  try {
    final result = database.select(
      'SELECT MIN(date) AS earliest_date, MAX(date) AS latest_date FROM message',
    );
    if (result.isEmpty) {
      return const HistoricalArchiveDateRange(
        earliestMessageUtc: null,
        latestMessageUtc: null,
      );
    }

    final row = result.first;
    return HistoricalArchiveDateRange(
      earliestMessageUtc: _archiveTimestampToUtcIsoString(row['earliest_date']),
      latestMessageUtc: _archiveTimestampToUtcIsoString(row['latest_date']),
    );
  } catch (_) {
    return const HistoricalArchiveDateRange(
      earliestMessageUtc: null,
      latestMessageUtc: null,
    );
  }
}

String? _archiveTimestampToUtcIsoString(Object? value) {
  if (value == null) {
    return null;
  }

  final rawValue = value is int
      ? value
      : value is num
      ? value.toInt()
      : int.tryParse('$value');
  if (rawValue == null) {
    return null;
  }

  const appleEpochDifferenceSeconds = 978307200;
  final isNanoseconds = rawValue.abs() >= 1000000000000;
  final utcDateTime = isNanoseconds
      ? DateTime.fromMicrosecondsSinceEpoch(
          (rawValue / 1000).round() +
              appleEpochDifferenceSeconds * Duration.microsecondsPerSecond,
          isUtc: true,
        )
      : DateTime.fromMillisecondsSinceEpoch(
          (rawValue + appleEpochDifferenceSeconds) * 1000,
          isUtc: true,
        );
  return utcDateTime.toUtc().toIso8601String();
}

String _dateSummaryLabel(String? utcIsoString) {
  final parsed = utcIsoString == null ? null : DateTime.tryParse(utcIsoString);
  if (parsed == null) {
    return 'unavailable';
  }

  final utc = parsed.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '${utc.year}-$month-$day';
}

int? _summaryLineInt(List<String> lines, String prefix) {
  final line = _firstLineWithPrefix(lines, prefix);
  if (line == null) {
    return null;
  }

  final match = RegExp(r'(\d+)').firstMatch(line);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

Future<int?> _readMatchedImportedArchiveBatchCount({
  required SqfliteImportDatabase? importDb,
  required String sourceChatDbPath,
}) async {
  if (importDb == null) {
    return null;
  }

  final batchIds = await importDb.batchIdsForSourceChatDb(
    sourceChatDb: sourceChatDbPath,
  );
  return batchIds.length;
}

Future<HistoricalArchivesDryRunEstimate>
_estimateDryRunAgainstConversationGraph({
  required Database sourceDatabase,
  required ConversationGraphDatabase? graphDb,
}) async {
  if (graphDb == null) {
    return const HistoricalArchivesDryRunEstimate.unavailable(
      unavailableReason:
          'conversation graph comparison is unavailable because the graph database could not be opened.',
    );
  }

  final comparableGuidCount = _readCount(
    sourceDatabase,
    'SELECT COUNT(DISTINCT guid) AS total_count FROM message WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0',
  );

  if (comparableGuidCount == 0) {
    return const HistoricalArchivesDryRunEstimate.available(
      comparableGuidCount: 0,
      duplicateGuidCount: 0,
      newGuidCount: 0,
    );
  }

  try {
    var duplicateGuidCount = 0;
    const sourceChunkSize = 400;

    for (var offset = 0; ; offset += sourceChunkSize) {
      final rows = sourceDatabase.select(
        'SELECT DISTINCT guid FROM message '
        'WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0 ORDER BY guid LIMIT $sourceChunkSize OFFSET $offset',
      );
      if (rows.isEmpty) {
        break;
      }

      final sourceGuids = <String>[
        for (final row in rows)
          if (_readTrimmedString(row['guid']) case final guid?) guid,
      ];

      duplicateGuidCount += await _countMatchingGraphGuids(
        graphDb: graphDb,
        sourceGuids: sourceGuids,
      );
    }

    return HistoricalArchivesDryRunEstimate.available(
      comparableGuidCount: comparableGuidCount,
      duplicateGuidCount: duplicateGuidCount,
      newGuidCount: comparableGuidCount - duplicateGuidCount,
    );
  } catch (error) {
    return HistoricalArchivesDryRunEstimate.unavailable(
      unavailableReason:
          'conversation graph comparison failed while estimating duplicate GUIDs: $error',
    );
  }
}

Future<int> _countMatchingGraphGuids({
  required ConversationGraphDatabase graphDb,
  required List<String> sourceGuids,
}) async {
  if (sourceGuids.isEmpty) {
    return 0;
  }

  final placeholders = List.filled(sourceGuids.length, '?').join(', ');
  final rows = await graphDb.selectRows(
    'SELECT COUNT(*) AS total_count FROM messages WHERE guid IN ($placeholders)',
    sourceGuids,
  );

  return _readIntegerValue(rows.single['total_count']);
}

String? _readTrimmedString(Object? value) {
  if (value == null) {
    return null;
  }

  final text = '$value'.trim();
  if (text.isEmpty) {
    return null;
  }

  return text;
}

String? _firstLineWithPrefix(List<String> lines, String prefix) {
  for (final line in lines) {
    if (line.startsWith(prefix)) {
      return line;
    }
  }

  return null;
}

Future<void> _deleteWorkingDatabaseFiles(Ref ref) async {
  try {
    final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
    await workingDb.close();
  } catch (_) {}

  ref.invalidate(driftWorkingDatabaseProvider);

  final basePath = path.join(databaseDirectoryPath, 'working.db');
  for (final filePath in <String>[basePath, '$basePath-wal', '$basePath-shm']) {
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  ref.invalidate(driftWorkingDatabaseProvider);
}

bool _isCurrentMacChatDbPath(String sourceChatDbPath) {
  final homeDir = Platform.environment['HOME'];
  if (homeDir == null) {
    return false;
  }

  final currentMacChatDbPath = path.normalize(
    path.join(homeDir, 'Library', 'Messages', 'chat.db'),
  );
  return path.normalize(sourceChatDbPath) == currentMacChatDbPath;
}

List<HistoricalArchivesWorkflowPhaseViewModel> _runningPreflightPhases() {
  return const [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Inspecting folder structure and source counts.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Normalizing records into canonical ledger format',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'No archive workflow has completed yet.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _runningArchiveRemovalPhases() {
  return const [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Removing archive-derived rows from db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail:
          'Deleting previously imported ledger rows for the selected archive source.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Rebuilding working.db from the remaining canonical ledger rows.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for rebuild completion.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive removal is still running.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _failedArchiveRemovalPhases({
  required String detail,
}) {
  return [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Removing archive-derived rows from db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail:
          'Skipped because archive row removal did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail:
          'Skipped because archive row removal did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive removal did not complete.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _runningArchiveImportPhases() {
  return const [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was already validated in preflight.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Normalizing records into canonical ledger format',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Canonical importers are reading archive source tables now.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Archive rows are being written into the canonical ledger.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Migration starts after the ledger import succeeds.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
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
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _failedArchiveImportPhases({
  required String detail,
}) {
  return [
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was already validated in preflight.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Normalizing records into canonical ledger format',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive import did not complete.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _completedArchiveImportPhases({
  required int importedMessageCount,
}) {
  return [
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was validated successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Normalizing records into canonical ledger format',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Canonical importers normalized archive rows successfully.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'Canonical ledger import completed and wrote $importedMessageCount messages for this archive source.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Canonical migration completed successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Projection rebuild steps completed successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'App-visible data was refreshed successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Archive import completed successfully.',
    ),
  ];
}

String _describeExecutionOwnerLabel(String? owner) {
  return switch (owner) {
    'db-import-control' => 'Import or migration',
    'chat-db-monitor' => 'Automatic chat monitor import',
    null => 'Another workflow',
    _ => 'Execution owner "$owner"',
  };
}

String _describeExecutionOwnerPhrase(String? owner) {
  return switch (owner) {
    'db-import-control' => 'import or migration',
    'chat-db-monitor' => 'automatic chat monitor import',
    null => 'another workflow',
    _ => 'execution owner "$owner"',
  };
}
