import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../application/conversation_timeline/conversation_timeline_integrator.dart';

class ConversationMessagesPreviewView extends ConsumerStatefulWidget {
  const ConversationMessagesPreviewView({
    required this.conversationId,
    super.key,
  });

  final int conversationId;

  @override
  ConsumerState<ConversationMessagesPreviewView> createState() =>
      _ConversationMessagesPreviewViewState();
}

class _ConversationMessagesPreviewViewState
    extends ConsumerState<ConversationMessagesPreviewView> {
  var _messageLimit = 100;
  var _timelineOrder = ConversationTimelineOrder.oldestFirst;
  var _timelineFilter = ConversationTimelineFilter.all;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      conversationMessagesProvider(
        conversationId: widget.conversationId,
        limit: _messageLimit,
      ),
    );
    final overviewsAsync = ref.watch(
      conversationOverviewsProvider(limit: 1000),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: messagesAsync.when(
        data: (messages) => _ConversationMessagesTimeline(
          conversationId: widget.conversationId,
          overview: _overviewForConversation(
            overviewsAsync.valueOrNull,
            widget.conversationId,
          ),
          messages: messages,
          messageLimit: _messageLimit,
          timelineOrder: _timelineOrder,
          timelineFilter: _timelineFilter,
          onMessageLimitChanged: (value) {
            setState(() {
              _messageLimit = value;
            });
          },
          onTimelineOrderChanged: (value) {
            setState(() {
              _timelineOrder = value;
            });
          },
          onTimelineFilterChanged: (value) {
            setState(() {
              _timelineFilter = value;
            });
          },
        ),
        loading: () =>
            const Center(child: Text('Loading conversation graph messages...')),
        error: (error, stackTrace) =>
            Center(child: Text('Conversation graph timeline failed: $error')),
      ),
    );
  }

  ConversationOverview? _overviewForConversation(
    List<ConversationOverview>? overviews,
    int conversationId,
  ) {
    if (overviews == null) {
      return null;
    }
    for (final overview in overviews) {
      if (overview.conversationId == conversationId) {
        return overview;
      }
    }
    return null;
  }
}

class _ConversationMessagesTimeline extends StatelessWidget {
  const _ConversationMessagesTimeline({
    required this.conversationId,
    required this.overview,
    required this.messages,
    required this.messageLimit,
    required this.timelineOrder,
    required this.timelineFilter,
    required this.onMessageLimitChanged,
    required this.onTimelineOrderChanged,
    required this.onTimelineFilterChanged,
  });

  final int conversationId;
  final ConversationOverview? overview;
  final List<ConversationMessage> messages;
  final int messageLimit;
  final ConversationTimelineOrder timelineOrder;
  final ConversationTimelineFilter timelineFilter;
  final ValueChanged<int> onMessageLimitChanged;
  final ValueChanged<ConversationTimelineOrder> onTimelineOrderChanged;
  final ValueChanged<ConversationTimelineFilter> onTimelineFilterChanged;

  @override
  Widget build(BuildContext context) {
    final timeline = const ConversationTimelineIntegrator().build(
      overview: overview,
      messages: messages,
      filter: timelineFilter,
      order: timelineOrder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineHeader(
          conversationId: conversationId,
          timeline: timeline,
          messageLimit: messageLimit,
          timelineOrder: timelineOrder,
          timelineFilter: timelineFilter,
          onMessageLimitChanged: onMessageLimitChanged,
          onTimelineOrderChanged: onTimelineOrderChanged,
          onTimelineFilterChanged: onTimelineFilterChanged,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: timeline.visibleMessageCount == 0
              ? const Center(
                  child: Text('No messages match this conversation filter.'),
                )
              : ListView(children: _buildGroupedRows(timeline.groups)),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedRows(List<ConversationTimelineDayGroup> groups) {
    final rows = <Widget>[];
    for (final group in groups) {
      rows.add(_DayDivider(label: group.dayLabel));
      for (final message in group.messages) {
        rows.add(_ConversationMessageRow(message: message));
      }
    }
    return rows;
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({
    required this.conversationId,
    required this.timeline,
    required this.messageLimit,
    required this.timelineOrder,
    required this.timelineFilter,
    required this.onMessageLimitChanged,
    required this.onTimelineOrderChanged,
    required this.onTimelineFilterChanged,
  });

  final int conversationId;
  final ConversationTimelineModel timeline;
  final int messageLimit;
  final ConversationTimelineOrder timelineOrder;
  final ConversationTimelineFilter timelineFilter;
  final ValueChanged<int> onMessageLimitChanged;
  final ValueChanged<ConversationTimelineOrder> onTimelineOrderChanged;
  final ValueChanged<ConversationTimelineFilter> onTimelineFilterChanged;

  @override
  Widget build(BuildContext context) {
    final overview = timeline.overview;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        border: Border.all(color: const Color(0x22000000)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversation graph timeline',
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('conversationId: $conversationId'),
            if (overview != null) ...[
              Text('participants: ${overview.participantHandles.join(' | ')}'),
              Text(
                'participant count: ${overview.participantCount} | '
                '${overview.isGroup ? 'group' : 'single'}',
              ),
              Text('conversation message count: ${overview.messageCount}'),
            ],
            Text('loaded messages: ${timeline.totalLoadedMessageCount}'),
            Text('visible messages: ${timeline.visibleMessageCount}'),
            Text(
              'text-bearing: ${timeline.textMessageCount} | '
              'no text: ${timeline.noTextMessageCount}',
            ),
            Text(
              'from me: ${timeline.fromMeMessageCount} | '
              'received: ${timeline.receivedMessageCount} | '
              'associated: ${timeline.associatedMessageCount}',
            ),
            Text('filter: ${conversationTimelineFilterLabel(timelineFilter)}'),
            Text('order: ${conversationTimelineOrderLabel(timelineOrder)}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceButton(
                  label: 'Latest 100',
                  isSelected: messageLimit == 100,
                  onPressed: () => onMessageLimitChanged(100),
                ),
                _ChoiceButton(
                  label: 'Latest 500',
                  isSelected: messageLimit == 500,
                  onPressed: () => onMessageLimitChanged(500),
                ),
                _ChoiceButton(
                  label: 'Oldest first',
                  isSelected:
                      timelineOrder == ConversationTimelineOrder.oldestFirst,
                  onPressed: () => onTimelineOrderChanged(
                    ConversationTimelineOrder.oldestFirst,
                  ),
                ),
                _ChoiceButton(
                  label: 'Newest first',
                  isSelected:
                      timelineOrder == ConversationTimelineOrder.newestFirst,
                  onPressed: () => onTimelineOrderChanged(
                    ConversationTimelineOrder.newestFirst,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in ConversationTimelineFilter.values)
                  _ChoiceButton(
                    label: conversationTimelineFilterLabel(filter),
                    isSelected: timelineFilter == filter,
                    onPressed: () => onTimelineFilterChanged(filter),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F0FF) : const Color(0xFFFFFFFF),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E6BD6)
                : const Color(0x33000000),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(label),
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        label,
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ConversationMessageRow extends StatelessWidget {
  const _ConversationMessageRow({required this.message});

  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    final text = message.text;
    final direction = message.isFromMe ? 'from me' : 'received';
    final associatedMessageId = message.associatedMessageId;

    return Align(
      alignment: message.isFromMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: message.isFromMe
                  ? const Color(0xFFEAF3FF)
                  : const Color(0xFFFFFFFF),
              border: Border.all(color: const Color(0x22000000)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${message.messageId} | ${message.dateUtc ?? 'no date'} | '
                    '$direction',
                    style: DefaultTextStyle.of(
                      context,
                    ).style.copyWith(fontSize: 12),
                  ),
                  if (associatedMessageId != null)
                    Text('associatedMessageId: $associatedMessageId'),
                  const SizedBox(height: 4),
                  Text(_hasText(text) ? text! : 'no text'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _hasText(String? value) {
  return value != null && value.isNotEmpty;
}
