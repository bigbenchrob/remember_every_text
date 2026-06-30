import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../application/conversation_signatures/conversation_signature.dart';

class ConversationSignatureCardData {
  const ConversationSignatureCardData({
    required this.conversationId,
    required this.title,
    required this.participantCount,
    required this.messageCount,
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
    required this.activityMonths,
  });

  final int conversationId;
  final String title;
  final int participantCount;
  final int messageCount;
  final String? firstMessageAtUtc;
  final String? lastMessageAtUtc;
  final List<ConversationSignatureMonth> activityMonths;
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
    required this.participantSuffixStyle,
    required this.summaryStyle,
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
  final TextStyle participantSuffixStyle;
  final TextStyle summaryStyle;
  final Color emptyMonthBorderColor;
}

class ConversationSignatureCard extends StatefulWidget {
  const ConversationSignatureCard({
    required this.signature,
    required this.style,
    required this.monthColorForMessageCount,
    required this.onPressed,
    this.isSelected = false,
    this.trailing,
    super.key,
  });

  final ConversationSignatureCardData signature;
  final ConversationSignatureCardStyle style;
  final Color Function(int messageCount) monthColorForMessageCount;
  final VoidCallback onPressed;
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
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
                    if (widget.trailing != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      widget.trailing!,
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                _ConversationMonthGlyph(
                  months: signature.activityMonths,
                  monthColorForMessageCount: widget.monthColorForMessageCount,
                  emptyMonthBorderColor: widget.style.emptyMonthBorderColor,
                ),
                const SizedBox(height: 5),
                Text(
                  _signatureSummary(signature),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.style.summaryStyle,
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
    required this.monthColorForMessageCount,
    required this.emptyMonthBorderColor,
  });

  final List<ConversationSignatureMonth> months;
  final Color Function(int messageCount) monthColorForMessageCount;
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
                        emptyColor: emptyMonthBorderColor,
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
    required this.emptyColor,
    required this.monthColorForMessageCount,
  });

  final ConversationSignatureMonth month;
  final Color emptyColor;
  final Color Function(int messageCount) monthColorForMessageCount;

  @override
  Widget build(BuildContext context) {
    final size = month.messageCount <= 0 ? _emptyGlyphDotSize : _glyphDotSize;

    if (month.messageCount <= 0) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: emptyColor.withValues(alpha: 0.38)),
        ),
        child: SizedBox(width: size, height: size),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: monthColorForMessageCount(month.messageCount),
        shape: BoxShape.circle,
      ),
      child: SizedBox(width: size, height: size),
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

String _signatureSummary(ConversationSignatureCardData signature) {
  final messageCount = _formatCount(signature.messageCount);
  final range = _formatDateRange(
    signature.firstMessageAtUtc,
    signature.lastMessageAtUtc,
  );
  return '$messageCount messages • $range';
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
  if (value == null || value.isEmpty) {
    return '';
  }
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) {
    return value;
  }
  return '${parsed.year}-${_twoDigits(parsed.month)}-${_twoDigits(parsed.day)}';
}

String _formatDateRange(String? firstValue, String? lastValue) {
  final first = _formatDate(firstValue);
  final last = _formatDate(lastValue);
  if (first.isEmpty && last.isEmpty) {
    return 'no dated messages';
  }
  if (first.isEmpty) {
    return 'through $last';
  }
  if (last.isEmpty || first == last) {
    return first;
  }
  return '$first - $last';
}

String _monthKey(int year, int month) {
  return '$year-${month.toString().padLeft(2, '0')}';
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}

const int _fallbackGlyphColumns = 24;
const double _glyphDotSize = 6;
const double _emptyGlyphDotSize = 5;
const double _glyphSpacing = 3;
