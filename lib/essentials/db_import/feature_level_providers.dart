import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../import/domain/ports/message_extractor_port.dart';
import '../import/infrastructure/extraction/rust_message_extractor.dart';
import 'application/import/ledger_import_service.dart';

part 'feature_level_providers.g.dart';

/// Provides the Rust-backed message extractor used to decode attributed blobs
/// during the database import pipeline.
@riverpod
MessageExtractorPort dbImportMessageExtractor(Ref ref) {
  return RustMessageExtractor();
}

/// High-level service orchestrating the ingest into the Sqflite ledger.
@riverpod
LedgerImportService ledgerImportService(Ref ref) {
  return LedgerImportService(
    ref: ref,
    extractor: ref.watch(dbImportMessageExtractorProvider),
  );
}
