import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../../contacts/feature_level_providers.dart';

part 'recent_chats_provider.g.dart';

/// Lightweight view model describing the data needed for the recent chats list.
class RecentChatSummary {
  const RecentChatSummary({
    required this.chatId,
    required this.title,
    required this.messageCount,
    required this.attachmentCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.isGroup,
    required this.participants,
    required this.handles,
    this.lastMessagePreview,
  });

  final int chatId;
  final String title;
  final int messageCount;
  final int attachmentCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final bool isGroup;
  final List<String> participants;
  final List<String> handles;
  final String? lastMessagePreview;
}

@riverpod
Future<List<RecentChatSummary>> recentChats(Ref ref, {int? limit}) async {
  return readGraphRecentChats(ref, limit: limit);
}

Future<List<RecentChatSummary>> readGraphRecentChats(
  Ref ref, {
  int? limit,
}) async {
  final overviews = await ref.watch(
    conversationOverviewsProvider(limit: limit ?? 100).future,
  );
  final identityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  return _mapGraphOverviews(overviews, identityResolver);
}

List<RecentChatSummary> _mapGraphOverviews(
  List<ConversationOverview> overviews,
  DisplayIdentityResolver identityResolver,
) {
  return [
    for (final overview in overviews)
      _mapGraphOverview(overview, identityResolver),
  ];
}

RecentChatSummary _mapGraphOverview(
  ConversationOverview overview,
  DisplayIdentityResolver identityResolver,
) {
  final lastMessageDate = _parseGraphUtc(overview.lastMessageAtUtc);
  final firstMessageDate = _parseGraphUtc(overview.firstMessageAtUtc);
  final displayIdentity = identityResolver.resolveConversationFromHandles(
    conversationId: overview.conversationId,
    handles: overview.participantHandles,
  );
  final participantLabels = displayIdentity.participantLabels;
  return RecentChatSummary(
    chatId: overview.conversationId,
    title: displayIdentity.title,
    messageCount: overview.messageCount,
    attachmentCount: overview.attachmentCount,
    firstMessageDate: firstMessageDate,
    lastMessageDate: lastMessageDate,
    isGroup: overview.isGroup,
    participants: participantLabels.isEmpty
        ? const ['Unknown Contact']
        : participantLabels,
    handles: overview.participantHandles,
    lastMessagePreview: overview.lastMessageText,
  );
}

DateTime? _parseGraphUtc(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}
