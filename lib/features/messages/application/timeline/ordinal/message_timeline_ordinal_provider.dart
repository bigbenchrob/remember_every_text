import 'package:flutter/animation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../strategies/ordinal_strategy.dart';
import './message_timeline_scope_ordinal_extensions.dart';

part 'message_timeline_ordinal_provider.g.dart';

/// Unified state for ordinal-based message timeline lists.
///
/// Works across all scopes (global, contact, chat) with identical structure.
/// Contains the total message count and scroll controllers for virtual scrolling.
class MessageTimelineOrdinalState {
  const MessageTimelineOrdinalState({
    required this.scope,
    required this.totalCount,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.strategy,
  });

  /// The scope this state represents.
  final MessageTimelineScope scope;

  /// Total message count in this scope.
  final int totalCount;

  /// Controller for jumping to specific ordinal positions.
  final ItemScrollController itemScrollController;

  /// Listener for tracking visible ordinals.
  final ItemPositionsListener itemPositionsListener;

  /// Strategy for scope-specific ordinal queries.
  final OrdinalStrategy strategy;

  MessageTimelineOrdinalState copyWith({int? totalCount}) {
    return MessageTimelineOrdinalState(
      scope: scope,
      totalCount: totalCount ?? this.totalCount,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      strategy: strategy,
    );
  }
}

/// Unified ordinal provider for message timelines.
///
/// Accepts a [MessageTimelineScope] to determine which message set to query.
/// Uses the strategy pattern to delegate to scope-specific data sources.
@riverpod
class MessageTimelineOrdinal extends _$MessageTimelineOrdinal {
  late final ItemScrollController _itemScrollController =
      ItemScrollController();
  late final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  Future<MessageTimelineOrdinalState> build({
    required MessageTimelineScope scope,
  }) async {
    // During maintenance, return empty state to avoid DB access.
    final isMaintenance = ref.watch(dbMaintenanceLockProvider);
    if (isMaintenance) {
      return MessageTimelineOrdinalState(
        scope: scope,
        totalCount: 0,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        strategy: _EmptyOrdinalStrategy(),
      );
    }

    final strategy = await scope.resolveOrdinalStrategy(ref);
    final totalCount = await strategy.getTotalCount();

    return MessageTimelineOrdinalState(
      scope: scope,
      totalCount: totalCount,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      strategy: strategy,
    );
  }

  /// Jump to the latest (most recent) message.
  Future<void> jumpToLatest() async {
    final currentState = state.value;
    if (currentState == null || currentState.totalCount == 0) {
      return;
    }

    currentState.itemScrollController.jumpTo(
      index: currentState.totalCount - 1,
    );
  }

  /// Jump to a specific month in the timeline.
  ///
  /// Month key format: 'YYYY-MM' (e.g., '2023-06')
  Future<void> jumpToMonth(String monthKey) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final ordinal = await currentState.strategy.getFirstOrdinalForMonth(
      monthKey,
    );
    if (ordinal == null) {
      return;
    }

    currentState.itemScrollController.jumpTo(index: ordinal);
  }

  /// Jump to a specific date in the timeline.
  ///
  /// Finds the first message on or after the given date.
  Future<void> jumpToDate(DateTime date) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final ordinal = await currentState.strategy.getFirstOrdinalOnOrAfter(date);
    if (ordinal == null) {
      return;
    }

    currentState.itemScrollController.jumpTo(index: ordinal);
  }

  /// Scroll to a specific ordinal with animation.
  Future<void> scrollTo(int ordinal, {Duration? duration}) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    await currentState.itemScrollController.scrollTo(
      index: ordinal,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

/// Empty strategy used during maintenance mode.
class _EmptyOrdinalStrategy implements OrdinalStrategy {
  @override
  Future<int> getTotalCount() async => 0;

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) async => null;

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) async => null;

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) async => null;

  @override
  Future<String?> getMonthKeyByOrdinal(int ordinal) async => null;

  @override
  Future<int?> getOrdinalForMessage(int messageId) async => null;
}
