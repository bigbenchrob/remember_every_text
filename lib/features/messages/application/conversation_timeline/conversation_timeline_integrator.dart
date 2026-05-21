import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';

enum ConversationTimelineFilter {
  all,
  textOnly,
  noText,
  fromMe,
  received,
  associatedOnly,
}

enum ConversationTimelineOrder { oldestFirst, newestFirst }

class ConversationTimelineModel {
  const ConversationTimelineModel({
    required this.overview,
    required this.totalLoadedMessageCount,
    required this.visibleMessageCount,
    required this.textMessageCount,
    required this.noTextMessageCount,
    required this.fromMeMessageCount,
    required this.receivedMessageCount,
    required this.associatedMessageCount,
    required this.groups,
  });

  final ConversationOverview? overview;
  final int totalLoadedMessageCount;
  final int visibleMessageCount;
  final int textMessageCount;
  final int noTextMessageCount;
  final int fromMeMessageCount;
  final int receivedMessageCount;
  final int associatedMessageCount;
  final List<ConversationTimelineDayGroup> groups;
}

class ConversationTimelineDayGroup {
  const ConversationTimelineDayGroup({
    required this.dayLabel,
    required this.messages,
  });

  final String dayLabel;
  final List<ConversationMessage> messages;
}

class ConversationTimelineIntegrator {
  const ConversationTimelineIntegrator();

  ConversationTimelineModel build({
    required ConversationOverview? overview,
    required List<ConversationMessage> messages,
    required ConversationTimelineFilter filter,
    required ConversationTimelineOrder order,
  }) {
    final orderedMessages = order == ConversationTimelineOrder.oldestFirst
        ? messages.reversed.toList(growable: false)
        : messages;
    final visibleMessages = orderedMessages
        .where((message) => _matchesFilter(message, filter))
        .toList(growable: false);

    return ConversationTimelineModel(
      overview: overview,
      totalLoadedMessageCount: messages.length,
      visibleMessageCount: visibleMessages.length,
      textMessageCount: messages
          .where((message) => _hasText(message.text))
          .length,
      noTextMessageCount: messages
          .where((message) => !_hasText(message.text))
          .length,
      fromMeMessageCount: messages.where((message) => message.isFromMe).length,
      receivedMessageCount: messages
          .where((message) => !message.isFromMe)
          .length,
      associatedMessageCount: messages
          .where((message) => message.associatedMessageId != null)
          .length,
      groups: _groupByDay(visibleMessages),
    );
  }

  bool _matchesFilter(
    ConversationMessage message,
    ConversationTimelineFilter filter,
  ) {
    return switch (filter) {
      ConversationTimelineFilter.all => true,
      ConversationTimelineFilter.textOnly => _hasText(message.text),
      ConversationTimelineFilter.noText => !_hasText(message.text),
      ConversationTimelineFilter.fromMe => message.isFromMe,
      ConversationTimelineFilter.received => !message.isFromMe,
      ConversationTimelineFilter.associatedOnly =>
        message.associatedMessageId != null,
    };
  }

  List<ConversationTimelineDayGroup> _groupByDay(
    List<ConversationMessage> messages,
  ) {
    final groups = <ConversationTimelineDayGroup>[];
    var currentDay = '';
    var currentMessages = <ConversationMessage>[];

    for (final message in messages) {
      final day = _dayLabel(message.dateUtc);
      if (currentMessages.isNotEmpty && day != currentDay) {
        groups.add(
          ConversationTimelineDayGroup(
            dayLabel: currentDay,
            messages: List.unmodifiable(currentMessages),
          ),
        );
        currentMessages = <ConversationMessage>[];
      }
      currentDay = day;
      currentMessages.add(message);
    }

    if (currentMessages.isNotEmpty) {
      groups.add(
        ConversationTimelineDayGroup(
          dayLabel: currentDay,
          messages: List.unmodifiable(currentMessages),
        ),
      );
    }

    return List.unmodifiable(groups);
  }
}

String conversationTimelineFilterLabel(ConversationTimelineFilter filter) {
  return switch (filter) {
    ConversationTimelineFilter.all => 'All',
    ConversationTimelineFilter.textOnly => 'Text',
    ConversationTimelineFilter.noText => 'No text',
    ConversationTimelineFilter.fromMe => 'From me',
    ConversationTimelineFilter.received => 'Received',
    ConversationTimelineFilter.associatedOnly => 'Associated',
  };
}

String conversationTimelineOrderLabel(ConversationTimelineOrder order) {
  return switch (order) {
    ConversationTimelineOrder.oldestFirst => 'oldest to newest',
    ConversationTimelineOrder.newestFirst => 'newest to oldest',
  };
}

String _dayLabel(String? dateUtc) {
  if (dateUtc == null || dateUtc.isEmpty) {
    return 'No date';
  }
  final parsed = DateTime.tryParse(dateUtc);
  if (parsed == null) {
    return 'Invalid date';
  }
  final year = parsed.year.toString().padLeft(4, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

bool _hasText(String? value) {
  return value != null && value.isNotEmpty;
}
