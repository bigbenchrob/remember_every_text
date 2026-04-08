import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/features/messages/application/strategies/ordinal_strategy.dart';
import 'package:remember_this_text/features/messages/application/timeline/ordinal/message_timeline_ordinal_provider.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  group('messageTimelineViewModelProvider', () {
    test('filters recovered scope through shared search results', () async {
      const scope = MessageTimelineScope.recovered(contactId: 7);
      final container = ProviderContainer(
        overrides: [
          messageTimelineOrdinalProvider(
            scope: scope,
          ).overrideWith(_FakeMessageTimelineOrdinal.new),
          recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
            (ref) => Stream<List<RecoveredUnlinkedMessageItem>>.value([
              RecoveredUnlinkedMessageItem(
                id: 10,
                guid: 'recovered-10',
                senderHandleId: null,
                contactName: null,
                rawItemType: null,
                rawAssociatedMessageType: null,
                semanticKind: 'plain-text',
                isSparseArtifact: false,
                isFromMe: false,
                isInferred: false,
                senderLabel: 'Alice',
                service: 'iMessage',
                text: 'alpha note',
                sentAt: DateTime(2024, 1, 10),
                itemType: 'text',
                hasAttachments: false,
                attachmentCount: 0,
                attachments: const <AttachmentInfo>[],
              ),
              RecoveredUnlinkedMessageItem(
                id: 20,
                guid: 'recovered-20',
                senderHandleId: null,
                contactName: null,
                rawItemType: null,
                rawAssociatedMessageType: null,
                semanticKind: 'plain-text',
                isSparseArtifact: false,
                isFromMe: false,
                isInferred: false,
                senderLabel: 'Bob',
                service: 'SMS',
                text: 'beta archive',
                sentAt: DateTime(2024, 2, 20),
                itemType: 'text',
                hasAttachments: true,
                attachmentCount: 1,
                attachments: const <AttachmentInfo>[
                  AttachmentInfo(
                    id: 501,
                    localPath: null,
                    mimeType: 'image/png',
                    transferName: 'receipt.png',
                  ),
                ],
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        messageTimelineViewModelProvider(scope: scope),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final provider = messageTimelineViewModelProvider(scope: scope);
      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      final searchController = container.read(provider).searchController;
      searchController.text = 'receipt';

      await Future<void>.delayed(const Duration(milliseconds: 300));

      final state = container.read(provider);
      expect(state.debouncedQuery, 'receipt');
      expect(state.searchResultIds.valueOrNull, <int>[20]);
    });

    test('returns no recovered matches when query does not match', () async {
      const scope = MessageTimelineScope.recovered(contactId: 7);
      final container = ProviderContainer(
        overrides: [
          messageTimelineOrdinalProvider(
            scope: scope,
          ).overrideWith(_FakeMessageTimelineOrdinal.new),
          recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
            (ref) => Stream<List<RecoveredUnlinkedMessageItem>>.value([
              RecoveredUnlinkedMessageItem(
                id: 30,
                guid: 'recovered-30',
                senderHandleId: null,
                contactName: null,
                rawItemType: null,
                rawAssociatedMessageType: null,
                semanticKind: 'plain-text',
                isSparseArtifact: false,
                isFromMe: false,
                isInferred: false,
                senderLabel: 'Charlie',
                service: 'iMessage',
                text: 'gamma record',
                sentAt: DateTime(2024, 3, 10),
                itemType: 'text',
                hasAttachments: false,
                attachmentCount: 0,
                attachments: const <AttachmentInfo>[],
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        messageTimelineViewModelProvider(scope: scope),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final provider = messageTimelineViewModelProvider(scope: scope);
      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      final searchController = container.read(provider).searchController;
      searchController.text = 'missing';

      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(container.read(provider).searchResultIds.valueOrNull, isEmpty);
    });
  });
}

class _FakeMessageTimelineOrdinal extends MessageTimelineOrdinal {
  @override
  Future<MessageTimelineOrdinalState> build({
    required MessageTimelineScope scope,
  }) async {
    return MessageTimelineOrdinalState(
      scope: scope,
      totalCount: 0,
      itemScrollController: ItemScrollController(),
      itemPositionsListener: ItemPositionsListener.create(),
      strategy: _FakeOrdinalStrategy(),
    );
  }
}

class _FakeOrdinalStrategy implements OrdinalStrategy {
  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) async {
    return null;
  }

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) async {
    return null;
  }

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) async {
    return null;
  }

  @override
  Future<String?> getMonthKeyByOrdinal(int ordinal) async {
    return null;
  }

  @override
  Future<int?> getOrdinalForMessage(int messageId) async {
    return null;
  }

  @override
  Future<int> getTotalCount() async {
    return 0;
  }
}
