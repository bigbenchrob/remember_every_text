import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/domain.dart'
    show ArchiveMutationDeniedException, ArchiveMutationOperation;
import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider, archiveMutationCoordinatorProvider;
import '../../conversation_graph/feature_level_providers.dart'
    show conversationGraphBuildControllerProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/feature_level_providers.dart'
    show SidebarMode, activeSidebarModeProvider;
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_operation_snapshot.dart';
import '../domain/onboarding_status.dart';
import 'database_existence_checker.dart';
import 'full_disk_access_provider.dart';
import 'message_data_reset_service.dart';
import 'onboarding_database_probe_reader_provider.dart';
import 'onboarding_durable_completion_verifier_provider.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_failure_storage_provider.dart';
import 'onboarding_operation_snapshot_controller.dart';
import 'onboarding_operation_snapshot_provider.dart';

part 'onboarding_gate_provider.g.dart';

enum _AutomaticRecoveryDeferral {
  none,
  waitingForMutationRelease,
  awaitingFreshEnvironment,
}

/// Controls the onboarding overlay lifecycle.
///
/// Gate 1 — Full Disk Access:
/// On [build], checks whether the app can read `~/Library/Messages/chat.db`.
/// If not, exposes [OnboardingStatus.awaitingFda] so the FDA instruction
/// screen is shown.  Nothing else can proceed until FDA is confirmed.
///
/// Gate 2 — Data import:
/// Once FDA is confirmed, checks whether the source-scoped import ledger and
/// app-facing conversation graph exist with data. If not, exposes
/// [OnboardingStatus.awaitingUserAction] so the import overlay appears.
///
/// [startImportAndGraphBuild] builds the source-scoped conversation graph
/// directly. Retired database files are cleanup/diagnostic inventory only
/// and are not the app-facing setup path.
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  OnboardingStatus? _workflowOverrideStatus;
  bool _automaticRecoveryInFlight = false;
  bool _automaticRecoverySuppressed = false;
  _AutomaticRecoveryDeferral _automaticRecoveryDeferral =
      _AutomaticRecoveryDeferral.none;
  bool _mutationCoordinatorIsLocked = false;
  OnboardingStatus? _lastLoggedResolvedStatus;
  OnboardingEnvironmentState? _lastLoggedEnvironmentState;
  OnboardingBlockerKind? _lastLoggedBlockerKind;
  bool? _lastLoggedHasPopulatedAppDatabases;

  @override
  OnboardingStatus build() {
    ref.listen<bool>(
      archiveMutationCoordinatorProvider.select((state) => state.isLocked),
      _handleMutationLockChanged,
      fireImmediately: true,
    );

    final reportAsync = ref.watch(onboardingEnvironmentReportProvider);
    if (!reportAsync.isLoading && !reportAsync.hasError) {
      final report = reportAsync.valueOrNull;
      if (report != null) {
        _handleEnvironmentReport(report);
      }
    }

    final resolvedStatus = resolveBuildStatus(
      reportAsync: reportAsync,
      workflowOverrideStatus: _workflowOverrideStatus,
      fallbackBuildStatus: _fallbackBuildStatus,
    );

    _maybeLogResolvedStatus(
      resolvedStatus: resolvedStatus,
      report: reportAsync.valueOrNull,
    );

    return resolvedStatus;
  }

  void _maybeLogResolvedStatus({
    required OnboardingStatus resolvedStatus,
    required OnboardingEnvironmentReport? report,
  }) {
    final hasPopulatedAppDatabases = report?.hasPopulatedAppDatabases;
    final shouldLog =
        _lastLoggedResolvedStatus != resolvedStatus ||
        _lastLoggedEnvironmentState != report?.state ||
        _lastLoggedBlockerKind != report?.blockerKind ||
        _lastLoggedHasPopulatedAppDatabases != hasPopulatedAppDatabases;

    if (!shouldLog) {
      return;
    }

    _lastLoggedResolvedStatus = resolvedStatus;
    _lastLoggedEnvironmentState = report?.state;
    _lastLoggedBlockerKind = report?.blockerKind;
    _lastLoggedHasPopulatedAppDatabases = hasPopulatedAppDatabases;

    final logContext = <String, dynamic>{
      'resolvedStatus': resolvedStatus.name,
      'workflowOverrideStatus': _workflowOverrideStatus?.name,
      'environmentState': report?.state.name,
      'environmentBlocker': report?.blockerKind.name,
      'hasFullDiskAccess': report?.hasFullDiskAccess,
      'hasPopulatedAppDatabases': hasPopulatedAppDatabases,
      'sourceScopedImportDbExists': report?.sourceScopedImportDatabase.exists,
      'sourceScopedImportDbRowCount':
          report?.sourceScopedImportDatabase.rowCount,
      'conversationGraphExists': report?.conversationGraph.exists,
      'conversationGraphRowCount': report?.conversationGraph.rowCount,
      'shouldResetAppDatabasesBeforeImport':
          report?.shouldResetAppDatabasesBeforeImport,
      'resetAppDatabasesReason': report?.resetAppDatabasesReason,
    };

    final logger = ref.read(appLoggerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.info(
        'Resolved onboarding gate status',
        source: 'OnboardingGate',
        context: logContext,
      );
    });
  }

  @visibleForTesting
  static OnboardingStatus resolveBuildStatus({
    required AsyncValue<OnboardingEnvironmentReport> reportAsync,
    required OnboardingStatus? workflowOverrideStatus,
    required OnboardingStatus Function() fallbackBuildStatus,
  }) {
    if (_shouldPreserveWorkflowOverride(workflowOverrideStatus)) {
      return workflowOverrideStatus!;
    }

    return reportAsync.when(
      data: _classifyStatusFromReport,
      loading: fallbackBuildStatus,
      error: (_, __) => fallbackBuildStatus(),
    );
  }

  static OnboardingStatus _classifyStatusFromReport(
    OnboardingEnvironmentReport report,
  ) {
    return switch (report.state) {
      OnboardingEnvironmentState.permissionBlocked =>
        OnboardingStatus.awaitingFda,
      OnboardingEnvironmentState.ready ||
      OnboardingEnvironmentState.maintenanceInProgress =>
        OnboardingStatus.notNeeded,
      OnboardingEnvironmentState.importFailed ||
      OnboardingEnvironmentState.graphProjectionFailed ||
      OnboardingEnvironmentState.sourceUnavailable ||
      OnboardingEnvironmentState.sourceSparseOrUnsynced ||
      OnboardingEnvironmentState.readyToImport =>
        OnboardingStatus.awaitingUserAction,
    };
  }

  static bool _shouldPreserveWorkflowOverride(OnboardingStatus? status) {
    return switch (status) {
      OnboardingStatus.recoveringFailedAttempt ||
      OnboardingStatus.preparationFailed ||
      OnboardingStatus.importing ||
      OnboardingStatus.buildingGraph ||
      OnboardingStatus.complete ||
      OnboardingStatus.reimporting ||
      OnboardingStatus.reimportBuildingGraph ||
      OnboardingStatus.reimportComplete ||
      OnboardingStatus.awaitingUserAction => true,
      null ||
      OnboardingStatus.awaitingFda ||
      OnboardingStatus.notNeeded => false,
    };
  }

  OnboardingStatus _fallbackBuildStatus() {
    if (!ref.read(onboardingFullDiskAccessProvider)) {
      return OnboardingStatus.awaitingFda;
    }

    final checker = DatabaseExistenceChecker(
      ref.read(onboardingDatabaseProbeReaderProvider),
    );
    final hasData = checker.hasPopulatedDatabases(
      ref.read(archiveAccessAuthorityProvider).rootPath,
    );
    if (hasData) {
      return OnboardingStatus.notNeeded;
    }

    return OnboardingStatus.awaitingUserAction;
  }

  /// Kick off the source-scoped conversation graph build.
  ///
  /// Wrapped in try/catch so the user is never stranded.
  Future<void> startImportAndGraphBuild() async {
    if (state != OnboardingStatus.awaitingUserAction &&
        state != OnboardingStatus.preparationFailed) {
      return;
    }

    final operationId = await ref
        .read(archiveMutationCoordinatorProvider.notifier)
        .run<OnboardingOperationId?>(
          operation: ArchiveMutationOperation.onboardingImport,
          ownerLabel: 'onboarding-first-run',
          action: _startImportAndGraphBuild,
        );
    if (operationId == null) {
      return;
    }
    await _verifyAndCompleteInstallation(
      operationId: operationId,
      completionStatus: OnboardingStatus.complete,
    );
  }

  Future<OnboardingOperationId?> _startImportAndGraphBuild() async {
    ref
        .read(appLoggerProvider.notifier)
        .info(
          'Starting fresh onboarding conversation graph build',
          source: 'OnboardingGate',
        );

    // Gate 2 safety check: verify we can still read chat.db before
    // committing to the import.  If FDA was revoked after the earlier
    // check, fall back to the FDA screen.
    if (!ref.read(onboardingFullDiskAccessProvider)) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Aborting fresh onboarding import because Messages database is no longer readable',
            source: 'OnboardingGate',
          );
      _clearWorkflowOverride();
      state = OnboardingStatus.awaitingFda;
      return null;
    }

    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final operationId = await operationController.begin(
      kind: OnboardingOperationKind.initialImport,
      initialStage: OnboardingOperationStage.environmentPreparation,
    );

    _setWorkflowOverride(OnboardingStatus.importing);
    await _waitForEndOfFrame();
    try {
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.environmentPreparation,
        failureCategory:
            OnboardingOperationFailureCategory.environmentPreparation,
        action: (_) => _prepareForFreshStartIfNeeded(),
      );
    } catch (error, stackTrace) {
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Fresh onboarding preparation failed',
      );
      return null;
    }

    // ── Graph build phase ──
    _setWorkflowOverride(OnboardingStatus.buildingGraph);
    await _waitForEndOfFrame();
    try {
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.messageDataBuild,
        failureCategory: OnboardingOperationFailureCategory.messageDataBuild,
        action: (_) =>
            _runConversationGraphBuild(owner: 'onboarding-first-run'),
      );
    } catch (error) {
      await _recordConversationGraphBuildFailure(error);
      _finishFirstRunWithFailure();
      return null;
    }

    ref
        .read(appLoggerProvider.notifier)
        .info(
          'Fresh onboarding conversation graph build completed successfully',
          source: 'OnboardingGate',
        );

    await operationController.enterStage(
      operationId: operationId,
      stage: OnboardingOperationStage.durableReadinessVerification,
    );
    return operationId;
  }

  /// Wait until the current frame has finished painting.
  ///
  /// Unlike [Future.delayed] with [Duration.zero] (which fires between
  /// microtasks, before the frame pipeline), this uses
  /// [WidgetsBinding.addPostFrameCallback] to guarantee that layout and
  /// paint have completed — meaning any widgets that depend on our state
  /// change have already mounted and started watching providers.
  Future<void> _waitForEndOfFrame() {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
  }

  /// Open System Settings to the Full Disk Access pane.
  Future<void> openFdaSettings() async {
    await ref.read(fullDiskAccessProvider).openSettings();
  }

  void refreshEnvironment() {
    _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
    _automaticRecoverySuppressed = false;
    _clearWorkflowOverride();
    ref.invalidate(onboardingFullDiskAccessProvider);
    ref.invalidate(onboardingEnvironmentReportProvider);
    ref.invalidateSelf();
  }

  /// Trigger a full reimport from settings.
  ///
  /// Unlike [startImportAndGraphBuild], this can be called when the app is
  /// already running with populated databases.  It shows the same
  /// progress overlay but uses the reimport-specific status values so the UI
  /// can distinguish first-run from settings-triggered graph rebuild.
  Future<void> startReimport() async {
    if (state != OnboardingStatus.notNeeded) {
      return;
    }

    final operationId = await ref
        .read(archiveMutationCoordinatorProvider.notifier)
        .run<OnboardingOperationId?>(
          operation: ArchiveMutationOperation.onboardingImport,
          ownerLabel: 'settings-reimport',
          action: _startReimport,
        );
    if (operationId == null) {
      return;
    }
    await _verifyAndCompleteInstallation(
      operationId: operationId,
      completionStatus: OnboardingStatus.reimportComplete,
    );
  }

  Future<OnboardingOperationId?> _startReimport() async {
    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final operationId = await operationController.begin(
      kind: OnboardingOperationKind.reimport,
      initialStage: OnboardingOperationStage.environmentPreparation,
    );
    // Clean out previous derived graph/import data so the build reimports
    // everything from the live source while preserving overlays and archive
    // files.
    try {
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.environmentPreparation,
        failureCategory:
            OnboardingOperationFailureCategory.environmentPreparation,
        action: (_) =>
            ref.read(messageDataResetServiceProvider).resetDerivedData(),
      );
    } catch (error, stackTrace) {
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Settings reimport preparation failed',
      );
      return null;
    }

    // ── Graph rebuild phase ──
    _setWorkflowOverride(OnboardingStatus.reimporting);
    await _waitForEndOfFrame();
    _setWorkflowOverride(OnboardingStatus.reimportBuildingGraph);
    await _waitForEndOfFrame();
    try {
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.messageDataBuild,
        failureCategory: OnboardingOperationFailureCategory.messageDataBuild,
        action: (_) => _runConversationGraphBuild(owner: 'settings-reimport'),
      );
    } catch (error) {
      await _recordConversationGraphBuildFailure(error);
      _finishReimportWithFailure();
      return null;
    }

    await operationController.enterStage(
      operationId: operationId,
      stage: OnboardingOperationStage.durableReadinessVerification,
    );
    return operationId;
  }

  /// Dismiss the overlay and switch to the Messages sidebar.
  ///
  /// Deferred to the next frame so the [ModalBarrier] in the overlay is not
  /// removed during an active gesture callback (avoids the
  /// `!_debugDuringDeviceUpdate` assertion in mouse_tracker.dart).
  void dismiss() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearWorkflowOverride();
      ref
          .read(activeSidebarModeProvider.notifier)
          .setMode(SidebarMode.messages);
      state = OnboardingStatus.notNeeded;
    });
  }

  void _setWorkflowOverride(OnboardingStatus status) {
    _workflowOverrideStatus = status;
    state = status;
  }

  void _clearWorkflowOverride() {
    _workflowOverrideStatus = null;
  }

  void _maybeTriggerAutomaticRecovery(OnboardingEnvironmentReport report) {
    if (_workflowOverrideStatus == OnboardingStatus.preparationFailed) {
      return;
    }

    if (!report.shouldResetAppDatabasesBeforeImport) {
      _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
      _automaticRecoverySuppressed = false;
      return;
    }

    if (_automaticRecoveryInFlight || _automaticRecoverySuppressed) {
      return;
    }

    _automaticRecoveryInFlight = true;
    _automaticRecoverySuppressed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runAutomaticRecovery(report));
    });
  }

  void _handleEnvironmentReport(OnboardingEnvironmentReport report) {
    if (_automaticRecoveryDeferral ==
        _AutomaticRecoveryDeferral.awaitingFreshEnvironment) {
      _automaticRecoveryDeferral = _AutomaticRecoveryDeferral.none;
      _automaticRecoverySuppressed = false;
    }
    _maybeTriggerAutomaticRecovery(report);
  }

  Future<void> _runAutomaticRecovery(OnboardingEnvironmentReport report) async {
    final coordinator = ref.read(archiveMutationCoordinatorProvider.notifier);
    final logger = ref.read(appLoggerProvider.notifier);
    try {
      await coordinator.run<void>(
        operation: ArchiveMutationOperation.automaticRecovery,
        ownerLabel: 'onboarding-automatic-recovery',
        action: () => _runAdmittedAutomaticRecovery(report),
      );
    } on ArchiveMutationDeniedException catch (error) {
      _automaticRecoveryInFlight = false;
      _automaticRecoverySuppressed = true;
      _automaticRecoveryDeferral =
          _AutomaticRecoveryDeferral.waitingForMutationRelease;
      _clearWorkflowOverride();
      logger.warn(
        'Deferred automatic onboarding recovery because archive mutation authority is busy: $error',
        source: 'OnboardingGate',
      );
      if (!_mutationCoordinatorIsLocked) {
        _requestFreshEnvironmentAfterMutation();
      }
    } catch (error, stackTrace) {
      _automaticRecoveryInFlight = false;
      _automaticRecoverySuppressed = true;
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Automatic onboarding recovery admission failed',
      );
    }
  }

  Future<void> _runAdmittedAutomaticRecovery(
    OnboardingEnvironmentReport report,
  ) async {
    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    final operationId = await operationController.begin(
      kind: OnboardingOperationKind.automaticRecovery,
      initialStage: OnboardingOperationStage.automaticRecoveryReset,
    );
    try {
      _setWorkflowOverride(OnboardingStatus.recoveringFailedAttempt);
      await _waitForEndOfFrame();
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Auto-resetting app databases before onboarding retry: ${report.resetAppDatabasesReason ?? 'no reason provided'}',
            source: 'OnboardingGate',
          );
      await operationController.runStage<void>(
        operationId: operationId,
        stage: OnboardingOperationStage.automaticRecoveryReset,
        failureCategory:
            OnboardingOperationFailureCategory.environmentPreparation,
        action: (_) =>
            ref.read(messageDataResetServiceProvider).resetDerivedData(),
      );
      await operationController.complete(
        operationId: operationId,
        proof: OnboardingDerivedResetCompletedProof(
          verifiedAtUtc: DateTime.now().toUtc(),
        ),
      );
    } catch (error, stackTrace) {
      _automaticRecoveryInFlight = false;
      _automaticRecoverySuppressed = true;
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Automatic onboarding DB reset failed',
      );
      return;
    }

    _automaticRecoveryInFlight = false;
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    ref.invalidateSelf();
    state = OnboardingStatus.awaitingUserAction;
  }

  void _handleMutationLockChanged(bool? previous, bool next) {
    _mutationCoordinatorIsLocked = next;
    final mutationAuthorityJustBecameIdle = previous == true && !next;
    if (!mutationAuthorityJustBecameIdle ||
        _automaticRecoveryDeferral !=
            _AutomaticRecoveryDeferral.waitingForMutationRelease) {
      return;
    }

    _requestFreshEnvironmentAfterMutation();
  }

  void _requestFreshEnvironmentAfterMutation() {
    if (_automaticRecoveryDeferral !=
        _AutomaticRecoveryDeferral.waitingForMutationRelease) {
      return;
    }

    // Claim this release event before invalidating so the lifecycle listener
    // and denial catch cannot request duplicate evaluations. The denied report
    // is discarded; the next provider result is the only recovery authority.
    _automaticRecoveryDeferral =
        _AutomaticRecoveryDeferral.awaitingFreshEnvironment;
    ref.invalidate(onboardingEnvironmentReportProvider);
  }

  void _enterPreparationFailure({
    required Object error,
    required StackTrace stackTrace,
    required String logMessage,
  }) {
    _automaticRecoverySuppressed = true;
    ref
        .read(appLoggerProvider.notifier)
        .error(
          '$logMessage: $error',
          source: 'OnboardingGate',
          context: {'stackTrace': stackTrace.toString()},
        );
    _setWorkflowOverride(OnboardingStatus.preparationFailed);
  }

  Future<void> _prepareForFreshStartIfNeeded() async {
    final report = ref.read(onboardingEnvironmentReportProvider).valueOrNull;
    if (report?.shouldResetAppDatabasesBeforeImport ?? false) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Preparing for fresh onboarding start by resetting app databases',
            source: 'OnboardingGate',
            context: {'reason': report?.resetAppDatabasesReason},
          );
      await ref.read(messageDataResetServiceProvider).resetDerivedData();
      ref.invalidate(onboardingEnvironmentReportProvider);
      return;
    }

    ref
        .read(appLoggerProvider.notifier)
        .info(
          'Preparing for fresh onboarding start by deleting derived databases',
          source: 'OnboardingGate',
        );
    await ref.read(messageDataResetServiceProvider).resetDerivedData();
  }

  Future<void> _runConversationGraphBuild({required String owner}) async {
    await ref
        .read(conversationGraphBuildControllerProvider.notifier)
        .runOnce(owner: owner);
    await _clearConversationGraphBuildFailure();
  }

  Future<void> _recordConversationGraphBuildFailure(Object error) async {
    final storage = ref.read(onboardingFailureStorageProvider);
    await storage.saveGraphProjectionFailure(
      message: 'Conversation graph build failed: $error',
      recordedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _clearConversationGraphBuildFailure() async {
    final storage = ref.read(onboardingFailureStorageProvider);
    await storage.clearGraphProjectionFailure();
  }

  Future<void> _verifyAndCompleteInstallation({
    required OnboardingOperationId operationId,
    required OnboardingStatus completionStatus,
  }) async {
    final operationController = await ref.read(
      onboardingOperationControllerProvider.future,
    );
    try {
      final proof = await ref
          .read(onboardingDurableCompletionVerifierProvider)
          .verifyInstallationReady();
      await operationController.complete(
        operationId: operationId,
        proof: proof,
      );
      _setWorkflowOverride(completionStatus);
    } catch (error, stackTrace) {
      if (operationController.current.status ==
              OnboardingOperationStatus.running &&
          operationController.current.operationId == operationId) {
        await operationController.fail(
          operationId: operationId,
          category:
              OnboardingOperationFailureCategory.durableReadinessVerification,
          summary: error.toString(),
          recoveryDisposition:
              OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
        );
      }
      _enterPreparationFailure(
        error: error,
        stackTrace: stackTrace,
        logMessage: 'Durable onboarding completion verification failed',
      );
    }
  }

  void _finishFirstRunWithFailure() {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Fresh onboarding conversation graph build failed; returning to awaiting user action',
          source: 'OnboardingGate',
        );
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    _setWorkflowOverride(OnboardingStatus.awaitingUserAction);
  }

  void _finishReimportWithFailure() {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Settings-triggered reimport failed; returning to awaiting user action',
          source: 'OnboardingGate',
        );
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    _setWorkflowOverride(OnboardingStatus.awaitingUserAction);
  }
}
