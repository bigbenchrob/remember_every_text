import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/chats/application/conversation_browser/conversation_browser_integrator.dart';
import 'package:remember_this_text/features/chats/presentation/view_model/recent_chats_provider.dart';

void main() {
  test('derives counts and filters conversations', () {
    final model = const ConversationBrowserIntegrator().build(
      conversations: [
        _summary(id: 1, participants: ['+1'], messageCount: 10),
        _summary(
          id: 2,
          participants: ['+1', '+2'],
          messageCount: 20,
          attachmentCount: 3,
        ),
        _summary(id: 3, participants: ['+1', '+2', '+3'], messageCount: 5),
      ],
      filter: ConversationBrowserFilter.groups,
      sort: ConversationBrowserSort.mostRecent,
    );

    expect(model.totalConversationCount, 3);
    expect(model.visibleConversationCount, 2);
    expect(model.groupConversationCount, 2);
    expect(model.singleConversationCount, 1);
    expect(model.zeroParticipantConversationCount, 0);
    expect(model.zeroMessageConversationCount, 0);
    expect(model.attachmentConversationCount, 1);
    expect(model.largestParticipantCount, 3);
    expect(model.largestMessageCount, 20);
    expect(model.conversations.map((conversation) => conversation.chatId), [
      2,
      3,
    ]);
  });

  test('filters conversations with attachments', () {
    final model = const ConversationBrowserIntegrator().build(
      conversations: [
        _summary(id: 1, participants: ['+1'], messageCount: 10),
        _summary(
          id: 2,
          participants: ['+1', '+2'],
          messageCount: 20,
          attachmentCount: 2,
        ),
      ],
      filter: ConversationBrowserFilter.withAttachments,
      sort: ConversationBrowserSort.mostRecent,
    );

    expect(model.visibleConversationCount, 1);
    expect(model.conversations.single.chatId, 2);
  });

  test('sorts by message and participant counts', () {
    final conversations = [
      _summary(id: 1, participants: ['+1'], messageCount: 10),
      _summary(id: 2, participants: ['+1', '+2'], messageCount: 20),
      _summary(id: 3, participants: ['+1', '+2', '+3'], messageCount: 5),
    ];

    final byMessages = const ConversationBrowserIntegrator().build(
      conversations: conversations,
      filter: ConversationBrowserFilter.all,
      sort: ConversationBrowserSort.largestMessageCount,
    );
    final byParticipants = const ConversationBrowserIntegrator().build(
      conversations: conversations,
      filter: ConversationBrowserFilter.all,
      sort: ConversationBrowserSort.largestParticipantCount,
    );

    expect(
      byMessages.conversations.map((conversation) => conversation.chatId),
      [2, 1, 3],
    );
    expect(
      byParticipants.conversations.map((conversation) => conversation.chatId),
      [3, 2, 1],
    );
  });

  test('does not treat preview text or graph ids as user-facing search', () {
    final conversations = [
      _summary(
        id: 101,
        participants: ['+15551'],
        messageCount: 10,
        preview: 'airport pickup',
      ),
      _summary(
        id: 202,
        participants: ['cathie@example.com'],
        messageCount: 20,
        preview: 'dinner',
      ),
      _summary(id: 303, participants: [], messageCount: 0, preview: null),
    ];

    final byHandle = const ConversationBrowserIntegrator().build(
      conversations: conversations,
      filter: ConversationBrowserFilter.all,
      sort: ConversationBrowserSort.mostRecent,
      includeParticipantsQuery: 'cathie',
    );
    final byPreview = const ConversationBrowserIntegrator().build(
      conversations: conversations,
      filter: ConversationBrowserFilter.all,
      sort: ConversationBrowserSort.mostRecent,
      includeParticipantsQuery: 'airport',
    );
    final byId = const ConversationBrowserIntegrator().build(
      conversations: conversations,
      filter: ConversationBrowserFilter.all,
      sort: ConversationBrowserSort.mostRecent,
      includeParticipantsQuery: '303',
    );

    expect(byHandle.conversations.single.chatId, 202);
    expect(byPreview.conversations, isEmpty);
    expect(byId.conversations, isEmpty);
    expect(byId.zeroParticipantConversationCount, 1);
    expect(byId.zeroMessageConversationCount, 1);
  });

  test(
    'builds conversation sets with include and exclude participant terms',
    () {
      final conversations = [
        _summary(
          id: 101,
          participants: ['claire@example.com', 'rusung@example.com'],
          messageCount: 10,
        ),
        _summary(
          id: 202,
          participants: [
            'claire@example.com',
            'rusung@example.com',
            'scot@example.com',
          ],
          messageCount: 20,
        ),
        _summary(
          id: 303,
          participants: ['claire@example.com'],
          messageCount: 30,
        ),
      ];

      final model = const ConversationBrowserIntegrator().build(
        conversations: conversations,
        filter: ConversationBrowserFilter.all,
        sort: ConversationBrowserSort.mostRecent,
        includeParticipantsQuery: 'claire, rusung',
        excludeParticipantsQuery: 'scot',
      );

      expect(model.conversations.map((conversation) => conversation.chatId), [
        101,
      ]);
    },
  );

  test('matches multiple participant fragments separated by whitespace', () {
    final conversations = [
      _summary(
        id: 101,
        participants: ['cathie.campbell@gmail.com', '+17789908506'],
        messageCount: 10,
      ),
      _summary(
        id: 202,
        participants: ['cathie.campbell@gmail.com'],
        messageCount: 20,
      ),
      _summary(id: 303, participants: ['+17789908506'], messageCount: 30),
    ];

    final model = const ConversationBrowserIntegrator().build(
      conversations: conversations,
      filter: ConversationBrowserFilter.all,
      sort: ConversationBrowserSort.mostRecent,
      includeParticipantsQuery: 'cathie 17789908506',
    );

    expect(model.conversations.map((conversation) => conversation.chatId), [
      101,
    ]);
  });
}

RecentChatSummary _summary({
  required int id,
  required List<String> participants,
  required int messageCount,
  int attachmentCount = 0,
  String? preview,
}) {
  return RecentChatSummary(
    chatId: id,
    title: participants.join(' and '),
    messageCount: messageCount,
    attachmentCount: attachmentCount,
    firstMessageDate: null,
    lastMessageDate: DateTime.utc(2026, 5, 20).subtract(Duration(days: id)),
    isGroup: participants.length > 1,
    participants: participants,
    handles: participants,
    calendarHeatmapTimelineData: null,
    lastMessagePreview: preview ?? 'preview $id',
  );
}
