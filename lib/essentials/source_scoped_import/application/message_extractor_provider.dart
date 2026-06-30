import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../domain/ports/message_extractor_port.dart';
import '../infrastructure/extraction/rust_message_extractor.dart';

part 'message_extractor_provider.g.dart';

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
