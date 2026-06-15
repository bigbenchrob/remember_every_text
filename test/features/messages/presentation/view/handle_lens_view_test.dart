import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart';
import 'package:remember_this_text/features/handles/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_lens_view.dart';

void main() {
  testWidgets('renders unfamiliar-source evidence with one unified header', (
    tester,
  ) async {
    const handleId = 12;
    const handleValue = '1 (604) 307-8325';
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2020-06-22T17:04:00.000Z',
          monthKey: '2020-06',
        ),
      ],
      hydratedMessage: ConversationMessage(
        messageId: 1,
        dateUtc: '2020-06-22T17:04:00.000Z',
        isFromMe: true,
        text: 'Please forward the information.',
        associatedMessageId: null,
        attachmentCount: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          strayHandlesProvider.overrideWith((ref) async {
            return [
              StrayHandleSummary(
                handleId: handleId,
                handleValue: handleValue,
                serviceType: 'SMS',
                totalMessages: 243,
                lastMessageDate: DateTime.utc(2020, 6, 22),
              ),
            ];
          }),
          handleDisplayNameProvider(handleId: handleId).overrideWith((
            ref,
          ) async {
            return handleValue;
          }),
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: const MacosApp(home: HandleLensView(handleId: handleId)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unfamiliar source'), findsOneWidget);
    expect(find.text(handleValue), findsOneWidget);
    expect(find.text('Message evidence'), findsNothing);
    expect(find.textContaining('Handle scope'), findsNothing);
    expect(find.textContaining('Last:'), findsNothing);
    expect(find.text('SMS'), findsNothing);
    expect(find.text('Create Contact'), findsOneWidget);
    expect(find.text('Link to Existing'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
    expect(find.text('Please forward the information.'), findsOneWidget);
  });

  testWidgets('uses raw handle while semantic display name is loading', (
    tester,
  ) async {
    const handleId = 12;
    const handleValue = '1 (604) 307-8325';
    final displayNameCompleter = Completer<String>();
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2020-06-22T17:04:00.000Z',
          monthKey: '2020-06',
        ),
      ],
      hydratedMessage: ConversationMessage(
        messageId: 1,
        dateUtc: '2020-06-22T17:04:00.000Z',
        isFromMe: true,
        text: 'Please forward the information.',
        associatedMessageId: null,
        attachmentCount: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          strayHandlesProvider.overrideWith((ref) async {
            return [
              StrayHandleSummary(
                handleId: handleId,
                handleValue: handleValue,
                serviceType: 'SMS',
                totalMessages: 243,
                lastMessageDate: DateTime.utc(2020, 6, 22),
              ),
            ];
          }),
          handleDisplayNameProvider(handleId: handleId).overrideWith((ref) {
            return displayNameCompleter.future;
          }),
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: const MacosApp(home: HandleLensView(handleId: handleId)),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(handleValue), findsOneWidget);
    expect(find.text('Handle #$handleId'), findsNothing);
  });
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  const _FakeMessageGraphRepository({
    required this.timeline,
    required this.hydratedMessage,
  });

  final List<ConversationMessageTimelineEntry> timeline;
  final ConversationMessage hydratedMessage;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readGlobalMessageById({
    required int messageId,
  }) async {
    return null;
  }

  @override
  Future<List<int>> readGlobalMessageIdsMatchingText({
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return const <int>[];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  }) async {
    return timeline;
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    return hydratedMessage.messageId == messageId ? hydratedMessage : null;
  }

  @override
  Future<List<int>> readHandleMessageIdsMatchingText({
    required int handleId,
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return const <int>[];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readMessageContextTimeline({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) async {
    return const <ConversationMessageTimelineEntry>[];
  }
}
