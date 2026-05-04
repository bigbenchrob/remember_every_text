import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../features/attachments/application/attachment_archive_service_provider.dart';
import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db_migrate/domain/entities/db_migration_result.dart';
import '../../../db_migrate/feature_level_providers.dart';
import '../../../logging/application/app_logger.dart';
import '../../domain/entities/db_import_result.dart';
import '../../feature_level_providers.dart';
import '../import_execution_gate_provider.dart';

part 'chat_db_change_monitor_provider.g.dart';

enum StartupProbeTrigger { rowIdAdvanced, ledgerCountLagging }

class StartupProbeDecision {
  const StartupProbeDecision({
    required this.shouldSchedule,
    required this.reason,
    this.trigger,
  });

  final bool shouldSchedule;
  final String reason;
  final StartupProbeTrigger? trigger;
}

@visibleForTesting
StartupProbeDecision resolveStartupProbeDecision({
  required int liveMaxRowId,
  required int? importedMaxSourceRowId,
  required int liveImportableMessageCount,
  required int importedMessageCount,
}) {
  if (importedMaxSourceRowId == null) {
    return const StartupProbeDecision(
      shouldSchedule: false,
      reason: 'no imported cursor available',
    );
  }

  if (liveMaxRowId > importedMaxSourceRowId) {
    return const StartupProbeDecision(
      shouldSchedule: true,
      trigger: StartupProbeTrigger.rowIdAdvanced,
      reason: 'live MAX(ROWID) is ahead of imported MAX(source_rowid)',
    );
  }

  if (liveImportableMessageCount > importedMessageCount) {
    return const StartupProbeDecision(
      shouldSchedule: true,
      trigger: StartupProbeTrigger.ledgerCountLagging,
      reason: 'live importable message count exceeds imported message count',
    );
  }

  return const StartupProbeDecision(
    shouldSchedule: false,
    reason: 'ledger cursor and importable message count are current',
  );
}

class ChatDbChangeMonitorState {
  const ChatDbChangeMonitorState({
    this.lastMaxRowId,
    this.lastChangeDetected,
    this.lastError,
  });

  final int? lastMaxRowId;
  final DateTime? lastChangeDetected;
  final String? lastError;

  ChatDbChangeMonitorState copyWith({
    int? lastMaxRowId,
    DateTime? lastChangeDetected,
    String? lastError,
    bool clearError = false,
  }) {
    return ChatDbChangeMonitorState(
      lastMaxRowId: lastMaxRowId ?? this.lastMaxRowId,
      lastChangeDetected: lastChangeDetected ?? this.lastChangeDetected,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatDbChangeMonitor extends _$ChatDbChangeMonitor {
  static const Duration _attachmentSweepInterval = Duration(minutes: 5);

  Timer? _debounceTimer;
  Timer? _pollingTimer;
  Timer? _attachmentSweepTimer;
  bool _importInFlight = false;
  bool _attachmentSweepInFlight = false;
  bool _pendingProbe = false;
  bool _retryWhenGateReleases = false;
  String? _chatDbPath;
  StartupProbeTrigger? _pendingProbeTrigger;

  @override
  ChatDbChangeMonitorState build() {
    if (!Platform.isMacOS) {
      return const ChatDbChangeMonitorState();
    }

    ref.listen(importExecutionGateProvider, _handleExecutionGateChange);

    unawaited(_initialize());

    ref.onDispose(() {
      _debounceTimer?.cancel();
      _pollingTimer?.cancel();
      _attachmentSweepTimer?.cancel();
    });

    return const ChatDbChangeMonitorState();
  }

  Future<void> _initialize() async {
    try {
      final pathsHelper = await ref.read(pathsHelperProvider.future);
      final chatDbPath = pathsHelper.chatDBPath;
      _chatDbPath = chatDbPath;

      await _primeMaxRowId(chatDbPath);

      // Immediate check on startup to catch messages that arrived while app was closed.
      // This ensures users don't see stale data for 15 seconds.
      await _checkForNewMessagesOnStartup(chatDbPath);

      _startPolling(chatDbPath);
      _startAttachmentSweep();
    } catch (error, stackTrace) {
      _handleError('Failed to initialize chat.db monitor: $error', stackTrace);
    }
  }

  /// Check for new messages immediately on startup.
  ///
  /// This catches the case where the app was closed for an extended period
  /// and new messages arrived. Without this, users would see stale data until
  /// the first polling interval (15 seconds).
  Future<void> _checkForNewMessagesOnStartup(String chatDbPath) async {
    try {
      final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
      final currentMaxRowId = _readMaxRowId(chatDbPath);
      final importedMaxRowId = await importDb.getMaxImportedMessageRowId();
      final liveImportableMessageCount = _readImportableMessageCount(
        chatDbPath,
      );
      final importedMessageCount = await importDb.getImportedMessageCount();
      final decision = resolveStartupProbeDecision(
        liveMaxRowId: currentMaxRowId,
        importedMaxSourceRowId: importedMaxRowId,
        liveImportableMessageCount: liveImportableMessageCount,
        importedMessageCount: importedMessageCount,
      );
      final summary =
          'Startup consistency probe: '
          'live MAX(ROWID)=$currentMaxRowId, '
          'imported MAX(source_rowid)=${importedMaxRowId ?? 'null'}, '
          'live importable count=$liveImportableMessageCount, '
          'imported message count=$importedMessageCount. '
          'Reason: ${decision.reason}.';

      if (decision.shouldSchedule && decision.trigger != null) {
        ref
            .read(appLoggerProvider.notifier)
            .info(
              '$summary Scheduling incremental import/migration.',
              source: 'ChatDbMonitor',
            );
        _scheduleProbe(trigger: decision.trigger!);
      } else {
        ref
            .read(appLoggerProvider.notifier)
            .info(
              '$summary No incremental work scheduled.',
              source: 'ChatDbMonitor',
            );
      }
    } catch (error) {
      // Non-fatal - polling will catch up
      ref
          .read(appLoggerProvider.notifier)
          .warn('Startup check failed: $error', source: 'ChatDbMonitor');
    }
  }

  Future<void> _primeMaxRowId(String chatDbPath) async {
    try {
      // CRITICAL: Prime from import.db, not chat.db!
      // This ensures we detect messages that arrived before app launch
      // but after the last import batch completed.
      final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
      final importedMaxRowId = await importDb.getMaxImportedMessageRowId();

      // Use imported max if available, otherwise fall back to chat.db
      final maxRowId = importedMaxRowId ?? _readMaxRowId(chatDbPath);
      state = state.copyWith(lastMaxRowId: maxRowId, clearError: true);
    } catch (error, stackTrace) {
      _handleError('Unable to prime MAX(ROWID): $error', stackTrace);
    }
  }

  void _startPolling(String chatDbPath) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      try {
        final currentMaxRowId = _readMaxRowId(chatDbPath);
        final previousMaxRowId = state.lastMaxRowId;

        if (previousMaxRowId != null && currentMaxRowId > previousMaxRowId) {
          _scheduleProbe(trigger: StartupProbeTrigger.rowIdAdvanced);
        }
      } catch (error) {
        // Silently continue on polling errors
      }
    });
  }

  void _startAttachmentSweep() {
    _attachmentSweepTimer = Timer.periodic(_attachmentSweepInterval, (timer) {
      unawaited(_runAttachmentSweep());
    });
  }

  Future<void> _runAttachmentSweep() async {
    if (_importInFlight || _attachmentSweepInFlight) {
      return;
    }

    final archiveProgress = ref.read(attachmentArchiveServiceProvider);
    if (archiveProgress.phase == BulkArchivePhase.running ||
        archiveProgress.phase == BulkArchivePhase.paused) {
      return;
    }

    _attachmentSweepInFlight = true;

    try {
      final archiveService = ref.read(
        attachmentArchiveServiceProvider.notifier,
      );
      final sweepResult = await archiveService.archiveNextWorkingSweepChunk();

      if (sweepResult.newlyArchived > 0 || sweepResult.failed > 0) {
        ref
            .read(appLoggerProvider.notifier)
            .info(
              'Attachment maintenance sweep completed: '
              '${sweepResult.newlyArchived} archived, '
              '${sweepResult.skipped} skipped, '
              '${sweepResult.failed} failed.',
              source: 'ChatDbMonitor',
            );
      }
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Attachment maintenance sweep failed: $error',
            source: 'ChatDbMonitor',
            context: {'stackTrace': '$stackTrace'},
          );
    } finally {
      _attachmentSweepInFlight = false;
    }
  }

  void _scheduleProbe({required StartupProbeTrigger trigger}) {
    _pendingProbe = true;
    _pendingProbeTrigger = switch ((_pendingProbeTrigger, trigger)) {
      (StartupProbeTrigger.ledgerCountLagging, _) =>
        StartupProbeTrigger.ledgerCountLagging,
      (_, StartupProbeTrigger.ledgerCountLagging) =>
        StartupProbeTrigger.ledgerCountLagging,
      _ => trigger,
    };
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(_processPendingChanges());
    });
  }

  Future<void> _processPendingChanges() async {
    if (!_pendingProbe || _importInFlight) {
      return;
    }

    final chatDbPath = _chatDbPath;
    if (chatDbPath == null) {
      _pendingProbe = false;
      return;
    }

    _importInFlight = true;
    int? attemptPreviousMaxRowId;
    DateTime? attemptDetectedAt;

    try {
      while (_pendingProbe) {
        _pendingProbe = false;
        final pendingTrigger =
            _pendingProbeTrigger ?? StartupProbeTrigger.rowIdAdvanced;
        _pendingProbeTrigger = null;

        final currentMaxRowId = _readMaxRowId(chatDbPath);
        final previousMaxRowId = state.lastMaxRowId;
        final shouldBypassRowIdGate =
            pendingTrigger == StartupProbeTrigger.ledgerCountLagging;

        if (!shouldBypassRowIdGate &&
            previousMaxRowId != null &&
            currentMaxRowId <= previousMaxRowId) {
          continue;
        }

        final now = DateTime.now();
        final updateStartedAt = DateTime.now();
        final newMessageCount = previousMaxRowId != null
            ? currentMaxRowId - previousMaxRowId
            : 0;

        attemptPreviousMaxRowId = previousMaxRowId;
        attemptDetectedAt = now;
        state = state.copyWith(lastChangeDetected: now, clearError: true);

        ref
            .read(appLoggerProvider.notifier)
            .info(
              shouldBypassRowIdGate
                  ? 'Ledger inconsistency detected: live/imported counts diverged while MAX(ROWID) remained $currentMaxRowId. Running recovery import.'
                  : 'New messages detected: $newMessageCount message(s), MAX(ROWID): $previousMaxRowId → $currentMaxRowId',
              source: 'ChatDbMonitor',
            );

        // Trigger incremental import and migration
        ref
            .read(appLoggerProvider.notifier)
            .info(
              'Triggering incremental import and migration',
              source: 'ChatDbMonitor',
            );

        final importService = ref.read(orchestratedLedgerImportServiceProvider);
        final importResult = await importService.runImport(
          executionOwner: 'chat-db-monitor',
          forceFullReimport:
              pendingTrigger == StartupProbeTrigger.ledgerCountLagging,
        );

        if (_isImportExecutionDenied(importResult)) {
          _retryWhenGateReleases = true;
          ref
              .read(appLoggerProvider.notifier)
              .debug(
                'Skipping incremental import because another import is already running',
                source: 'ChatDbMonitor',
              );
          continue;
        }

        if (importResult.success) {
          ref
              .read(appLoggerProvider.notifier)
              .info(
                _buildImportSummaryLog(
                  timestamp: updateStartedAt,
                  newMessageCount: newMessageCount,
                  importResult: importResult,
                ),
                source: 'ChatDbMonitor',
              );
          ref
              .read(appLoggerProvider.notifier)
              .info(
                'Incremental import successful. Archiving new attachments before migration',
                source: 'ChatDbMonitor',
              );
          final archiveService = ref.read(
            attachmentArchiveServiceProvider.notifier,
          );
          final archiveResult = await archiveService.archiveImportedBatch(
            batchId: importResult.batchId,
          );
          ref
              .read(appLoggerProvider.notifier)
              .info(
                'Incremental attachment archive completed: '
                '${archiveResult.newlyArchived} archived, '
                '${archiveResult.skipped} skipped, '
                '${archiveResult.failed} failed.',
                source: 'ChatDbMonitor',
              );
          ref
              .read(appLoggerProvider.notifier)
              .info(
                'Incremental batch ready. Triggering migration',
                source: 'ChatDbMonitor',
              );
          final migrationService = ref.read(handlesMigrationServiceProvider);
          final migrationResult = await migrationService.run(
            incrementalMode: true,
          );

          if (migrationResult.success) {
            final completedAt = DateTime.now();
            state = state.copyWith(
              lastMaxRowId: currentMaxRowId,
              lastChangeDetected: now,
              clearError: true,
            );
            ref
                .read(appLoggerProvider.notifier)
                .info(
                  _buildMigrationSummaryLog(
                    startedAt: updateStartedAt,
                    completedAt: completedAt,
                    importResult: importResult,
                    migrationResult: migrationResult,
                  ),
                  source: 'ChatDbMonitor',
                );
            // Signal to UI providers that new message data is available
            // This causes message list providers to rebuild with updated counts
            ref.read(messageDataVersionProvider.notifier).bump();
            // Note: Do NOT invalidate driftWorkingDatabaseProvider here!
            // It closes the isolate connection and causes "connection was closed"
            // errors for in-flight queries. Drift's reactive streams automatically
            // detect data changes via its internal watch mechanisms.
          } else {
            _handleError(
              'Incremental migration failed: ${migrationResult.error}',
              null,
            );
            _restoreStableCursor(
              previousMaxRowId: previousMaxRowId,
              detectedAt: now,
            );
          }
        } else {
          _handleError(
            'Incremental import failed: ${importResult.error}',
            null,
          );
          _restoreStableCursor(
            previousMaxRowId: previousMaxRowId,
            detectedAt: now,
          );
        }

        _retryWhenGateReleases = false;
        attemptPreviousMaxRowId = null;
        attemptDetectedAt = null;
      }
    } catch (error, stackTrace) {
      _restoreStableCursor(
        previousMaxRowId: attemptPreviousMaxRowId,
        detectedAt: attemptDetectedAt,
      );
      _handleError('Change detection failed: $error', stackTrace);
    } finally {
      _importInFlight = false;

      if (_pendingProbe) {
        unawaited(_processPendingChanges());
      }
    }
  }

  int _readMaxRowId(String chatDbPath) {
    try {
      final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final result = db.select(
          'SELECT MAX(ROWID) as max_rowid FROM message;',
        );
        if (result.isEmpty || result.first.values.isEmpty) {
          throw const FormatException('MAX(ROWID) query returned no rows');
        }
        final value = result.first.values.first;
        if (value == null) {
          return 0; // Empty table
        }
        if (value is int) {
          return value;
        }
        if (value is num) {
          return value.toInt();
        }
        return int.parse('$value');
      } finally {
        db.dispose();
      }
    } on SqliteException catch (error) {
      throw Exception('SQLite error (${error.extendedResultCode}): $error');
    }
  }

  int _readImportableMessageCount(String chatDbPath) {
    try {
      final db = sqlite3.open(chatDbPath, mode: OpenMode.readOnly);
      try {
        db.execute('PRAGMA query_only = ON;');
        db.execute('PRAGMA busy_timeout = 3000;');
        final result = db.select('''
SELECT COUNT(*) AS importable_message_count
FROM message
WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0;
''');
        if (result.isEmpty || result.first.values.isEmpty) {
          throw const FormatException(
            'importable message count query returned no rows',
          );
        }
        final value = result.first.values.first;
        if (value == null) {
          return 0;
        }
        if (value is int) {
          return value;
        }
        if (value is num) {
          return value.toInt();
        }
        return int.parse('$value');
      } finally {
        db.dispose();
      }
    } on SqliteException catch (error) {
      throw Exception(
        'SQLite error while counting importable messages (${error.extendedResultCode}): $error',
      );
    }
  }

  void _handleError(String message, StackTrace? stackTrace) {
    state = state.copyWith(lastError: message);
    ref
        .read(appLoggerProvider.notifier)
        .error(
          message,
          source: 'ChatDbMonitor',
          context: {if (stackTrace != null) 'stackTrace': '$stackTrace'},
        );
  }

  void _handleExecutionGateChange(
    ImportExecutionGateState? previous,
    ImportExecutionGateState next,
  ) {
    final gateJustReleased = previous?.owner != null && next.owner == null;
    if (!gateJustReleased || !_retryWhenGateReleases) {
      return;
    }

    _retryWhenGateReleases = false;
    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'Execution gate released. Retrying pending incremental import immediately',
          source: 'ChatDbMonitor',
        );
    _scheduleProbe(trigger: StartupProbeTrigger.rowIdAdvanced);
  }

  void _restoreStableCursor({
    required int? previousMaxRowId,
    required DateTime? detectedAt,
  }) {
    state = state.copyWith(
      lastMaxRowId: previousMaxRowId,
      lastChangeDetected: detectedAt,
    );
  }

  bool _isImportExecutionDenied(DbImportResult result) {
    final error = result.error;
    if (result.success || error == null) {
      return false;
    }

    return error.startsWith('Import is already running for ');
  }

  String _buildImportSummaryLog({
    required DateTime timestamp,
    required int newMessageCount,
    required DbImportResult importResult,
  }) {
    final timeLabel = _formatLocalClockTime(timestamp);
    return 'Incremental update at $timeLabel: '
        '$newMessageCount new source row(s) detected; '
        'import batch ${importResult.batchId} added '
        '${importResult.messagesImported} message(s), '
        '${importResult.attachmentsImported} attachment(s), and '
        '${importResult.messageAttachmentsImported} message/attachment link(s).';
  }

  String _buildMigrationSummaryLog({
    required DateTime startedAt,
    required DateTime completedAt,
    required DbImportResult importResult,
    required DbMigrationResult migrationResult,
  }) {
    final timeLabel = _formatLocalClockTime(completedAt);
    final durationMs = completedAt.difference(startedAt).inMilliseconds;
    return 'Incremental update at $timeLabel completed in ${durationMs}ms: '
        'batch ${importResult.batchId}, '
        '${importResult.messagesImported} imported message(s), '
        '${importResult.attachmentsImported} imported attachment(s), '
        '${migrationResult.messagesProjected} working message row(s), '
        '${migrationResult.attachmentsProjected} working attachment row(s).';
  }

  String _formatLocalClockTime(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
