import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../contacts/infrastructure/repositories/contact_profile_provider.dart';
import '../../domain/value_objects/message_timeline_scope.dart';
import '../view_model/timeline/ordinal/current_visible_month_provider.dart';
import '../widgets/message_evidence/graph_message_evidence_row.dart';
import '../widgets/message_evidence/message_evidence_fade_overlay.dart';
import '../widgets/message_evidence/message_evidence_header.dart';

class ContactGraphMessagesView extends ConsumerStatefulWidget {
  const ContactGraphMessagesView({
    required this.contactId,
    this.monthAnchor,
    super.key,
  });

  final int contactId;
  final DateTime? monthAnchor;

  @override
  ConsumerState<ContactGraphMessagesView> createState() =>
      _ContactGraphMessagesViewState();
}

class _ContactGraphMessagesViewState
    extends ConsumerState<ContactGraphMessagesView> {
  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(
      contactPageGraphMessageTimelineProvider(contactId: widget.contactId),
    );
    final snapshotAsync = ref.watch(
      contactPageGraphSnapshotProvider(contactId: widget.contactId),
    );
    final profileAsync = ref.watch(
      contactProfileProvider(contactId: widget.contactId),
    );

    return timelineAsync.when(
      data: (timelineEntries) {
        return _ContactGraphMessagesTimeline(
          contactId: widget.contactId,
          contactName: profileAsync.valueOrNull?.shortName,
          snapshot: snapshotAsync.valueOrNull,
          timelineEntries: timelineEntries,
          monthAnchor: widget.monthAnchor,
        );
      },
      loading: () => const Center(child: Text('Loading contact timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Contact graph timeline failed: $error')),
    );
  }
}

class _ContactGraphMessagesTimeline extends ConsumerStatefulWidget {
  const _ContactGraphMessagesTimeline({
    required this.contactId,
    required this.contactName,
    required this.snapshot,
    required this.timelineEntries,
    required this.monthAnchor,
  });

  final int contactId;
  final String? contactName;
  final ContactGraphSnapshot? snapshot;
  final List<ContactGraphMessageTimelineEntry> timelineEntries;
  final DateTime? monthAnchor;

  @override
  ConsumerState<_ContactGraphMessagesTimeline> createState() =>
      _ContactGraphMessagesTimelineState();
}

class _ContactGraphMessagesTimelineState
    extends ConsumerState<_ContactGraphMessagesTimeline> {
  late final ItemScrollController _itemScrollController =
      ItemScrollController();
  late final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  int? _lastPublishedContactId;
  String? _lastPublishedMonthKey;
  String? _lastJumpRequestKey;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_publishTopVisibleMonth);
  }

  @override
  void didUpdateWidget(covariant _ContactGraphMessagesTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contactId != widget.contactId ||
        oldWidget.monthAnchor != widget.monthAnchor ||
        oldWidget.timelineEntries != widget.timelineEntries) {
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
          MessageEvidenceHeader(
            data: MessageEvidenceHeaderData(
              title: 'All messages from ${_contactLabel()}',
              subtitleParts: _subtitleParts(),
              statusLine: _statusLine(),
            ),
          ),
          Expanded(
            child: MessageEvidenceFadeOverlay(
              backgroundColor: backgroundColor,
              child: widget.timelineEntries.isEmpty
                  ? Center(child: Text(_emptyMessage()))
                  : ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      initialScrollIndex: targetIndex,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      itemCount: widget.timelineEntries.length,
                      itemBuilder: (context, index) {
                        final entry = widget.timelineEntries[index];
                        final previousEntry = index == 0
                            ? null
                            : widget.timelineEntries[index - 1];
                        final previousDayLabel = previousEntry == null
                            ? null
                            : _dayLabel(previousEntry.dateUtc);
                        return _GraphContactMessageTimelineRow(
                          contactId: widget.contactId,
                          entry: entry,
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
    if (widget.timelineEntries.isEmpty) {
      _publishVisibleMonth(null);
      return;
    }

    final requestKey =
        '${widget.contactId}:${widget.monthAnchor?.toIso8601String() ?? 'latest'}:${widget.timelineEntries.length}';
    if (_lastJumpRequestKey == requestKey) {
      return;
    }
    _lastJumpRequestKey = requestKey;

    final targetIndex = _targetIndex();
    final monthKey = widget.timelineEntries[targetIndex].monthKey;
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
    if (index < 0 || index >= widget.timelineEntries.length) {
      return;
    }

    _publishVisibleMonth(widget.timelineEntries[index].monthKey);
  }

  void _publishVisibleMonth(String? monthKey) {
    if (_lastPublishedContactId == widget.contactId &&
        _lastPublishedMonthKey == monthKey) {
      return;
    }

    _lastPublishedContactId = widget.contactId;
    _lastPublishedMonthKey = monthKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(
            currentVisibleMonthForScopeProvider(
              scope: MessageTimelineScope.contact(contactId: widget.contactId),
            ).notifier,
          )
          .setVisibleMonthKey(monthKey);
    });
  }

  int _targetIndex() {
    if (widget.timelineEntries.isEmpty) {
      return 0;
    }

    final monthAnchor = widget.monthAnchor;
    if (monthAnchor != null) {
      final targetMonth = _monthKey(monthAnchor);
      final index = widget.timelineEntries.indexWhere((entry) {
        return entry.monthKey == targetMonth;
      });
      if (index >= 0) {
        return index;
      }
    }

    return widget.timelineEntries.length - 1;
  }

  List<String> _subtitleParts() {
    final monthLabel = _monthLabel(widget.monthAnchor);
    if (monthLabel != null) {
      return [
        monthLabel,
        '${_formatCount(_monthMessageCount(_monthKey(widget.monthAnchor!)))} messages this month',
      ];
    }

    final activity = widget.snapshot?.messageActivity;
    if (activity == null) {
      return ['${_formatCount(widget.timelineEntries.length)} messages'];
    }

    return [
      _dateSpan(activity.firstMessageAtUtc, activity.lastMessageAtUtc),
      '${_formatCount(activity.totalMessageCount)} messages',
    ];
  }

  String _statusLine() {
    if (widget.monthAnchor != null) {
      return 'selected month • graph skeleton • hydrate visible rows';
    }
    return 'graph skeleton • latest position • hydrate visible rows';
  }

  String _emptyMessage() {
    if (widget.monthAnchor != null) {
      return 'No graph messages found for this contact in the selected month.';
    }
    return 'No graph messages found for this contact.';
  }

  String _contactLabel() {
    final label = widget.contactName?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return 'contact ${widget.contactId}';
  }

  int _monthMessageCount(String monthKey) {
    return widget.timelineEntries.where((entry) {
      return entry.monthKey == monthKey;
    }).length;
  }
}

class _GraphContactMessageTimelineRow extends ConsumerWidget {
  const _GraphContactMessageTimelineRow({
    required this.contactId,
    required this.entry,
    required this.showDayDivider,
  });

  final int contactId;
  final ContactGraphMessageTimelineEntry entry;
  final bool showDayDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(
      contactPageGraphMessageByIdProvider(
        contactId: contactId,
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
            return GraphMessageEvidenceRow(message: message);
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

String _monthKey(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';
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

String? _monthLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateFormat.yMMMM().format(value);
}

String _dateSpan(String? first, String? last) {
  final firstLabel = _dateLabel(first);
  final lastLabel = _dateLabel(last);
  if (firstLabel == null && lastLabel == null) {
    return 'No date range';
  }
  if (firstLabel == null) {
    return 'through $lastLabel';
  }
  if (lastLabel == null || firstLabel == lastLabel) {
    return firstLabel;
  }
  return '$firstLabel to $lastLabel';
}

String? _dateLabel(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return DateFormat.yMMMd().format(parsed.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}
