import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/conversation_graph/application/archives/source_scoped_archive_graph_import_service_provider.dart';
import '../../../essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service_provider.dart';
import '../../../essentials/conversation_graph/application/orchestration/graph_maintenance_execution_gate_provider.dart';
import '../../../essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import '../../../essentials/db/feature_level_providers/db_maintenance_lock_provider.dart';
import '../../../essentials/db/feature_level_providers/message_data_version_provider.dart';
import '../../../essentials/onboarding/application/onboarding_environment_report_provider.dart';
import '../feature_level_providers.dart';
import 'archive_source_inspection.dart';
import 'historical_archive_sources.dart';

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
    bool clearSelectedFolderPath = false,
    bool clearArchiveRemovalTargetChatDbPath = false,
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
      'Likely duplicates already in conversation graph: waiting for folder selection',
      'Likely new rows: waiting for folder selection',
    ],
    dryRunSummaryLines: [
      'Estimated new messages: waiting for preflight',
      'Estimated duplicates: waiting for preflight',
    ],
    resultSummaryLines: [
      'No archive import has run yet.',
      'User-facing success appears after source-scoped archive import and graph projection complete.',
    ],
    activityLog: [
      HistoricalArchivesLogEntryViewModel(
        label: 'Archive workflow ready',
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
        label: 'Writing archive rows to source-scoped import',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Ledger ingestion starts after you run archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Projecting archive rows into conversation graph',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Graph projection begins only after successful archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Post-projection rebuild steps are still waiting.',
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
    final folderChooser = ref.read(historicalArchiveFolderChooserProvider);
    final folderPath = await folderChooser.chooseMessagesFolder();
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
        'User-facing success appears after source-scoped archive import and graph projection complete.',
      ],
      activityLog: [
        HistoricalArchivesLogEntryViewModel(
          label: 'Reading archive…',
          message: 'Inspecting ${path.basename(folderPath)}.',
        ),
      ],
      phases: _runningPreflightPhases(),
    );

    ArchiveSourceInspector? archiveSourceInspector;
    HistoricalArchiveSources? archiveSources;
    try {
      archiveSourceInspector = await ref.read(
        archiveSourceInspectorProvider.future,
      );
    } catch (_) {}
    try {
      archiveSources = await ref.read(historicalArchiveSourcesProvider.future);
    } catch (_) {}

    final result = await preflightHistoricalArchivesFolder(
      folderPath: folderPath,
      archiveSourceInspector: archiveSourceInspector,
    );

    await _persistHistoricalArchiveSourceIfEligible(
      archiveSources: archiveSources,
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
    if (_isCurrentMacChatDbPath(
      selectedChatDbPath,
      currentMessagesDatabasePath: ref.read(
        onboardingMessagesDatabasePathProvider,
      ),
    )) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'Current Messages source protected',
          message:
              'Remove Imported Archive Data refuses to target the live ~/Library/Messages/chat.db source. Choose an archive folder instead.',
        ),
      );
      return;
    }

    final executionGate = ref.read(
      graphMaintenanceExecutionGateProvider.notifier,
    );
    if (!executionGate.tryAcquire(_historicalArchivesTestingOwner)) {
      final currentOwner = ref
          .read(graphMaintenanceExecutionGateProvider)
          .owner;
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
            'Deleting previously imported archive ledger rows for this source and refreshing graph-visible data.',
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
      final removalService = await ref.read(
        sourceScopedArchiveGraphRemovalServiceProvider.future,
      );
      final removalResult = await removalService.removeArchiveSource(
        folderPath: selectedFolderPath,
      );
      ref.invalidate(conversationGraphReadinessProvider);
      ref.invalidate(conversationGraphPopulatedProvider);
      ref.read(messageDataVersionProvider.notifier).bump();

      if (!removalResult.sourceWasRegistered ||
          removalResult.deletionResult == null ||
          removalResult.deletedSourceFactCount == 0) {
        await loadFolder(folderPath: selectedFolderPath);
        _prependActivityLog(
          const HistoricalArchivesLogEntryViewModel(
            label: 'No imported archive data found',
            message:
                'MessageLens did not find source-scoped imported rows for the selected archive source.',
          ),
        );
        return;
      }

      await loadFolder(folderPath: selectedFolderPath);
      _prependActivityLog(
        HistoricalArchivesLogEntryViewModel(
          label: 'Imported archive data removed',
          message:
              'Deleted ${removalResult.deletedSourceFactCount} source fact rows and ${removalResult.deletedTopologyEdgeCount} topology rows for this source, then reprojected the conversation graph.',
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
    if (_isCurrentMacChatDbPath(
      selectedChatDbPath,
      currentMessagesDatabasePath: ref.read(
        onboardingMessagesDatabasePathProvider,
      ),
    )) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'Current Messages source protected',
          message:
              'Historical Archives refuses to import the live ~/Library/Messages/chat.db source. Choose an archive folder instead.',
        ),
      );
      return;
    }

    final executionGate = ref.read(
      graphMaintenanceExecutionGateProvider.notifier,
    );
    if (!executionGate.tryAcquire('historical-archives-import')) {
      final currentOwner = ref
          .read(graphMaintenanceExecutionGateProvider)
          .owner;
      _prependActivityLog(
        HistoricalArchivesLogEntryViewModel(
          label: 'Execution gate busy',
          message:
              '${_describeExecutionOwnerLabel(currentOwner)} currently owns the execution gate. Archive import must wait.',
        ),
      );
      return;
    }

    ref.read(dbMaintenanceLockProvider.notifier).begin();
    state = state.copyWith(
      preflight: const HistoricalArchivesPreflightViewModel(
        status: HistoricalArchivesPreflightStatus.running,
        statusLabel: 'Import running',
        detail:
            'Running source-scoped archive import for the selected source, then projecting it into the conversation graph.',
      ),
      activityLog: [
        HistoricalArchivesLogEntryViewModel(
          label: 'Beginning import…',
          message:
              'Starting source-scoped import for ${path.basename(selectedFolderPath)}.',
        ),
        ...state.activityLog,
      ],
      phases: _runningArchiveImportPhases(),
      resultSummaryLines: const [
        'Archive import is running.',
        'Source-scoped import and graph projection must both finish before imported archive messages become visible in normal app surfaces.',
      ],
    );

    try {
      final archiveSources = await ref.read(
        historicalArchiveSourcesProvider.future,
      );
      final archiveGraphImportService = await ref.read(
        sourceScopedArchiveGraphImportServiceProvider.future,
      );
      final archiveResult = await archiveGraphImportService.importAndProject(
        folderPath: selectedFolderPath,
        sourceLabel: state.sourceLabel,
      );
      ref.invalidate(conversationGraphReadinessProvider);
      ref.invalidate(conversationGraphPopulatedProvider);
      ref.read(messageDataVersionProvider.notifier).bump();

      ArchiveSourceInspector? archiveSourceInspector;
      try {
        archiveSourceInspector = await ref.read(
          archiveSourceInspectorProvider.future,
        );
      } catch (_) {}

      final refreshedResult = await preflightHistoricalArchivesFolder(
        folderPath: selectedFolderPath,
        archiveSourceInspector: archiveSourceInspector,
      );
      final importedMessageCount =
          archiveResult.importResult.messages.insertedMessageCount;

      final completedAtUtc = DateTime.now().toUtc().toIso8601String();
      await archiveSources.upsertSourceMetadata(
        HistoricalArchiveSourceMetadataUpdate(
          sourceChatDb: selectedChatDbPath,
          folderPath: selectedFolderPath,
          sourceLabel: refreshedResult.sourceLabel,
          chatDbStatusLabel: refreshedResult.chatDbStatusLabel,
          attachmentsStatusLabel: refreshedResult.attachmentsStatusLabel,
          preflightStatusLabel: 'Imported successfully',
          preflightDetail:
              'Source-scoped archive import and graph projection completed successfully.',
          totalMessages: refreshedResult.totalMessages,
          totalChats: refreshedResult.totalChats,
          totalHandles: refreshedResult.totalHandles,
          missingGuids: refreshedResult.missingGuids,
          earliestMessageUtc: refreshedResult.earliestMessageUtc,
          latestMessageUtc: refreshedResult.latestMessageUtc,
          dryRunNewMessages: refreshedResult.dryRunNewMessages,
          dryRunDuplicateMessages: refreshedResult.dryRunDuplicateMessages,
          lastImportFinishedAtUtc: completedAtUtc,
          lastImportSuccess: true,
          lastImportedMessageCount: importedMessageCount,
          updatedAtUtc: completedAtUtc,
        ),
      );

      final refreshedState = _workflowStateFromPreflightResult(refreshedResult);
      state = refreshedState.copyWith(
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Import complete',
            message:
                'Imported $importedMessageCount messages from ${path.basename(selectedFolderPath)} and refreshed graph-visible data.',
          ),
          ...refreshedState.activityLog,
        ],
        phases: _completedArchiveImportPhases(
          importedMessageCount: importedMessageCount,
        ),
        resultSummaryLines: [
          'Imported $importedMessageCount messages from ${path.basename(selectedFolderPath)}.',
          'Source-scoped import and graph projection completed successfully.',
        ],
      );
    } catch (error) {
      final detail = 'Archive import failed: $error';
      final archiveSources = await ref.read(
        historicalArchiveSourcesProvider.future,
      );
      final failedAtUtc = DateTime.now().toUtc().toIso8601String();
      await archiveSources.upsertSourceMetadata(
        HistoricalArchiveSourceMetadataUpdate(
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
          lastImportFinishedAtUtc: failedAtUtc,
          lastImportSuccess: false,
          lastImportError: detail,
          updatedAtUtc: failedAtUtc,
        ),
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
          'Archive import failed before graph projection completed.',
          detail,
        ],
      );
    } finally {
      ref.read(dbMaintenanceLockProvider.notifier).end();
      executionGate.release('historical-archives-import');
    }
  }

  void _prependActivityLog(HistoricalArchivesLogEntryViewModel entry) {
    state = state.copyWith(activityLog: [entry, ...state.activityLog]);
  }

  Future<void> _persistHistoricalArchiveSourceIfEligible({
    required HistoricalArchiveSources? archiveSources,
    required HistoricalArchivesFolderPreflightResult result,
  }) async {
    if (archiveSources == null) {
      return;
    }
    if (result.chatDbStatusLabel != 'Found and readable') {
      return;
    }

    await archiveSources.upsertSourceMetadata(
      HistoricalArchiveSourceMetadataUpdate(
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
        updatedAtUtc: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }
}

@riverpod
HistoricalArchivesWorkflowPanelViewModel historicalArchivesWorkflowPanelModel(
  Ref ref,
) {
  final executionGateState = ref.watch(graphMaintenanceExecutionGateProvider);
  final isMaintenanceLocked = ref.watch(dbMaintenanceLockProvider);
  final workflowState = ref.watch(historicalArchivesWorkflowProvider);
  final currentMessagesDatabasePath = ref.watch(
    onboardingMessagesDatabasePathProvider,
  );

  return buildHistoricalArchivesWorkflowPanelModel(
    executionGateState: executionGateState,
    isMaintenanceLocked: isMaintenanceLocked,
    workflowState: workflowState,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  );
}

HistoricalArchivesWorkflowPanelViewModel
buildHistoricalArchivesWorkflowPanelModel({
  required GraphMaintenanceExecutionGateState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
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
      'The canonical import pipeline is currently busy. Historical Archives stays visible so you can inspect the workflow, but import cannot begin until the current pipeline owner releases the execution gate.',
    HistoricalArchivesExecutionGateStatus.blocked =>
      'Message data maintenance is currently blocking new archive work. Historical Archives remains visible, but import cannot begin until maintenance completes and the execution gate becomes available again.',
  };

  final importButtonDetail = switch (executionGate.status) {
    HistoricalArchivesExecutionGateStatus.available =>
      _availableImportButtonDetail(
        workflowState,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      ),
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
      currentMessagesDatabasePath: currentMessagesDatabasePath,
    ),
    importButtonDetail: importButtonDetail,
    archiveRemovalTargetChatDbPath:
        workflowState.archiveRemovalTargetChatDbPath,
    archiveManagementSummaryLines: _archiveManagementSummaryLines(
      workflowState,
    ),
    removeImportedArchiveDataEnabled: _removeImportedArchiveDataEnabled(
      executionGate: executionGate,
      workflowState: workflowState,
      currentMessagesDatabasePath: currentMessagesDatabasePath,
    ),
    removeImportedArchiveDataDetail: _removeImportedArchiveDataDetail(
      executionGateState: executionGateState,
      isMaintenanceLocked: isMaintenanceLocked,
      workflowState: workflowState,
      currentMessagesDatabasePath: currentMessagesDatabasePath,
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
  required GraphMaintenanceExecutionGateState executionGateState,
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
        'No source import, graph projection, or reset flow currently owns the execution gate.',
  );
}

List<HistoricalArchivesLogEntryViewModel> _buildActivityLog({
  required GraphMaintenanceExecutionGateState executionGateState,
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
      'Historical archive import is a durable, step-by-step workflow. Choose an older Messages folder, review preflight evidence, then run source-scoped import and graph projection before messages become visible in normal app surfaces.',
    HistoricalArchivesPreflightStatus.running =>
      'Historical Archives is reading the selected source folder now. The workflow remains visible while source checks gather basic message, chat, handle, and GUID evidence.',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Historical Archives has completed source preflight for the selected folder. Review the source metadata and message counts, then run archive import when the evidence looks correct.',
    HistoricalArchivesPreflightStatus.failed =>
      'Historical Archives could not validate the selected folder as a usable Messages source. Review the failure details, then choose a different folder or fix the source contents before trying again.',
  };
}

String _availableImportButtonDetail(
  HistoricalArchivesWorkflowState workflowState, {
  required String currentMessagesDatabasePath,
}) {
  final selectedFolderPath = workflowState.selectedFolderPath;
  final selectedChatDbPath = selectedFolderPath == null
      ? null
      : path.join(selectedFolderPath, 'chat.db');

  if (selectedChatDbPath != null &&
      _isCurrentMacChatDbPath(
        selectedChatDbPath,
        currentMessagesDatabasePath: currentMessagesDatabasePath,
      )) {
    return 'Historical Archives does not import the live current_mac Messages source. Choose an archive folder instead.';
  }

  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder =>
      'Import stays disabled until a folder is selected and preflight completes.',
    HistoricalArchivesPreflightStatus.running =>
      'Import stays disabled while Historical Archives is reading source structure and counts.',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Source checks are complete. Begin Import will run source-scoped archive import and refresh the conversation graph. Source IDs keep archive rows isolated from the live Messages source.',
    HistoricalArchivesPreflightStatus.failed =>
      'Import stays disabled until the selected folder passes source preflight.',
  };
}

bool _importButtonEnabled({
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  if (executionGate.status != HistoricalArchivesExecutionGateStatus.available) {
    return false;
  }

  final selectedFolderPath = workflowState.selectedFolderPath;
  if (selectedFolderPath == null) {
    return false;
  }

  if (_isCurrentMacChatDbPath(
    path.join(selectedFolderPath, 'chat.db'),
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  )) {
    return false;
  }

  return workflowState.preflight.status ==
      HistoricalArchivesPreflightStatus.completeReadyToImport;
}

List<String> _archiveManagementSummaryLines(
  HistoricalArchivesWorkflowState workflowState,
) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;

  if (targetPath == null) {
    return const [
      'Removal target chat.db: waiting for folder selection',
      'Source-scoped archive removal: waiting for folder selection',
    ];
  }

  return [
    'Removal target chat.db: $targetPath',
    'Source-scoped archive removal: available after preflight',
  ];
}

bool _removeImportedArchiveDataEnabled({
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
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
  if (_isCurrentMacChatDbPath(
    targetPath,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  )) {
    return false;
  }
  return true;
}

String _removeImportedArchiveDataDetail({
  required GraphMaintenanceExecutionGateState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
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
    return 'Choose an archive folder first so MessageLens can identify which source-scoped archive rows would be removed.';
  }
  if (_isCurrentMacChatDbPath(
    targetPath,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  )) {
    return 'Removal is unavailable for the live current_mac Messages source.';
  }
  return 'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.';
}

Future<HistoricalArchivesFolderPreflightResult>
preflightHistoricalArchivesFolder({
  required String folderPath,
  ArchiveSourceInspector? archiveSourceInspector,
}) async {
  final inspection =
      await (archiveSourceInspector ??
              const _UnavailableArchiveSourceInspector())
          .inspectFolder(folderPath: folderPath);
  if (!inspection.isReadable) {
    return _failedPreflightResult(
      folderPath: inspection.folderPath,
      sourceLabel: inspection.sourceLabel,
      detail: inspection.detail,
      archiveRemovalTargetChatDbPath: inspection.chatDbPath,
      chatDbStatusLabel: inspection.chatDbStatusLabel,
      attachmentsStatusLabel: inspection.attachmentsStatusLabel,
    );
  }

  final dryRunEstimate = inspection.dryRunEstimate;
  return HistoricalArchivesFolderPreflightResult(
    preflight: HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.completeReadyToImport,
      statusLabel: 'Preflight complete',
      detail: inspection.detail,
    ),
    selectedFolderPath: inspection.folderPath,
    archiveRemovalTargetChatDbPath: inspection.chatDbPath,
    chatDbStatusLabel: inspection.chatDbStatusLabel,
    attachmentsStatusLabel: inspection.attachmentsStatusLabel,
    sourceLabel: inspection.sourceLabel,
    totalMessages: inspection.totalMessages,
    totalChats: inspection.totalChats,
    totalHandles: inspection.totalHandles,
    missingGuids: inspection.missingGuids,
    earliestMessageUtc: inspection.earliestMessageUtc,
    latestMessageUtc: inspection.latestMessageUtc,
    dryRunNewMessages: dryRunEstimate.isAvailable
        ? dryRunEstimate.newGuidCount
        : null,
    dryRunDuplicateMessages: dryRunEstimate.isAvailable
        ? dryRunEstimate.duplicateGuidCount
        : null,
    preflightSummaryLines: [
      'Total messages: ${inspection.totalMessages}',
      'Total chats: ${inspection.totalChats}',
      'Total handles: ${inspection.totalHandles}',
      'Rows with missing GUIDs: ${inspection.missingGuids}',
      'Earliest message: ${_dateSummaryLabel(inspection.earliestMessageUtc)}',
      'Latest message: ${_dateSummaryLabel(inspection.latestMessageUtc)}',
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
        message: 'Read source counts from ${inspection.sourceLabel}.',
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
            'The selected archive folder passed source checks and is ready for archive import.',
      ),
    ],
    phases: const [
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Reading archive source',
        status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
        detail: 'Archive source metadata and counts were read successfully.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Normalizing records into canonical ledger format',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Normalization begins when you run archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Writing archive rows to source-scoped import',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Ledger ingestion begins when you run archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Projecting archive rows into conversation graph',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Graph projection begins only after successful archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Rebuild steps are still waiting.',
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

final class _UnavailableArchiveSourceInspector
    implements ArchiveSourceInspector {
  const _UnavailableArchiveSourceInspector();

  @override
  Future<ArchiveSourceInspection> inspectFolder({
    required String folderPath,
  }) async {
    return ArchiveSourceInspection(
      folderPath: folderPath,
      sourceLabel: path.basename(folderPath),
      chatDbPath: path.join(folderPath, 'chat.db'),
      chatDbStatusLabel: 'Unavailable',
      attachmentsStatusLabel: 'Unavailable',
      isReadable: false,
      detail:
          'Archive source inspection is unavailable because the inspection service could not be constructed.',
      dryRunEstimate: const ArchiveSourceDryRunEstimate.unavailable(
        unavailableReason: 'archive source inspection service unavailable.',
      ),
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
      'Likely duplicates already in conversation graph: unavailable',
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
        label: 'Writing archive rows to source-scoped import',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Projecting archive rows into conversation graph',
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

String? _firstLineWithPrefix(List<String> lines, String prefix) {
  for (final line in lines) {
    if (line.startsWith(prefix)) {
      return line;
    }
  }

  return null;
}

bool _isCurrentMacChatDbPath(
  String sourceChatDbPath, {
  required String currentMessagesDatabasePath,
}) {
  return path.normalize(sourceChatDbPath) ==
      path.normalize(currentMessagesDatabasePath);
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
      label: 'Writing archive rows to source-scoped import',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Projecting archive rows into conversation graph',
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
      label: 'Removing archive source rows from source-scoped import',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail:
          'Deleting imported source facts and topology edges for the selected archive source.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reprojecting conversation graph',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail:
          'Rebuilding graph-visible data from the remaining source-scoped import facts.',
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
      label: 'Removing archive source rows from source-scoped import',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Reprojecting conversation graph',
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
      label: 'Writing archive rows to source-scoped import',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Archive rows are being written into the canonical ledger.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Projecting archive rows into conversation graph',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Graph projection starts after source-scoped import succeeds.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for graph projection to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing app-visible data',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for graph projection to complete.',
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
      label: 'Writing archive rows to source-scoped import',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Projecting archive rows into conversation graph',
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
      label: 'Writing archive rows to source-scoped import',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'Source-scoped import completed and wrote $importedMessageCount messages for this archive source.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Projecting archive rows into conversation graph',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Conversation graph projection completed successfully.',
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
    'db-import-control' => 'Source import or graph projection',
    'chat-db-monitor' => 'Automatic chat monitor import',
    null => 'Another workflow',
    _ => 'Execution owner "$owner"',
  };
}

String _describeExecutionOwnerPhrase(String? owner) {
  return switch (owner) {
    'db-import-control' => 'source import or graph projection',
    'chat-db-monitor' => 'automatic chat monitor import',
    null => 'another workflow',
    _ => 'execution owner "$owner"',
  };
}
