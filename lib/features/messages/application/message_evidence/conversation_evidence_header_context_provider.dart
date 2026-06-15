import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../../contacts/feature_level_providers.dart';

part 'conversation_evidence_header_context_provider.g.dart';

class ConversationEvidenceHeaderContext {
  const ConversationEvidenceHeaderContext({
    required this.conversationId,
    required this.title,
    required this.messageCount,
    this.firstMessageAtUtc,
    this.lastMessageAtUtc,
  });

  final int conversationId;
  final String title;
  final int messageCount;
  final String? firstMessageAtUtc;
  final String? lastMessageAtUtc;
}

@riverpod
Future<ConversationEvidenceHeaderContext?> conversationEvidenceHeaderContext(
  Ref ref, {
  required int conversationId,
}) async {
  final overviews = await ref.watch(
    conversationOverviewsProvider(limit: 1000).future,
  );
  final identityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );

  final overview = _overviewForConversation(overviews, conversationId);
  if (overview == null) {
    return null;
  }

  final displayIdentity = identityResolver.resolveConversationFromHandles(
    conversationId: overview.conversationId,
    handles: overview.participantHandles,
  );
  return ConversationEvidenceHeaderContext(
    conversationId: overview.conversationId,
    title: displayIdentity.title,
    messageCount: overview.messageCount,
    firstMessageAtUtc: overview.firstMessageAtUtc,
    lastMessageAtUtc: overview.lastMessageAtUtc,
  );
}

ConversationOverview? _overviewForConversation(
  List<ConversationOverview> overviews,
  int conversationId,
) {
  for (final overview in overviews) {
    if (overview.conversationId == conversationId) {
      return overview;
    }
  }
  return null;
}
