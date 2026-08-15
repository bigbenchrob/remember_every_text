import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' show MacosTooltip;

import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/heatmap/activity_heatmap_color_scale.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../domain/calendar_heatmap_timeline_data.dart';

/// Renders a calendar heatmap timeline visualization
///
/// Each month is displayed as a fixed-size rectangle (or dots for sparse data)
/// colored by message intensity. Years wrap to multiple rows if needed.
///
/// Visual encoding has two deliberate regimes:
/// - 0 messages: Empty month
/// - 1-3 messages: Literal sparse-message dots
/// - 4-50 messages: Neutral sparse-activity gray ramp
/// - 51+ messages: Explicit approximately logarithmic categories forming one
///   sequential yellow-green-teal-blue-purple active-activity scale
///
/// The dark-gray to bright-yellow transition is intentional: chromatic color
/// marks the semantic boundary between sparse and sustained activity. Within
/// the active regime, increasing counts become progressively darker.
class CalendarHeatmapTimelineWidget extends ConsumerWidget {
  const CalendarHeatmapTimelineWidget({
    required this.data,
    this.monthSize = 14.0,
    this.monthSpacing = 2.0,
    required this.onMonthTap,
    this.selectedMonthKey,
    this.monthTooltipBuilder,
    super.key,
  });

  final CalendarHeatmapTimelineData data;
  final double monthSize;
  final double monthSpacing;

  /// Caller-owned tap handler. Heatmap widgets render timeline data; they do
  /// not choose message evidence routes.
  final void Function(int year, int month, int messageCount) onMonthTap;

  /// Currently selected/visible month in format "YYYY-MM"
  final String? selectedMonthKey;

  /// Optional hover text builder for month cells.
  final String? Function(MonthData monthData)? monthTooltipBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.yearRows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group years into display rows based on wrapping rules
    final groups = data.wrappedYearRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final group in groups)
          _YearRowsGroup(
            yearRows: group,
            monthSize: monthSize,
            monthSpacing: monthSpacing,
            onMonthTap: onMonthTap,
            selectedMonthKey: selectedMonthKey,
            monthTooltipBuilder: monthTooltipBuilder,
          ),
      ],
    );
  }
}

/// A group of year rows (wraps years into display rows)
class _YearRowsGroup extends StatelessWidget {
  const _YearRowsGroup({
    required this.yearRows,
    required this.monthSize,
    required this.monthSpacing,
    required this.onMonthTap,
    this.selectedMonthKey,
    this.monthTooltipBuilder,
  });

  final List<YearRow> yearRows;
  final double monthSize;
  final double monthSpacing;
  final void Function(int year, int month, int messageCount) onMonthTap;
  final String? selectedMonthKey;
  final String? Function(MonthData monthData)? monthTooltipBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final yearRow in yearRows) ...[
          _SingleYearRow(
            yearRow: yearRow,
            monthSize: monthSize,
            monthSpacing: monthSpacing,
            onMonthTap: onMonthTap,
            selectedMonthKey: selectedMonthKey,
            monthTooltipBuilder: monthTooltipBuilder,
          ),
          SizedBox(height: monthSpacing * 2),
        ],
      ],
    );
  }
}

/// A single year row: year label + 12 month cells
class _SingleYearRow extends ConsumerWidget {
  const _SingleYearRow({
    required this.yearRow,
    required this.monthSize,
    required this.monthSpacing,
    required this.onMonthTap,
    this.selectedMonthKey,
    this.monthTooltipBuilder,
  });

  final YearRow yearRow;
  final double monthSize;
  final double monthSpacing;
  final void Function(int year, int month, int messageCount) onMonthTap;
  final String? selectedMonthKey;
  final String? Function(MonthData monthData)? monthTooltipBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Year label
        SizedBox(
          width: 32,
          child: Text(
            yearRow.year.toString(),
            style: typography.vizAxisLabel.copyWith(fontSize: 10),
          ),
        ),
        SizedBox(width: monthSpacing * 2),

        // 12 months
        for (var i = 0; i < 12; i++) ...[
          if (i > 0) SizedBox(width: monthSpacing),
          _MonthCell(
            monthData: yearRow.months[i],
            size: monthSize,
            onMonthTap: onMonthTap,
            isSelected: _isMonthSelected(yearRow.months[i]),
            monthTooltipBuilder: monthTooltipBuilder,
          ),
        ],
      ],
    );
  }

  bool _isMonthSelected(MonthData month) {
    if (selectedMonthKey == null) {
      return false;
    }
    final monthKey = DateLabelFormatter.monthKey(
      DateTime(month.year, month.month),
    );
    return monthKey == selectedMonthKey;
  }
}

/// A single month cell - clickable, shows dots or colored rectangle
class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.monthData,
    required this.size,
    required this.onMonthTap,
    this.isSelected = false,
    this.monthTooltipBuilder,
  });

  final MonthData monthData;
  final double size;
  final void Function(int year, int month, int messageCount) onMonthTap;
  final bool isSelected;
  final String? Function(MonthData monthData)? monthTooltipBuilder;

  void _handleTap() {
    // Don't navigate for notYetStarted or empty months
    if (monthData.intensity.isNotYetStarted || monthData.messageCount == 0) {
      return;
    }

    onMonthTap(monthData.year, monthData.month, monthData.messageCount);
  }

  @override
  Widget build(BuildContext context) {
    Widget cellContent;

    if (monthData.intensity.isNotYetStarted) {
      // Month before chat started - show empty space
      cellContent = SizedBox(width: size, height: size);
    } else if (monthData.intensity.isEmpty) {
      // Chat active but no messages - show empty square with light grey border
      cellContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD0D0D0), width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (monthData.intensity.shouldRenderAsDots) {
      // 1-3 messages: Show as 6×6 dot matrix
      cellContent = _DotMatrixIndicator(
        count: monthData.messageCount,
        size: size,
      );
    } else {
      // 4+ messages: Show as colored rectangle
      cellContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: activityHeatmapColorForMessageCount(monthData.messageCount),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    // Add pink border if selected
    if (isSelected) {
      cellContent = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF1493), // Deep pink
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: cellContent,
      );
    }

    // Wrap in GestureDetector for click handling (except notYetStarted)
    if (monthData.intensity.isNotYetStarted) {
      return cellContent;
    }

    final tooltipMessage = monthTooltipBuilder?.call(monthData);

    Widget interactiveCell = GestureDetector(
      onTap: _handleTap,
      child: MouseRegion(
        cursor: monthData.messageCount > 0
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: cellContent,
      ),
    );

    if (tooltipMessage != null && tooltipMessage.trim().isNotEmpty) {
      interactiveCell = MacosTooltip(
        message: tooltipMessage,
        child: interactiveCell,
      );
    }

    return interactiveCell;
  }
}

/// Renders a 6×6 dot matrix for 1-3 messages
/// Creates a cacheable visual representation where dots fill from top-left
class _DotMatrixIndicator extends StatelessWidget {
  const _DotMatrixIndicator({required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dotCount = count.clamp(1, 3);

    // 6×6 grid with 1px dots and minimal spacing
    // Total: 6 dots + 5 gaps = needs ~11-12px
    // For 14px cell, use 1px dots with 1px spacing (compressed at edges)
    const gridSize = 6;
    const dotSize = 1.0;
    const spacing = 1.0;
    const totalGridSize = (gridSize * dotSize) + ((gridSize - 1) * spacing);
    final padding = (size - totalGridSize) / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: CustomPaint(
          painter: _DotMatrixPainter(dotCount: dotCount),
          size: const Size(totalGridSize, totalGridSize),
        ),
      ),
    );
  }
}

/// Custom painter for efficient 6×6 dot matrix
class _DotMatrixPainter extends CustomPainter {
  const _DotMatrixPainter({required this.dotCount});

  final int dotCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF999999)
      ..style = PaintingStyle.fill;

    const gridSize = 6;
    const dotSize = 1.0;
    const spacing = 1.0;

    // Fill dots from top-left, row by row
    var dotsDrawn = 0;
    for (var row = 0; row < gridSize && dotsDrawn < dotCount; row++) {
      for (var col = 0; col < gridSize && dotsDrawn < dotCount; col++) {
        final x = col * (dotSize + spacing) + (dotSize / 2);
        final y = row * (dotSize + spacing) + (dotSize / 2);
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
        dotsDrawn++;
      }
    }
  }

  @override
  bool shouldRepaint(_DotMatrixPainter oldDelegate) {
    return oldDelegate.dotCount != dotCount;
  }
}
