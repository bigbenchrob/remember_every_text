import '../../presentation/view_model/recent_chats_provider.dart';

enum ConversationBrowserFilter { all, groups, singles, withAttachments }

enum ConversationBrowserSort {
  mostRecent,
  largestMessageCount,
  largestParticipantCount,
}

class ConversationBrowserModel {
  const ConversationBrowserModel({
    required this.totalConversationCount,
    required this.visibleConversationCount,
    required this.groupConversationCount,
    required this.singleConversationCount,
    required this.zeroParticipantConversationCount,
    required this.zeroMessageConversationCount,
    required this.attachmentConversationCount,
    required this.largestParticipantCount,
    required this.largestMessageCount,
    required this.conversations,
  });

  final int totalConversationCount;
  final int visibleConversationCount;
  final int groupConversationCount;
  final int singleConversationCount;
  final int zeroParticipantConversationCount;
  final int zeroMessageConversationCount;
  final int attachmentConversationCount;
  final int largestParticipantCount;
  final int largestMessageCount;
  final List<RecentChatSummary> conversations;
}

class ConversationBrowserIntegrator {
  const ConversationBrowserIntegrator();

  ConversationBrowserModel build({
    required List<RecentChatSummary> conversations,
    required ConversationBrowserFilter filter,
    required ConversationBrowserSort sort,
    String includeParticipantsQuery = '',
    String excludeParticipantsQuery = '',
  }) {
    final includeTerms = _parseTerms(includeParticipantsQuery);
    final excludeTerms = _parseTerms(excludeParticipantsQuery);
    final visibleConversations = conversations
        .where((conversation) => _matchesFilter(conversation, filter))
        .where(
          (conversation) =>
              _matchesAllParticipantTerms(conversation, includeTerms),
        )
        .where(
          (conversation) =>
              !_matchesAnyParticipantTerm(conversation, excludeTerms),
        )
        .toList(growable: false);
    visibleConversations.sort((left, right) => _compare(left, right, sort));

    return ConversationBrowserModel(
      totalConversationCount: conversations.length,
      visibleConversationCount: visibleConversations.length,
      groupConversationCount: conversations
          .where((conversation) => conversation.isGroup)
          .length,
      singleConversationCount: conversations
          .where((conversation) => !conversation.isGroup)
          .length,
      zeroParticipantConversationCount: conversations
          .where((conversation) => conversation.participants.isEmpty)
          .length,
      zeroMessageConversationCount: conversations
          .where((conversation) => conversation.messageCount == 0)
          .length,
      attachmentConversationCount: conversations
          .where((conversation) => conversation.attachmentCount > 0)
          .length,
      largestParticipantCount: conversations.fold<int>(
        0,
        (largest, conversation) => conversation.participants.length > largest
            ? conversation.participants.length
            : largest,
      ),
      largestMessageCount: conversations.fold<int>(
        0,
        (largest, conversation) => conversation.messageCount > largest
            ? conversation.messageCount
            : largest,
      ),
      conversations: List.unmodifiable(visibleConversations),
    );
  }

  bool _matchesFilter(
    RecentChatSummary conversation,
    ConversationBrowserFilter filter,
  ) {
    return switch (filter) {
      ConversationBrowserFilter.all => true,
      ConversationBrowserFilter.groups => conversation.isGroup,
      ConversationBrowserFilter.singles => !conversation.isGroup,
      ConversationBrowserFilter.withAttachments =>
        conversation.attachmentCount > 0,
    };
  }

  List<String> _parseTerms(String query) {
    return query
        .split(RegExp(r'[\s,]+'))
        .map((term) => term.trim().toLowerCase())
        .where((term) => term.isNotEmpty)
        .toList(growable: false);
  }

  bool _matchesAllParticipantTerms(
    RecentChatSummary conversation,
    List<String> terms,
  ) {
    return terms.every(
      (term) => _participantSearchValues(
        conversation,
      ).any((value) => value.contains(term)),
    );
  }

  bool _matchesAnyParticipantTerm(
    RecentChatSummary conversation,
    List<String> terms,
  ) {
    return terms.any(
      (term) => _participantSearchValues(
        conversation,
      ).any((value) => value.contains(term)),
    );
  }

  List<String> _participantSearchValues(RecentChatSummary conversation) {
    return <String>[
      ...conversation.participants,
      ...conversation.handles,
    ].map((value) => value.toLowerCase()).toList(growable: false);
  }

  int _compare(
    RecentChatSummary left,
    RecentChatSummary right,
    ConversationBrowserSort sort,
  ) {
    final primary = switch (sort) {
      ConversationBrowserSort.mostRecent => _compareNullableDatesDescending(
        left.lastMessageDate,
        right.lastMessageDate,
      ),
      ConversationBrowserSort.largestMessageCount =>
        right.messageCount.compareTo(left.messageCount),
      ConversationBrowserSort.largestParticipantCount =>
        right.participants.length.compareTo(left.participants.length),
    };
    if (primary != 0) {
      return primary;
    }
    return left.chatId.compareTo(right.chatId);
  }

  int _compareNullableDatesDescending(DateTime? left, DateTime? right) {
    if (left == null && right == null) {
      return 0;
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }
    return right.compareTo(left);
  }
}

String conversationBrowserFilterLabel(ConversationBrowserFilter filter) {
  return switch (filter) {
    ConversationBrowserFilter.all => 'All conversations',
    ConversationBrowserFilter.groups => 'Groups',
    ConversationBrowserFilter.singles => 'Singles',
    ConversationBrowserFilter.withAttachments => 'With attachments',
  };
}

String conversationBrowserSortLabel(ConversationBrowserSort sort) {
  return switch (sort) {
    ConversationBrowserSort.mostRecent => 'Most recent',
    ConversationBrowserSort.largestMessageCount => 'Largest message count',
    ConversationBrowserSort.largestParticipantCount =>
      'Largest participant count',
  };
}
