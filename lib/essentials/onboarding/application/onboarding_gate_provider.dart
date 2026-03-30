import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart'
    show databaseDirectoryPath, sqfliteImportDatabaseProvider;
import '../../db/feature_level_providers/message_data_version_provider.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../../navigation/application/sidebar_mode_provider.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../domain/onboarding_environment_report.dart';
import '../domain/onboarding_status.dart';
import 'database_existence_checker.dart';
import 'fda_checker.dart';
import 'onboarding_environment_report_provider.dart';

part 'onboarding_gate_provider.g.dart';

/// Controls the onboarding overlay lifecycle.
///
/// Gate 1 — Full Disk Access:
/// On [build], checks whether the app can read `~/Library/Messages/chat.db`.
/// If not, exposes [OnboardingStatus.awaitingFda] so the FDA instruction
/// screen is shown.  Nothing else can proceed until FDA is confirmed.
///
/// Gate 2 — Data import:
/// Once FDA is confirmed, checks whether both import and working databases
/// exist with data.  If not, exposes [OnboardingStatus.awaitingUserAction]
/// so the import overlay appears.
///
/// [startImportAndMigration] delegates to [DbImportControlViewModel] and
/// watches its state to transition through importing → migrating → complete.
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  static const _checker = DatabaseExistenceChecker();
  static const _fdaChecker = FdaChecker();
  OnboardingStatus? _workflowOverrideStatus;

  @override
  OnboardingStatus build() {
    final reportAsync = ref.watch(onboardingEnvironmentReportProvider);

    return resolveBuildStatus(
      reportAsync: reportAsync,
      workflowOverrideStatus: _workflowOverrideStatus,
      fallbackBuildStatus: _fallbackBuildStatus,
    );
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
      OnboardingEnvironmentState.migrationFailed ||
      OnboardingEnvironmentState.sourceUnavailable ||
      OnboardingEnvironmentState.sourceSparseOrUnsynced ||
      OnboardingEnvironmentState.readyToImport =>
        OnboardingStatus.awaitingUserAction,
    };
  }

  static bool _shouldPreserveWorkflowOverride(OnboardingStatus? status) {
    return switch (status) {
      OnboardingStatus.importing ||
      OnboardingStatus.migrating ||
      OnboardingStatus.complete ||
      OnboardingStatus.reimporting ||
      OnboardingStatus.reimportMigrating ||
      OnboardingStatus.reimportComplete => true,
      null ||
      OnboardingStatus.awaitingFda ||
      OnboardingStatus.awaitingUserAction ||
      OnboardingStatus.notNeeded => false,
    };
  }

  OnboardingStatus _fallbackBuildStatus() {
    if (!_fdaChecker.canReadMessagesDatabase()) {
      return OnboardingStatus.awaitingFda;
    }

    final hasData = _checker.hasPopulatedDatabases(databaseDirectoryPath);
    if (hasData) {
      return OnboardingStatus.notNeeded;
    }

    return OnboardingStatus.awaitingUserAction;
  }

  /// Kick off the full import + migration pipeline.
  ///
  /// Calls [startImport] then [startMigration] separately so the overlay
  /// can show the correct phase, and passes `skipImportCheck: true` to
  /// prevent the recursive-loop bug in startMigration's unimported-data
  /// guard. Wrapped in try/catch so the user is **never** stranded.
  Future<void> startImportAndMigration() async {
    if (state != OnboardingStatus.awaitingUserAction) {
      return;
    }

    // Gate 2 safety check: verify we can still read chat.db before
    // committing to the import.  If FDA was revoked after the earlier
    // check, fall back to the FDA screen.
    if (!_fdaChecker.canReadMessagesDatabase()) {
      state = OnboardingStatus.awaitingFda;
      return;
    }

    // Remove stale import DB files from a previous failed or aborted run
    // so the pipeline starts from a clean slate.
    await _deleteImportDatabaseFiles();

    // ── Import phase ──
    _setWorkflowOverride(OnboardingStatus.importing);
    // Wait until the frame has actually painted so the overlay's
    // _ProgressContent widget is mounted and ref.watch-ing
    // dbImportControlViewModelProvider.  A plain Future.delayed(Duration.zero)
    // fires before the frame pipeline, which means the widget isn't
    // watching yet and the auto-dispose provider may be a stale instance.
    await _waitForEndOfFrame();
    try {
      await ref.read(dbImportControlViewModelProvider.notifier).startImport();
    } catch (_) {
      _finishFirstRunWithFailure();
      return;
    }

    final importSucceeded =
        ref.read(dbImportControlViewModelProvider).lastImportResult?.success ??
        false;
    if (!importSucceeded) {
      _finishFirstRunWithFailure();
      return;
    }

    // ── Migration phase ──
    _setWorkflowOverride(OnboardingStatus.migrating);
    await _waitForEndOfFrame();
    try {
      await ref
          .read(dbImportControlViewModelProvider.notifier)
          .startMigration(skipImportCheck: true);
    } catch (_) {
      _finishFirstRunWithFailure();
      return;
    }

    final migrationSucceeded =
        ref
            .read(dbImportControlViewModelProvider)
            .lastMigrationResult
            ?.success ??
        false;
    if (!migrationSucceeded) {
      _finishFirstRunWithFailure();
      return;
    }

    // Signal all data-dependent providers (contacts, messages, etc.) to
    // rebuild with the freshly-populated working database.
    ref.read(messageDataVersionProvider.notifier).bump();

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
    await FdaChecker.openFdaSettings();
  }

  void refreshEnvironment() {
    _clearWorkflowOverride();
    ref.invalidate(onboardingFullDiskAccessProvider);
    ref.invalidate(onboardingEnvironmentReportProvider);
    ref.invalidateSelf();
  }

  /// Abort the in-progress import, delete the partially-created database
  /// files, and reset state to [OnboardingStatus.awaitingUserAction] so the
  /// next launch triggers a clean onboarding.
  Future<void> abortImport() async {
    // Delete import and working DB files (plus WAL/SHM companions).
    for (final name in ['macos_import.db', 'working.db']) {
      final basePath = path.join(databaseDirectoryPath, name);
      for (final suffix in ['', '-wal', '-shm']) {
        final file = File('$basePath$suffix');
        if (file.existsSync()) {
          await file.delete();
        }
      }
    }

    // Reset to awaiting so the next launch shows the welcome screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = OnboardingStatus.awaitingUserAction;
    });
  }

  /// Trigger a full reimport from settings.
  ///
  /// Unlike [startImportAndMigration], this can be called when the app is
  /// already running with populated databases.  It shows the same
  /// progress overlay but uses the reimport-specific status values so the
  /// UI can distinguish first-run from settings-triggered reimport.
  Future<void> startReimport() async {
    if (state != OnboardingStatus.notNeeded) {
      return;
    }

    // Clean out the previous import DB so the pipeline reimports everything.
    await _deleteImportDatabaseFiles();

    // ── Import phase ──
    _setWorkflowOverride(OnboardingStatus.reimporting);
    await _waitForEndOfFrame();
    try {
      await ref.read(dbImportControlViewModelProvider.notifier).startImport();
    } catch (_) {
      _setWorkflowOverride(OnboardingStatus.reimportComplete);
      return;
    }

    // ── Migration phase ──
    _setWorkflowOverride(OnboardingStatus.reimportMigrating);
    await _waitForEndOfFrame();
    try {
      await ref
          .read(dbImportControlViewModelProvider.notifier)
          .startMigration(skipImportCheck: true);
    } catch (_) {
      // Swallow — land on complete so user can dismiss.
    }

    ref.read(messageDataVersionProvider.notifier).bump();

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

  void _finishFirstRunWithFailure() {
    _clearWorkflowOverride();
    ref.invalidate(onboardingEnvironmentReportProvider);
    state = OnboardingStatus.awaitingUserAction;
  }

  /// Close any open import DB connection, delete the files, and
  /// invalidate the provider so the next access creates a fresh instance.
  Future<void> _deleteImportDatabaseFiles() async {
    // Close an existing connection if the provider was already accessed.
    try {
      final ledgerDb = await ref.read(sqfliteImportDatabaseProvider.future);
      await ledgerDb.close();
    } catch (_) {
      // No connection open — safe to proceed.
    }
    ref.invalidate(sqfliteImportDatabaseProvider);

    // Delete the file and WAL/SHM companions.
    final basePath = path.join(databaseDirectoryPath, 'macos_import.db');
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('$basePath$suffix');
      if (file.existsSync()) {
        await file.delete();
      }
    }
    ref.invalidate(sqfliteImportDatabaseProvider);
  }
}
