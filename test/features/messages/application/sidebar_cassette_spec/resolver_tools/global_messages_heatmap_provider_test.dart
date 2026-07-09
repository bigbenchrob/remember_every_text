import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/resolver_tools/global_messages_heatmap_provider.dart';

void main() {
  test(
    'global messages heatmap can be derived from graph message timeline',
    () async {
      final container = ProviderContainer(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(
              repository: _FakeMessageGraphRepository(
                timeline: [
                  ConversationMessageTimelineEntry(
                    messageId: 1,
                    dateUtc: '2026-04-10T10:00:00.000Z',
                    monthKey: '2026-04',
                  ),
                  ConversationMessageTimelineEntry(
                    messageId: 2,
                    dateUtc: '2026-04-11T10:00:00.000Z',
                    monthKey: '2026-04',
                  ),
                  ConversationMessageTimelineEntry(
                    messageId: 3,
                    dateUtc: '2026-06-10T10:00:00.000Z',
                    monthKey: '2026-06',
                  ),
                ],
              ),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final timeline = await container.read(
        globalMessagesHeatmapProvider.future,
      );

      final months = {
        for (final row in timeline!.yearRows)
          for (final month in row.months)
            '${month.year}-${month.month}': month.messageCount,
      };
      expect(timeline.totalMessages, 3);
      expect(timeline.maxMonthCount, 2);
      expect(timeline.firstMessageDate.month, 4);
      expect(timeline.lastMessageDate.month, 6);
      expect(months['2026-4'], 2);
      expect(months['2026-5'], 0);
      expect(months['2026-6'], 1);
    },
  );
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  const _FakeMessageGraphRepository({required this.timeline});

  final List<ConversationMessageTimelineEntry> timeline;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    return timeline;
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
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    return null;
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
  Future<List<ConversationMessageTimelineEntry>>
  readConversationExcerptTimeline({
    required int conversationId,
    required int anchorMessageId,
    required int beforeCount,
    required int afterCount,
  }) async {
    return const <ConversationMessageTimelineEntry>[];
  }
}
