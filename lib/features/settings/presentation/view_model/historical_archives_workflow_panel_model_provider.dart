import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../core/util/date_converter.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../essentials/db_importers/application/import_execution_gate_provider.dart';
import '../../../../essentials/db_importers/application/orchestrator/import_orchestrator.dart';
import '../../../../essentials/db_importers/application/pipeline_cancellation.dart';
import '../../../../essentials/db_importers/domain/states/table_import_progress.dart';
import '../../../../essentials/db_importers/feature_level_providers.dart';
import '../../../../essentials/db_importers/presentation/view_model/db_import_control_provider.dart';
import '../../../../essentials/logging/application/app_logger.dart';
import '../../../contacts/infrastructure/repositories/participant_merge_utils.dart';

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
  preparationRecorded,
  migrationCompleted,
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
    this.progress,
  });

  final String label;
  final HistoricalArchivesWorkflowPhaseStatus status;
  final String detail;
  final double? progress;
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

final class HistoricalArchivesDuplicateProvenanceEstimate {
  const HistoricalArchivesDuplicateProvenanceEstimate.available({
    required this.currentMacDuplicateCount,
    required this.historicalArchiveDuplicateCount,
  }) : unavailableReason = null;

  const HistoricalArchivesDuplicateProvenanceEstimate.unavailable({
    required this.unavailableReason,
  }) : currentMacDuplicateCount = 0,
       historicalArchiveDuplicateCount = 0;

  final int currentMacDuplicateCount;
  final int historicalArchiveDuplicateCount;
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

enum HistoricalArchivesImportDialogState { running, success, failure }

final class HistoricalArchivesImportDialogViewModel {
  const HistoricalArchivesImportDialogViewModel({
    required this.state,
    required this.title,
    required this.detail,
    required this.summaryLines,
    required this.phases,
    required this.dismissActionLabel,
    required this.cleanupAvailable,
    required this.cleanupDetail,
    this.failureStageLabel,
  });

  final HistoricalArchivesImportDialogState state;
  final String title;
  final String detail;
  final List<String> summaryLines;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;
  final String? dismissActionLabel;
  final bool cleanupAvailable;
  final String cleanupDetail;
  final String? failureStageLabel;

  bool get isTerminal {
    return state != HistoricalArchivesImportDialogState.running;
  }
}

final class HistoricalArchivesPostMigrationHealthCheck {
  const HistoricalArchivesPostMigrationHealthCheck({
    required this.workingLinkedMessageCount,
    required this.workingRecoveredMessageCount,
    required this.contactPickerCandidateCount,
    required this.globalTimelineUsableRowCount,
    required this.contactMessageIndexCount,
    required this.executionGateOwner,
    required this.isMaintenanceLocked,
    required this.messageDataVersionBumped,
    required this.failedCheckLabel,
  });

  final int workingLinkedMessageCount;
  final int workingRecoveredMessageCount;
  final int contactPickerCandidateCount;
  final int globalTimelineUsableRowCount;
  final int contactMessageIndexCount;
  final String? executionGateOwner;
  final bool isMaintenanceLocked;
  final bool messageDataVersionBumped;
  final String? failedCheckLabel;

  int get totalProjectedMessageCount {
    return workingLinkedMessageCount + workingRecoveredMessageCount;
  }

  bool get isHealthy {
    return failedCheckLabel == null;
  }
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
      'Already in current Mac import: waiting for folder selection',
      'Already in historical archive imports: waiting for folder selection',
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
  bool _cancelRequested = false;

  @override
  HistoricalArchivesWorkflowState build() {
    return buildInitialHistoricalArchivesWorkflowState();
  }

  void requestCancelRunningImport() {
    if (state.preflight.status != HistoricalArchivesPreflightStatus.running) {
      return;
    }

    _cancelRequested = true;
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.running,
        statusLabel: 'Cancel requested',
        detail:
            'MessageLens is stopping the archive workflow at the next safe checkpoint.',
      ),
      activityLog: [
        const HistoricalArchivesLogEntryViewModel(
          label: 'Cancel requested',
          message:
              'Archive import cancellation was requested. MessageLens will stop at the next safe checkpoint.',
        ),
        ...state.activityLog,
      ],
    );
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

    WorkingDatabase? workingDb;
    SqfliteImportDatabase? importDb;
    try {
      workingDb = await ref.read(driftWorkingDatabaseProvider.future);
    } catch (_) {}
    try {
      importDb = await ref.read(sqfliteImportDatabaseProvider.future);
    } catch (_) {}

    final result = await preflightHistoricalArchivesFolder(
      folderPath: folderPath,
      workingDb: workingDb,
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
    _cancelRequested = false;
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

    final executionGate = ref.read(importExecutionGateProvider.notifier);
    if (!executionGate.tryAcquire(_historicalArchivesTestingOwner)) {
      final currentOwner = ref.read(importExecutionGateProvider).owner;
      _prependActivityLog(
        HistoricalArchivesLogEntryViewModel(
          label: 'Execution gate busy',
          message:
              '${_describeExecutionOwnerLabel(currentOwner)} currently owns the execution gate. Archive import must wait.',
        ),
      );
      return;
    }

    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    var executionGateReleased = false;
    try {
      state = state.copyWith(
        preflight: const HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.running,
          statusLabel: 'Import running',
          detail:
              'Running canonical ledger import for the selected archive source, then starting the normal canonical migration orchestrator.',
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
          'Success in this slice requires both canonical ledger import and canonical migration to complete.',
        ],
      );

      final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
      final sourceId = await importDb.prepareHistoricalArchiveSource(
        sourceChatDb: selectedChatDbPath,
        folderPath: selectedFolderPath,
        sourceLabel: state.sourceLabel,
        chatDbStatusLabel: state.chatDbStatusLabel,
        attachmentsStatusLabel: state.attachmentsStatusLabel,
        preflightStatusLabel: 'Archive import running',
        preflightDetail:
            'Canonical ledger import started for this historical archive source.',
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
        updatedAtUtc: startedAtUtc,
      );

      final importResult = await ref
          .read(orchestratedLedgerImportServiceProvider)
          .runImport(
            executionOwner: _historicalArchivesTestingOwner,
            sourceChatDbOverride: selectedChatDbPath,
            chatSourceKind: 'historical_archive',
            sourceLabelOverride: state.sourceLabel,
            includeContactImport: false,
            includeAttachmentImport: false,
            onExecutionPlan: (steps) {
              _throwIfCancelRequested();
              state = state.copyWith(
                phases: _archiveImportPhasesFromPlan(steps),
              );
            },
            onTableProgress: (event) {
              _throwIfCancelRequested();
              state = state.copyWith(
                phases: _updateArchiveImportPhasesForEvent(
                  currentPhases: state.phases,
                  event: event,
                ),
              );
            },
          );

      final importFinishedAtUtc = DateTime.now().toUtc().toIso8601String();
      final matchedImportedBatchCount =
          await _readMatchedImportedArchiveBatchCount(
            importDb: importDb,
            sourceChatDbPath: selectedChatDbPath,
          );

      if (_cancelRequested || _isCancellationResult(importResult.error)) {
        await _finalizeCanceledArchiveImport(
          importDb: importDb,
          selectedChatDbPath: selectedChatDbPath,
          selectedFolderPath: selectedFolderPath,
          matchedImportedBatchCount: matchedImportedBatchCount,
          sourceId: sourceId,
          lastImportBatchId: importResult.batchId > 0
              ? importResult.batchId
              : null,
          startedAtUtc: startedAtUtc,
          finishedAtUtc: importFinishedAtUtc,
        );
        return;
      }

      if (!importResult.success) {
        final detail =
            importResult.error ??
            'Canonical archive ledger import did not report success.';
        await importDb.upsertHistoricalArchiveSource(
          sourceChatDb: selectedChatDbPath,
          folderPath: selectedFolderPath,
          sourceLabel: state.sourceLabel,
          chatDbStatusLabel: state.chatDbStatusLabel,
          attachmentsStatusLabel: state.attachmentsStatusLabel,
          preflightStatusLabel: 'Archive ledger import failed',
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
          matchedImportedBatchCount: matchedImportedBatchCount,
          ledgerSourceId: sourceId,
          lastImportBatchId: importResult.batchId > 0
              ? importResult.batchId
              : null,
          lastImportStartedAtUtc: startedAtUtc,
          lastImportFinishedAtUtc: importFinishedAtUtc,
          lastImportSuccess: false,
          lastImportError: detail,
          updatedAtUtc: importFinishedAtUtc,
        );

        state = state.copyWith(
          preflight: HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.failed,
            statusLabel: 'Archive ledger import failed',
            detail: detail,
          ),
          matchedImportedArchiveBatchCount: matchedImportedBatchCount,
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Archive import failed',
              message: detail,
            ),
            ...state.activityLog,
          ],
          phases: _failedArchiveImportPhases(detail: detail),
          resultSummaryLines: const [
            'Canonical archive ledger import failed.',
            'No migration ran, so imported archive rows are not visible in normal app surfaces.',
          ],
        );
        return;
      }

      state = state.copyWith(
        preflight: const HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.running,
          statusLabel: 'Migration running',
          detail:
              'Archive rows were written to db-import. Running the normal canonical migration orchestrator now.',
        ),
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Ledger import complete',
            message:
                'Archive rows were written to db-import for ${path.basename(selectedFolderPath)}. Starting canonical migration.',
          ),
          ...state.activityLog,
        ],
        phases: _runningArchiveMigrationPhases(),
        resultSummaryLines: const [
          'Archive ledger import completed successfully.',
          'Canonical migration is now running so archive rows can become visible through working.db and the normal app surfaces.',
        ],
      );

      ref.read(dbMaintenanceLockProvider.notifier).begin();
      try {
        await ref
            .read(dbImportControlViewModelProvider.notifier)
            .startMigration(
              skipImportCheck: true,
              shouldCancel: () => _cancelRequested,
            );
      } finally {
        ref.read(dbMaintenanceLockProvider.notifier).end();
      }

      final migrationResult = ref
          .read(dbImportControlViewModelProvider)
          .lastMigrationResult;
      final finishedAtUtc = DateTime.now().toUtc().toIso8601String();

      if (_cancelRequested || _isCancellationResult(migrationResult?.error)) {
        await _finalizeCanceledArchiveImport(
          importDb: importDb,
          selectedChatDbPath: selectedChatDbPath,
          selectedFolderPath: selectedFolderPath,
          matchedImportedBatchCount: matchedImportedBatchCount,
          sourceId: sourceId,
          lastImportBatchId: importResult.batchId,
          startedAtUtc: startedAtUtc,
          finishedAtUtc: finishedAtUtc,
        );
        return;
      }

      if (migrationResult?.success != true) {
        final detail =
            migrationResult?.error ??
            'Archive ledger import succeeded, but the canonical migration did not report success.';
        await importDb.upsertHistoricalArchiveSource(
          sourceChatDb: selectedChatDbPath,
          folderPath: selectedFolderPath,
          sourceLabel: state.sourceLabel,
          chatDbStatusLabel: state.chatDbStatusLabel,
          attachmentsStatusLabel: state.attachmentsStatusLabel,
          preflightStatusLabel: 'Ledger import succeeded; migration failed',
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
          matchedImportedBatchCount: matchedImportedBatchCount,
          ledgerSourceId: sourceId,
          lastImportBatchId: importResult.batchId,
          lastImportStartedAtUtc: startedAtUtc,
          lastImportFinishedAtUtc: finishedAtUtc,
          lastImportSuccess: false,
          lastImportError: detail,
          lastImportedMessageCount: importResult.messagesImported,
          updatedAtUtc: finishedAtUtc,
        );

        state = state.copyWith(
          preflight: HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.failed,
            statusLabel: 'Migration failed after archive import',
            detail: detail,
          ),
          matchedImportedArchiveBatchCount: matchedImportedBatchCount,
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Migration failed after import',
              message: detail,
            ),
            ...state.activityLog,
          ],
          phases: _failedArchiveMigrationPhases(detail: detail),
          resultSummaryLines: const [
            'Archive ledger import succeeded, but canonical migration failed.',
            'Archive rows remain staged in db-import and are not visible in normal app surfaces until migration succeeds.',
          ],
        );
        return;
      }

      final previousMessageDataVersion = ref.read(messageDataVersionProvider);
      executionGate.release(_historicalArchivesTestingOwner);
      executionGateReleased = true;

      ref.read(messageDataVersionProvider.notifier).bump();

      final healthCheck = await _runPostMigrationHealthCheck(
        ref,
        previousMessageDataVersion: previousMessageDataVersion,
      );

      if (!healthCheck.isHealthy) {
        final failedCheckLabel =
            healthCheck.failedCheckLabel ??
            'Unknown post-migration health failure';
        final detail =
            'Archive rows were imported, but MessageLens could not confirm that normal app views refreshed correctly. Failed health check: $failedCheckLabel.';

        await importDb.upsertHistoricalArchiveSource(
          sourceChatDb: selectedChatDbPath,
          folderPath: selectedFolderPath,
          sourceLabel: state.sourceLabel,
          chatDbStatusLabel: state.chatDbStatusLabel,
          attachmentsStatusLabel: state.attachmentsStatusLabel,
          preflightStatusLabel: 'Import completed but app data is not ready',
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
          matchedImportedBatchCount: matchedImportedBatchCount,
          ledgerSourceId: sourceId,
          lastImportBatchId: importResult.batchId,
          lastImportStartedAtUtc: startedAtUtc,
          lastImportFinishedAtUtc: finishedAtUtc,
          lastImportSuccess: false,
          lastImportError: detail,
          lastImportedMessageCount: importResult.messagesImported,
          updatedAtUtc: finishedAtUtc,
        );

        state = state.copyWith(
          preflight: HistoricalArchivesPreflightViewModel(
            status: HistoricalArchivesPreflightStatus.failed,
            statusLabel: 'Import completed but app data is not ready',
            detail: detail,
          ),
          matchedImportedArchiveBatchCount: matchedImportedBatchCount,
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Post-migration health check failed',
              message: detail,
            ),
            ...state.activityLog,
          ],
          phases: _failedArchiveAppReadinessPhases(detail: detail),
          resultSummaryLines: _postMigrationHealthFailureSummaryLines(
            healthCheck,
          ),
        );
        return;
      }

      const successDetail =
          'Archive rows were written to db-import, migrated into working.db, and verified through post-migration health checks before MessageLens marked the import complete.';

      await importDb.upsertHistoricalArchiveSource(
        sourceChatDb: selectedChatDbPath,
        folderPath: selectedFolderPath,
        sourceLabel: state.sourceLabel,
        chatDbStatusLabel: state.chatDbStatusLabel,
        attachmentsStatusLabel: state.attachmentsStatusLabel,
        preflightStatusLabel: 'Import and migration complete',
        preflightDetail: successDetail,
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
        matchedImportedBatchCount: matchedImportedBatchCount,
        ledgerSourceId: sourceId,
        lastImportBatchId: importResult.batchId,
        lastImportStartedAtUtc: startedAtUtc,
        lastImportFinishedAtUtc: finishedAtUtc,
        lastImportSuccess: true,
        lastImportError: null,
        lastImportedMessageCount: importResult.messagesImported,
        updatedAtUtc: finishedAtUtc,
      );

      state = state.copyWith(
        preflight: const HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.migrationCompleted,
          statusLabel: 'Archive Import Complete',
          detail: successDetail,
        ),
        matchedImportedArchiveBatchCount: matchedImportedBatchCount,
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Archive import and migration complete',
            message:
                'Imported ${path.basename(selectedFolderPath)} into db-import, completed canonical migration, verified app-visible data, and refreshed normal surfaces.',
          ),
          ...state.activityLog,
        ],
        phases: _completedArchiveImportPhases(),
        resultSummaryLines: _postMigrationHealthSuccessSummaryLines(
          healthCheck,
        ),
      );
    } finally {
      _cancelRequested = false;
      if (!executionGateReleased) {
        executionGate.release(_historicalArchivesTestingOwner);
      }
    }
  }

  void _throwIfCancelRequested() {
    if (_cancelRequested) {
      throw const DbPipelineCancelledException();
    }
  }

  bool _isCancellationResult(String? error) {
    if (error == null) {
      return false;
    }

    return error.contains(dbPipelineCancelledMessage);
  }

  Future<void> _finalizeCanceledArchiveImport({
    required SqfliteImportDatabase importDb,
    required String selectedChatDbPath,
    required String selectedFolderPath,
    required int? matchedImportedBatchCount,
    required int sourceId,
    required int? lastImportBatchId,
    required String startedAtUtc,
    required String finishedAtUtc,
  }) async {
    const detail =
        'Archive import was canceled by the user. MessageLens stopped the historical archive workflow before it could complete.';

    await importDb.upsertHistoricalArchiveSource(
      sourceChatDb: selectedChatDbPath,
      folderPath: selectedFolderPath,
      sourceLabel: state.sourceLabel,
      chatDbStatusLabel: state.chatDbStatusLabel,
      attachmentsStatusLabel: state.attachmentsStatusLabel,
      preflightStatusLabel: 'Archive import canceled',
      preflightDetail: detail,
      totalMessages: _summaryLineInt(
        state.preflightSummaryLines,
        'Total messages:',
      ),
      totalChats: _summaryLineInt(state.preflightSummaryLines, 'Total chats:'),
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
      matchedImportedBatchCount: matchedImportedBatchCount,
      ledgerSourceId: sourceId,
      lastImportBatchId: lastImportBatchId,
      lastImportStartedAtUtc: startedAtUtc,
      lastImportFinishedAtUtc: finishedAtUtc,
      lastImportSuccess: false,
      lastImportError: dbPipelineCancelledMessage,
      updatedAtUtc: finishedAtUtc,
    );

    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.failed,
        statusLabel: 'Archive import canceled',
        detail: detail,
      ),
      matchedImportedArchiveBatchCount: matchedImportedBatchCount,
      activityLog: [
        const HistoricalArchivesLogEntryViewModel(
          label: 'Archive import canceled',
          message:
              'The historical archive workflow was canceled by the user and the execution gate was released.',
        ),
        ...state.activityLog,
      ],
      phases: _cancelledArchivePhases(currentPhases: state.phases),
      resultSummaryLines: const [
        'Archive import was canceled by the user.',
        'MessageLens stopped the historical archive workflow before completion.',
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

    await importDb.prepareHistoricalArchiveSource(
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
  final dbImportControlState = ref.watch(dbImportControlViewModelProvider);

  return buildHistoricalArchivesWorkflowPanelModel(
    executionGateState: executionGateState,
    isMaintenanceLocked: isMaintenanceLocked,
    workflowState: workflowState,
    dbImportControlState: dbImportControlState,
  );
}

HistoricalArchivesWorkflowPanelViewModel
buildHistoricalArchivesWorkflowPanelModel({
  required ImportExecutionGateState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
  DbImportControlState dbImportControlState = const DbImportControlState(),
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
    phases: _effectiveWorkflowPhases(
      workflowState: workflowState,
      dbImportControlState: dbImportControlState,
    ),
  );
}

List<HistoricalArchivesWorkflowPhaseViewModel> _effectiveWorkflowPhases({
  required HistoricalArchivesWorkflowState workflowState,
  required DbImportControlState dbImportControlState,
}) {
  if (workflowState.preflight.status ==
          HistoricalArchivesPreflightStatus.running &&
      workflowState.preflight.statusLabel == 'Migration running' &&
      dbImportControlState.stages.isNotEmpty) {
    return _archiveMigrationPhasesFromUiStages(dbImportControlState.stages);
  }

  return workflowState.phases;
}

List<HistoricalArchivesWorkflowPhaseViewModel> _archiveImportPhasesFromPlan(
  List<ImporterStep> steps,
) {
  if (steps.isEmpty) {
    return _runningArchiveImportPhases();
  }

  return <HistoricalArchivesWorkflowPhaseViewModel>[
    for (var index = 0; index < steps.length; index++)
      HistoricalArchivesWorkflowPhaseViewModel(
        label: _archiveImportStepLabel(steps[index].displayName),
        status: index == 0
            ? HistoricalArchivesWorkflowPhaseStatus.running
            : HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: _archiveImportStepDetail(
          displayName: steps[index].displayName,
          status: index == 0
              ? HistoricalArchivesWorkflowPhaseStatus.running
              : HistoricalArchivesWorkflowPhaseStatus.waiting,
        ),
      ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Run canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for ledger import to complete before migration begins.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refresh app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for canonical migration to complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive import is still running.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel>
_updateArchiveImportPhasesForEvent({
  required List<HistoricalArchivesWorkflowPhaseViewModel> currentPhases,
  required TableImportProgressEvent event,
}) {
  final targetLabel = _archiveImportStepLabel(event.displayName);
  final targetIndex = currentPhases.indexWhere(
    (phase) => phase.label == targetLabel,
  );
  if (targetIndex == -1) {
    return currentPhases;
  }

  final status = switch (event.status) {
    TableImportStatus.failed => HistoricalArchivesWorkflowPhaseStatus.failed,
    TableImportStatus.succeeded
        when event.phase == TableImportPhase.postValidate =>
      HistoricalArchivesWorkflowPhaseStatus.succeeded,
    _ => HistoricalArchivesWorkflowPhaseStatus.running,
  };

  final updated = <HistoricalArchivesWorkflowPhaseViewModel>[];
  for (var index = 0; index < currentPhases.length; index++) {
    final phase = currentPhases[index];

    if (index < targetIndex) {
      updated.add(
        phase.status == HistoricalArchivesWorkflowPhaseStatus.failed
            ? phase
            : HistoricalArchivesWorkflowPhaseViewModel(
                label: phase.label,
                status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
                detail: phase.detail,
                progress: 1.0,
              ),
      );
      continue;
    }

    if (index == targetIndex) {
      updated.add(
        HistoricalArchivesWorkflowPhaseViewModel(
          label: phase.label,
          status: status,
          detail: _archiveImportEventDetail(event, status: status),
          progress: status == HistoricalArchivesWorkflowPhaseStatus.running
              ? event.progress
              : status == HistoricalArchivesWorkflowPhaseStatus.waiting
              ? 0.0
              : 1.0,
        ),
      );
      continue;
    }

    updated.add(
      HistoricalArchivesWorkflowPhaseViewModel(
        label: phase.label,
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: phase.detail,
        progress: 0.0,
      ),
    );
  }

  return updated;
}

List<HistoricalArchivesWorkflowPhaseViewModel>
_archiveMigrationPhasesFromUiStages(List<UiStageProgress> stages) {
  final runningIndex = () {
    final activeIndex = stages.indexWhere((stage) => stage.isActive);
    if (activeIndex != -1) {
      return activeIndex;
    }
    return stages.indexWhere((stage) => !stage.isComplete);
  }();

  return <HistoricalArchivesWorkflowPhaseViewModel>[
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Archive source validated',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was validated successfully.',
      progress: 1.0,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Write archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Archive rows were written into the canonical ledger.',
      progress: 1.0,
    ),
    for (var index = 0; index < stages.length; index++)
      HistoricalArchivesWorkflowPhaseViewModel(
        label: _migrationStepLabel(stages[index].displayName),
        status: stages[index].isComplete
            ? HistoricalArchivesWorkflowPhaseStatus.succeeded
            : index == runningIndex
            ? HistoricalArchivesWorkflowPhaseStatus.running
            : HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: _migrationStageDetail(
          stage: stages[index],
          status: stages[index].isComplete
              ? HistoricalArchivesWorkflowPhaseStatus.succeeded
              : index == runningIndex
              ? HistoricalArchivesWorkflowPhaseStatus.running
              : HistoricalArchivesWorkflowPhaseStatus.waiting,
        ),
        progress: stages[index].isComplete
            ? 1.0
            : index == runningIndex
            ? stages[index].progress
            : 0.0,
      ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refresh app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail:
          'Waiting for canonical migration to finish before refreshing providers.',
      progress: 0.0,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for refresh to finish.',
      progress: 0.0,
    ),
  ];
}

String _archiveImportStepLabel(String displayName) {
  return switch (displayName) {
    'Prepare Sources' => 'Read archive source',
    'Clear Ledger' => 'Clear archive target ledger state',
    _ => 'Write ${displayName.toLowerCase()} to db-import',
  };
}

String _archiveImportStepDetail({
  required String displayName,
  required HistoricalArchivesWorkflowPhaseStatus status,
}) {
  final noun = displayName.toLowerCase();
  return switch (displayName) {
    'Prepare Sources' =>
      status == HistoricalArchivesWorkflowPhaseStatus.running
          ? 'Reading archive metadata and preparing canonical source context.'
          : 'Waiting to read archive metadata and prepare canonical source context.',
    'Clear Ledger' =>
      status == HistoricalArchivesWorkflowPhaseStatus.running
          ? 'Clearing any stale ledger rows for this archive import run.'
          : 'Waiting to clear ledger rows for this archive import run.',
    _ =>
      status == HistoricalArchivesWorkflowPhaseStatus.running
          ? 'Importing $noun into the canonical ledger.'
          : 'Waiting to import $noun into the canonical ledger.',
  };
}

String _archiveImportEventDetail(
  TableImportProgressEvent event, {
  required HistoricalArchivesWorkflowPhaseStatus status,
}) {
  if (event.currentItem case final String currentItem?) {
    return currentItem;
  }
  if (event.rowsProcessed != null && event.totalRows != null) {
    final rowsProcessed = event.rowsProcessed!;
    final totalRows = event.totalRows!;
    return 'Processed $rowsProcessed of $totalRows rows for ${event.displayName.toLowerCase()}.';
  }
  if (event.message case final String message?) {
    return message;
  }

  return _archiveImportStepDetail(
    displayName: event.displayName,
    status: status,
  );
}

String _migrationStepLabel(String displayName) {
  return switch (displayName) {
    'Handles' => 'Build handles',
    'Chats' => 'Build chats',
    'Chat To Handle' => 'Build chat-handle joins',
    'Participants' => 'Build participants',
    'Handle To Participant' => 'Build handle-participant joins',
    'Messages' => 'Build working messages',
    'Recovered Unlinked Messages' => 'Build recovered messages',
    'Attachments' => 'Build attachments',
    'Recovered Unlinked Attachments' => 'Build recovered attachments',
    'Reactions' => 'Build reactions',
    'Reaction Counts' => 'Build reaction counts',
    'Message Read Marks' => 'Build message read marks',
    'Read State' => 'Build read state',
    'Rebuild Indexes' => 'Rebuild indexes',
    'Rebuild Search' => 'Rebuild search support',
    _ => displayName,
  };
}

String _migrationStageDetail({
  required UiStageProgress stage,
  required HistoricalArchivesWorkflowPhaseStatus status,
}) {
  if (stage.current != null && stage.total != null) {
    final progressPercent = ((stage.progress ?? 0) * 100).round();
    if (_migrationStepLabel(stage.displayName) == 'Build working messages') {
      return 'Processed: ${stage.current} / ${stage.total} messages ($progressPercent%)';
    }
    return 'Processed ${stage.current} of ${stage.total} rows ($progressPercent%).';
  }
  return switch (_migrationStepLabel(stage.displayName)) {
    'Build handles' => 'Creating canonical handles from imported ledger rows.',
    'Build chats' => 'Creating working chat rows from canonical ledger data.',
    'Build chat-handle joins' => 'Linking chats to their participant handles.',
    'Build participants' =>
      'Building participant records for contact-aware views.',
    'Build handle-participant joins' =>
      'Linking handles to participant records.',
    'Build working messages' =>
      'Rebuilding working.db message rows from canonical ledger data.',
    'Build recovered messages' =>
      'Rebuilding recovered-message rows for unlinked historical records.',
    'Build attachments' => 'Rebuilding attachment projections.',
    'Build recovered attachments' =>
      'Rebuilding recovered attachment projections.',
    'Build reactions' =>
      'Rebuilding reaction records tied to projected messages.',
    'Build reaction counts' => 'Recomputing reaction count summaries.',
    'Build message read marks' => 'Rebuilding read mark projections.',
    'Build read state' => 'Rebuilding conversation read state projections.',
    'Rebuild indexes' => 'Rebuilding working.db indexes for timeline access.',
    'Rebuild search support' =>
      'Rebuilding search support data after migration.',
    _ =>
      status == HistoricalArchivesWorkflowPhaseStatus.running
          ? 'This migration step is running.'
          : 'Waiting for this migration step.',
  };
}

HistoricalArchivesImportDialogViewModel
buildHistoricalArchivesImportDialogViewModel({
  required HistoricalArchivesWorkflowPanelViewModel panelModel,
}) {
  switch (panelModel.preflight.status) {
    case HistoricalArchivesPreflightStatus.migrationCompleted:
      return HistoricalArchivesImportDialogViewModel(
        state: HistoricalArchivesImportDialogState.success,
        title: 'Import Complete',
        detail: panelModel.preflight.detail,
        summaryLines: _successfulImportDialogSummaryLines(panelModel),
        phases: panelModel.phases,
        dismissActionLabel: 'Done',
        cleanupAvailable: false,
        cleanupDetail: '',
      );
    case HistoricalArchivesPreflightStatus.failed:
      final failedStageLabel = _firstFailedPhaseLabel(panelModel.phases);
      final isVisibilityFailure =
          panelModel.preflight.statusLabel ==
          'Migration failed after archive import';
      final isReadinessFailure =
          panelModel.preflight.statusLabel ==
          'Import completed but app data is not ready';
      return HistoricalArchivesImportDialogViewModel(
        state: HistoricalArchivesImportDialogState.failure,
        title: isReadinessFailure
            ? 'Import Completed But App Data Is Not Ready'
            : isVisibilityFailure
            ? 'Import Could Not Be Made Visible'
            : 'Archive Import Failed',
        detail: panelModel.preflight.detail,
        summaryLines: _failedImportDialogSummaryLines(
          panelModel,
          failedStageLabel: failedStageLabel,
        ),
        phases: panelModel.phases,
        dismissActionLabel: 'Close',
        cleanupAvailable: panelModel.removeImportedArchiveDataEnabled,
        cleanupDetail: panelModel.removeImportedArchiveDataEnabled
            ? panelModel.removeImportedArchiveDataDetail
            : 'Cleanup actions are not available for this source yet.',
        failureStageLabel: failedStageLabel,
      );
    case HistoricalArchivesPreflightStatus.waitingForFolder:
    case HistoricalArchivesPreflightStatus.running:
    case HistoricalArchivesPreflightStatus.completeReadyToImport:
    case HistoricalArchivesPreflightStatus.preparationRecorded:
      return HistoricalArchivesImportDialogViewModel(
        state: HistoricalArchivesImportDialogState.running,
        title: 'Importing Historical Messages',
        detail: panelModel.preflight.detail,
        summaryLines: _runningImportDialogSummaryLines(panelModel),
        phases: panelModel.phases,
        dismissActionLabel: null,
        cleanupAvailable: false,
        cleanupDetail: '',
      );
  }
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

List<String> _runningImportDialogSummaryLines(
  HistoricalArchivesWorkflowPanelViewModel panelModel,
) {
  return <String>[
    'Source label: ${panelModel.sourceLabel}',
    if (panelModel.selectedFolderPath case final String selectedFolderPath)
      'Folder path: $selectedFolderPath',
    ...panelModel.resultSummaryLines,
  ];
}

List<String> _successfulImportDialogSummaryLines(
  HistoricalArchivesWorkflowPanelViewModel panelModel,
) {
  final earliest = _firstLineWithPrefix(
    panelModel.preflightSummaryLines,
    'Earliest message:',
  );
  final latest = _firstLineWithPrefix(
    panelModel.preflightSummaryLines,
    'Latest message:',
  );
  final newMessages = _firstLineWithPrefix(
    panelModel.dryRunSummaryLines,
    'Estimated new messages:',
  );
  final currentMacDuplicates =
      _firstLineWithPrefix(
        panelModel.preflightSummaryLines,
        'Already in current Mac import:',
      ) ??
      _firstLineWithPrefix(
        panelModel.dryRunSummaryLines,
        'Estimated duplicates:',
      );
  final historicalArchiveDuplicates = _firstLineWithPrefix(
    panelModel.preflightSummaryLines,
    'Already in historical archive imports:',
  );
  final missingIdentifiers = _firstLineWithPrefix(
    panelModel.preflightSummaryLines,
    'Rows with missing GUIDs:',
  );

  return <String>[
    if (newMessages != null)
      'New messages added: ${newMessages.substring('Estimated new messages:'.length).trim()}',
    if (currentMacDuplicates != null)
      'Already in current Mac data: ${currentMacDuplicates.substring(currentMacDuplicates.indexOf(':') + 1).trim()}',
    if (historicalArchiveDuplicates != null)
      'Already imported from archives: ${historicalArchiveDuplicates.substring('Already in historical archive imports:'.length).trim()}',
    if (missingIdentifiers != null)
      'Missing identifiers: ${missingIdentifiers.substring('Rows with missing GUIDs:'.length).trim()}',
    if (earliest != null && latest != null)
      'Date range: ${earliest.substring('Earliest message:'.length).trim()} -> ${latest.substring('Latest message:'.length).trim()}',
    'Your timeline, search, and heatmap have been updated.',
  ];
}

List<String> _failedImportDialogSummaryLines(
  HistoricalArchivesWorkflowPanelViewModel panelModel, {
  required String? failedStageLabel,
}) {
  return <String>[
    'Source label: ${panelModel.sourceLabel}',
    if (failedStageLabel != null) 'Failed stage: $failedStageLabel',
    ...panelModel.resultSummaryLines,
    if (panelModel.removeImportedArchiveDataEnabled)
      'Cleanup is available from the setup screen for this source.'
    else
      'Cleanup is not available for this source yet.',
  ];
}

Future<HistoricalArchivesPostMigrationHealthCheck> _runPostMigrationHealthCheck(
  Ref ref, {
  required int previousMessageDataVersion,
}) async {
  ref.invalidate(driftWorkingDatabaseProvider);
  final workingDb = await ref.read(driftWorkingDatabaseProvider.future);

  final workingLinkedMessageCount = await _workingTableRowCount(
    workingDb,
    tableName: 'messages',
  );
  final workingRecoveredMessageCount = await _workingTableRowCount(
    workingDb,
    tableName: 'recovered_unlinked_messages',
  );
  final contactPickerCandidateCount = await _contactPickerCandidateCount(
    workingDb,
  );
  final globalTimelineUsableRowCount = await _globalTimelineUsableRowCount(
    workingDb,
  );
  final contactMessageIndexCount = await _workingTableRowCount(
    workingDb,
    tableName: 'contact_message_index',
  );
  final executionGateOwner = ref.read(importExecutionGateProvider).owner;
  final isMaintenanceLocked = ref.read(dbMaintenanceLockProvider);
  final messageDataVersionBumped =
      ref.read(messageDataVersionProvider) > previousMessageDataVersion;

  String? failedCheckLabel;
  if (workingLinkedMessageCount + workingRecoveredMessageCount <= 0) {
    failedCheckLabel = 'working.db has no projected messages';
  } else if (contactPickerCandidateCount <= 0) {
    failedCheckLabel = 'contact picker has no selectable contacts';
  } else if (globalTimelineUsableRowCount <= 0) {
    failedCheckLabel = 'timeline metadata has no usable rows';
  } else if (executionGateOwner != null) {
    failedCheckLabel = 'execution gate is still owned by $executionGateOwner';
  } else if (isMaintenanceLocked) {
    failedCheckLabel = 'message-data maintenance lock is still active';
  } else if (!messageDataVersionBumped) {
    failedCheckLabel = 'message data version was not bumped after migration';
  }

  final result = HistoricalArchivesPostMigrationHealthCheck(
    workingLinkedMessageCount: workingLinkedMessageCount,
    workingRecoveredMessageCount: workingRecoveredMessageCount,
    contactPickerCandidateCount: contactPickerCandidateCount,
    globalTimelineUsableRowCount: globalTimelineUsableRowCount,
    contactMessageIndexCount: contactMessageIndexCount,
    executionGateOwner: executionGateOwner,
    isMaintenanceLocked: isMaintenanceLocked,
    messageDataVersionBumped: messageDataVersionBumped,
    failedCheckLabel: failedCheckLabel,
  );

  final logger = ref.read(appLoggerProvider.notifier);
  final logContext = <String, dynamic>{
    'workingLinkedMessageCount': result.workingLinkedMessageCount,
    'workingRecoveredMessageCount': result.workingRecoveredMessageCount,
    'contactPickerCandidateCount': result.contactPickerCandidateCount,
    'globalTimelineUsableRowCount': result.globalTimelineUsableRowCount,
    'contactMessageIndexCount': result.contactMessageIndexCount,
    'executionGateOwner': result.executionGateOwner,
    'isMaintenanceLocked': result.isMaintenanceLocked,
    'messageDataVersionBumped': result.messageDataVersionBumped,
    'failedCheckLabel': result.failedCheckLabel,
  };

  if (result.isHealthy) {
    logger.info(
      'Historical archive post-migration health check passed',
      source: 'HistoricalArchivesWorkflow',
      context: logContext,
    );
  } else {
    logger.warn(
      'Historical archive post-migration health check failed',
      source: 'HistoricalArchivesWorkflow',
      context: logContext,
    );
  }

  return result;
}

Future<int> _workingTableRowCount(
  WorkingDatabase workingDb, {
  required String tableName,
}) async {
  final row = await workingDb
      .customSelect('SELECT COUNT(*) AS c FROM $tableName')
      .getSingle();
  return row.read<int>('c');
}

Future<int> _contactPickerCandidateCount(WorkingDatabase workingDb) async {
  final rows = await workingDb
      .customSelect(
        'SELECT display_name FROM participants ORDER BY display_name ASC',
        readsFrom: {workingDb.workingParticipants},
      )
      .get();

  return rows.where((row) {
    final displayName = row.read<String>('display_name');
    return !isPlaceholderDisplayName(displayName);
  }).length;
}

Future<int> _globalTimelineUsableRowCount(WorkingDatabase workingDb) async {
  final row = await workingDb
      .customSelect(
        '''
        SELECT COUNT(*) AS c
        FROM global_message_index
        WHERE sent_at_utc IS NOT NULL AND sent_at_utc != ''
        ''',
        readsFrom: {workingDb.globalMessageIndex},
      )
      .getSingle();
  return row.read<int>('c');
}

List<String> _postMigrationHealthSuccessSummaryLines(
  HistoricalArchivesPostMigrationHealthCheck healthCheck,
) {
  return <String>[
    'Projected messages: ${healthCheck.totalProjectedMessageCount}',
    'Selectable contacts: ${healthCheck.contactPickerCandidateCount}',
    'Timeline rows: ${healthCheck.globalTimelineUsableRowCount}',
    'Archive rows are now visible through the normal timeline, search, and heatmap surfaces.',
  ];
}

List<String> _postMigrationHealthFailureSummaryLines(
  HistoricalArchivesPostMigrationHealthCheck healthCheck,
) {
  return <String>[
    'Failed health check: ${healthCheck.failedCheckLabel ?? 'Unknown health check failure'}',
    'Projected messages: ${healthCheck.totalProjectedMessageCount}',
    'Selectable contacts: ${healthCheck.contactPickerCandidateCount}',
    'Timeline rows: ${healthCheck.globalTimelineUsableRowCount}',
    'Recommended action: close this dialog and send a diagnostic report before trying another archive import.',
  ];
}

String? _firstFailedPhaseLabel(
  List<HistoricalArchivesWorkflowPhaseViewModel> phases,
) {
  for (final phase in phases) {
    if (phase.status == HistoricalArchivesWorkflowPhaseStatus.failed) {
      return phase.label;
    }
  }
  return null;
}

String _availableStatusLabel(HistoricalArchivesWorkflowState workflowState) {
  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => 'No archive selected',
    HistoricalArchivesPreflightStatus.running =>
      workflowState.preflight.statusLabel,
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Archive Source Ready',
    HistoricalArchivesPreflightStatus.preparationRecorded =>
      'Archive Ledger Import Complete',
    HistoricalArchivesPreflightStatus.migrationCompleted =>
      'Archive Import Complete',
    HistoricalArchivesPreflightStatus.failed =>
      workflowState.preflight.statusLabel,
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
    HistoricalArchivesPreflightStatus.preparationRecorded =>
      'Historical Archives has written archive rows into the canonical ledger for the selected folder. Full canonical migration is still deferred in this slice, so those rows are not visible in normal app surfaces yet.',
    HistoricalArchivesPreflightStatus.migrationCompleted =>
      'Historical Archives has completed canonical ledger import and canonical migration for the selected folder. Archive rows are now visible through the normal app surfaces.',
    HistoricalArchivesPreflightStatus.failed => workflowState.preflight.detail,
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
      'Source checks are complete. Begin Import will write archive rows into db-import and then run the normal canonical migration orchestrator.',
    HistoricalArchivesPreflightStatus.preparationRecorded =>
      'Archive ledger import has already completed for this source. Full canonical migration remains deferred in this slice.',
    HistoricalArchivesPreflightStatus.migrationCompleted =>
      'Archive import and canonical migration have already completed for this source.',
    HistoricalArchivesPreflightStatus.failed =>
      workflowState.preflight.statusLabel ==
              'Migration failed after archive import'
          ? 'Archive import succeeded, but canonical migration failed. Fix the migration issue before retrying this archive source.'
          : 'Import stays disabled until the selected folder passes source preflight.',
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
  final currentMacDuplicates = _summaryLineInt(
    workflowState.preflightSummaryLines,
    'Already in current Mac import:',
  );
  final historicalArchiveDuplicates = _summaryLineInt(
    workflowState.preflightSummaryLines,
    'Already in historical archive imports:',
  );

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

  return [
    'Removal target chat.db: $targetPath',
    batchSummary,
    if (currentMacDuplicates != null)
      'Matching GUIDs already in current Mac import: $currentMacDuplicates',
    if (historicalArchiveDuplicates != null)
      'Matching GUIDs already in historical archive imports: $historicalArchiveDuplicates',
  ];
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
    final currentMacDuplicates = _summaryLineInt(
      workflowState.preflightSummaryLines,
      'Already in current Mac import:',
    );
    final historicalArchiveDuplicates = _summaryLineInt(
      workflowState.preflightSummaryLines,
      'Already in historical archive imports:',
    );

    if ((currentMacDuplicates ?? 0) > 0 &&
        (historicalArchiveDuplicates ?? 0) == 0) {
      return 'No imported archive batches are currently recorded for this selected source. The duplicate count is coming from messages already present in your current MessageLens data after the current Mac import.';
    }

    if ((historicalArchiveDuplicates ?? 0) > 0) {
      return 'MessageLens can see matching GUIDs that also appear in historical archive imports, but no imported archive batches are recorded for this exact selected folder path.';
    }

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
  WorkingDatabase? workingDb,
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
      final dryRunEstimate = await _estimateDryRunAgainstWorkingDatabase(
        sourceDatabase: database,
        workingDb: workingDb,
      );
      final duplicateProvenanceEstimate =
          await _estimateDuplicateProvenanceAgainstImportDatabase(
            sourceDatabase: database,
            importDb: importDb,
          );

      return HistoricalArchivesFolderPreflightResult(
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.completeReadyToImport,
          statusLabel: 'Preflight complete',
          detail: dryRunEstimate.isAvailable
              ? 'Source checks succeeded and GUID-based dry-run estimates are now visible. Canonical import wiring is still pending.'
              : 'Source checks succeeded, but working.db dry-run comparison is unavailable right now. Canonical import wiring is still pending.',
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
            'Likely duplicates already in working.db: ${dryRunEstimate.duplicateGuidCount} GUID-backed source rows'
          else
            'Likely duplicates already in working.db: unavailable',
          if (dryRunEstimate.isAvailable)
            'Likely new rows: ${dryRunEstimate.newGuidCount} GUID-backed source rows'
          else
            'Likely new rows: unavailable',
          if (duplicateProvenanceEstimate.isAvailable)
            'Already in current Mac import: ${duplicateProvenanceEstimate.currentMacDuplicateCount} GUID-backed source rows'
          else
            'Already in current Mac import: unavailable',
          if (duplicateProvenanceEstimate.isAvailable)
            'Already in historical archive imports: ${duplicateProvenanceEstimate.historicalArchiveDuplicateCount} GUID-backed source rows'
          else
            'Already in historical archive imports: unavailable',
        ],
        dryRunSummaryLines: [
          if (dryRunEstimate.isAvailable)
            'Estimated new messages: ${dryRunEstimate.newGuidCount} GUID-backed source rows not present in working.db'
          else
            'Estimated new messages: working.db comparison unavailable',
          if (dryRunEstimate.isAvailable)
            'Estimated duplicates: ${dryRunEstimate.duplicateGuidCount} GUID-backed source rows already projected'
          else
            'Estimated duplicates: working.db comparison unavailable',
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
                ? 'Compared ${dryRunEstimate.comparableGuidCount} GUID-backed source rows against working.db.'
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
      'Already in current Mac import: unavailable',
      'Already in historical archive imports: unavailable',
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

  final value = result.first['total_count'];
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
  // Delegate to the canonical utility so preflight, importers, and migrators
  // all interpret Apple-epoch raw values identically. The helper handles
  // null, zero, the seconds-vs-nanoseconds variants of chat.db, and never
  // silently coerces invalid values to epoch zero.
  return DateConverter.appleToIsoString(value);
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

Future<HistoricalArchivesDryRunEstimate> _estimateDryRunAgainstWorkingDatabase({
  required Database sourceDatabase,
  required WorkingDatabase? workingDb,
}) async {
  if (workingDb == null) {
    return const HistoricalArchivesDryRunEstimate.unavailable(
      unavailableReason:
          'working.db comparison is unavailable because the projected database could not be opened.',
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

      duplicateGuidCount += await _countMatchingProjectedGuids(
        workingDb: workingDb,
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
          'working.db comparison failed while estimating duplicate GUIDs: $error',
    );
  }
}

Future<HistoricalArchivesDuplicateProvenanceEstimate>
_estimateDuplicateProvenanceAgainstImportDatabase({
  required Database sourceDatabase,
  required SqfliteImportDatabase? importDb,
}) async {
  if (importDb == null) {
    return const HistoricalArchivesDuplicateProvenanceEstimate.unavailable(
      unavailableReason:
          'import db comparison is unavailable because the canonical ledger database could not be opened.',
    );
  }

  try {
    const sourceChunkSize = 400;
    var currentMacDuplicateCount = 0;
    var historicalArchiveDuplicateCount = 0;

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

      if (sourceGuids.isEmpty) {
        continue;
      }

      final counts = await _countMatchingImportGuidsBySourceKind(
        importDb: importDb,
        sourceGuids: sourceGuids,
      );
      currentMacDuplicateCount += counts['current_mac'] ?? 0;
      historicalArchiveDuplicateCount += counts['historical_archive'] ?? 0;
    }

    return HistoricalArchivesDuplicateProvenanceEstimate.available(
      currentMacDuplicateCount: currentMacDuplicateCount,
      historicalArchiveDuplicateCount: historicalArchiveDuplicateCount,
    );
  } catch (error) {
    return HistoricalArchivesDuplicateProvenanceEstimate.unavailable(
      unavailableReason:
          'import db comparison failed while estimating duplicate provenance: $error',
    );
  }
}

Future<Map<String, int>> _countMatchingImportGuidsBySourceKind({
  required SqfliteImportDatabase importDb,
  required List<String> sourceGuids,
}) async {
  if (sourceGuids.isEmpty) {
    return const <String, int>{};
  }

  final placeholders = List.filled(sourceGuids.length, '?').join(', ');
  final rows = await importDb.rawQuery(
    'SELECT ib.chat_source_kind AS source_kind, '
    'COUNT(DISTINCT m.guid) AS total_count '
    'FROM messages m '
    'JOIN import_batches ib ON ib.id = m.batch_id '
    'WHERE m.guid IN ($placeholders) '
    "AND (ib.status IS NULL OR ib.status != 'cancelled') "
    'GROUP BY ib.chat_source_kind',
    sourceGuids,
  );

  return <String, int>{
    for (final row in rows)
      if (row['source_kind'] case final String sourceKind)
        sourceKind: row['total_count'] is int
            ? row['total_count'] as int
            : int.tryParse('${row['total_count']}') ?? 0,
  };
}

Future<int> _countMatchingProjectedGuids({
  required WorkingDatabase workingDb,
  required List<String> sourceGuids,
}) async {
  if (sourceGuids.isEmpty) {
    return 0;
  }

  final placeholders = List.filled(sourceGuids.length, '?').join(', ');
  final row = await workingDb
      .customSelect(
        'SELECT COUNT(*) AS total_count FROM messages WHERE guid IN ($placeholders)',
        variables: [
          for (final guid in sourceGuids) drift.Variable.withString(guid),
        ],
      )
      .getSingle();

  return row.read<int>('total_count');
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
      progress: 1.0,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Prepare archive import plan',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Preparing the canonical archive import execution plan.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Write archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for the archive import plan to start.',
      progress: 0.0,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Run canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Migration starts after the ledger import succeeds.',
      progress: 0.0,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refresh app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for canonical migration to complete.',
      progress: 0.0,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive import is still running.',
      progress: 0.0,
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel>
_runningArchiveMigrationPhases() {
  return const [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Archive source validated',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was already validated in preflight.',
      progress: 1.0,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Write archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Archive rows were written into the canonical ledger.',
      progress: 1.0,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Prepare canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Preparing the canonical migration execution plan.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refresh app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail:
          'Waiting for the canonical migration orchestrator to complete successfully.',
      progress: 0.0,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive migration is still running.',
      progress: 0.0,
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _completedArchiveImportPhases() {
  return const [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was already validated in preflight.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Normalizing records into canonical ledger format',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'Archive source rows were normalized through the canonical import path.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Archive rows were written into the canonical ledger.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'The normal canonical migration orchestrator completed successfully.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
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
      detail: 'Archive import and canonical migration completed successfully.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel>
_failedArchiveAppReadinessPhases({required String detail}) {
  return [
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was already validated in preflight.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Normalizing records into canonical ledger format',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'Archive source rows were normalized through the canonical import path.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Archive rows were written into the canonical ledger.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'The normal canonical migration orchestrator completed successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'The normal migration rebuild refreshed indexes and support tables.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail:
          'Archive import cannot be marked complete until app data is ready.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _failedArchiveMigrationPhases({
  required String detail,
}) {
  return [
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reading archive source',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Selected archive metadata was already validated in preflight.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Normalizing records into canonical ledger format',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'Archive source rows were normalized through the canonical import path.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Archive rows were written into the canonical ledger.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail:
          'Skipped because canonical migration did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive migration did not complete.',
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
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Writing archive rows to db-import',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Running full canonical migration',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because canonical archive ledger import failed.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because canonical archive ledger import failed.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because canonical archive ledger import failed.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Complete',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Archive import did not complete.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _cancelledArchivePhases({
  required List<HistoricalArchivesWorkflowPhaseViewModel> currentPhases,
}) {
  var cancellationMarked = false;

  return <HistoricalArchivesWorkflowPhaseViewModel>[
    for (final phase in currentPhases)
      if (phase.status == HistoricalArchivesWorkflowPhaseStatus.succeeded)
        HistoricalArchivesWorkflowPhaseViewModel(
          label: phase.label,
          status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
          detail: phase.detail,
          progress: 1.0,
        )
      else if (!cancellationMarked &&
          phase.status == HistoricalArchivesWorkflowPhaseStatus.running)
        (() {
          cancellationMarked = true;
          return HistoricalArchivesWorkflowPhaseViewModel(
            label: phase.label,
            status: HistoricalArchivesWorkflowPhaseStatus.failed,
            detail: 'Canceled by user while this step was running.',
            progress: phase.progress,
          );
        })()
      else if (phase.label == 'Complete')
        const HistoricalArchivesWorkflowPhaseViewModel(
          label: 'Complete',
          status: HistoricalArchivesWorkflowPhaseStatus.waiting,
          detail: 'Archive import was canceled before completion.',
          progress: 0.0,
        )
      else
        HistoricalArchivesWorkflowPhaseViewModel(
          label: phase.label,
          status: HistoricalArchivesWorkflowPhaseStatus.skipped,
          detail: 'Skipped after the user canceled the archive workflow.',
          progress: 0.0,
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
