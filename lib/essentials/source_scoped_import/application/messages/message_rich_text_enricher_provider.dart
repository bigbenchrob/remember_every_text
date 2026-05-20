import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../../db_importers/feature_level_providers.dart';
import '../../infrastructure/import_database_provider.dart';
import 'message_rich_text_enricher.dart';

part 'message_rich_text_enricher_provider.g.dart';

@riverpod
Future<MessageRichTextEnricher> messageRichTextEnricher(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importDatabase = await ref.watch(importDatabaseProvider.future);

  return MessageRichTextEnricher(
    chatDbPath: pathsHelper.chatDBPath,
    importDatabase: importDatabase,
    extractor: ref.watch(dbImportMessageExtractorProvider),
  );
}
