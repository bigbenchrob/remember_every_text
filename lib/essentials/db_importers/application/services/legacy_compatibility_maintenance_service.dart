import '../../../db_migrate/domain/entities/db_migration_result.dart';
import '../../domain/entities/db_import_result.dart';

typedef LegacyCompatibilityImportRunner =
    Future<DbImportResult> Function({
      required String executionOwner,
      required bool forceFullReimport,
    });
typedef LegacyCompatibilityMigrationRunner =
    Future<DbMigrationResult> Function({required bool incrementalMode});
typedef LegacyCompatibilityLogCallback =
    void Function(
      String message, {
      String? source,
      Map<String, dynamic>? context,
    });

class LegacyCompatibilityMaintenanceService {
  const LegacyCompatibilityMaintenanceService({
    required this.runImport,
    required this.runMigration,
    required this.logInfo,
    required this.logWarn,
  });

  final LegacyCompatibilityImportRunner runImport;
  final LegacyCompatibilityMigrationRunner runMigration;
  final LegacyCompatibilityLogCallback logInfo;
  final LegacyCompatibilityLogCallback logWarn;

  Future<void> runAfterGraphUpdate({
    required String executionOwner,
    required bool forceFullReimport,
    required DateTime updateStartedAt,
    required int newMessageCount,
  }) async {
    DbImportResult? importResult;
    Object? importError;
    StackTrace? importStackTrace;
    try {
      importResult = await runImport(
        executionOwner: executionOwner,
        forceFullReimport: forceFullReimport,
      );
    } catch (error, stackTrace) {
      importError = error;
      importStackTrace = stackTrace;
    }

    final successfulImportResult = importResult != null && importResult.success
        ? importResult
        : null;
    if (successfulImportResult != null) {
      logInfo(
        _buildImportSummaryLog(
          timestamp: updateStartedAt,
          newMessageCount: newMessageCount,
          importResult: successfulImportResult,
        ),
        source: 'ChatDbMonitor',
      );
      logInfo(
        'Conversation graph build complete. Running legacy migration for compatibility maintenance',
        source: 'ChatDbMonitor',
      );
      await _runLegacyMigration(
        updateStartedAt: updateStartedAt,
        importResult: successfulImportResult,
      );
    } else if (importResult != null) {
      logWarn(
        'Legacy compatibility import failed after graph update: ${importResult.error}',
        source: 'ChatDbMonitor',
      );
    } else {
      logWarn(
        'Legacy compatibility import threw after graph update: $importError',
        source: 'ChatDbMonitor',
        context: {'stackTrace': '$importStackTrace'},
      );
    }
  }

  Future<void> _runLegacyMigration({
    required DateTime updateStartedAt,
    required DbImportResult importResult,
  }) async {
    try {
      final migrationResult = await runMigration(incrementalMode: true);

      if (migrationResult.success) {
        logInfo(
          _buildMigrationSummaryLog(
            startedAt: updateStartedAt,
            completedAt: DateTime.now(),
            importResult: importResult,
            migrationResult: migrationResult,
          ),
          source: 'ChatDbMonitor',
        );
      } else {
        logWarn(
          'Legacy compatibility migration failed after graph update: ${migrationResult.error}',
          source: 'ChatDbMonitor',
        );
      }
    } catch (error, stackTrace) {
      logWarn(
        'Legacy compatibility migration threw after graph update: $error',
        source: 'ChatDbMonitor',
        context: {'stackTrace': '$stackTrace'},
      );
    }
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
