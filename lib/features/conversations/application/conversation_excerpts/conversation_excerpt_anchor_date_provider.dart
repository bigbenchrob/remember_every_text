import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/feature_level_providers.dart'
    show messageGraphReaderProvider;

part 'conversation_excerpt_anchor_date_provider.g.dart';

/// Reads the graph fact used to orient a Conversation excerpt in time.
@riverpod
Future<DateTime?> conversationExcerptAnchorDate(
  Ref ref, {
  required int conversationId,
  required int anchorMessageId,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  final message = await reader.readGlobalMessageById(
    messageId: anchorMessageId,
  );
  if (message == null) {
    return null;
  }
  if (message.conversationId case final messageConversationId?
      when messageConversationId != conversationId) {
    return null;
  }
  final value = message.dateUtc;
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
