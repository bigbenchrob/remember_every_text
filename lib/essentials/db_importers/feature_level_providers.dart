import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logging/application/app_logger.dart';
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
