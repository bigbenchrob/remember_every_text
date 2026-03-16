import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../domain/value_objects/message_timeline_scope.dart';
import '../hydration/message_by_ordinal_provider.dart';
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

  @override
  FutureOr<String?> build({required MessageTimelineScope scope}) async {
    final ordinalAsync = ref.watch(
      messageTimelineOrdinalProvider(scope: scope),
    );
    final ordinalState = ordinalAsync.valueOrNull;

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

    final messageItem = await ref.read(
      messageByTimelineOrdinalProvider(
        scope: scope,
        ordinal: topPosition.index,
      ).future,
    );

    final sentAt = messageItem?.sentAt;
    if (sentAt == null) {
      return state.valueOrNull;
    }

    return DateFormat('yyyy-MM').format(sentAt);
  }
}
