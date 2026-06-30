import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/conversation_graph/feature_level_providers.dart'
    show contactPageGraphSnapshotProvider;
import 'conversation_signature_display_provider.dart';

part 'contact_conversation_signatures_provider.g.dart';

@riverpod
Future<List<ConversationSignatureDisplayModel>> contactConversationSignatures(
  Ref ref, {
  required int contactId,
}) async {
  final snapshot = await ref.watch(
    contactPageGraphSnapshotProvider(contactId: contactId).future,
  );
  final conversationIds = [
    for (final conversation in snapshot.conversations)
      conversation.conversationId,
  ];
  if (conversationIds.isEmpty) {
    return const <ConversationSignatureDisplayModel>[];
  }

  return ref.watch(
    conversationSignatureDisplayByIdsProvider(
      request: ConversationSignatureDisplayByIdsRequest(
        conversationIds: conversationIds,
      ),
    ).future,
  );
}
