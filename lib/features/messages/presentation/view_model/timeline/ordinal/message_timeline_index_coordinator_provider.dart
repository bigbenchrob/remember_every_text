import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../domain/value_objects/message_timeline_scope.dart';
import 'message_timeline_ordinal_provider.dart';

part 'message_timeline_index_coordinator_provider.g.dart';

class MessageTimelineIndexCoordinatorState {
  const MessageTimelineIndexCoordinatorState({
    required this.scope,
    required this.hasOrdinalState,
    required this.totalCount,
  });

  final MessageTimelineScope scope;
  final bool hasOrdinalState;
  final int totalCount;
}

@riverpod
class MessageTimelineIndexCoordinator
    extends _$MessageTimelineIndexCoordinator {
  MessageTimelineOrdinalState? _currentOrdinalState;
  VoidCallback? _detachPositionsListener;
  ValueListenable<Iterable<ItemPosition>>? _positionsListenable;
  int _anchorGeneration = 0;
  int? _lastVisibleTopMessageId;
  double? _lastVisibleTopAlignment;
  int? _previousTotalCount;
  int? _pendingRestoreCount;
  String? _lastAppliedInitialScrollKey;

  @override
  MessageTimelineIndexCoordinatorState build({
    required MessageTimelineScope scope,
  }) {
    ref.onCancel(() {
      if (scope is ContactTimelineScope) {
        _resetViewportSession();
      }
    });
    ref.onDispose(_reset);

    final ordinalState = ref
        .watch(messageTimelineOrdinalProvider(scope: scope))
        .valueOrNull;
    if (ordinalState == null) {
      _currentOrdinalState = null;
      return MessageTimelineIndexCoordinatorState(
        scope: scope,
        hasOrdinalState: false,
        totalCount: _previousTotalCount ?? 0,
      );
    }

    if (ordinalState.totalCount == 0) {
      _currentOrdinalState = ordinalState;
      _detachListener();
      _previousTotalCount = 0;
      _pendingRestoreCount = null;
      return MessageTimelineIndexCoordinatorState(
        scope: scope,
        hasOrdinalState: true,
        totalCount: 0,
      );
    }

    if (_shouldCaptureVisibleAnchor(scope)) {
      _currentOrdinalState = ordinalState;
      _attachPositionsListener();
      _queueRestoreIfNeeded(totalCount: ordinalState.totalCount);
    } else {
      _currentOrdinalState = ordinalState;
      _detachListener();
      _pendingRestoreCount = null;
    }

    _previousTotalCount = ordinalState.totalCount;

    return MessageTimelineIndexCoordinatorState(
      scope: scope,
      hasOrdinalState: true,
      totalCount: ordinalState.totalCount,
    );
  }

  void syncViewport({
    DateTime? scrollToDate,
    bool jumpToLatestWhenNoTarget = true,
  }) {
    final ordinalState = _currentOrdinalState;
    if (ordinalState != null && ordinalState.itemScrollController.isAttached) {
      unawaited(
        _applyViewportCommands(
          scrollToDate: scrollToDate,
          jumpToLatestWhenNoTarget: jumpToLatestWhenNoTarget,
        ),
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _applyViewportCommands(
          scrollToDate: scrollToDate,
          jumpToLatestWhenNoTarget: jumpToLatestWhenNoTarget,
        ),
      );
    });
  }

  Future<void> _applyViewportCommands({
    DateTime? scrollToDate,
    required bool jumpToLatestWhenNoTarget,
  }) async {
    final ordinalState = _currentOrdinalState;
    if (ordinalState == null || !ordinalState.itemScrollController.isAttached) {
      return;
    }

    if (_pendingRestoreCount == null) {
      final positionsListenable = _positionsListenable;
      if (positionsListenable != null) {
        await _captureVisibleTopAnchor(positionsListenable);
      }
    }

    final appliedInitial = await _applyInitialPositionIfNeeded(
      ordinalState: ordinalState,
      scrollToDate: scrollToDate,
      jumpToLatestWhenNoTarget: jumpToLatestWhenNoTarget,
    );
    if (appliedInitial) {
      return;
    }

    await _restoreAnchorIfNeeded(ordinalState);
  }

  Future<bool> _applyInitialPositionIfNeeded({
    required MessageTimelineOrdinalState ordinalState,
    required DateTime? scrollToDate,
    required bool jumpToLatestWhenNoTarget,
  }) async {
    if (scrollToDate == null && !jumpToLatestWhenNoTarget) {
      return false;
    }

    final requestKey = scrollToDate?.toIso8601String() ?? 'latest';
    if (_lastAppliedInitialScrollKey == requestKey) {
      return false;
    }

    if (scrollToDate != null) {
      final ordinal = await ordinalState.strategy.getFirstOrdinalOnOrAfter(
        scrollToDate,
      );
      if (ordinal == null) {
        return false;
      }

      ordinalState.itemScrollController.jumpTo(index: ordinal);
      _lastAppliedInitialScrollKey = requestKey;
      return true;
    }

    if (ordinalState.totalCount == 0) {
      return false;
    }

    ordinalState.itemScrollController.jumpTo(
      index: ordinalState.totalCount - 1,
    );
    _lastAppliedInitialScrollKey = requestKey;
    return true;
  }

  Future<void> _restoreAnchorIfNeeded(
    MessageTimelineOrdinalState ordinalState,
  ) async {
    final pendingRestoreCount = _pendingRestoreCount;
    if (pendingRestoreCount == null ||
        pendingRestoreCount != ordinalState.totalCount) {
      return;
    }

    _pendingRestoreCount = null;

    final restoreMessageId = _lastVisibleTopMessageId;
    if (restoreMessageId == null) {
      return;
    }

    final restoreOrdinal = await ordinalState.strategy.getOrdinalForMessage(
      restoreMessageId,
    );
    if (restoreOrdinal == null) {
      return;
    }

    final clampedOrdinal = restoreOrdinal.clamp(0, ordinalState.totalCount - 1);
    ordinalState.itemScrollController.jumpTo(
      index: clampedOrdinal,
      alignment: _lastVisibleTopAlignment ?? 0,
    );
  }

  void _attachPositionsListener() {
    final ordinalState = _currentOrdinalState;
    if (ordinalState == null) {
      return;
    }

    final positionsListenable =
        ordinalState.itemPositionsListener.itemPositions;
    if (identical(_positionsListenable, positionsListenable)) {
      return;
    }

    _detachListener();
    _positionsListenable = positionsListenable;

    void handlePositionsChanged() {
      unawaited(_captureVisibleTopAnchor(positionsListenable));
    }

    positionsListenable.addListener(handlePositionsChanged);
    _detachPositionsListener = () {
      positionsListenable.removeListener(handlePositionsChanged);
      if (identical(_positionsListenable, positionsListenable)) {
        _positionsListenable = null;
      }
    };

    handlePositionsChanged();
  }

  Future<void> _captureVisibleTopAnchor(
    ValueListenable<Iterable<ItemPosition>> positionsListenable,
  ) async {
    final topPosition = _findTopVisiblePosition(positionsListenable.value);
    if (topPosition == null) {
      return;
    }

    final ordinalState = _currentOrdinalState;
    if (ordinalState == null) {
      return;
    }

    _lastVisibleTopAlignment = topPosition.itemLeadingEdge;

    final captureGeneration = ++_anchorGeneration;
    final messageId = await ordinalState.strategy.getMessageIdByOrdinal(
      topPosition.index,
    );
    if (captureGeneration != _anchorGeneration) {
      return;
    }

    _lastVisibleTopMessageId = messageId;
  }

  void _queueRestoreIfNeeded({required int totalCount}) {
    final previousTotalCount = _previousTotalCount;
    if (previousTotalCount == null || previousTotalCount == totalCount) {
      return;
    }

    _pendingRestoreCount = totalCount;
  }

  bool _shouldCaptureVisibleAnchor(MessageTimelineScope scope) {
    return scope is! ContactTimelineScope;
  }

  ItemPosition? _findTopVisiblePosition(Iterable<ItemPosition> positions) {
    final visiblePositions = positions
        .where((position) {
          return position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1;
        })
        .toList(growable: false);
    if (visiblePositions.isEmpty) {
      return null;
    }

    return visiblePositions.reduce((left, right) {
      return left.itemLeadingEdge <= right.itemLeadingEdge ? left : right;
    });
  }

  void _detachListener() {
    _detachPositionsListener?.call();
    _detachPositionsListener = null;
  }

  void _reset() {
    _currentOrdinalState = null;
    _detachListener();
    _positionsListenable = null;
    _anchorGeneration = 0;
    _lastVisibleTopMessageId = null;
    _lastVisibleTopAlignment = null;
    _previousTotalCount = null;
    _pendingRestoreCount = null;
    _lastAppliedInitialScrollKey = null;
  }

  void _resetViewportSession() {
    _anchorGeneration = 0;
    _lastVisibleTopMessageId = null;
    _lastVisibleTopAlignment = null;
    _previousTotalCount = null;
    _pendingRestoreCount = null;
    _lastAppliedInitialScrollKey = null;
  }
}
