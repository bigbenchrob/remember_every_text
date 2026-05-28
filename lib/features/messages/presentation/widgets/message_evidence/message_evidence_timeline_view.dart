import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../../domain/message_evidence/message_evidence_scope.dart';
import '../../../domain/message_evidence/message_evidence_skeleton.dart';
import 'graph_message_evidence_row.dart';
import 'message_evidence_fade_overlay.dart';
import 'message_evidence_header.dart';

class MessageEvidenceTimelineView extends ConsumerStatefulWidget {
  const MessageEvidenceTimelineView({
    required this.evidenceScope,
    required this.skeleton,
    required this.headerData,
    required this.emptyMessage,
    this.monthAnchor,
    this.anchorMessageId,
    this.highlightQuery = '',
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

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_publishTopVisibleMonth);
  }

  @override
  void didUpdateWidget(covariant MessageEvidenceTimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.evidenceScope != widget.evidenceScope ||
        oldWidget.monthAnchor != widget.monthAnchor ||
        oldWidget.anchorMessageId != widget.anchorMessageId ||
        oldWidget.skeleton != widget.skeleton) {
      _scheduleAnchorJump();
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(
      _publishTopVisibleMonth,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final backgroundColor = colors.messagePanels.coolPanelSurface;
    final targetIndex = _targetIndex();

    _scheduleAnchorJump();

    return ColoredBox(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessageEvidenceHeader(data: widget.headerData),
          Expanded(
            child: MessageEvidenceFadeOverlay(
              backgroundColor: backgroundColor,
              child: widget.skeleton.isEmpty
                  ? Center(child: Text(widget.emptyMessage))
                  : ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      initialScrollIndex: targetIndex,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
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
                          isAnchorMessage:
                              entry.messageId == widget.anchorMessageId,
                          highlightQuery: widget.highlightQuery,
                          showDayDivider:
                              previousEntry == null ||
                              _dayLabel(entry.dateUtc) != previousDayLabel,
                        );
                      },
                    ),
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

    final requestKey =
        '${widget.evidenceScope.stableKey}:${widget.monthAnchor?.toIso8601String() ?? 'latest'}:${widget.anchorMessageId ?? 'no-anchor'}:${widget.skeleton.totalCount}';
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
    });
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

class _MessageEvidenceTimelineRow extends ConsumerWidget {
  const _MessageEvidenceTimelineRow({
    required this.evidenceScope,
    required this.entry,
    required this.isAnchorMessage,
    required this.highlightQuery,
    required this.showDayDivider,
  });

  final MessageEvidenceScope evidenceScope;
  final MessageEvidenceSkeletonEntry entry;
  final bool isAnchorMessage;
  final String highlightQuery;
  final bool showDayDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(
      graphMessageEvidenceRowProvider(
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
            return GraphMessageEvidenceRow(
              message: message,
              evidenceScope: evidenceScope,
              isAnchorMessage: isAnchorMessage,
              searchQuery: highlightQuery,
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
  final parsed = value == null ? null : DateTime.tryParse(value);
  if (parsed == null) {
    return 'No date';
  }
  return DateFormat.yMMMd().format(parsed.toLocal());
}
