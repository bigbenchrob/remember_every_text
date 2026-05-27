import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../domain/value_objects/message_timeline_scope.dart';
import '../../../debug/contact_timeline_scroll_probe.dart';
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
  static const Duration _scrollUpdateDebounce = Duration(milliseconds: 48);

  VoidCallback? _detachPositionsListener;
  Timer? _debounceTimer;
  int _sessionGeneration = 0;
  int _requestGeneration = 0;
  int? _lastVisibleOrdinal;
  MessageTimelineOrdinalState? _currentOrdinalState;
  bool _isUpdatingVisibleMonth = false;
  bool _hasPendingVisibleMonthUpdate = false;
  final Map<int, String?> _monthKeyByOrdinal = <int, String?>{};

  @override
  FutureOr<String?> build({required MessageTimelineScope scope}) async {
    ContactTimelineScrollProbe.count('provider.current_visible_month.build');
    final ordinalAsync = ref.watch(
      messageTimelineOrdinalProvider(scope: scope),
    );
    final ordinalState = ordinalAsync.valueOrNull;
    _sessionGeneration += 1;
    _currentOrdinalState = ordinalState;
    _lastVisibleOrdinal = null;
    _monthKeyByOrdinal.clear();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _isUpdatingVisibleMonth = false;
    _hasPendingVisibleMonthUpdate = false;

    _detachPositionsListener?.call();
    _detachPositionsListener = null;

    if (ordinalState == null || ordinalState.totalCount == 0) {
      ref.onDispose(() {
        _detachPositionsListener?.call();
        _currentOrdinalState = null;
      });
      return null;
    }

    final listener = ordinalState.itemPositionsListener.itemPositions;
    final sessionGeneration = _sessionGeneration;

    void handlePositionsChanged() {
      ContactTimelineScrollProbe.count(
        'visible_month.positions_listener_event',
      );
      _debounceVisibleMonthUpdate(
        positionsListener: listener,
        sessionGeneration: sessionGeneration,
      );
    }

    listener.addListener(handlePositionsChanged);
    _detachPositionsListener = () {
      listener.removeListener(handlePositionsChanged);
    };

    ref.onDispose(() {
      _debounceTimer?.cancel();
      _debounceTimer = null;
      _detachPositionsListener?.call();
      _detachPositionsListener = null;
      _currentOrdinalState = null;
    });

    final initialMonth = await _computeVisibleMonth(
      positionsListener: listener,
    );

    return initialMonth;
  }

  /// Publishes the visible month for message surfaces that do not use the
  /// ordinal scroll coordinator but still participate in heatmap feedback.
  void setVisibleMonthKey(String? monthKey) {
    if (state.valueOrNull == monthKey) {
      return;
    }

    state = AsyncData(monthKey);
  }

  void _debounceVisibleMonthUpdate({
    required ValueListenable<Iterable<ItemPosition>> positionsListener,
    required int sessionGeneration,
  }) {
    ContactTimelineScrollProbe.count('visible_month.debounce_request');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_scrollUpdateDebounce, () {
      _debounceTimer = null;
      unawaited(
        _scheduleVisibleMonthUpdate(
          positionsListener: positionsListener,
          sessionGeneration: sessionGeneration,
        ),
      );
    });
  }

  Future<void> _scheduleVisibleMonthUpdate({
    required ValueListenable<Iterable<ItemPosition>> positionsListener,
    required int sessionGeneration,
  }) async {
    ContactTimelineScrollProbe.count('visible_month.schedule_update');
    if (_isUpdatingVisibleMonth) {
      _hasPendingVisibleMonthUpdate = true;
      return;
    }

    _isUpdatingVisibleMonth = true;
    try {
      do {
        _hasPendingVisibleMonthUpdate = false;

        if (sessionGeneration != _sessionGeneration) {
          return;
        }

        await _updateVisibleMonth(
          positionsListener: positionsListener,
          sessionGeneration: sessionGeneration,
        );
      } while (_hasPendingVisibleMonthUpdate);
    } finally {
      _isUpdatingVisibleMonth = false;
    }
  }

  Future<void> _updateVisibleMonth({
    required ValueListenable<Iterable<ItemPosition>> positionsListener,
    required int sessionGeneration,
  }) async {
    ContactTimelineScrollProbe.count('visible_month.update_request');
    final generation = ++_requestGeneration;
    final monthKey = await ContactTimelineScrollProbe.traceAsync(
      'visible_month.update_compute',
      () => _computeVisibleMonth(positionsListener: positionsListener),
    );

    if (sessionGeneration != _sessionGeneration ||
        generation != _requestGeneration) {
      return;
    }

    if (state.valueOrNull == monthKey) {
      return;
    }

    ContactTimelineScrollProbe.count('visible_month.state_write');
    state = AsyncData(monthKey);
  }

  Future<String?> _computeVisibleMonth({
    required ValueListenable<Iterable<ItemPosition>> positionsListener,
  }) async {
    return ContactTimelineScrollProbe.traceAsync(
      'visible_month.compute',
      () async {
        final positions = positionsListener.value;
        if (positions.isEmpty) {
          return state.valueOrNull;
        }

        final visiblePositions = positions
            .where((position) {
              return position.itemTrailingEdge > 0 &&
                  position.itemLeadingEdge < 1;
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

        final strategy = _currentOrdinalState?.strategy;
        if (strategy == null) {
          return state.valueOrNull;
        }

        if (_monthKeyByOrdinal.containsKey(topPosition.index)) {
          ContactTimelineScrollProbe.count('visible_month.cache_hit');
          return _monthKeyByOrdinal[topPosition.index] ?? state.valueOrNull;
        }

        ContactTimelineScrollProbe.count('visible_month.ordinal_lookup');
        final monthKey = await ContactTimelineScrollProbe.traceAsync(
          'visible_month.ordinal_lookup',
          () => strategy.getMonthKeyByOrdinal(topPosition.index),
        );
        _monthKeyByOrdinal[topPosition.index] = monthKey;
        return monthKey ?? state.valueOrNull;
      },
    );
  }
}
