import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../providers.dart';
import '../../feature_level_providers.dart';
import 'message_rich_text_enricher.dart';

part 'message_rich_text_enricher_provider.g.dart';

@riverpod
Future<MessageRichTextEnricher> messageRichTextEnricher(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);

  return MessageRichTextEnricher(
    chatDbPath: pathsHelper.chatDBPath,
    importLedger: importLedger,
    extractor: ref.watch(sourceScopedMessageExtractorProvider),
  );
}
