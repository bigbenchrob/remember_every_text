import '../../../../../core/util/date_label_formatter.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';

CalendarHeatmapTimelineData? buildRecoveredMessagesHeatmapData({
  required List<DateTime> sentDates,
}) {
  if (sentDates.isEmpty) {
    return null;
  }

  final sortedDates = [...sentDates]..sort();
  final firstDate = sortedDates.first;
  final lastDate = sortedDates.last;

  final counts = <String, int>{};
  for (final sentDate in sortedDates) {
    final key = DateLabelFormatter.monthKey(sentDate);
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final firstMonth = DateTime(firstDate.year, firstDate.month);
  final yearRows = <YearRow>[];
  var maxMonthCount = 0;

  for (var year = firstDate.year; year <= lastDate.year; year += 1) {
    final months = <MonthData>[];
    var yearHasMessages = false;

    for (var month = 1; month <= 12; month += 1) {
      final key = DateLabelFormatter.monthKey(DateTime(year, month));
      final count = counts[key] ?? 0;
      final monthDate = DateTime(year, month);
      final isBeforeStart = monthDate.isBefore(firstMonth);

      if (!isBeforeStart && count > 0) {
        yearHasMessages = true;
        if (count > maxMonthCount) {
          maxMonthCount = count;
        }
      }

      final intensity = isBeforeStart
          ? MonthIntensity.notYetStarted
          : MonthIntensity.fromMessageCount(count);

      months.add(
        MonthData(
          year: year,
          month: month,
          messageCount: count,
          intensity: intensity,
          chatId: 0,
        ),
      );
    }

    yearRows.add(
      YearRow(year: year, months: months, hasMessages: yearHasMessages),
    );
  }

  return CalendarHeatmapTimelineData(
    yearRows: yearRows,
    firstMessageDate: firstDate,
    lastMessageDate: lastDate,
    totalMessages: sortedDates.length,
    maxMonthCount: maxMonthCount,
  );
}
