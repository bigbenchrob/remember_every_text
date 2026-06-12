import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logging/application/app_logger.dart';
import 'domain/ports/import_ledger_port.dart';
import 'domain/ports/message_extractor_port.dart';
import 'domain/ports/source_database_port.dart';
import 'infrastructure/extraction/rust_message_extractor.dart';
import 'infrastructure/import_database_provider.dart';
import 'infrastructure/source_database/sqflite_source_database.dart';

part 'feature_level_providers.g.dart';

/// Provides the Rust-backed attributed-body extractor used by source-scoped
/// message enrichment and archive import.
@riverpod
MessageExtractorPort sourceScopedMessageExtractor(Ref ref) {
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

@riverpod
SourceDatabaseOpener sourceDatabaseOpener(Ref ref) {
  return const SqfliteSourceDatabaseOpener();
}

@riverpod
Future<ImportLedger> sourceScopedImportLedger(Ref ref) async {
  return ref.watch(importDatabaseProvider.future);
}

/// Provides concrete source-scoped import database access for graph projection
/// infrastructure that still needs import-ledger queries not yet modeled by a
/// narrower port.
@riverpod
Future<ImportDatabase> sourceScopedImportDatabase(Ref ref) async {
  return ref.watch(importDatabaseProvider.future);
}

const sourceScopedImportDatabaseFileName = importDatabaseFileName;
