import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db_migrate/feature_level_providers.dart';
import '../logging/application/app_logger.dart';
import 'application/services/legacy_compatibility_maintenance_service.dart';
import 'application/services/orchestrated_ledger_import_service.dart';
import 'domain/ports/message_extractor_port.dart';
import 'infrastructure/extraction/rust_message_extractor.dart';

part 'feature_level_providers.g.dart';

/// Provides the Rust-backed message extractor used to decode attributed blobs
/// during the database import pipeline.
@riverpod
MessageExtractorPort dbImportMessageExtractor(Ref ref) {
  final logger = ref.read(appLoggerProvider.notifier);
  return RustMessageExtractor(
    logInfo: (String message, {Map<String, dynamic>? context}) {
      logger.info(message, source: 'RustMessageExtractor', context: context);
    },
    logWarn: (String message, {Map<String, dynamic>? context}) {
      logger.warn(message, source: 'RustMessageExtractor', context: context);
    },
    logError: (String message, {Map<String, dynamic>? context}) {
      logger.error(message, source: 'RustMessageExtractor', context: context);
    },
  );
}

/// High-level service orchestrating the ingest into the Sqflite ledger.
@Riverpod(keepAlive: true)
OrchestratedLedgerImportService orchestratedLedgerImportService(Ref ref) {
  return OrchestratedLedgerImportService(
    ref: ref,
    extractor: ref.watch(dbImportMessageExtractorProvider),
  );
}

/// Runs the retained legacy import/migration tail after a successful graph
/// update. This is compatibility maintenance, not the app-facing success path.
@Riverpod(keepAlive: true)
LegacyCompatibilityMaintenanceService legacyCompatibilityMaintenanceService(
  Ref ref,
) {
  final logger = ref.read(appLoggerProvider.notifier);
  final importService = ref.watch(orchestratedLedgerImportServiceProvider);
  final migrationService = ref.watch(handlesMigrationServiceProvider);
  return LegacyCompatibilityMaintenanceService(
    runImport: importService.runImport,
    runMigration: migrationService.run,
    logInfo: logger.info,
    logWarn: logger.warn,
  );
}
