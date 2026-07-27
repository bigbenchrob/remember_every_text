import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../core/util/date_label_formatter.dart';
import '../../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../../domain/message_evidence/message_evidence_row_data.dart';
import '../../../domain/message_evidence/message_evidence_scope.dart';
import '../../../domain/message_evidence/message_evidence_skeleton.dart';
import 'message_evidence_fade_overlay.dart';
import 'message_evidence_header.dart';
import 'message_evidence_row.dart';

typedef MessageEvidenceRowActionResolver =
    VoidCallback? Function(
      MessageEvidenceScope evidenceScope,
      MessageEvidenceRowData message,
      String highlightQuery,
    );

class MessageEvidenceTimelineView extends ConsumerStatefulWidget {
  const MessageEvidenceTimelineView({
    required this.evidenceScope,
    required this.skeleton,
    required this.headerData,
    required this.emptyMessage,
    this.monthAnchor,
    this.anchorMessageId,
    this.highlightQuery = '',
    this.initialRows = const <int, MessageEvidenceRowData>{},
    this.isInitialRowsLoading = false,
    this.showHeader = true,
    this.useFixedPanelFrame = false,
    this.continueHeaderInNativeFlowAfterTracks = false,
    this.resolveRowAction,
    this.onVisibleMonthChanged,
    super.key,
  });

  final MessageEvidenceScope evidenceScope;
  final MessageEvidenceTimelineSkeleton skeleton;
  final MessageEvidenceHeaderModel headerData;
  final String emptyMessage;
  final DateTime? monthAnchor;
  final int? anchorMessageId;
  final String highlightQuery;
  final Map<int, MessageEvidenceRowData> initialRows;
  final bool isInitialRowsLoading;
  final bool showHeader;
  final bool useFixedPanelFrame;
  final bool continueHeaderInNativeFlowAfterTracks;
  final MessageEvidenceRowActionResolver? resolveRowAction;
  final ValueChanged<String?>? onVisibleMonthChanged;

  @override
  ConsumerState<MessageEvidenceTimelineView> createState() =>
      _MessageEvidenceTimelineViewState();
}

class _MessageEvidenceTimelineViewState
    extends ConsumerState<MessageEvidenceTimelineView> {
  late final ItemScrollController _itemScrollController =
      ItemScrollController();
  late final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  String? _lastPublishedMonthKey;
  String? _lastJumpRequestKey;
  String? _listInitialRequestKey;
  int? _listInitialScrollIndex;
  var _pendingNewEvidenceCount = 0;
  var _anchorPulseId = 0;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(
      _handleItemPositionsChanged,
    );
  }

  @override
  void didUpdateWidget(covariant MessageEvidenceTimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final scopeChanged = oldWidget.evidenceScope != widget.evidenceScope;
    final anchorChanged =
        oldWidget.monthAnchor != widget.monthAnchor ||
        oldWidget.anchorMessageId != widget.anchorMessageId;

    if (scopeChanged || anchorChanged) {
      _pendingNewEvidenceCount = 0;
      _scheduleAnchorJump();
      return;
    }

    final addedCount =
        widget.skeleton.totalCount - oldWidget.skeleton.totalCount;
    if (addedCount <= 0) {
      return;
    }

    if (_shouldFollowLiveEdge(oldWidget.skeleton)) {
      _pendingNewEvidenceCount = 0;
      _lastJumpRequestKey = null;
      _scheduleAnchorJump();
    } else {
      _pendingNewEvidenceCount += addedCount;
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(
      _handleItemPositionsChanged,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final backgroundColor = colors.messagePanels.coolPanelSurface;
    final pendingGlowColor = colors.messagePanels.pendingEvidenceGlow;
    final listInitialScrollIndex = _listInitialScrollIndexForCurrentAnchor();

    _scheduleAnchorJump();

    return ColoredBox(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader)
            MessageEvidenceHeader(
              data: widget.headerData,
              useFixedPanelFrame: widget.useFixedPanelFrame,
              continueInNativeFlowAfterTracks:
                  widget.continueHeaderInNativeFlowAfterTracks,
            ),
          Expanded(
            child: Stack(
              children: [
                MessageEvidenceFadeOverlay(
                  backgroundColor: backgroundColor,
                  child: widget.skeleton.isEmpty
                      ? Center(child: Text(widget.emptyMessage))
                      : widget.isInitialRowsLoading &&
                            widget.initialRows.isEmpty
                      ? const _InitialEvidenceLoading()
                      : ScrollablePositionedList.builder(
                          itemScrollController: _itemScrollController,
                          itemPositionsListener: _itemPositionsListener,
                          initialScrollIndex: listInitialScrollIndex,
                          padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                          itemCount: widget.skeleton.totalCount,
                          itemBuilder: (context, index) {
                            final entry = widget.skeleton.entries[index];
                            final previousEntry = index == 0
                                ? null
                                : widget.skeleton.entries[index - 1];
                            final previousDayLabel = previousEntry == null
                                ? null
                                : _dayLabel(previousEntry.dateUtc);
                            return _MessageEvidenceTimelineRow(
                              evidenceScope: widget.evidenceScope,
                              entry: entry,
                              initialMessage:
                                  widget.initialRows[entry.messageId],
                              isAnchorMessage:
                                  entry.messageId == widget.anchorMessageId,
                              correspondencePulseId: _anchorPulseId,
                              highlightQuery: widget.highlightQuery,
                              resolveRowAction: widget.resolveRowAction,
                              showDayDivider:
                                  previousEntry == null ||
                                  _dayLabel(entry.dateUtc) != previousDayLabel,
                            );
                          },
                        ),
                ),
                _PendingEvidenceGlow(
                  visible: _pendingNewEvidenceCount > 0,
                  color: pendingGlowColor,
                  intensity: _pendingGlowIntensity(),
                  pulseKey: _pendingNewEvidenceCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleAnchorJump() {
    if (widget.skeleton.isEmpty) {
      _publishVisibleMonth(null);
      return;
    }

    final requestKey = _anchorRequestKey();
    if (_lastJumpRequestKey == requestKey) {
      return;
    }
    _lastJumpRequestKey = requestKey;

    final targetIndex = _targetIndex();
    final monthKey = widget.skeleton.entries[targetIndex].monthKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(index: targetIndex);
      }
      _publishVisibleMonth(monthKey);
      _scheduleAnchorPulse(requestKey);
    });
  }

  void _scheduleAnchorPulse(String requestKey) {
    if (widget.anchorMessageId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _lastJumpRequestKey != requestKey) {
        return;
      }
      setState(() {
        _anchorPulseId += 1;
      });
    });
  }

  void _handleItemPositionsChanged() {
    _publishTopVisibleMonth();
    if (_pendingNewEvidenceCount > 0 && _isAtLiveEdge(widget.skeleton)) {
      setState(() {
        _pendingNewEvidenceCount = 0;
      });
    }
  }

  bool _shouldFollowLiveEdge(MessageEvidenceTimelineSkeleton skeleton) {
    return widget.monthAnchor == null &&
        widget.anchorMessageId == null &&
        _isAtLiveEdge(skeleton);
  }

  bool _isAtLiveEdge(MessageEvidenceTimelineSkeleton skeleton) {
    if (skeleton.isEmpty) {
      return true;
    }

    final latestIndex = skeleton.latestIndex();
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      return false;
    }

    return positions.any((position) {
      return position.index >= latestIndex && position.itemLeadingEdge < 1;
    });
  }

  double _pendingGlowIntensity() {
    if (_pendingNewEvidenceCount <= 0) {
      return 0;
    }
    return (_pendingNewEvidenceCount / 4).clamp(0.35, 1).toDouble();
  }

  int _listInitialScrollIndexForCurrentAnchor() {
    if (widget.skeleton.isEmpty) {
      _listInitialRequestKey = null;
      _listInitialScrollIndex = 0;
      return 0;
    }

    final requestKey = _anchorRequestKey();
    if (_listInitialRequestKey != requestKey) {
      _listInitialRequestKey = requestKey;
      _listInitialScrollIndex = _targetIndex();
    }

    final initialScrollIndex = _listInitialScrollIndex ?? _targetIndex();
    return initialScrollIndex.clamp(0, widget.skeleton.latestIndex());
  }

  String _anchorRequestKey() {
    return '${widget.evidenceScope.stableKey}:'
        '${widget.monthAnchor?.toIso8601String() ?? 'latest'}:'
        '${widget.anchorMessageId ?? 'no-anchor'}';
  }

  void _publishTopVisibleMonth() {
    final positions = _itemPositionsListener.itemPositions.value
        .where((position) {
          return position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1;
        })
        .toList(growable: false);
    if (positions.isEmpty) {
      return;
    }

    final topPosition = positions.reduce((left, right) {
      return left.itemLeadingEdge <= right.itemLeadingEdge ? left : right;
    });
    final index = topPosition.index;
    if (index < 0 || index >= widget.skeleton.totalCount) {
      return;
    }

    _publishVisibleMonth(widget.skeleton.entries[index].monthKey);
  }

  void _publishVisibleMonth(String? monthKey) {
    if (_lastPublishedMonthKey == monthKey) {
      return;
    }

    _lastPublishedMonthKey = monthKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onVisibleMonthChanged?.call(monthKey);
    });
  }

  int _targetIndex() {
    if (widget.skeleton.isEmpty) {
      return 0;
    }

    final monthAnchor = widget.monthAnchor;
    final anchorMessageId =
        widget.anchorMessageId ?? widget.skeleton.initialAnchorMessageId;
    if (anchorMessageId != null) {
      final anchorIndex = widget.skeleton.indexForMessageId(anchorMessageId);
      if (anchorIndex != null) {
        return anchorIndex;
      }
    }

    if (monthAnchor != null) {
      return widget.skeleton.indexForMonth(monthAnchor);
    }

    return widget.skeleton.latestIndex();
  }
}

class _InitialEvidenceLoading extends StatelessWidget {
  const _InitialEvidenceLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Loading messages...'));
  }
}

class _PendingEvidenceGlow extends StatelessWidget {
  const _PendingEvidenceGlow({
    required this.visible,
    required this.color,
    required this.intensity,
    required this.pulseKey,
  });

  final bool visible;
  final Color color;
  final double intensity;
  final int pulseKey;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: TweenAnimationBuilder<double>(
            key: ValueKey<int>(pulseKey),
            tween: Tween<double>(begin: 1, end: 0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, pulse, child) {
              final pulseBoost = 0.38 * pulse;
              return Opacity(
                opacity: (intensity + pulseBoost).clamp(0, 1).toDouble(),
                child: child,
              );
            },
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0),
                    color.withValues(alpha: 0.55),
                    color,
                  ],
                  stops: const [0, 0.62, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageEvidenceTimelineRow extends ConsumerWidget {
  const _MessageEvidenceTimelineRow({
    required this.evidenceScope,
    required this.entry,
    required this.initialMessage,
    required this.isAnchorMessage,
    required this.correspondencePulseId,
    required this.highlightQuery,
    required this.resolveRowAction,
    required this.showDayDivider,
  });

  final MessageEvidenceScope evidenceScope;
  final MessageEvidenceSkeletonEntry entry;
  final MessageEvidenceRowData? initialMessage;
  final bool isAnchorMessage;
  final int correspondencePulseId;
  final String highlightQuery;
  final MessageEvidenceRowActionResolver? resolveRowAction;
  final bool showDayDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialMessage = this.initialMessage;
    if (initialMessage != null) {
      return _ResolvedMessageEvidenceTimelineRow(
        evidenceScope: evidenceScope,
        entry: entry,
        message: initialMessage,
        isAnchorMessage: isAnchorMessage,
        correspondencePulseId: correspondencePulseId,
        highlightQuery: highlightQuery,
        resolveRowAction: resolveRowAction,
        showDayDivider: showDayDivider,
      );
    }

    final messageAsync = ref.watch(
      messageEvidenceRowProvider(
        scope: evidenceScope,
        messageId: entry.messageId,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDayDivider) _DayDivider(label: _dayLabel(entry.dateUtc)),
        messageAsync.when(
          data: (message) {
            if (message == null) {
              return _GraphMessageSkeleton(
                label: 'Message ${entry.messageId} unavailable',
              );
            }
            return MessageEvidenceRow(
              message: message,
              evidenceScope: evidenceScope,
              isAnchorMessage: isAnchorMessage,
              correspondencePulseId: correspondencePulseId,
              searchQuery: highlightQuery,
              onOpenConversationContext: resolveRowAction?.call(
                evidenceScope,
                message,
                highlightQuery,
              ),
            );
          },
          loading: () => const _GraphMessageSkeleton(label: 'Loading message'),
          error: (error, stackTrace) =>
              _GraphMessageSkeleton(label: 'Unable to load message: $error'),
        ),
      ],
    );
  }
}

class _ResolvedMessageEvidenceTimelineRow extends ConsumerWidget {
  const _ResolvedMessageEvidenceTimelineRow({
    required this.evidenceScope,
    required this.entry,
    required this.message,
    required this.isAnchorMessage,
    required this.correspondencePulseId,
    required this.highlightQuery,
    required this.resolveRowAction,
    required this.showDayDivider,
  });

  final MessageEvidenceScope evidenceScope;
  final MessageEvidenceSkeletonEntry entry;
  final MessageEvidenceRowData message;
  final bool isAnchorMessage;
  final int correspondencePulseId;
  final String highlightQuery;
  final MessageEvidenceRowActionResolver? resolveRowAction;
  final bool showDayDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDayDivider) _DayDivider(label: _dayLabel(entry.dateUtc)),
        MessageEvidenceRow(
          message: message,
          evidenceScope: evidenceScope,
          isAnchorMessage: isAnchorMessage,
          correspondencePulseId: correspondencePulseId,
          searchQuery: highlightQuery,
          onOpenConversationContext: resolveRowAction?.call(
            evidenceScope,
            message,
            highlightQuery,
          ),
        ),
      ],
    );
  }
}

class _GraphMessageSkeleton extends StatelessWidget {
  const _GraphMessageSkeleton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        label,
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _dayLabel(String? value) {
  return DateLabelFormatter.fullDateFromIso(value, fallback: 'No date') ??
      'No date';
}
