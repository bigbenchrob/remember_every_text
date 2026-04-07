import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/messages/application/strategies/ordinal_strategy.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/ordinal/message_timeline_index_coordinator_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/ordinal/message_timeline_ordinal_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  group('MessageTimelineIndexCoordinator', () {
    test('reapplies latest jump when a contact timeline is reopened', () async {
      const scope = MessageTimelineScope.contact(contactId: 42);
      final scrollController = _FakeItemScrollController();
      final positionsListener = _FakeItemPositionsListener(
        const <ItemPosition>[],
      );
      final strategy = _FakeOrdinalStrategy(
        messageIdsByOrdinal: const <int, int>{0: 10, 1: 20, 2: 30},
        ordinalsByMessageId: const <int, int>{10: 0, 20: 1, 30: 2},
      );

      _FakeMessageTimelineOrdinal.currentState = MessageTimelineOrdinalState(
        scope: scope,
        totalCount: 3,
        itemScrollController: scrollController,
        itemPositionsListener: positionsListener,
        strategy: strategy,
      );

      final container = ProviderContainer(
        overrides: [
          messageTimelineOrdinalProvider(
            scope: scope,
          ).overrideWith(_FakeMessageTimelineOrdinal.new),
        ],
      );
      addTearDown(container.dispose);

      final provider = messageTimelineIndexCoordinatorProvider(scope: scope);
      final firstSubscription = container.listen(
        provider,
        (_, _) {},
        fireImmediately: true,
      );

      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      await container.pump();

      final firstNotifier = container.read(provider.notifier);
      firstNotifier.syncViewport();
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(scrollController.jumpCalls, [
        const _JumpCall(index: 2, alignment: 0),
      ]);

      firstSubscription.close();
      await container.pump();

      final secondSubscription = container.listen(
        provider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(secondSubscription.close);

      await container.pump();

      final secondNotifier = container.read(provider.notifier);
      secondNotifier.syncViewport();
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(scrollController.jumpCalls, [
        const _JumpCall(index: 2, alignment: 0),
        const _JumpCall(index: 2, alignment: 0),
      ]);
    });

    test('applies an initial date jump once per target', () async {
      const scope = MessageTimelineScope.recovered(contactId: 7);
      final scrollController = _FakeItemScrollController();
      final positionsListener = _FakeItemPositionsListener(
        const <ItemPosition>[],
      );
      final strategy = _FakeOrdinalStrategy(
        messageIdsByOrdinal: const <int, int>{0: 10, 1: 20, 2: 30},
        ordinalsByMessageId: const <int, int>{10: 0, 20: 1, 30: 2},
        ordinalsByDate: <String, int>{
          DateTime.utc(2024, 2, 1).toIso8601String(): 2,
        },
      );

      _FakeMessageTimelineOrdinal.currentState = MessageTimelineOrdinalState(
        scope: scope,
        totalCount: 3,
        itemScrollController: scrollController,
        itemPositionsListener: positionsListener,
        strategy: strategy,
      );

      final container = ProviderContainer(
        overrides: [
          messageTimelineOrdinalProvider(
            scope: scope,
          ).overrideWith(_FakeMessageTimelineOrdinal.new),
        ],
      );
      addTearDown(container.dispose);

      final provider = messageTimelineIndexCoordinatorProvider(scope: scope);
      final subscription = container.listen(
        provider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      await container.pump();
      expect(container.read(provider).hasOrdinalState, isTrue);

      final notifier = container.read(provider.notifier);
      notifier.syncViewport(
        scrollToDate: DateTime.utc(2024, 2, 1),
        jumpToLatestWhenNoTarget: false,
      );
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(scrollController.jumpCalls, [
        const _JumpCall(index: 2, alignment: 0),
      ]);

      notifier.syncViewport(
        scrollToDate: DateTime.utc(2024, 2, 1),
        jumpToLatestWhenNoTarget: false,
      );
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(scrollController.jumpCalls, [
        const _JumpCall(index: 2, alignment: 0),
      ]);
    });

    test('tracks total count changes from the ordinal provider', () async {
      const scope = MessageTimelineScope.global();
      final scrollController = _FakeItemScrollController();
      final positionsListener = _FakeItemPositionsListener([
        const ItemPosition(
          index: 1,
          itemLeadingEdge: 0.2,
          itemTrailingEdge: 0.8,
        ),
      ]);
      final initialStrategy = _FakeOrdinalStrategy(
        messageIdsByOrdinal: const <int, int>{0: 10, 1: 20, 2: 30},
        ordinalsByMessageId: const <int, int>{10: 0, 20: 1, 30: 2},
      );

      _FakeMessageTimelineOrdinal.currentState = MessageTimelineOrdinalState(
        scope: scope,
        totalCount: 3,
        itemScrollController: scrollController,
        itemPositionsListener: positionsListener,
        strategy: initialStrategy,
      );

      final container = ProviderContainer(
        overrides: [
          messageTimelineOrdinalProvider(
            scope: scope,
          ).overrideWith(_FakeMessageTimelineOrdinal.new),
        ],
      );
      addTearDown(container.dispose);

      final provider = messageTimelineIndexCoordinatorProvider(scope: scope);
      final subscription = container.listen(
        provider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      await container.pump();
      expect(container.read(provider).totalCount, 3);

      _FakeMessageTimelineOrdinal.currentState = MessageTimelineOrdinalState(
        scope: scope,
        totalCount: 5,
        itemScrollController: scrollController,
        itemPositionsListener: positionsListener,
        strategy: _FakeOrdinalStrategy(
          messageIdsByOrdinal: const <int, int>{
            0: 10,
            1: 11,
            2: 12,
            3: 20,
            4: 30,
          },
          ordinalsByMessageId: const <int, int>{
            10: 0,
            11: 1,
            12: 2,
            20: 3,
            30: 4,
          },
        ),
      );

      container.invalidate(messageTimelineOrdinalProvider(scope: scope));
      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      await container.pump();

      final coordinatorState = container.read(provider);
      expect(coordinatorState.hasOrdinalState, isTrue);
      expect(coordinatorState.totalCount, 5);
      expect(scrollController.jumpCalls, isEmpty);
    });
  });
}

class _FakeMessageTimelineOrdinal extends MessageTimelineOrdinal {
  static late MessageTimelineOrdinalState currentState;

  @override
  Future<MessageTimelineOrdinalState> build({
    required MessageTimelineScope scope,
  }) async {
    return currentState;
  }
}

class _FakeOrdinalStrategy implements OrdinalStrategy {
  _FakeOrdinalStrategy({
    required this.messageIdsByOrdinal,
    required this.ordinalsByMessageId,
    this.ordinalsByDate = const <String, int>{},
  });

  final Map<int, int> messageIdsByOrdinal;
  final Map<int, int> ordinalsByMessageId;
  final Map<String, int> ordinalsByDate;

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) {
    return SynchronousFuture<int?>(null);
  }

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) {
    return SynchronousFuture<int?>(ordinalsByDate[date.toIso8601String()]);
  }

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) {
    return SynchronousFuture<int?>(messageIdsByOrdinal[ordinal]);
  }

  @override
  Future<String?> getMonthKeyByOrdinal(int ordinal) {
    return SynchronousFuture<String?>(null);
  }

  @override
  Future<int?> getOrdinalForMessage(int messageId) {
    return SynchronousFuture<int?>(ordinalsByMessageId[messageId]);
  }

  @override
  Future<int> getTotalCount() {
    return SynchronousFuture<int>(messageIdsByOrdinal.length);
  }
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

class _FakeItemScrollController extends ItemScrollController {
  final List<_JumpCall> jumpCalls = <_JumpCall>[];

  @override
  bool get isAttached => true;

  @override
  void jumpTo({required int index, double alignment = 0}) {
    jumpCalls.add(_JumpCall(index: index, alignment: alignment));
  }
}

@immutable
class _JumpCall {
  const _JumpCall({required this.index, required this.alignment});

  final int index;
  final double alignment;

  @override
  bool operator ==(Object other) {
    return other is _JumpCall &&
        other.index == index &&
        other.alignment == alignment;
  }

  @override
  int get hashCode => Object.hash(index, alignment);

  @override
  String toString() {
    return '_JumpCall(index: $index, alignment: $alignment)';
  }
}
