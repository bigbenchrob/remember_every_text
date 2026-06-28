import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../../essentials/conversation_graph/feature_level_providers.dart'
    show messageGraphReaderProvider;
import '../../../../../essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../domain/calendar_heatmap_timeline_data.dart';

part 'global_messages_heatmap_provider.g.dart';

/// Provides a calendar heatmap timeline spanning the entire message archive.
@riverpod
Future<CalendarHeatmapTimelineData?> globalMessagesHeatmap(
  GlobalMessagesHeatmapRef ref,
) async {
  // Watch message data version so we rebuild when new messages are imported.
  ref.watch(messageDataVersionProvider);

  final reader = await ref.watch(messageGraphReaderProvider.future);
  return _buildGraphGlobalTimeline(await reader.readGlobalMessageTimeline());
}

CalendarHeatmapTimelineData? _buildGraphGlobalTimeline(
  List<ConversationMessageTimelineEntry> entries,
) {
  final datedEntries = [
    for (final entry in entries)
      if (entry.dateUtc != null && DateTime.tryParse(entry.dateUtc!) != null)
        (date: DateTime.parse(entry.dateUtc!), monthKey: entry.monthKey),
  ];
  if (datedEntries.isEmpty) {
    return null;
  }

  datedEntries.sort((left, right) => left.date.compareTo(right.date));
  final firstDate = datedEntries.first.date;
  final lastDate = datedEntries.last.date;
  final counts = <String, int>{};
  for (final entry in datedEntries) {
    final key =
        entry.monthKey ??
        '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final firstYear = firstDate.year;
  final lastYear = lastDate.year;
  final firstMonth = DateTime(firstDate.year, firstDate.month);
  final yearRows = <YearRow>[];
  var totalMessages = 0;
  var maxMonthCount = 0;

  for (var year = firstYear; year <= lastYear; year++) {
    final months = <MonthData>[];
    var yearHasMessages = false;

    for (var month = 1; month <= 12; month++) {
      final key = '$year-${month.toString().padLeft(2, '0')}';
      final monthDate = DateTime(year, month);
      final isBeforeStart = monthDate.isBefore(firstMonth);
      final count = isBeforeStart ? 0 : counts[key] ?? 0;

      if (count > 0) {
        yearHasMessages = true;
        totalMessages += count;
        if (count > maxMonthCount) {
          maxMonthCount = count;
        }
      }

      months.add(
        MonthData(
          year: year,
          month: month,
          messageCount: count,
          intensity: isBeforeStart
              ? MonthIntensity.notYetStarted
              : MonthIntensity.fromMessageCount(count),
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
    totalMessages: totalMessages,
    maxMonthCount: maxMonthCount,
  );
}
