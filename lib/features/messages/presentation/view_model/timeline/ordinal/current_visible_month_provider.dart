import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../domain/value_objects/message_timeline_scope.dart';
import 'message_timeline_ordinal_provider.dart';

part 'current_visible_month_provider.g.dart';

/// Provides the currently visible month key for a given timeline scope.
///
/// The month key is in 'yyyy-MM' format (e.g., '2023-06').
/// This is used by the heatmap widget to highlight the current scroll position.
///
/// Returns null if the ordinal state is not yet loaded.
@riverpod
class CurrentVisibleMonthForScope extends _$CurrentVisibleMonthForScope {
  VoidCallback? _detachPositionsListener;
  int _updateGeneration = 0;
  int? _lastVisibleOrdinal;
  final Map<int, int> _messageIdByOrdinal = <int, int>{};
  final Map<int, String> _monthKeyByMessageId = <int, String>{};

  @override
  FutureOr<String?> build({required MessageTimelineScope scope}) async {
    final ordinalAsync = ref.watch(
      messageTimelineOrdinalProvider(scope: scope),
    );
    final ordinalState = ordinalAsync.valueOrNull;
    _lastVisibleOrdinal = null;
    _messageIdByOrdinal.clear();
    _monthKeyByMessageId.clear();

    _detachPositionsListener?.call();
    _detachPositionsListener = null;

    if (ordinalState == null || ordinalState.totalCount == 0) {
      ref.onDispose(() {
        _detachPositionsListener?.call();
      });
      return null;
    }

    final listener = ordinalState.itemPositionsListener.itemPositions;

    void handlePositionsChanged() {
      unawaited(_updateVisibleMonth(scope: scope, positionsListener: listener));
    }

    listener.addListener(handlePositionsChanged);
    _detachPositionsListener = () {
      listener.removeListener(handlePositionsChanged);
    };

    ref.onDispose(() {
      _detachPositionsListener?.call();
      _detachPositionsListener = null;
    });

    final initialMonth = await _computeVisibleMonth(
      scope: scope,
      positionsListener: listener,
    );

    return initialMonth;
  }

  Future<void> _updateVisibleMonth({
    required MessageTimelineScope scope,
    required ValueListenable<Iterable<ItemPosition>> positionsListener,
  }) async {
    final generation = ++_updateGeneration;
    final monthKey = await _computeVisibleMonth(
      scope: scope,
      positionsListener: positionsListener,
    );

    if (generation != _updateGeneration) {
      return;
    }

    if (state.valueOrNull == monthKey) {
      return;
    }

    state = AsyncData(monthKey);
  }

  Future<String?> _computeVisibleMonth({
    required MessageTimelineScope scope,
    required ValueListenable<Iterable<ItemPosition>> positionsListener,
  }) async {
    final positions = positionsListener.value;
    if (positions.isEmpty) {
      return state.valueOrNull;
    }

    final visiblePositions = positions
        .where((position) {
          return position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1;
        })
        .toList(growable: false);

    if (visiblePositions.isEmpty) {
      return state.valueOrNull;
    }

    final topPosition = visiblePositions.reduce((left, right) {
      return left.itemLeadingEdge <= right.itemLeadingEdge ? left : right;
    });
    if (_lastVisibleOrdinal == topPosition.index) {
      return state.valueOrNull;
    }
    _lastVisibleOrdinal = topPosition.index;

    final ordinalState = ref
        .read(messageTimelineOrdinalProvider(scope: scope))
        .valueOrNull;
    final strategy = ordinalState?.strategy;
    if (strategy == null) {
      return state.valueOrNull;
    }

    final cachedMessageId = _messageIdByOrdinal[topPosition.index];
    final messageId =
        cachedMessageId ??
        await strategy.getMessageIdByOrdinal(topPosition.index);
    if (messageId == null) {
      return state.valueOrNull;
    }
    _messageIdByOrdinal[topPosition.index] = messageId;

    final cachedMonthKey = _monthKeyByMessageId[messageId];
    if (cachedMonthKey != null) {
      return cachedMonthKey;
    }

    final db = await ref.read(driftWorkingDatabaseProvider.future);
    final sentAtRow =
        await (db.selectOnly(db.workingMessages)
              ..addColumns([db.workingMessages.sentAtUtc])
              ..where(db.workingMessages.id.equals(messageId))
              ..limit(1))
            .getSingleOrNull();
    final sentAtUtc = sentAtRow?.read(db.workingMessages.sentAtUtc);
    if (sentAtUtc == null || sentAtUtc.isEmpty) {
      return state.valueOrNull;
    }

    final sentAt = DateTime.tryParse(sentAtUtc);
    if (sentAt == null) {
      return state.valueOrNull;
    }

    final monthKey = _monthKeyForDate(sentAt);
    _monthKeyByMessageId[messageId] = monthKey;
    return monthKey;
  }
}

String _monthKeyForDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}
