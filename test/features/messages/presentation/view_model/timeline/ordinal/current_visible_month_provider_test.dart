import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/messages/application/strategies/ordinal_strategy.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/ordinal/current_visible_month_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  late WorkingDatabase db;
  late ProviderContainer container;
  late _FakeItemPositionsListener positionsListener;

  setUp(() async {
    db = WorkingDatabase(NativeDatabase.memory());
    positionsListener = _FakeItemPositionsListener([
      const ItemPosition(index: 0, itemLeadingEdge: 0, itemTrailingEdge: 0.5),
    ]);

    final chatId = await db
        .into(db.workingChats)
        .insert(WorkingChatsCompanion.insert(guid: 'chat-1'));

    final januaryMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-jan',
            chatId: chatId,
            sentAtUtc: const Value('2024-01-15T12:00:00Z'),
          ),
        );
    final februaryMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-feb',
            chatId: chatId,
            sentAtUtc: const Value('2024-02-20T18:30:00Z'),
          ),
        );

    _FakeMessageTimelineOrdinal.strategy = _FakeOrdinalStrategy({
      0: januaryMessageId,
      1: februaryMessageId,
    });
    _FakeMessageTimelineOrdinal.positionsListener = positionsListener;

    container = ProviderContainer(
      overrides: [
        driftWorkingDatabaseProvider.overrideWith((ref) async => db),
        messageTimelineOrdinalProvider(
          scope: const MessageTimelineScope.contact(contactId: 42),
        ).overrideWith(_FakeMessageTimelineOrdinal.new),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'tracks visible month from top visible ordinal via sent_at lookup',
    () async {
      const scope = MessageTimelineScope.contact(contactId: 42);
      final provider = currentVisibleMonthForScopeProvider(scope: scope);
      final subscription = container.listen<AsyncValue<String?>>(
        provider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final initialMonth = await container.read(provider.future);
      expect(initialMonth, '2024-01');

      positionsListener.setPositions([
        const ItemPosition(index: 1, itemLeadingEdge: 0, itemTrailingEdge: 0.5),
      ]);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(provider).valueOrNull, '2024-02');
    },
  );
}

class _FakeMessageTimelineOrdinal extends MessageTimelineOrdinal {
  static late OrdinalStrategy strategy;
  static late ItemPositionsListener positionsListener;

  @override
  Future<MessageTimelineOrdinalState> build({
    required MessageTimelineScope scope,
  }) async {
    return MessageTimelineOrdinalState(
      scope: scope,
      totalCount: 2,
      itemScrollController: ItemScrollController(),
      itemPositionsListener: positionsListener,
      strategy: strategy,
    );
  }
}

class _FakeOrdinalStrategy implements OrdinalStrategy {
  _FakeOrdinalStrategy(this._messageIdsByOrdinal);

  final Map<int, int> _messageIdsByOrdinal;

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) async => null;

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) async => null;

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) async {
    return _messageIdsByOrdinal[ordinal];
  }

  @override
  Future<int?> getOrdinalForMessage(int messageId) async => null;

  @override
  Future<int> getTotalCount() async => _messageIdsByOrdinal.length;
}

class _FakeItemPositionsListener implements ItemPositionsListener {
  _FakeItemPositionsListener(Iterable<ItemPosition> initialPositions)
    : _positions = ValueNotifier<Iterable<ItemPosition>>(initialPositions);

  final ValueNotifier<Iterable<ItemPosition>> _positions;

  @override
  ValueListenable<Iterable<ItemPosition>> get itemPositions => _positions;

  void setPositions(Iterable<ItemPosition> positions) {
    _positions.value = positions;
  }
}
