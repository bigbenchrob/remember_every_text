///***************************************************************** */
///* The entry point for dependency injection for the import feature.
///***************************************************************** */

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../databases/feature_level_providers.dart';
import 'application/debug_settings_provider.dart';
import 'application/import_service.dart';
import 'domain/ports/import_database_port.dart';
import 'domain/ports/message_extractor_port.dart';
import 'infrastructure/extraction/rust_message_extractor.dart';

///
/// Infrastructure dependencies
///
final _rustMessageExtractorProvider = Provider<MessageExtractorPort>(
  (ref) => RustMessageExtractor(),
);

///
/// Application dependencies - This is the ONLY export from this feature
///
final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService(
    importDb: ref.watch(importDatabaseProvider) as ImportDatabasePort,
    extractor: ref.watch(_rustMessageExtractorProvider),
    debugSettings: ref.watch(importDebugSettingsProvider),
  );
});
