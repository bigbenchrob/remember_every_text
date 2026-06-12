import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import '../../../features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import '../../../features/address_book_folders/feature_level_providers.dart';
import '../../db/feature_level_providers.dart'
    show databaseDirectoryPath, dbMaintenanceLockProvider;
import '../../db/feature_level_providers/conversation_graph_readiness_provider.dart'
    show ConversationGraphReadiness, conversationGraphDatabaseFileName;
import '../../source_scoped_import/feature_level_providers.dart'
    show sourceScopedImportDatabaseFileName;
import '../domain/onboarding_environment_report.dart';
import '../infrastructure/persistence/onboarding_database_probe_reader_provider.dart';
import '../infrastructure/persistence/onboarding_failure_storage_provider.dart';
import '../infrastructure/system/full_disk_access_provider.dart';
import 'onboarding_database_probe_reader.dart';

part 'onboarding_environment_report_provider.g.dart';

const int _sparseMessagesThreshold = 10;
const int _automaticRecoveryMinimumImportRows = 25;
const double _automaticRecoveryWorkingToImportRatio = 0.5;

class OnboardingDevOverridesState {
  const OnboardingDevOverridesState({
    this.simulateFullDiskAccessBlocked = false,
    this.simulateMessagesDatabaseMissing = false,
    this.simulateAddressBookUnavailable = false,
    this.simulateSparseSourceHistory = false,
    this.simulateImportFailure = false,
    this.simulateGraphProjectionFailure = false,
  });

  final bool simulateFullDiskAccessBlocked;
  final bool simulateMessagesDatabaseMissing;
  final bool simulateAddressBookUnavailable;
  final bool simulateSparseSourceHistory;
  final bool simulateImportFailure;
  final bool simulateGraphProjectionFailure;

  bool get hasAnyOverride {
    return simulateFullDiskAccessBlocked ||
        simulateMessagesDatabaseMissing ||
        simulateAddressBookUnavailable ||
        simulateSparseSourceHistory ||
        simulateImportFailure ||
        simulateGraphProjectionFailure;
  }

  OnboardingDevOverridesState copyWith({
    bool? simulateFullDiskAccessBlocked,
    bool? simulateMessagesDatabaseMissing,
    bool? simulateAddressBookUnavailable,
    bool? simulateSparseSourceHistory,
    bool? simulateImportFailure,
    bool? simulateGraphProjectionFailure,
  }) {
    return OnboardingDevOverridesState(
      simulateFullDiskAccessBlocked:
          simulateFullDiskAccessBlocked ?? this.simulateFullDiskAccessBlocked,
      simulateMessagesDatabaseMissing:
          simulateMessagesDatabaseMissing ??
          this.simulateMessagesDatabaseMissing,
      simulateAddressBookUnavailable:
          simulateAddressBookUnavailable ?? this.simulateAddressBookUnavailable,
      simulateSparseSourceHistory:
          simulateSparseSourceHistory ?? this.simulateSparseSourceHistory,
      simulateImportFailure:
          simulateImportFailure ?? this.simulateImportFailure,
      simulateGraphProjectionFailure:
          simulateGraphProjectionFailure ?? this.simulateGraphProjectionFailure,
    );
  }
}

@Riverpod(keepAlive: true)
class OnboardingDevOverrides extends _$OnboardingDevOverrides {
  @override
  OnboardingDevOverridesState build() {
    return const OnboardingDevOverridesState();
  }

  void setFullDiskAccessBlocked({required bool enabled}) {
    state = state.copyWith(simulateFullDiskAccessBlocked: enabled);
  }

  void setMessagesDatabaseMissing({required bool enabled}) {
    state = state.copyWith(simulateMessagesDatabaseMissing: enabled);
  }

  void setAddressBookUnavailable({required bool enabled}) {
    state = state.copyWith(simulateAddressBookUnavailable: enabled);
  }

  void setSparseSourceHistory({required bool enabled}) {
    state = state.copyWith(simulateSparseSourceHistory: enabled);
  }

  void setImportFailure({required bool enabled}) {
    state = state.copyWith(simulateImportFailure: enabled);
  }

  void setGraphProjectionFailure({required bool enabled}) {
    state = state.copyWith(simulateGraphProjectionFailure: enabled);
  }

  void clearAll() {
    state = const OnboardingDevOverridesState();
  }
}

@Riverpod(keepAlive: true)
bool onboardingFullDiskAccess(Ref ref) {
  return ref.watch(fullDiskAccessProvider).canReadMessagesDatabase();
}

@Riverpod(keepAlive: true)
String onboardingMessagesDatabasePath(Ref ref) {
  return ref.watch(fullDiskAccessProvider).messagesDatabasePath;
}

@Riverpod(keepAlive: true)
String onboardingDatabaseDirectoryPath(Ref ref) {
  return databaseDirectoryPath;
}

@Riverpod(keepAlive: true)
Future<OnboardingEnvironmentReport> onboardingEnvironmentReport(Ref ref) async {
  final evaluator = _OnboardingEnvironmentEvaluator(ref);
  return evaluator.evaluate();
}

class _OnboardingEnvironmentEvaluator {
  const _OnboardingEnvironmentEvaluator(this.ref);

  final Ref ref;

  Future<OnboardingEnvironmentReport> evaluate() async {
    final devOverrides = ref.watch(onboardingDevOverridesProvider);
    final failureStorage = ref.watch(onboardingFailureStorageProvider);
    final databaseProbeReader = ref.watch(
      onboardingDatabaseProbeReaderProvider,
    );
    final persistedImportEntry = await failureStorage.loadImportResultEntry();
    final persistedGraphProjectionEntry = await failureStorage
        .loadGraphProjectionResultEntry();
    final persistedImportFailure = persistedImportEntry?.failure;
    final persistedGraphProjectionFailure =
        persistedGraphProjectionEntry?.failure;
    final simulatedPipelineFailureActive =
        devOverrides.simulateImportFailure ||
        devOverrides.simulateGraphProjectionFailure;
    final lastImportFailure = devOverrides.simulateImportFailure
        ? const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.import,
            batchId: -1,
            message: 'Simulated import failure from onboarding dev panel',
          )
        : simulatedPipelineFailureActive
        ? null
        : persistedImportFailure;
    final lastGraphProjectionFailure =
        devOverrides.simulateGraphProjectionFailure
        ? const OnboardingPipelineFailure(
            phase: OnboardingPipelinePhase.graphProjection,
            batchId: -1,
            message:
                'Simulated graph projection failure from onboarding dev panel',
          )
        : simulatedPipelineFailureActive
        ? null
        : persistedGraphProjectionFailure;
    var hasFullDiskAccess = ref.watch(onboardingFullDiskAccessProvider);
    if (devOverrides.simulateFullDiskAccessBlocked) {
      hasFullDiskAccess = false;
    }
    final messagesDatabasePath = ref.watch(
      onboardingMessagesDatabasePathProvider,
    );
    final messagesProbe = devOverrides.simulateMessagesDatabaseMissing
        ? OnboardingDatabaseProbe(
            path: messagesDatabasePath,
            exists: false,
            readable: false,
          )
        : databaseProbeReader.probeFile(messagesDatabasePath);

    final addressBookProbe = devOverrides.simulateAddressBookUnavailable
        ? const _AddressBookProbeResult(
            probe: null,
            failureMessage:
                'Simulated unavailable Contacts source from onboarding dev panel',
          )
        : _probeAddressBook(
            databaseProbeReader,
            await ref.watch(futureGetFolderAggregateProvider.future),
          );

    final databaseDirPath = ref.watch(onboardingDatabaseDirectoryPathProvider);
    final sourceScopedImportDbPath = p.join(
      databaseDirPath,
      sourceScopedImportDatabaseFileName,
    );
    final graphDbPath = p.join(
      databaseDirPath,
      conversationGraphDatabaseFileName,
    );
    final isMaintenanceLocked = ref.watch(dbMaintenanceLockProvider);

    final sourceMessageCount = devOverrides.simulateSparseSourceHistory
        ? 0
        : databaseProbeReader.readTableCount(
            dbPath: messagesDatabasePath,
            tableName: 'message',
            queryOnly: true,
          );
    final sourceAttachmentCount = databaseProbeReader.readTableCount(
      dbPath: messagesDatabasePath,
      tableName: 'attachment',
      queryOnly: true,
    );

    final importRowCount = databaseProbeReader.readTableCount(
      dbPath: sourceScopedImportDbPath,
      tableName: 'messages',
    );
    final graphRowCount = isMaintenanceLocked
        ? null
        : databaseProbeReader.readTableCount(
            dbPath: graphDbPath,
            tableName: 'messages',
          );
    final graphReadiness = isMaintenanceLocked
        ? const ConversationGraphReadiness(
            isReady: false,
            reason: 'database maintenance is active',
            messageCount: 0,
            chatCount: 0,
            chatToMessageEdgeCount: 0,
          )
        : databaseProbeReader.readConversationGraphReadiness(graphDbPath);

    final importProbe = databaseProbeReader.probeFile(
      sourceScopedImportDbPath,
      rowCount: importRowCount,
    );
    final graphProbe = databaseProbeReader.probeFile(
      graphDbPath,
      rowCount: graphRowCount,
    );
    final usingPersistedImportFailure =
        !devOverrides.simulateImportFailure &&
        !simulatedPipelineFailureActive &&
        persistedImportEntry != null;
    final usingPersistedGraphProjectionFailure =
        !devOverrides.simulateGraphProjectionFailure &&
        !simulatedPipelineFailureActive &&
        persistedGraphProjectionEntry != null;
    final resetAppDatabasesReason = _detectResetAppDatabasesReason(
      isMaintenanceLocked: isMaintenanceLocked,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      sourceMessageCount: sourceMessageCount,
      importProbe: importProbe,
      graphProbe: graphProbe,
    );

    final state = _classifyState(
      hasFullDiskAccess: hasFullDiskAccess,
      messagesProbe: messagesProbe,
      addressBookProbe: addressBookProbe,
      sourceMessageCount: sourceMessageCount,
      forceImportFailure: devOverrides.simulateImportFailure,
      forceGraphProjectionFailure: devOverrides.simulateGraphProjectionFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      resetAppDatabasesReason: resetAppDatabasesReason,
      graphProjectionReady: graphReadiness.isReady,
      importProbe: importProbe,
      graphProbe: graphProbe,
    );

    final blockerKind = _classifyBlocker(
      state: state,
      hasFullDiskAccess: hasFullDiskAccess,
      messagesProbe: messagesProbe,
      addressBookProbe: addressBookProbe,
      sourceMessageCount: sourceMessageCount,
      forceImportFailure: devOverrides.simulateImportFailure,
      forceGraphProjectionFailure: devOverrides.simulateGraphProjectionFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      resetAppDatabasesReason: resetAppDatabasesReason,
      graphProjectionReady: graphReadiness.isReady,
      importProbe: importProbe,
      graphProbe: graphProbe,
    );

    final syncPlausibility = _classifySyncPlausibility(
      hasFullDiskAccess: hasFullDiskAccess,
      sourceMessageCount: sourceMessageCount,
    );

    return OnboardingEnvironmentReport(
      state: state,
      blockerKind: blockerKind,
      syncPlausibility: syncPlausibility,
      messagesDatabase: messagesProbe.copyWith(rowCount: sourceMessageCount),
      addressBookDatabase: addressBookProbe.probe,
      sourceScopedImportDatabase: importProbe,
      conversationGraph: graphProbe,
      hasFullDiskAccess: hasFullDiskAccess,
      sourceAttachmentCount: sourceAttachmentCount,
      addressBookFailureMessage: addressBookProbe.failureMessage,
      lastImportFailure: lastImportFailure,
      lastGraphProjectionFailure: lastGraphProjectionFailure,
      lastImportFailureRecordedAt: persistedImportEntry?.recordedAt,
      lastGraphProjectionFailureRecordedAt:
          persistedGraphProjectionEntry?.recordedAt,
      usingPersistedImportFailure: usingPersistedImportFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      shouldResetAppDatabasesBeforeImport: resetAppDatabasesReason != null,
      resetAppDatabasesReason: resetAppDatabasesReason,
    );
  }

  OnboardingEnvironmentState _classifyState({
    required bool hasFullDiskAccess,
    required OnboardingDatabaseProbe messagesProbe,
    required _AddressBookProbeResult addressBookProbe,
    required int? sourceMessageCount,
    required bool forceImportFailure,
    required bool forceGraphProjectionFailure,
    required bool usingPersistedImportFailure,
    required bool usingPersistedGraphProjectionFailure,
    required String? resetAppDatabasesReason,
    required bool graphProjectionReady,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (!hasFullDiskAccess || !messagesProbe.readable) {
      return OnboardingEnvironmentState.permissionBlocked;
    }

    if (!messagesProbe.exists || !addressBookProbe.isAvailable) {
      return OnboardingEnvironmentState.sourceUnavailable;
    }

    if (sourceMessageCount != null &&
        sourceMessageCount <= _sparseMessagesThreshold) {
      return OnboardingEnvironmentState.sourceSparseOrUnsynced;
    }

    if (forceGraphProjectionFailure) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (forceImportFailure) {
      return OnboardingEnvironmentState.importFailed;
    }

    if (resetAppDatabasesReason != null) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (importProbe.hasData && graphProjectionReady) {
      return OnboardingEnvironmentState.ready;
    }

    if (importProbe.hasData && graphProbe.exists && !graphProjectionReady) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (_shouldSurfaceGraphProjectionFailure(
      forceGraphProjectionFailure: forceGraphProjectionFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingEnvironmentState.graphProjectionFailed;
    }

    if (_shouldSurfaceImportFailure(
      forceImportFailure: forceImportFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingEnvironmentState.importFailed;
    }

    return OnboardingEnvironmentState.readyToImport;
  }

  OnboardingBlockerKind _classifyBlocker({
    required OnboardingEnvironmentState state,
    required bool hasFullDiskAccess,
    required OnboardingDatabaseProbe messagesProbe,
    required _AddressBookProbeResult addressBookProbe,
    required int? sourceMessageCount,
    required bool forceImportFailure,
    required bool forceGraphProjectionFailure,
    required bool usingPersistedImportFailure,
    required bool usingPersistedGraphProjectionFailure,
    required String? resetAppDatabasesReason,
    required bool graphProjectionReady,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (!hasFullDiskAccess || !messagesProbe.readable) {
      return OnboardingBlockerKind.fullDiskAccessMissing;
    }

    if (!messagesProbe.exists) {
      return OnboardingBlockerKind.messagesDatabaseMissing;
    }

    if (!addressBookProbe.isAvailable) {
      return OnboardingBlockerKind.addressBookUnavailable;
    }

    if (state == OnboardingEnvironmentState.sourceSparseOrUnsynced ||
        (sourceMessageCount != null &&
            sourceMessageCount <= _sparseMessagesThreshold)) {
      return OnboardingBlockerKind.sourceDataSparseOrUnsynced;
    }

    if (forceGraphProjectionFailure) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (forceImportFailure) {
      return OnboardingBlockerKind.importFailed;
    }

    if (resetAppDatabasesReason != null) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (state == OnboardingEnvironmentState.ready) {
      return OnboardingBlockerKind.none;
    }

    if (importProbe.hasData && graphProbe.exists && !graphProjectionReady) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (_shouldSurfaceGraphProjectionFailure(
      forceGraphProjectionFailure: forceGraphProjectionFailure,
      usingPersistedGraphProjectionFailure:
          usingPersistedGraphProjectionFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingBlockerKind.graphProjectionFailed;
    }

    if (_shouldSurfaceImportFailure(
      forceImportFailure: forceImportFailure,
      usingPersistedImportFailure: usingPersistedImportFailure,
      importProbe: importProbe,
      graphProbe: graphProbe,
    )) {
      return OnboardingBlockerKind.importFailed;
    }

    if (!importProbe.exists) {
      return OnboardingBlockerKind.importDatabaseMissing;
    }

    if (!graphProbe.exists) {
      return OnboardingBlockerKind.conversationGraphMissing;
    }

    if (!importProbe.hasData) {
      return OnboardingBlockerKind.importDatabaseEmpty;
    }

    if (!graphProbe.hasData) {
      return OnboardingBlockerKind.conversationGraphEmpty;
    }

    return OnboardingBlockerKind.none;
  }

  bool _shouldSurfaceImportFailure({
    required bool forceImportFailure,
    required bool usingPersistedImportFailure,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (forceImportFailure) {
      return true;
    }

    if (!usingPersistedImportFailure) {
      return false;
    }

    return importProbe.hasData || graphProbe.hasData;
  }

  bool _shouldSurfaceGraphProjectionFailure({
    required bool forceGraphProjectionFailure,
    required bool usingPersistedGraphProjectionFailure,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (forceGraphProjectionFailure) {
      return true;
    }

    if (!usingPersistedGraphProjectionFailure) {
      return false;
    }

    return importProbe.hasData || graphProbe.hasData;
  }

  OnboardingSyncPlausibility _classifySyncPlausibility({
    required bool hasFullDiskAccess,
    required int? sourceMessageCount,
  }) {
    if (!hasFullDiskAccess || sourceMessageCount == null) {
      return OnboardingSyncPlausibility.unknown;
    }

    if (sourceMessageCount <= _sparseMessagesThreshold) {
      return OnboardingSyncPlausibility.likelySparseOrUnsynced;
    }

    return OnboardingSyncPlausibility.likelySyncedOrLocallyAvailable;
  }

  _AddressBookProbeResult _probeAddressBook(
    OnboardingDatabaseProbeReader databaseProbeReader,
    Either<FolderRetrievalFailure, AddressBookFolderAggregate>
    addressBookEither,
  ) {
    return addressBookEither.fold(
      (failure) =>
          _AddressBookProbeResult(probe: null, failureMessage: failure.message),
      (aggregate) {
        final filePath = aggregate.mostRecentFolderPath;
        return _AddressBookProbeResult(
          probe: databaseProbeReader.probeFile(filePath),
        );
      },
    );
  }

  String? _detectResetAppDatabasesReason({
    required bool isMaintenanceLocked,
    required bool usingPersistedImportFailure,
    required bool usingPersistedGraphProjectionFailure,
    required int? sourceMessageCount,
    required OnboardingDatabaseProbe importProbe,
    required OnboardingDatabaseProbe graphProbe,
  }) {
    if (isMaintenanceLocked || !importProbe.hasData) {
      return null;
    }

    final importCount = importProbe.rowCount;
    if (importCount == null ||
        importCount < _automaticRecoveryMinimumImportRows) {
      return null;
    }

    final graphCount = graphProbe.rowCount ?? 0;
    final hasRecordedFailure =
        usingPersistedImportFailure || usingPersistedGraphProjectionFailure;
    final importTracksSource =
        sourceMessageCount == null ||
        sourceMessageCount <= _sparseMessagesThreshold ||
        importCount >=
            (sourceMessageCount * _automaticRecoveryWorkingToImportRatio)
                .round();
    final workingClearlyIncomplete =
        !graphProbe.hasData ||
        graphCount <
            (importCount * _automaticRecoveryWorkingToImportRatio).round();

    if (!importTracksSource || !workingClearlyIncomplete) {
      return null;
    }

    if (hasRecordedFailure) {
      return 'A previous import or graph projection failure left a populated import ledger but an incomplete conversation graph.';
    }

    if (graphProbe.hasData) {
      return 'The conversation graph contains far fewer messages than the import ledger, which strongly suggests a stale partial graph projection.';
    }

    return null;
  }
}

class _AddressBookProbeResult {
  const _AddressBookProbeResult({required this.probe, this.failureMessage});

  final OnboardingDatabaseProbe? probe;
  final String? failureMessage;

  bool get isAvailable => probe != null && probe!.exists && probe!.readable;
}

extension on OnboardingDatabaseProbe {
  OnboardingDatabaseProbe copyWith({int? rowCount}) {
    return OnboardingDatabaseProbe(
      path: path,
      exists: exists,
      readable: readable,
      sizeBytes: sizeBytes,
      lastModified: lastModified,
      rowCount: rowCount ?? this.rowCount,
    );
  }
}
