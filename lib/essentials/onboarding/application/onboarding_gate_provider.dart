import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../conversation_graph/application/conversation_graph_build_controller_provider.dart';
import '../../db/database_directory.dart';
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/feature_level_providers.dart'
    show SidebarMode, activeSidebarModeProvider;
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_status.dart';
import 'database_existence_checker.dart';
import 'full_disk_access_provider.dart';
import 'message_data_reset_service.dart';
import 'onboarding_database_probe_reader_provider.dart';
import 'onboarding_environment_report_provider.dart';
import 'onboarding_failure_storage_provider.dart';

part 'onboarding_gate_provider.g.dart';

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
  OnboardingStatus? _lastLoggedResolvedStatus;
  OnboardingEnvironmentState? _lastLoggedEnvironmentState;
  OnboardingBlockerKind? _lastLoggedBlockerKind;
  bool? _lastLoggedHasPopulatedAppDatabases;

  @override
  OnboardingStatus build() {
    final reportAsync = ref.watch(onboardingEnvironmentReportProvider);
    reportAsync.whenData(_maybeTriggerAutomaticRecovery);

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
      OnboardingEnvironmentState.ready => OnboardingStatus.notNeeded,
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
    final hasData = checker.hasPopulatedDatabases(databaseDirectoryPath);
    if (hasData) {
      return OnboardingStatus.notNeeded;
    }

    return OnboardingStatus.awaitingUserAction;
  }

  /// Kick off the source-scoped conversation graph build.
  ///
  /// Wrapped in try/catch so the user is never stranded.
  Future<void> startImportAndGraphBuild() async {
    if (state != OnboardingStatus.awaitingUserAction) {
      return;
    }

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
      state = OnboardingStatus.awaitingFda;
      return;
    }

    await _prepareForFreshStartIfNeeded();

    // ── Graph build phase ──
    _setWorkflowOverride(OnboardingStatus.importing);
    await _waitForEndOfFrame();
    _setWorkflowOverride(OnboardingStatus.buildingGraph);
    await _waitForEndOfFrame();
    try {
      await _runConversationGraphBuild(owner: 'onboarding-first-run');
    } catch (error) {
      await _recordConversationGraphBuildFailure(error);
      _finishFirstRunWithFailure();
      return;
    }

    ref
        .read(appLoggerProvider.notifier)
        .info(
          'Fresh onboarding conversation graph build completed successfully',
          source: 'OnboardingGate',
        );

    _setWorkflowOverride(OnboardingStatus.complete);
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
    _automaticRecoverySuppressed = false;
    _clearWorkflowOverride();
    ref.invalidate(onboardingFullDiskAccessProvider);
    ref.invalidate(onboardingEnvironmentReportProvider);
    ref.invalidateSelf();
  }

  /// Abort the in-progress import, delete the partially-created database
  /// files, and reset state to [OnboardingStatus.awaitingUserAction] so the
  /// next launch triggers a clean onboarding.
  Future<void> abortImport() async {
    await ref.read(messageDataResetServiceProvider).resetDerivedData();

    // Reset to awaiting so the next launch shows the welcome screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = OnboardingStatus.awaitingUserAction;
    });
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

    // Clean out previous derived graph/import data so the build reimports
    // everything from the live source while preserving overlays and archive
    // files.
    await ref.read(messageDataResetServiceProvider).resetDerivedData();

    // ── Graph rebuild phase ──
    _setWorkflowOverride(OnboardingStatus.reimporting);
    await _waitForEndOfFrame();
    _setWorkflowOverride(OnboardingStatus.reimportBuildingGraph);
    await _waitForEndOfFrame();
    try {
      await _runConversationGraphBuild(owner: 'settings-reimport');
    } catch (error) {
      await _recordConversationGraphBuildFailure(error);
      _finishReimportWithFailure();
      return;
    }

    _setWorkflowOverride(OnboardingStatus.reimportComplete);
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
    if (!report.shouldResetAppDatabasesBeforeImport) {
      _automaticRecoverySuppressed = false;
      return;
    }

    if (_automaticRecoveryInFlight || _automaticRecoverySuppressed) {
      return;
    }

    _automaticRecoveryInFlight = true;
    _automaticRecoverySuppressed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setWorkflowOverride(OnboardingStatus.recoveringFailedAttempt);
      unawaited(_runAutomaticRecovery(report));
    });
  }

  Future<void> _runAutomaticRecovery(OnboardingEnvironmentReport report) async {
    try {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Auto-resetting app databases before onboarding retry: ${report.resetAppDatabasesReason ?? 'no reason provided'}',
            source: 'OnboardingGate',
          );
      await ref.read(messageDataResetServiceProvider).resetDerivedData();
    } catch (error) {
      _automaticRecoverySuppressed = true;
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Automatic onboarding DB reset failed: $error',
            source: 'OnboardingGate',
          );
    } finally {
      _automaticRecoveryInFlight = false;
      _clearWorkflowOverride();
      ref.invalidate(onboardingEnvironmentReportProvider);
      ref.invalidateSelf();
      state = OnboardingStatus.awaitingUserAction;
    }
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
