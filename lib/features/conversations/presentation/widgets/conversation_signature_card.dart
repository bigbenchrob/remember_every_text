import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../../../essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';

class ConversationSignatureCardData {
  const ConversationSignatureCardData({
    required this.conversationId,
    required this.title,
    this.titleContextLabel,
    this.summaryHighlight = ConversationSignatureSummaryHighlight.none,
    this.highlightedMonth,
    required this.participantCount,
    required this.messageCount,
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
    required this.activityMonths,
  });

  final int conversationId;
  final String title;
  final String? titleContextLabel;
  final ConversationSignatureSummaryHighlight summaryHighlight;
  final ConversationSignatureMonthMarker? highlightedMonth;
  final int participantCount;
  final int messageCount;
  final String? firstMessageAtUtc;
  final String? lastMessageAtUtc;
  final List<ConversationSignatureMonth> activityMonths;
}

class ConversationSignatureMonthMarker {
  const ConversationSignatureMonthMarker({
    required this.year,
    required this.month,
  });

  final int year;
  final int month;

  bool matches(ConversationSignatureMonth candidate) {
    return candidate.year == year && candidate.month == month;
  }
}

enum ConversationSignatureSummaryHighlight {
  none,
  messageCount,
  firstDate,
  lastDate,
  dateRange,
}

class ConversationSignatureCardStyle {
  const ConversationSignatureCardStyle({
    required this.backgroundColor,
    required this.hoverBackgroundColor,
    required this.selectedBackgroundColor,
    required this.borderColor,
    required this.hoverBorderColor,
    required this.selectedBorderColor,
    required this.titleStyle,
    required this.selectedTitleStyle,
    this.titleContextStyle,
    required this.participantSuffixStyle,
    required this.summaryStyle,
    this.summaryHighlightStyle,
    this.monthHighlightColor,
    required this.emptyMonthBorderColor,
  });

  final Color backgroundColor;
  final Color hoverBackgroundColor;
  final Color selectedBackgroundColor;
  final Color borderColor;
  final Color hoverBorderColor;
  final Color selectedBorderColor;
  final TextStyle titleStyle;
  final TextStyle selectedTitleStyle;
  final TextStyle? titleContextStyle;
  final TextStyle participantSuffixStyle;
  final TextStyle summaryStyle;
  final TextStyle? summaryHighlightStyle;
  final Color? monthHighlightColor;
  final Color emptyMonthBorderColor;
}

class ConversationSignatureCard extends StatefulWidget {
  const ConversationSignatureCard({
    required this.signature,
    required this.style,
    required this.monthColorForMessageCount,
    this.onPressed,
    this.isSelected = false,
    this.trailing,
    super.key,
  });

  final ConversationSignatureCardData signature;
  final ConversationSignatureCardStyle style;
  final Color Function(int messageCount) monthColorForMessageCount;
  final VoidCallback? onPressed;
  final bool isSelected;
  final Widget? trailing;

  @override
  State<ConversationSignatureCard> createState() =>
      _ConversationSignatureCardState();
}

class _ConversationSignatureCardState extends State<ConversationSignatureCard> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final signature = widget.signature;
    final background = widget.isSelected
        ? widget.style.selectedBackgroundColor
        : _isHovered
        ? widget.style.hoverBackgroundColor
        : widget.style.backgroundColor;
    final borderColor = widget.isSelected
        ? widget.style.selectedBorderColor
        : _isHovered
        ? widget.style.hoverBorderColor
        : widget.style.borderColor;

    final onPressed = widget.onPressed;
    final isInteractive = onPressed != null;

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) {
        if (!isInteractive) {
          return;
        }
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        if (!isInteractive) {
          return;
        }
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: borderColor,
              width: widget.isSelected || _isHovered ? 1 : 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: signature.title),
                            if (signature.participantCount > 1)
                              TextSpan(
                                text: ' +${signature.participantCount}',
                                style: widget.style.participantSuffixStyle,
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: widget.isSelected
                            ? widget.style.selectedTitleStyle
                            : widget.style.titleStyle,
                      ),
                    ),
                    if (signature.titleContextLabel != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        signature.titleContextLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            widget.style.titleContextStyle ??
                            widget.style.participantSuffixStyle,
                      ),
                    ],
                    if (widget.trailing != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      widget.trailing!,
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                _ConversationMonthGlyph(
                  months: signature.activityMonths,
                  highlightedMonth: signature.highlightedMonth,
                  monthColorForMessageCount: widget.monthColorForMessageCount,
                  monthHighlightColor:
                      widget.style.monthHighlightColor ??
                      widget.style.emptyMonthBorderColor,
                  emptyMonthBorderColor: widget.style.emptyMonthBorderColor,
                ),
                const SizedBox(height: 5),
                Text.rich(
                  _signatureSummarySpan(
                    signature,
                    baseStyle: widget.style.summaryStyle,
                    highlightStyle:
                        widget.style.summaryHighlightStyle ??
                        widget.style.summaryStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationMonthGlyph extends StatelessWidget {
  const _ConversationMonthGlyph({
    required this.months,
    required this.highlightedMonth,
    required this.monthColorForMessageCount,
    required this.monthHighlightColor,
    required this.emptyMonthBorderColor,
  });

  final List<ConversationSignatureMonth> months;
  final ConversationSignatureMonthMarker? highlightedMonth;
  final Color Function(int messageCount) monthColorForMessageCount;
  final Color monthHighlightColor;
  final Color emptyMonthBorderColor;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return const SizedBox(height: 9);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _glyphColumnsForWidth(constraints.maxWidth);
        final anchoredMonths = _anchorMonthsToNow(months);
        final rows = _chunkMonthsFromNewest(anchoredMonths, columns: columns);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final row in rows) ...[
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var index = 0; index < row.length; index++) ...[
                      if (index > 0) const SizedBox(width: _glyphSpacing),
                      _MonthGlyphDot(
                        month: row[index],
                        isHighlighted:
                            highlightedMonth?.matches(row[index]) ?? false,
                        emptyColor: emptyMonthBorderColor,
                        highlightColor: monthHighlightColor,
                        monthColorForMessageCount: monthColorForMessageCount,
                      ),
                    ],
                  ],
                ),
              ),
              if (row != rows.last) const SizedBox(height: _glyphSpacing),
            ],
          ],
        );
      },
    );
  }
}

class _MonthGlyphDot extends StatelessWidget {
  const _MonthGlyphDot({
    required this.month,
    required this.isHighlighted,
    required this.emptyColor,
    required this.highlightColor,
    required this.monthColorForMessageCount,
  });

  final ConversationSignatureMonth month;
  final bool isHighlighted;
  final Color emptyColor;
  final Color highlightColor;
  final Color Function(int messageCount) monthColorForMessageCount;

  @override
  Widget build(BuildContext context) {
    final size = month.messageCount <= 0 ? _emptyGlyphDotSize : _glyphDotSize;
    final fillColor = month.messageCount <= 0
        ? null
        : monthColorForMessageCount(month.messageCount);
    final dot = DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: month.messageCount <= 0
            ? Border.all(color: emptyColor.withValues(alpha: 0.38))
            : null,
      ),
      child: SizedBox(width: size, height: size),
    );

    if (!isHighlighted) {
      return dot;
    }

    return DecoratedBox(
      key: ValueKey(
        'conversation-signature-highlighted-month-${month.year}-${month.month}',
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: highlightColor, width: 1),
      ),
      child: Padding(padding: const EdgeInsets.all(1.5), child: dot),
    );
  }
}

int _glyphColumnsForWidth(double maxWidth) {
  if (!maxWidth.isFinite || maxWidth <= 0) {
    return _fallbackGlyphColumns;
  }
  return math.max(
    1,
    ((maxWidth + _glyphSpacing) / (_glyphDotSize + _glyphSpacing)).floor(),
  );
}

List<ConversationSignatureMonth> _anchorMonthsToNow(
  List<ConversationSignatureMonth> months,
) {
  final counts = <String, int>{
    for (final month in months)
      _monthKey(month.year, month.month): month.messageCount,
  };
  final firstMonth = months.first;
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final anchoredMonths = <ConversationSignatureMonth>[];

  var cursor = DateTime(firstMonth.year, firstMonth.month);
  while (!cursor.isAfter(currentMonth)) {
    anchoredMonths.add(
      ConversationSignatureMonth(
        year: cursor.year,
        month: cursor.month,
        messageCount: counts[_monthKey(cursor.year, cursor.month)] ?? 0,
      ),
    );
    cursor = DateTime(cursor.year, cursor.month + 1);
  }

  return anchoredMonths;
}

List<List<ConversationSignatureMonth>> _chunkMonthsFromNewest(
  List<ConversationSignatureMonth> months, {
  required int columns,
}) {
  final rowsNewestFirst = <List<ConversationSignatureMonth>>[];
  for (var end = months.length; end > 0; end -= columns) {
    final start = math.max(0, end - columns);
    rowsNewestFirst.add(months.sublist(start, end));
  }
  return rowsNewestFirst.reversed.toList(growable: false);
}

TextSpan _signatureSummarySpan(
  ConversationSignatureCardData signature, {
  required TextStyle baseStyle,
  required TextStyle highlightStyle,
}) {
  TextSpan span(String text, {required bool isHighlighted}) {
    return TextSpan(
      text: text,
      style: isHighlighted ? highlightStyle : baseStyle,
    );
  }

  final messageCount = _formatCount(signature.messageCount);
  final firstDate = _formatDate(signature.firstMessageAtUtc);
  final lastDate = _formatDate(signature.lastMessageAtUtc);
  final highlight = signature.summaryHighlight;

  final children = <TextSpan>[
    span(
      '$messageCount ${signature.messageCount == 1 ? 'message' : 'messages'}',
      isHighlighted:
          highlight == ConversationSignatureSummaryHighlight.messageCount,
    ),
    span(' • ', isHighlighted: false),
    ..._dateRangeSpans(
      firstDate: firstDate,
      lastDate: lastDate,
      highlight: highlight,
      span: span,
    ),
  ];
  return TextSpan(children: children);
}

List<TextSpan> _dateRangeSpans({
  required String firstDate,
  required String lastDate,
  required ConversationSignatureSummaryHighlight highlight,
  required TextSpan Function(String text, {required bool isHighlighted}) span,
}) {
  final highlightFirst =
      highlight == ConversationSignatureSummaryHighlight.firstDate ||
      highlight == ConversationSignatureSummaryHighlight.dateRange;
  final highlightLast =
      highlight == ConversationSignatureSummaryHighlight.lastDate ||
      highlight == ConversationSignatureSummaryHighlight.dateRange;

  if (firstDate.isEmpty && lastDate.isEmpty) {
    return [span('no dated messages', isHighlighted: false)];
  }
  if (firstDate.isEmpty) {
    return [
      span('through ', isHighlighted: false),
      span(lastDate, isHighlighted: highlightLast),
    ];
  }
  if (lastDate.isEmpty || firstDate == lastDate) {
    return [span(firstDate, isHighlighted: highlightFirst || highlightLast)];
  }
  return [
    span(firstDate, isHighlighted: highlightFirst),
    span(
      ' - ',
      isHighlighted:
          highlight == ConversationSignatureSummaryHighlight.dateRange,
    ),
    span(lastDate, isHighlighted: highlightLast),
  ];
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return '$value';
}

String _formatDate(String? value) {
  return DateLabelFormatter.sortableDateFromIso(value, fallback: value) ?? '';
}

String _monthKey(int year, int month) {
  return DateLabelFormatter.monthKey(DateTime(year, month));
}

const int _fallbackGlyphColumns = 24;
const double _glyphDotSize = 6;
const double _emptyGlyphDotSize = 5;
const double _glyphSpacing = 3;
