import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/features/messages/application/conversation_timeline/conversation_timeline_integrator.dart';

void main() {
  test('derives counts, order, and day groups from graph messages', () {
    final timeline = const ConversationTimelineIntegrator().build(
      overview: null,
      messages: const [
        ConversationMessage(
          messageId: 3,
          dateUtc: '2026-05-20T10:00:00.000Z',
          isFromMe: true,
          text: 'newest',
          associatedMessageId: 1,
        ),
        ConversationMessage(
          messageId: 2,
          dateUtc: '2026-05-19T10:00:00.000Z',
          isFromMe: false,
          text: null,
          associatedMessageId: null,
        ),
        ConversationMessage(
          messageId: 1,
          dateUtc: '2026-05-18T10:00:00.000Z',
          isFromMe: false,
          text: 'oldest',
          associatedMessageId: null,
        ),
      ],
      filter: ConversationTimelineFilter.all,
      order: ConversationTimelineOrder.oldestFirst,
    );

    expect(timeline.totalLoadedMessageCount, 3);
    expect(timeline.visibleMessageCount, 3);
    expect(timeline.textMessageCount, 2);
    expect(timeline.noTextMessageCount, 1);
    expect(timeline.fromMeMessageCount, 1);
    expect(timeline.receivedMessageCount, 2);
    expect(timeline.associatedMessageCount, 1);
    expect(timeline.groups.map((group) => group.dayLabel), [
      '2026-05-18',
      '2026-05-19',
      '2026-05-20',
    ]);
    expect(timeline.groups.first.messages.single.messageId, 1);
  });

  test('filters without hiding anomalous rows by default', () {
    const messages = [
      ConversationMessage(
        messageId: 1,
        dateUtc: null,
        isFromMe: false,
        text: null,
        associatedMessageId: null,
      ),
      ConversationMessage(
        messageId: 2,
        dateUtc: null,
        isFromMe: true,
        text: 'hello',
        associatedMessageId: 1,
      ),
    ];

    final allTimeline = const ConversationTimelineIntegrator().build(
      overview: null,
      messages: messages,
      filter: ConversationTimelineFilter.all,
      order: ConversationTimelineOrder.newestFirst,
    );
    final noTextTimeline = const ConversationTimelineIntegrator().build(
      overview: null,
      messages: messages,
      filter: ConversationTimelineFilter.noText,
      order: ConversationTimelineOrder.newestFirst,
    );
    final associatedTimeline = const ConversationTimelineIntegrator().build(
      overview: null,
      messages: messages,
      filter: ConversationTimelineFilter.associatedOnly,
      order: ConversationTimelineOrder.newestFirst,
    );

    expect(allTimeline.visibleMessageCount, 2);
    expect(noTextTimeline.visibleMessageCount, 1);
    expect(noTextTimeline.groups.single.messages.single.messageId, 1);
    expect(associatedTimeline.visibleMessageCount, 1);
    expect(associatedTimeline.groups.single.messages.single.messageId, 2);
  });
}
