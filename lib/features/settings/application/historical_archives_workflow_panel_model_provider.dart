import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/util/date_label_formatter.dart';
import '../../../essentials/archive_environment/domain.dart'
    show ArchiveMutationDeniedException, ArchiveMutationOperation;
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show ArchiveMutationCoordinatorState, archiveMutationCoordinatorProvider;
import '../../../essentials/conversation_graph/feature_level_providers.dart'
    show
        sourceScopedArchiveGraphImportServiceProvider,
        sourceScopedArchiveGraphRemovalServiceProvider;
import '../../../essentials/db/feature_level_providers.dart'
    show dbMaintenanceLockProvider;
import '../../../essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../essentials/navigation/feature_level_providers.dart'
    show SidebarMode, activeSidebarModeProvider;
import '../../../essentials/onboarding/feature_level_providers.dart'
    show onboardingMessagesDatabasePathProvider;
import '../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import '../../sidebar_utilities/domain/sidebar_utilities_constants.dart'
    show SettingsMenuActionId;
import 'archive_source_inspection.dart';
import 'archive_source_inspector_provider.dart';
import 'historical_archive_folder_chooser_provider.dart';
import 'historical_archive_sources.dart';
import 'historical_archive_sources_provider.dart';

part 'historical_archives_workflow_panel_model_provider.g.dart';

const _historicalArchivesTestingOwner = 'historical-archives-testing-clear';

void _logHistoricalArchivesWarning(
  Ref ref, {
  required String message,
  required Object error,
  required StackTrace stackTrace,
}) {
  ref
      .read(appLoggerProvider.notifier)
      .warn(
        message,
        source: 'HistoricalArchivesWorkflow',
        context: {
          'error': error.toString(),
          'stack': stackTrace.toString().split('\n').take(5).join('\n'),
        },
      );
}

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

enum HistoricalArchivesPresentationStage {
  noSource,
  inspectingSource,
  inspectionFailed,
  readyForImport,
  knownSource,
  existingSource,
  laterWorkflow,
}

/// Transient feature context. Durable source metadata never selects a context.
enum HistoricalArchivesPresentationContext {
  hub,
  existingSource,
  addArchive,
  removingSource,
}

/// Ephemeral presentation state only. [sourceKey] identifies the archive;
/// [referenceOccurrence] identifies a fresh "look here" event in this process.
final class HistoricalArchivesKnownSourceReference {
  const HistoricalArchivesKnownSourceReference({
    required this.sourceKey,
    required this.referenceOccurrence,
  });

  final String sourceKey;
  final int referenceOccurrence;
}

/// One-use presentation notice for a failed add attempt.
///
/// The source key identifies the existing sidebar object. Both occurrences are
/// process-only guards; none of this state is archive metadata.
final class HistoricalArchivesDuplicateFolderNotice {
  const HistoricalArchivesDuplicateFolderNotice({
    required this.sourceKey,
    required this.noticeOccurrence,
    required this.presentationSessionOccurrence,
  });

  final String sourceKey;
  final int noticeOccurrence;
  final int presentationSessionOccurrence;
}

/// One-use presentation notice for a folder that did not qualify as an archive.
///
/// It deliberately carries no folder identity or inspection evidence. The two
/// occurrences exist only to prevent stale modal completion from changing a
/// later presentation session.
final class HistoricalArchivesInvalidFolderNotice {
  const HistoricalArchivesInvalidFolderNotice({
    required this.noticeOccurrence,
    required this.presentationSessionOccurrence,
  });

  final int noticeOccurrence;
  final int presentationSessionOccurrence;
}

const historicalArchivesReferenceFadeInDuration = Duration(milliseconds: 750);
const historicalArchivesReferenceHoldDuration = Duration(milliseconds: 1000);
const historicalArchivesReferenceFadeOutDuration = Duration(milliseconds: 2000);
const historicalArchivesReferenceLifetime = Duration(milliseconds: 3750);

final class HistoricalArchivesInspectionEvidence {
  const HistoricalArchivesInspectionEvidence({
    required this.folderPath,
    required this.chatDbPath,
    required this.sourceLabel,
    required this.chatDbStatusLabel,
    required this.attachmentsStatusLabel,
    required this.totalMessages,
    required this.totalChats,
    required this.totalHandles,
    required this.missingGuids,
    required this.earliestMessageUtc,
    required this.latestMessageUtc,
    required this.dateRangeUnavailableReason,
    required this.dryRunNewMessages,
    required this.dryRunDuplicateMessages,
    required this.dryRunComparableMessages,
    required this.dryRunUnavailableReason,
    this.successfulImportFinishedAtUtc,
  });

  final String folderPath;
  final String chatDbPath;
  final String sourceLabel;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final int? totalMessages;
  final int? totalChats;
  final int? totalHandles;
  final int? missingGuids;
  final String? earliestMessageUtc;
  final String? latestMessageUtc;
  final String? dateRangeUnavailableReason;
  final int? dryRunNewMessages;
  final int? dryRunDuplicateMessages;
  final int? dryRunComparableMessages;
  final String? dryRunUnavailableReason;
  final String? successfulImportFinishedAtUtc;
}

enum HistoricalArchivesNarratorPresentationKind {
  noSource,
  inspectingSource,
  inspectionFailed,
  readyForImport,
  knownSource,
  removingSource,
  removalFailed,
}

enum HistoricalArchivesInstrumentationStatus { working, resolved, failed }

final class HistoricalArchivesInstrumentationRowViewModel {
  const HistoricalArchivesInstrumentationRowViewModel({
    required this.label,
    required this.value,
    required this.status,
  });

  final String label;
  final String value;
  final HistoricalArchivesInstrumentationStatus status;
}

final class HistoricalArchivesNarratorPresentationViewModel {
  const HistoricalArchivesNarratorPresentationViewModel({
    required this.kind,
    required this.narratorText,
    required this.instrumentationRows,
    required this.detailsLines,
    required this.retryInspectionEnabled,
  });

  final HistoricalArchivesNarratorPresentationKind kind;
  final String narratorText;
  final List<HistoricalArchivesInstrumentationRowViewModel> instrumentationRows;
  final List<String> detailsLines;
  final bool retryInspectionEnabled;
}

final class HistoricalArchivesExistingSourcePresentationViewModel {
  const HistoricalArchivesExistingSourcePresentationViewModel({
    required this.sourceTypeStatement,
    required this.importDateStatement,
    required this.contentsStatement,
    required this.detailsLines,
    this.removalFailureStatement,
  });

  final String sourceTypeStatement;
  final String? importDateStatement;
  final String? contentsStatement;
  final List<String> detailsLines;
  final String? removalFailureStatement;
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
    required this.importSafetySummaryLines,
    required this.resultSummaryLines,
    required this.activityLog,
    required this.phases,
    required this.presentationContext,
    this.presentationStage = HistoricalArchivesPresentationStage.noSource,
    this.inspectionEvidence,
    this.knownSourceReference,
    this.duplicateFolderNotice,
    this.invalidFolderNotice,
    this.selectedKnownSourceKey,
    this.removalFailureDetail,
  });

  final HistoricalArchivesPreflightViewModel preflight;
  final String? selectedFolderPath;
  final String? archiveRemovalTargetChatDbPath;
  final String chatDbStatusLabel;
  final String attachmentsStatusLabel;
  final String sourceLabel;
  final List<String> preflightSummaryLines;
  final List<String> dryRunSummaryLines;
  final List<String> importSafetySummaryLines;
  final List<String> resultSummaryLines;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;
  final HistoricalArchivesPresentationStage presentationStage;
  final HistoricalArchivesPresentationContext presentationContext;
  final HistoricalArchivesInspectionEvidence? inspectionEvidence;
  final HistoricalArchivesKnownSourceReference? knownSourceReference;
  final HistoricalArchivesDuplicateFolderNotice? duplicateFolderNotice;
  final HistoricalArchivesInvalidFolderNotice? invalidFolderNotice;

  /// Exact-key selection established only by a cartouche action this session.
  final String? selectedKnownSourceKey;
  final String? removalFailureDetail;

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
    List<String>? importSafetySummaryLines,
    List<String>? resultSummaryLines,
    List<HistoricalArchivesLogEntryViewModel>? activityLog,
    List<HistoricalArchivesWorkflowPhaseViewModel>? phases,
    HistoricalArchivesPresentationStage? presentationStage,
    HistoricalArchivesPresentationContext? presentationContext,
    HistoricalArchivesInspectionEvidence? inspectionEvidence,
    bool clearInspectionEvidence = false,
    HistoricalArchivesKnownSourceReference? knownSourceReference,
    bool clearKnownSourceReference = false,
    HistoricalArchivesDuplicateFolderNotice? duplicateFolderNotice,
    bool clearDuplicateFolderNotice = false,
    HistoricalArchivesInvalidFolderNotice? invalidFolderNotice,
    bool clearInvalidFolderNotice = false,
    String? selectedKnownSourceKey,
    bool clearSelectedKnownSourceKey = false,
    String? removalFailureDetail,
    bool clearRemovalFailureDetail = false,
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
      importSafetySummaryLines:
          importSafetySummaryLines ?? this.importSafetySummaryLines,
      resultSummaryLines: resultSummaryLines ?? this.resultSummaryLines,
      activityLog: activityLog ?? this.activityLog,
      phases: phases ?? this.phases,
      presentationStage: presentationStage ?? this.presentationStage,
      presentationContext: presentationContext ?? this.presentationContext,
      inspectionEvidence: clearInspectionEvidence
          ? null
          : inspectionEvidence ?? this.inspectionEvidence,
      knownSourceReference: clearKnownSourceReference
          ? null
          : knownSourceReference ?? this.knownSourceReference,
      duplicateFolderNotice: clearDuplicateFolderNotice
          ? null
          : duplicateFolderNotice ?? this.duplicateFolderNotice,
      invalidFolderNotice: clearInvalidFolderNotice
          ? null
          : invalidFolderNotice ?? this.invalidFolderNotice,
      selectedKnownSourceKey: clearSelectedKnownSourceKey
          ? null
          : selectedKnownSourceKey ?? this.selectedKnownSourceKey,
      removalFailureDetail: clearRemovalFailureDetail
          ? null
          : removalFailureDetail ?? this.removalFailureDetail,
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
    required this.dryRunComparableMessages,
    required this.preflightSummaryLines,
    required this.dryRunSummaryLines,
    required this.activityLog,
    required this.phases,
    this.dateRangeUnavailableReason,
    this.dryRunUnavailableReason,
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
  final int? dryRunComparableMessages;
  final String? dateRangeUnavailableReason;
  final String? dryRunUnavailableReason;
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
    required this.importSafetySummaryLines,
    required this.importButtonEnabled,
    required this.importButtonDetail,
    required this.archiveRemovalTargetChatDbPath,
    required this.archiveManagementSummaryLines,
    required this.removeImportedArchiveDataEnabled,
    required this.removeImportedArchiveDataDetail,
    required this.activityLog,
    required this.resultSummaryLines,
    required this.phases,
    this.isHub = false,
    this.narratorPresentation,
    this.existingSourcePresentation,
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
  final List<String> importSafetySummaryLines;
  final bool importButtonEnabled;
  final String importButtonDetail;
  final String? archiveRemovalTargetChatDbPath;
  final List<String> archiveManagementSummaryLines;
  final bool removeImportedArchiveDataEnabled;
  final String removeImportedArchiveDataDetail;
  final List<HistoricalArchivesLogEntryViewModel> activityLog;
  final List<String> resultSummaryLines;
  final List<HistoricalArchivesWorkflowPhaseViewModel> phases;
  final bool isHub;
  final HistoricalArchivesNarratorPresentationViewModel? narratorPresentation;
  final HistoricalArchivesExistingSourcePresentationViewModel?
  existingSourcePresentation;
}

HistoricalArchivesWorkflowState buildInitialHistoricalArchivesWorkflowState() {
  return const HistoricalArchivesWorkflowState(
    presentationContext: HistoricalArchivesPresentationContext.hub,
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
      'Likely already imported: waiting for folder selection',
      'Likely new rows: waiting for folder selection',
    ],
    dryRunSummaryLines: [
      'Estimated new messages: waiting for preflight',
      'Estimated duplicates: waiting for preflight',
    ],
    importSafetySummaryLines: [
      'Waiting for preflight before archive import safety can be confirmed.',
    ],
    resultSummaryLines: [
      'No archive import has run yet.',
      'Imported archive messages will become visible after MessageLens finishes preparing them.',
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
        label: 'Preparing archive records',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'No archive source has started yet.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Importing archive messages',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Archive import starts after you run Begin Import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Preparing messages for browsing',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Browsing preparation begins after archive import succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Post-projection rebuild steps are still waiting.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Refreshing shared evidence surfaces',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail:
            'Shared message evidence surfaces are unchanged until refresh completes.',
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
  var _nextReferenceOccurrence = 0;
  var _nextDuplicateNoticeOccurrence = 0;
  var _nextInvalidFolderNoticeOccurrence = 0;
  var _presentationSessionOccurrence = 0;
  Timer? _referenceClearTimer;

  @override
  HistoricalArchivesWorkflowState build() {
    ref.onDispose(() {
      _referenceClearTimer?.cancel();
    });
    ref.listen(activeSidebarModeProvider, (previous, next) {
      if (previous == SidebarMode.settings && next != SidebarMode.settings) {
        resetPresentationContext();
      }
    });
    ref.listen(
      sidebarFlowProvider.select((value) => value.persistentSettingsContext),
      (previous, next) {
        if (previous == SettingsMenuActionId.historicalArchives &&
            next != SettingsMenuActionId.historicalArchives) {
          resetPresentationContext();
        }
      },
    );
    return buildInitialHistoricalArchivesWorkflowState();
  }

  Future<void> chooseMessagesFolder() async {
    final presentationSessionOccurrence = _presentationSessionOccurrence;
    final folderChooser = ref.read(historicalArchiveFolderChooserProvider);
    final folderPath = await folderChooser.chooseMessagesFolder();
    if (folderPath == null ||
        presentationSessionOccurrence != _presentationSessionOccurrence) {
      return;
    }

    await loadFolder(
      folderPath: folderPath,
      presentationSessionOccurrence: presentationSessionOccurrence,
    );
  }

  Future<void> loadFolder({
    required String folderPath,
    int? presentationSessionOccurrence,
  }) async {
    final expectedPresentationSessionOccurrence =
        presentationSessionOccurrence ?? _presentationSessionOccurrence;
    state = state.copyWith(
      presentationContext: HistoricalArchivesPresentationContext.addArchive,
      presentationStage: HistoricalArchivesPresentationStage.inspectingSource,
      clearInspectionEvidence: true,
      clearKnownSourceReference: true,
      clearDuplicateFolderNotice: true,
      clearInvalidFolderNotice: true,
      clearSelectedKnownSourceKey: true,
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
        'Imported archive messages will become visible after MessageLens finishes preparing them.',
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
    HistoricalArchiveImportedSourceLookup? importedSourceLookup;
    try {
      archiveSourceInspector = await ref.read(
        archiveSourceInspectorProvider.future,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message: 'Archive source inspector unavailable during preflight',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      archiveSources = await ref.read(historicalArchiveSourcesProvider.future);
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive sources boundary unavailable during preflight',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      importedSourceLookup = await ref.read(
        historicalArchiveImportedSourceLookupProvider.future,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive imported-source lookup unavailable during preflight',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final result = await preflightHistoricalArchivesFolder(
      folderPath: folderPath,
      archiveSourceInspector: archiveSourceInspector,
    );

    final importedSourceMatch = await _findImportedSourceMatch(
      lookup: importedSourceLookup,
      result: result,
    );

    if (expectedPresentationSessionOccurrence !=
        _presentationSessionOccurrence) {
      return;
    }

    if (_isInvalidFolderQualificationFailure(result)) {
      _nextInvalidFolderNoticeOccurrence += 1;
      state = buildInitialHistoricalArchivesWorkflowState().copyWith(
        invalidFolderNotice: HistoricalArchivesInvalidFolderNotice(
          noticeOccurrence: _nextInvalidFolderNoticeOccurrence,
          presentationSessionOccurrence: _presentationSessionOccurrence,
        ),
      );
      return;
    }

    if (importedSourceMatch != null) {
      _nextDuplicateNoticeOccurrence += 1;
      state = buildInitialHistoricalArchivesWorkflowState().copyWith(
        duplicateFolderNotice: HistoricalArchivesDuplicateFolderNotice(
          sourceKey: importedSourceMatch.sourceKey,
          noticeOccurrence: _nextDuplicateNoticeOccurrence,
          presentationSessionOccurrence: _presentationSessionOccurrence,
        ),
      );
      return;
    }

    await _persistHistoricalArchiveSourceIfEligible(
      archiveSources: archiveSources,
      result: result,
    );

    if (expectedPresentationSessionOccurrence !=
        _presentationSessionOccurrence) {
      return;
    }

    state = _workflowStateFromPreflightResult(result);
  }

  Future<void> showKnownSource({required String sourceKey}) async {
    final presentationSessionOccurrence = _presentationSessionOccurrence;
    final sources = await ref.read(
      historicalArchiveSourceMetadataProvider.future,
    );
    HistoricalArchiveSourceMetadata? source;
    for (final candidate in sources) {
      if (candidate.sourceKey == sourceKey) {
        source = candidate;
        break;
      }
    }
    if (source == null ||
        presentationSessionOccurrence != _presentationSessionOccurrence) {
      return;
    }

    HistoricalArchiveImportedSourceMatch? importedSourceMatch;
    try {
      final lookup = await ref.read(
        historicalArchiveImportedSourceLookupProvider.future,
      );
      importedSourceMatch = await lookup.findImportedSourceByKey(
        sourceKey: sourceKey,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive imported-source classification failed during known-source navigation',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (presentationSessionOccurrence != _presentationSessionOccurrence) {
      return;
    }

    if (importedSourceMatch == null) {
      resetPresentationContext();
      return;
    }

    state = _workflowStateFromKnownSourceMetadata(
      source,
      importedMessageCount: importedSourceMatch.importedMessageCount,
      selectedKnownSourceKey: sourceKey,
    );
  }

  void clearSelection() {
    resetPresentationContext();
  }

  void dismissDuplicateFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    final notice = state.duplicateFolderNotice;
    if (notice == null ||
        notice.noticeOccurrence != noticeOccurrence ||
        notice.presentationSessionOccurrence != presentationSessionOccurrence ||
        _presentationSessionOccurrence != presentationSessionOccurrence ||
        state.presentationContext !=
            HistoricalArchivesPresentationContext.hub) {
      return;
    }

    _referenceClearTimer?.cancel();
    _nextReferenceOccurrence += 1;
    final referenceOccurrence = _nextReferenceOccurrence;
    state = state.copyWith(
      clearDuplicateFolderNotice: true,
      knownSourceReference: HistoricalArchivesKnownSourceReference(
        sourceKey: notice.sourceKey,
        referenceOccurrence: referenceOccurrence,
      ),
    );
    _referenceClearTimer = Timer(historicalArchivesReferenceLifetime, () {
      _clearKnownSourceReference(
        referenceOccurrence: referenceOccurrence,
        presentationSessionOccurrence: presentationSessionOccurrence,
      );
    });
  }

  void dismissInvalidFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    final notice = state.invalidFolderNotice;
    if (notice == null ||
        notice.noticeOccurrence != noticeOccurrence ||
        notice.presentationSessionOccurrence != presentationSessionOccurrence ||
        _presentationSessionOccurrence != presentationSessionOccurrence ||
        state.presentationContext !=
            HistoricalArchivesPresentationContext.hub) {
      return;
    }

    state = state.copyWith(clearInvalidFolderNotice: true);
  }

  void resetPresentationContext() {
    _presentationSessionOccurrence += 1;
    _referenceClearTimer?.cancel();
    _referenceClearTimer = null;
    if (state.presentationContext ==
            HistoricalArchivesPresentationContext.hub &&
        state.selectedKnownSourceKey == null &&
        state.knownSourceReference == null &&
        state.duplicateFolderNotice == null &&
        state.invalidFolderNotice == null) {
      return;
    }
    state = buildInitialHistoricalArchivesWorkflowState();
  }

  void _clearKnownSourceReference({
    required int referenceOccurrence,
    required int presentationSessionOccurrence,
  }) {
    if (_presentationSessionOccurrence != presentationSessionOccurrence ||
        state.knownSourceReference?.referenceOccurrence !=
            referenceOccurrence) {
      return;
    }
    state = state.copyWith(clearKnownSourceReference: true);
    _referenceClearTimer = null;
  }

  Future<void> retrySelectedFolderInspection() async {
    final selectedFolderPath = state.selectedFolderPath;
    if (selectedFolderPath == null) {
      return;
    }

    await loadFolder(folderPath: selectedFolderPath);
  }

  Future<void> removeImportedArchiveDataForSelectedSource() async {
    if (state.presentationContext !=
            HistoricalArchivesPresentationContext.existingSource ||
        state.selectedKnownSourceKey == null) {
      _prependActivityLog(
        const HistoricalArchivesLogEntryViewModel(
          label: 'No selected imported folder',
          message:
              'Select a folder under Folders Already Added before removing it from MessageLens.',
        ),
      );
      return;
    }

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

    final selectedSourceKey = state.selectedKnownSourceKey!;
    final selectedSourceState = state.copyWith(clearRemovalFailureDetail: true);
    final removalPresentationSessionOccurrence = _presentationSessionOccurrence;

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

    try {
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation: ArchiveMutationOperation.historicalArchiveRemoval,
            ownerLabel: _historicalArchivesTestingOwner,
            action: () async {
              state = selectedSourceState.copyWith(
                presentationContext:
                    HistoricalArchivesPresentationContext.removingSource,
                presentationStage:
                    HistoricalArchivesPresentationStage.laterWorkflow,
                clearRemovalFailureDetail: true,
                preflight: const HistoricalArchivesPreflightViewModel(
                  status: HistoricalArchivesPreflightStatus.running,
                  statusLabel: 'Removing folder',
                  detail: "Removing this folder's messages from MessageLens.",
                ),
                activityLog: [
                  HistoricalArchivesLogEntryViewModel(
                    label: 'Removing folder…',
                    message:
                        'Removing messages added from ${path.basename(selectedFolderPath)}.',
                  ),
                  ...selectedSourceState.activityLog,
                ],
                phases: _runningArchiveRemovalPhases(),
              );

              final removalService = await ref.read(
                sourceScopedArchiveGraphRemovalServiceProvider.future,
              );
              await removalService.removeArchiveSource(
                folderPath: selectedFolderPath,
              );
              ref.read(messageDataVersionProvider.notifier).bump();

              final importedSourceLookup = await ref.read(
                historicalArchiveImportedSourceLookupProvider.future,
              );
              final remainingSource = await importedSourceLookup
                  .findImportedSourceByKey(sourceKey: selectedSourceKey);
              if (!_ownsCurrentRemovalPresentation(
                sourceKey: selectedSourceKey,
                presentationSessionOccurrence:
                    removalPresentationSessionOccurrence,
              )) {
                return;
              }
              if (remainingSource != null) {
                state = selectedSourceState.copyWith(
                  removalFailureDetail:
                      'The removal operation finished, but ${remainingSource.importedMessageCount} messages from this folder are still part of MessageLens.',
                );
                return;
              }

              resetPresentationContext();
            },
          );
    } on ArchiveMutationDeniedException catch (error) {
      if (_presentationSessionOccurrence !=
              removalPresentationSessionOccurrence ||
          state.selectedKnownSourceKey != selectedSourceKey) {
        return;
      }
      state = selectedSourceState.copyWith(
        removalFailureDetail:
            'MessageLens could not remove this folder because another message-data operation is running. Its messages remain part of MessageLens.',
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Removal unavailable',
            message:
                '${_describeExecutionOwnerLabel(error.currentOwner)} currently owns archive mutation authority.',
          ),
          ...selectedSourceState.activityLog,
        ],
      );
    } catch (error) {
      final detail = 'Archive data removal failed: $error';
      ref.read(messageDataVersionProvider.notifier).bump();
      HistoricalArchiveImportedSourceMatch? remainingSource;
      try {
        final importedSourceLookup = await ref.read(
          historicalArchiveImportedSourceLookupProvider.future,
        );
        remainingSource = await importedSourceLookup.findImportedSourceByKey(
          sourceKey: selectedSourceKey,
        );
      } catch (lookupError, stackTrace) {
        _logHistoricalArchivesWarning(
          ref,
          message:
              'Historical archive membership could not be rechecked after removal failure',
          error: lookupError,
          stackTrace: stackTrace,
        );
      }
      if (!_ownsCurrentRemovalPresentation(
        sourceKey: selectedSourceKey,
        presentationSessionOccurrence: removalPresentationSessionOccurrence,
      )) {
        return;
      }
      if (remainingSource != null) {
        state = selectedSourceState.copyWith(
          removalFailureDetail: detail,
          activityLog: [
            HistoricalArchivesLogEntryViewModel(
              label: 'Archive removal failed',
              message: detail,
            ),
            ...selectedSourceState.activityLog,
          ],
        );
        return;
      }
      state = selectedSourceState.copyWith(
        presentationContext:
            HistoricalArchivesPresentationContext.removingSource,
        presentationStage: HistoricalArchivesPresentationStage.laterWorkflow,
        removalFailureDetail: detail,
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.failed,
          statusLabel: 'Folder removal failed',
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
    }
  }

  bool _ownsCurrentRemovalPresentation({
    required String sourceKey,
    required int presentationSessionOccurrence,
  }) {
    return _presentationSessionOccurrence == presentationSessionOccurrence &&
        state.presentationContext ==
            HistoricalArchivesPresentationContext.removingSource &&
        state.selectedKnownSourceKey == sourceKey;
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

    try {
      await ref
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation: ArchiveMutationOperation.historicalArchiveImport,
            ownerLabel: 'historical-archives-import',
            action: () async {
              final archiveGraphImportService = await ref.read(
                sourceScopedArchiveGraphImportServiceProvider.future,
              );
              state = state.copyWith(
                presentationStage:
                    HistoricalArchivesPresentationStage.laterWorkflow,
                preflight: const HistoricalArchivesPreflightViewModel(
                  status: HistoricalArchivesPreflightStatus.running,
                  statusLabel: 'Import running',
                  detail:
                      'Importing archive messages from the selected folder, then preparing them for browsing.',
                ),
                activityLog: [
                  HistoricalArchivesLogEntryViewModel(
                    label: 'Beginning import…',
                    message:
                        'Starting archive import for ${path.basename(selectedFolderPath)}.',
                  ),
                  ...state.activityLog,
                ],
                phases: _runningArchiveImportPhases(),
                resultSummaryLines: const [
                  'Archive import is running.',
                  'Imported archive messages will become visible after MessageLens finishes preparing them.',
                ],
              );

              final archiveSources = await ref.read(
                historicalArchiveSourcesProvider.future,
              );
              final archiveResult = await archiveGraphImportService
                  .importAndProject(
                    folderPath: selectedFolderPath,
                    sourceLabel: state.sourceLabel,
                  );
              ref.read(messageDataVersionProvider.notifier).bump();

              ArchiveSourceInspector? archiveSourceInspector;
              try {
                archiveSourceInspector = await ref.read(
                  archiveSourceInspectorProvider.future,
                );
              } catch (error, stackTrace) {
                _logHistoricalArchivesWarning(
                  ref,
                  message: 'Archive source inspector unavailable after import',
                  error: error,
                  stackTrace: stackTrace,
                );
              }

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
                  attachmentsStatusLabel:
                      refreshedResult.attachmentsStatusLabel,
                  preflightStatusLabel: 'Imported successfully',
                  preflightDetail:
                      'Archive import completed and messages were prepared for browsing.',
                  totalMessages: refreshedResult.totalMessages,
                  totalChats: refreshedResult.totalChats,
                  totalHandles: refreshedResult.totalHandles,
                  missingGuids: refreshedResult.missingGuids,
                  earliestMessageUtc: refreshedResult.earliestMessageUtc,
                  latestMessageUtc: refreshedResult.latestMessageUtc,
                  dryRunNewMessages: refreshedResult.dryRunNewMessages,
                  dryRunDuplicateMessages:
                      refreshedResult.dryRunDuplicateMessages,
                  lastImportFinishedAtUtc: completedAtUtc,
                  lastImportSuccess: true,
                  lastImportedMessageCount: importedMessageCount,
                  updatedAtUtc: completedAtUtc,
                ),
              );

              final refreshedState = _workflowStateFromPreflightResult(
                refreshedResult,
              );
              state = refreshedState.copyWith(
                presentationStage:
                    HistoricalArchivesPresentationStage.laterWorkflow,
                activityLog: [
                  HistoricalArchivesLogEntryViewModel(
                    label: 'Import complete',
                    message:
                        'Imported $importedMessageCount messages from ${path.basename(selectedFolderPath)} and refreshed browsing data.',
                  ),
                  ...refreshedState.activityLog,
                ],
                phases: _completedArchiveImportPhases(
                  importedMessageCount: importedMessageCount,
                ),
                resultSummaryLines: [
                  'Imported $importedMessageCount messages from ${path.basename(selectedFolderPath)}.',
                  'Archive messages are ready to browse in MessageLens.',
                ],
              );
            },
          );
    } on ArchiveMutationDeniedException catch (error) {
      _prependActivityLog(
        HistoricalArchivesLogEntryViewModel(
          label: 'Execution gate busy',
          message:
              '${_describeExecutionOwnerLabel(error.currentOwner)} currently owns archive mutation authority. Archive import must wait.',
        ),
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
        presentationStage: HistoricalArchivesPresentationStage.laterWorkflow,
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
          'Archive import failed before messages were ready to browse.',
          detail,
        ],
      );
    }
  }

  void _prependActivityLog(HistoricalArchivesLogEntryViewModel entry) {
    state = state.copyWith(activityLog: [entry, ...state.activityLog]);
  }

  Future<HistoricalArchiveImportedSourceMatch?> _findImportedSourceMatch({
    required HistoricalArchiveImportedSourceLookup? lookup,
    required HistoricalArchivesFolderPreflightResult result,
  }) async {
    if (lookup == null || result.chatDbStatusLabel != 'Found and readable') {
      return null;
    }

    try {
      return await lookup.findImportedSource(
        folderPath: result.selectedFolderPath,
      );
    } catch (error, stackTrace) {
      _logHistoricalArchivesWarning(
        ref,
        message:
            'Historical archive imported-source classification failed during preflight',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
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
  final executionGateState = ref.watch(archiveMutationCoordinatorProvider);
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
  required ArchiveMutationCoordinatorState executionGateState,
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
      'MessageLens is already importing or preparing message data. Historical Archives stays visible so you can inspect the workflow, but import cannot begin until the current task finishes.',
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
      'Import is unavailable because ${_describeExecutionOwnerPhrase(executionGateState.ownerLabel)} currently owns archive mutation authority.',
    HistoricalArchivesExecutionGateStatus.blocked =>
      'Import is unavailable while reset or another maintenance operation is holding the message-data lock.',
  };

  final importButtonEnabled = _importButtonEnabled(
    executionGate: executionGate,
    workflowState: workflowState,
    currentMessagesDatabasePath: currentMessagesDatabasePath,
  );

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
    importSafetySummaryLines: _importSafetySummaryLines(
      workflowState,
      currentMessagesDatabasePath: currentMessagesDatabasePath,
    ),
    importButtonEnabled: importButtonEnabled,
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
    isHub:
        workflowState.presentationContext ==
        HistoricalArchivesPresentationContext.hub,
    narratorPresentation: _buildNarratorPresentation(
      workflowState: workflowState,
      executionGate: executionGate,
      importButtonEnabled: importButtonEnabled,
    ),
    existingSourcePresentation: _buildExistingSourcePresentation(
      workflowState: workflowState,
      executionGate: executionGate,
    ),
  );
}

HistoricalArchivesExistingSourcePresentationViewModel?
_buildExistingSourcePresentation({
  required HistoricalArchivesWorkflowState workflowState,
  required HistoricalArchivesExecutionGateViewModel executionGate,
}) {
  if (workflowState.presentationContext !=
      HistoricalArchivesPresentationContext.existingSource) {
    return null;
  }

  final evidence = workflowState.inspectionEvidence;
  final importDate = DateLabelFormatter.fullDateFromIso(
    evidence?.successfulImportFinishedAtUtc,
  );
  final detailsLines = _inspectionDetailsLines(
    workflowState: workflowState,
    executionGate: executionGate,
    importButtonEnabled: false,
  );

  return HistoricalArchivesExistingSourcePresentationViewModel(
    sourceTypeStatement: 'This is a Mac Messages folder.',
    importDateStatement: importDate == null
        ? null
        : 'You added it to MessageLens on $importDate.',
    contentsStatement: _existingSourceContentsStatement(evidence),
    detailsLines: [
      ...detailsLines,
      if (workflowState.removalFailureDetail case final String failureDetail)
        'Removal detail: $failureDetail',
      if (evidence?.successfulImportFinishedAtUtc case final completedAtUtc?)
        'Successful import completed UTC: $completedAtUtc',
    ],
    removalFailureStatement: workflowState.removalFailureDetail == null
        ? null
        : "MessageLens couldn't remove this folder. Its messages are still part of MessageLens.",
  );
}

String? _existingSourceContentsStatement(
  HistoricalArchivesInspectionEvidence? evidence,
) {
  if (evidence == null) {
    return null;
  }

  final totalMessages = evidence.totalMessages;
  final earliest = _monthYearLong(evidence.earliestMessageUtc);
  final latest = _monthYearLong(evidence.latestMessageUtc);
  if (totalMessages != null && earliest != null && latest != null) {
    return 'It contains ${_formattedCount(totalMessages)} messages sent or '
        'received between $earliest and $latest.';
  }
  if (totalMessages != null) {
    return 'It contains ${_formattedCount(totalMessages)} messages.';
  }
  if (earliest != null && latest != null) {
    return 'Its messages span $earliest through $latest.';
  }
  return null;
}

HistoricalArchivesNarratorPresentationViewModel? _buildNarratorPresentation({
  required HistoricalArchivesWorkflowState workflowState,
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required bool importButtonEnabled,
}) {
  if (workflowState.presentationContext ==
      HistoricalArchivesPresentationContext.hub) {
    return null;
  }

  if (workflowState.presentationContext ==
      HistoricalArchivesPresentationContext.existingSource) {
    return null;
  }

  if (workflowState.presentationContext ==
      HistoricalArchivesPresentationContext.removingSource) {
    final failed = workflowState.removalFailureDetail != null;
    return HistoricalArchivesNarratorPresentationViewModel(
      kind: failed
          ? HistoricalArchivesNarratorPresentationKind.removalFailed
          : HistoricalArchivesNarratorPresentationKind.removingSource,
      narratorText: failed
          ? "MessageLens couldn't finish removing this folder."
          : 'Removing this folder from MessageLens.',
      instrumentationRows: [
        HistoricalArchivesInstrumentationRowViewModel(
          label: 'Removing messages added from this folder',
          value: failed ? "Couldn't finish" : 'Working',
          status: failed
              ? HistoricalArchivesInstrumentationStatus.failed
              : HistoricalArchivesInstrumentationStatus.working,
        ),
      ],
      detailsLines: [
        'Your original Messages folder and its files were not changed.',
        if (workflowState.removalFailureDetail case final String failureDetail)
          failureDetail,
      ],
      retryInspectionEnabled: false,
    );
  }

  return switch (workflowState.presentationStage) {
    HistoricalArchivesPresentationStage.noSource =>
      const HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.noSource,
        narratorText: 'Add an older Messages archive to extend your history.',
        instrumentationRows: [],
        detailsLines: [
          'No Messages archive folder is selected.',
          'Choose a folder and MessageLens will inspect it before offering any import decision.',
        ],
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesPresentationStage.inspectingSource =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.inspectingSource,
        narratorText: 'Let\u2019s see what\u2019s in this Messages folder.',
        instrumentationRows: const [
          HistoricalArchivesInstrumentationRowViewModel(
            label: 'Inspecting archive source',
            value: 'Working',
            status: HistoricalArchivesInstrumentationStatus.working,
          ),
        ],
        detailsLines: _inspectionDetailsLines(
          workflowState: workflowState,
          executionGate: executionGate,
        ),
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesPresentationStage.inspectionFailed =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.inspectionFailed,
        narratorText: _failedInspectionNarrator(workflowState),
        instrumentationRows: [
          HistoricalArchivesInstrumentationRowViewModel(
            label: 'Messages database',
            value: workflowState.chatDbStatusLabel,
            status: HistoricalArchivesInstrumentationStatus.failed,
          ),
        ],
        detailsLines: _inspectionDetailsLines(
          workflowState: workflowState,
          executionGate: executionGate,
        ),
        retryInspectionEnabled: _inspectionCanBeRetried(workflowState),
      ),
    HistoricalArchivesPresentationStage.readyForImport =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.readyForImport,
        narratorText: _readyNarrator(workflowState.inspectionEvidence),
        instrumentationRows: _readyInstrumentationRows(
          workflowState.inspectionEvidence,
        ),
        detailsLines: _inspectionDetailsLines(
          workflowState: workflowState,
          executionGate: executionGate,
          importButtonEnabled: importButtonEnabled,
        ),
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesPresentationStage.knownSource =>
      HistoricalArchivesNarratorPresentationViewModel(
        kind: HistoricalArchivesNarratorPresentationKind.knownSource,
        narratorText: 'This archive is known to MessageLens.',
        instrumentationRows: _knownSourceInstrumentationRows(
          workflowState.inspectionEvidence,
          workflowState.preflight.statusLabel,
        ),
        detailsLines: [
          ..._inspectionDetailsLines(
            workflowState: workflowState,
            executionGate: executionGate,
            importButtonEnabled: false,
          ),
          'Choose the archive folder again to establish current source truth before importing.',
        ],
        retryInspectionEnabled: false,
      ),
    HistoricalArchivesPresentationStage.existingSource => null,
    HistoricalArchivesPresentationStage.laterWorkflow => null,
  };
}

String _failedInspectionNarrator(HistoricalArchivesWorkflowState state) {
  if (state.chatDbStatusLabel == 'Missing') {
    return 'This folder does not contain a Messages database.';
  }
  if (state.chatDbStatusLabel == 'Read failed') {
    return 'MessageLens couldn\u2019t read the Messages database in this folder.';
  }
  return 'MessageLens couldn\u2019t establish that this is a readable Messages archive.';
}

bool _inspectionCanBeRetried(HistoricalArchivesWorkflowState state) {
  return state.chatDbStatusLabel != 'Missing';
}

String _readyNarrator(HistoricalArchivesInspectionEvidence? evidence) {
  final earliest = _monthYearLong(evidence?.earliestMessageUtc);
  if (earliest == null) {
    return 'Good. This archive can extend your MessageLens history.';
  }
  return 'Good. This archive can extend your history back to $earliest.';
}

List<HistoricalArchivesInstrumentationRowViewModel> _readyInstrumentationRows(
  HistoricalArchivesInspectionEvidence? evidence,
) {
  if (evidence == null) {
    return const [];
  }

  final rows = <HistoricalArchivesInstrumentationRowViewModel>[
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Messages database',
      value: evidence.chatDbStatusLabel == 'Found and readable'
          ? 'Found'
          : evidence.chatDbStatusLabel,
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Messages',
      value: _formattedCount(evidence.totalMessages),
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Dates',
      value: _dateRangeLabel(
        evidence.earliestMessageUtc,
        evidence.latestMessageUtc,
      ),
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
  ];

  if (evidence.dryRunNewMessages != null &&
      evidence.dryRunDuplicateMessages != null &&
      _hasCoherentComparisonEvidence(evidence)) {
    rows.addAll([
      HistoricalArchivesInstrumentationRowViewModel(
        label: 'New to MessageLens',
        value: _formattedCount(evidence.dryRunNewMessages),
        status: HistoricalArchivesInstrumentationStatus.resolved,
      ),
      HistoricalArchivesInstrumentationRowViewModel(
        label: 'Already represented',
        value: _formattedCount(evidence.dryRunDuplicateMessages),
        status: HistoricalArchivesInstrumentationStatus.resolved,
      ),
    ]);
  } else {
    rows.add(
      const HistoricalArchivesInstrumentationRowViewModel(
        label: 'Message comparison',
        value: 'Unavailable',
        status: HistoricalArchivesInstrumentationStatus.resolved,
      ),
    );
  }

  return rows;
}

bool _hasCoherentComparisonEvidence(
  HistoricalArchivesInspectionEvidence evidence,
) {
  final comparable = evidence.dryRunComparableMessages;
  final newMessages = evidence.dryRunNewMessages;
  final represented = evidence.dryRunDuplicateMessages;
  if (comparable == null || newMessages == null || represented == null) {
    return false;
  }
  if (comparable < 0 || newMessages < 0 || represented < 0) {
    return false;
  }
  if (newMessages + represented != comparable) {
    return false;
  }
  final totalMessages = evidence.totalMessages;
  return totalMessages == null || comparable <= totalMessages;
}

List<HistoricalArchivesInstrumentationRowViewModel>
_sourceFactsInstrumentationRows(
  HistoricalArchivesInspectionEvidence? evidence,
) {
  if (evidence == null) {
    return const [];
  }

  return [
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Messages',
      value: _formattedCount(evidence.totalMessages),
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Dates',
      value: _dateRangeLabel(
        evidence.earliestMessageUtc,
        evidence.latestMessageUtc,
      ),
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
  ];
}

List<HistoricalArchivesInstrumentationRowViewModel>
_knownSourceInstrumentationRows(
  HistoricalArchivesInspectionEvidence? evidence,
  String statusLabel,
) {
  if (evidence == null) {
    return const [];
  }

  return [
    ..._sourceFactsInstrumentationRows(evidence),
    HistoricalArchivesInstrumentationRowViewModel(
      label: 'Status',
      value: statusLabel,
      status: HistoricalArchivesInstrumentationStatus.resolved,
    ),
  ];
}

List<String> _inspectionDetailsLines({
  required HistoricalArchivesWorkflowState workflowState,
  required HistoricalArchivesExecutionGateViewModel executionGate,
  bool? importButtonEnabled,
}) {
  final evidence = workflowState.inspectionEvidence;
  final selectedFolderPath = workflowState.selectedFolderPath;
  final chatDbPath =
      evidence?.chatDbPath ??
      (selectedFolderPath == null
          ? null
          : path.join(selectedFolderPath, 'chat.db'));

  return [
    if (selectedFolderPath != null) 'Folder: $selectedFolderPath',
    if (chatDbPath != null) 'Messages database: $chatDbPath',
    'Source label: ${workflowState.sourceLabel}',
    'Messages database status: ${workflowState.chatDbStatusLabel}',
    'Attachments folder: ${workflowState.attachmentsStatusLabel}',
    if (evidence?.totalChats case final totalChats?)
      'Chats: ${_formattedCount(totalChats)}',
    if (evidence?.totalHandles case final totalHandles?)
      'Handles: ${_formattedCount(totalHandles)}',
    if (evidence?.missingGuids case final missingGuids?)
      'Rows with missing GUIDs: ${_formattedCount(missingGuids)}',
    if (evidence?.earliestMessageUtc case final earliest?)
      'Earliest message UTC: $earliest',
    if (evidence?.latestMessageUtc case final latest?)
      'Latest message UTC: $latest',
    if (evidence?.dateRangeUnavailableReason case final reason?)
      'Date range diagnostic: $reason',
    if (evidence?.dryRunUnavailableReason case final reason?)
      'GUID comparison unavailable: $reason',
    if (evidence?.dryRunComparableMessages case final comparableMessages?)
      'Comparable source GUIDs: ${_formattedCount(comparableMessages)}',
    'GUID comparison: distinct source GUIDs are compared with distinct GUIDs already represented in MessageLens.',
    'Archive mutation authority: ${executionGate.statusLabel} (${executionGate.detail})',
    if (importButtonEnabled != null)
      'Import authorization: ${importButtonEnabled ? 'available' : 'not currently available'}',
    'Inspection detail: ${workflowState.preflight.detail}',
    for (final entry in workflowState.activityLog)
      '${entry.label}: ${entry.message}',
  ];
}

String _formattedCount(int? value) {
  if (value == null) {
    return 'Unavailable';
  }
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _dateRangeLabel(String? earliestUtc, String? latestUtc) {
  final earliest = _monthYearShort(earliestUtc);
  final latest = _monthYearShort(latestUtc);
  if (earliest == null || latest == null) {
    return 'Unavailable';
  }
  return '$earliest \u2013 $latest';
}

String? _monthYearLong(String? isoUtc) {
  final date = isoUtc == null ? null : DateTime.tryParse(isoUtc)?.toUtc();
  if (date == null) {
    return null;
  }
  return '${_longMonthNames[date.month - 1]} ${date.year}';
}

String? _monthYearShort(String? isoUtc) {
  final date = isoUtc == null ? null : DateTime.tryParse(isoUtc)?.toUtc();
  if (date == null) {
    return null;
  }
  return '${_shortMonthNames[date.month - 1]} ${date.year}';
}

const _longMonthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _shortMonthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

HistoricalArchivesExecutionGateViewModel _buildExecutionGateViewModel({
  required ArchiveMutationCoordinatorState executionGateState,
  required bool isMaintenanceLocked,
}) {
  if (isMaintenanceLocked) {
    return const HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.blocked,
      statusLabel: 'Blocked',
      detail:
          'Message data reset or another maintenance operation is currently active.',
    );
  }

  if (executionGateState.isLocked) {
    return HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.busy,
      statusLabel: 'Busy',
      detail:
          '${_describeExecutionOwnerLabel(executionGateState.ownerLabel)} currently owns archive mutation authority.',
    );
  }

  return const HistoricalArchivesExecutionGateViewModel(
    status: HistoricalArchivesExecutionGateStatus.available,
    statusLabel: 'Available',
    detail: 'No other import, preparation, or reset task is running.',
  );
}

List<HistoricalArchivesLogEntryViewModel> _buildActivityLog({
  required ArchiveMutationCoordinatorState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
}) {
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

  if (executionGateState.isLocked) {
    return [
      ...workflowState.activityLog,
      HistoricalArchivesLogEntryViewModel(
        label: 'Execution gate busy',
        message:
            '${_describeExecutionOwnerLabel(executionGateState.ownerLabel)} is running now. Historical archive import must wait until that operation owner finishes.',
      ),
    ];
  }

  return workflowState.activityLog;
}

List<String> _importSafetySummaryLines(
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
    return const [
      'Live Messages source detected: import is disabled for this folder.',
      'Choose an older Messages archive folder instead.',
    ];
  }

  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => const [
      'Choose an archive folder before importing.',
      'MessageLens will run preflight before enabling Begin Import.',
    ],
    HistoricalArchivesPreflightStatus.running => const [
      'Preflight is still reading the selected folder.',
      'Begin Import stays disabled until source checks complete.',
    ],
    HistoricalArchivesPreflightStatus.failed => const [
      'Begin Import is disabled because the selected folder failed preflight.',
      'No archive messages will be imported from this source until it passes.',
    ],
    HistoricalArchivesPreflightStatus.completeReadyToImport => [
      'Begin Import adds messages from "${workflowState.sourceLabel}" without replacing current message data.',
      'The live Messages database is not modified.',
      'User settings, favourites, and manual labels remain in the overlay database.',
      'Archive messages keep separate source identity even when GUIDs overlap with live messages.',
    ],
  };
}

String _availableStatusLabel(HistoricalArchivesWorkflowState workflowState) {
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.knownSource) {
    return 'Known Archive Source';
  }
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.existingSource) {
    return 'Archive Already Imported';
  }
  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder => 'No archive selected',
    HistoricalArchivesPreflightStatus.running => 'Reading Archive Source',
    HistoricalArchivesPreflightStatus.completeReadyToImport =>
      'Archive Source Ready',
    HistoricalArchivesPreflightStatus.failed => 'Archive Preflight Failed',
  };
}

String _availableSummaryText(HistoricalArchivesWorkflowState workflowState) {
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.knownSource) {
    return 'The selected sidebar source is known to MessageLens. Choose its folder again before any import decision is offered.';
  }
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.existingSource) {
    return 'The selected folder matches an archive source that already has imported messages in MessageLens.';
  }
  return switch (workflowState.preflight.status) {
    HistoricalArchivesPreflightStatus.waitingForFolder =>
      'Historical archive import is a durable, step-by-step workflow. Choose an older Messages folder, review preflight evidence, then import it before messages become visible in MessageLens.',
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
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.knownSource) {
    return 'Import is not offered from persisted known-source information. Choose the folder again to establish current source truth.';
  }
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.existingSource) {
    return 'Import is not offered because this archive is already part of MessageLens.';
  }
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
      'Source checks are complete. Begin Import will add archive messages and refresh browsing data. Archive rows remain isolated from the live Messages source.',
    HistoricalArchivesPreflightStatus.failed =>
      'Import stays disabled until the selected folder passes source preflight.',
  };
}

bool _importButtonEnabled({
  required HistoricalArchivesExecutionGateViewModel executionGate,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.knownSource) {
    return false;
  }
  if (workflowState.presentationStage ==
      HistoricalArchivesPresentationStage.existingSource) {
    return false;
  }
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
  if (workflowState.presentationContext !=
          HistoricalArchivesPresentationContext.existingSource ||
      workflowState.selectedKnownSourceKey == null) {
    return false;
  }
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
  required ArchiveMutationCoordinatorState executionGateState,
  required bool isMaintenanceLocked,
  required HistoricalArchivesWorkflowState workflowState,
  required String currentMessagesDatabasePath,
}) {
  final targetPath = workflowState.archiveRemovalTargetChatDbPath;
  if (executionGateState.isLocked) {
    return 'Removal is unavailable because ${_describeExecutionOwnerPhrase(executionGateState.ownerLabel)} currently owns archive mutation authority.';
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
    dryRunComparableMessages: dryRunEstimate.isAvailable
        ? dryRunEstimate.comparableGuidCount
        : null,
    dateRangeUnavailableReason: inspection.dateRangeUnavailableReason,
    dryRunUnavailableReason: dryRunEstimate.unavailableReason,
    preflightSummaryLines: [
      'Total messages: ${inspection.totalMessages}',
      'Total chats: ${inspection.totalChats}',
      'Total handles: ${inspection.totalHandles}',
      'Rows with missing GUIDs: ${inspection.missingGuids}',
      'Earliest message: ${_dateSummaryLabel(inspection.earliestMessageUtc)}',
      'Latest message: ${_dateSummaryLabel(inspection.latestMessageUtc)}',
      if (inspection.dateRangeUnavailableReason case final reason?)
        'Date range diagnostic: $reason',
      if (dryRunEstimate.isAvailable)
        'Likely already imported: ${dryRunEstimate.duplicateGuidCount} comparable source rows'
      else
        'Likely already imported: unavailable',
      if (dryRunEstimate.isAvailable)
        'Likely new rows: ${dryRunEstimate.newGuidCount} comparable source rows'
      else
        'Likely new rows: unavailable',
    ],
    dryRunSummaryLines: [
      if (dryRunEstimate.isAvailable)
        'Estimated new messages: ${dryRunEstimate.newGuidCount} comparable source rows not already imported'
      else
        'Estimated new messages: comparison unavailable',
      if (dryRunEstimate.isAvailable)
        'Estimated duplicates: ${dryRunEstimate.duplicateGuidCount} comparable source rows already imported'
      else
        'Estimated duplicates: comparison unavailable',
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
            ? 'Compared ${dryRunEstimate.comparableGuidCount} source rows against existing imported messages.'
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
        label: 'Preparing archive records',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Normalization begins when you run archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Importing archive messages',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Archive import begins when you run Begin Import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Preparing messages for browsing',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Graph projection begins only after successful archive import.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'Rebuild steps are still waiting.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Refreshing shared evidence surfaces',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail:
            'Shared message evidence surfaces are unchanged until refresh completes.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Complete',
        status: HistoricalArchivesWorkflowPhaseStatus.waiting,
        detail: 'No archive workflow has completed yet.',
      ),
    ],
  );
}

bool _isInvalidFolderQualificationFailure(
  HistoricalArchivesFolderPreflightResult result,
) {
  return result.chatDbStatusLabel == 'Missing';
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
    presentationContext: HistoricalArchivesPresentationContext.addArchive,
    preflight: result.preflight,
    selectedFolderPath: result.selectedFolderPath,
    archiveRemovalTargetChatDbPath: result.archiveRemovalTargetChatDbPath,
    chatDbStatusLabel: result.chatDbStatusLabel,
    attachmentsStatusLabel: result.attachmentsStatusLabel,
    sourceLabel: result.sourceLabel,
    preflightSummaryLines: result.preflightSummaryLines,
    dryRunSummaryLines: result.dryRunSummaryLines,
    importSafetySummaryLines:
        buildInitialHistoricalArchivesWorkflowState().importSafetySummaryLines,
    resultSummaryLines:
        buildInitialHistoricalArchivesWorkflowState().resultSummaryLines,
    activityLog: result.activityLog,
    phases: result.phases,
    presentationStage:
        result.preflight.status ==
            HistoricalArchivesPreflightStatus.completeReadyToImport
        ? HistoricalArchivesPresentationStage.readyForImport
        : HistoricalArchivesPresentationStage.inspectionFailed,
    inspectionEvidence: HistoricalArchivesInspectionEvidence(
      folderPath: result.selectedFolderPath,
      chatDbPath: result.archiveRemovalTargetChatDbPath,
      sourceLabel: result.sourceLabel,
      chatDbStatusLabel: result.chatDbStatusLabel,
      attachmentsStatusLabel: result.attachmentsStatusLabel,
      totalMessages: result.totalMessages,
      totalChats: result.totalChats,
      totalHandles: result.totalHandles,
      missingGuids: result.missingGuids,
      earliestMessageUtc: result.earliestMessageUtc,
      latestMessageUtc: result.latestMessageUtc,
      dateRangeUnavailableReason: result.dateRangeUnavailableReason,
      dryRunNewMessages: result.dryRunNewMessages,
      dryRunDuplicateMessages: result.dryRunDuplicateMessages,
      dryRunComparableMessages: result.dryRunComparableMessages,
      dryRunUnavailableReason: result.dryRunUnavailableReason,
    ),
  );
}

HistoricalArchivesWorkflowState _workflowStateFromKnownSourceMetadata(
  HistoricalArchiveSourceMetadata source, {
  required int importedMessageCount,
  required String selectedKnownSourceKey,
}) {
  final initial = buildInitialHistoricalArchivesWorkflowState();
  return HistoricalArchivesWorkflowState(
    preflight: const HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.waitingForFolder,
      statusLabel: 'Already imported',
      detail:
          'The source-scoped import ledger contains messages for this archive.',
    ),
    selectedFolderPath: source.folderPath,
    archiveRemovalTargetChatDbPath: source.sourceChatDb,
    chatDbStatusLabel: source.chatDbStatusLabel,
    attachmentsStatusLabel: source.attachmentsStatusLabel,
    sourceLabel: source.sourceLabel,
    preflightSummaryLines: const [],
    dryRunSummaryLines: const [],
    importSafetySummaryLines: initial.importSafetySummaryLines,
    resultSummaryLines: initial.resultSummaryLines,
    activityLog: const [],
    phases: initial.phases,
    presentationStage: HistoricalArchivesPresentationStage.existingSource,
    presentationContext: HistoricalArchivesPresentationContext.existingSource,
    inspectionEvidence: HistoricalArchivesInspectionEvidence(
      folderPath: source.folderPath,
      chatDbPath: source.sourceChatDb,
      sourceLabel: source.sourceLabel,
      chatDbStatusLabel: source.chatDbStatusLabel,
      attachmentsStatusLabel: source.attachmentsStatusLabel,
      totalMessages: importedMessageCount,
      totalChats: null,
      totalHandles: null,
      missingGuids: null,
      earliestMessageUtc: source.earliestMessageUtc,
      latestMessageUtc: source.latestMessageUtc,
      dateRangeUnavailableReason: null,
      dryRunNewMessages: null,
      dryRunDuplicateMessages: null,
      dryRunComparableMessages: null,
      dryRunUnavailableReason:
          'A fresh folder inspection is required before comparison.',
      successfulImportFinishedAtUtc: source.lastImportSuccess == true
          ? source.lastImportFinishedAtUtc
          : null,
    ),
    selectedKnownSourceKey: selectedKnownSourceKey,
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
    dryRunComparableMessages: null,
    preflightSummaryLines: const [
      'Total messages: unavailable',
      'Total chats: unavailable',
      'Total handles: unavailable',
      'Rows with missing GUIDs: unavailable',
      'Earliest message: unavailable',
      'Latest message: unavailable',
      'Likely already imported: unavailable',
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
        label: 'Preparing archive records',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Importing archive messages',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Preparing messages for browsing',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Rebuilding indexes/search/heatmap support tables',
        status: HistoricalArchivesWorkflowPhaseStatus.skipped,
        detail: 'Skipped until source preflight succeeds.',
      ),
      HistoricalArchivesWorkflowPhaseViewModel(
        label: 'Refreshing shared evidence surfaces',
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
      label: 'Preparing archive records',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Importing archive messages',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing messages for browsing',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for source checks to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing shared evidence surfaces',
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
      label: 'Removing messages added from this folder',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'The source-scoped removal operation is still running.',
    ),
  ];
}

List<HistoricalArchivesWorkflowPhaseViewModel> _failedArchiveRemovalPhases({
  required String detail,
}) {
  return [
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Removing messages added from this folder',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
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
      label: 'Preparing archive records',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'MessageLens is reading archive source tables now.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Importing archive messages',
      status: HistoricalArchivesWorkflowPhaseStatus.running,
      detail: 'Archive messages are being imported into MessageLens.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing messages for browsing',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Browsing preparation starts after archive import succeeds.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for browsing preparation to complete.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing shared evidence surfaces',
      status: HistoricalArchivesWorkflowPhaseStatus.waiting,
      detail: 'Waiting for browsing preparation to complete.',
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
      label: 'Preparing archive records',
      status: HistoricalArchivesWorkflowPhaseStatus.failed,
      detail: detail,
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Importing archive messages',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing messages for browsing',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.skipped,
      detail: 'Skipped because archive import did not complete successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing shared evidence surfaces',
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
      label: 'Preparing archive records',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Archive records were prepared successfully.',
    ),
    HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Importing archive messages',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail:
          'Archive import wrote $importedMessageCount messages for this archive source.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Preparing messages for browsing',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Messages were prepared for browsing successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Rebuilding indexes/search/heatmap support tables',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Projection rebuild steps completed successfully.',
    ),
    const HistoricalArchivesWorkflowPhaseViewModel(
      label: 'Refreshing shared evidence surfaces',
      status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
      detail: 'Shared message evidence surfaces refreshed successfully.',
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
