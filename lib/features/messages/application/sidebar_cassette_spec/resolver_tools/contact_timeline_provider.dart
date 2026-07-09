import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/util/date_label_formatter.dart';
import '../../../../../essentials/conversation_graph/application/contacts/contact_graph.dart';
import '../../../../../essentials/conversation_graph/feature_level_providers.dart'
    show
        contactPageGraphHandleMessageTimelineProvider,
        contactPageGraphSnapshotProvider;
import '../../../../../essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../domain/calendar_heatmap_timeline_data.dart';

part 'contact_timeline_provider.g.dart';

/// Provides calendar heatmap timeline data for a contact's message history
/// across all their chats/handles.
///
/// This is a resolver tool: a data-fetching provider used by resolvers and
/// widget builders. It derives the timeline from graph contact activity.
@riverpod
Future<CalendarHeatmapTimelineData?> contactTimeline(
  Ref ref, {
  required int contactId,
  int? filterHandleId,
}) async {
  ref.watch(messageDataVersionProvider);

  return filterHandleId == null
      ? _readGraphContactTimeline(ref, contactId: contactId)
      : _readGraphContactHandleTimeline(
          ref,
          contactId: contactId,
          handleId: filterHandleId,
        );
}

Future<CalendarHeatmapTimelineData?> _readGraphContactTimeline(
  Ref ref, {
  required int contactId,
}) async {
  final snapshot = await ref.watch(
    contactPageGraphSnapshotProvider(contactId: contactId).future,
  );
  return _buildGraphContactTimeline(
    contactId: contactId,
    activity: snapshot.messageActivity,
  );
}

Future<CalendarHeatmapTimelineData?> _readGraphContactHandleTimeline(
  Ref ref, {
  required int contactId,
  required int handleId,
}) async {
  final entries = await ref.watch(
    contactPageGraphHandleMessageTimelineProvider(
      contactId: contactId,
      handleId: handleId,
    ).future,
  );
  return _buildGraphTimelineFromEntries(contactId: contactId, entries: entries);
}

CalendarHeatmapTimelineData? _buildGraphContactTimeline({
  required int contactId,
  ContactMessageActivity? activity,
}) {
  if (activity == null || activity.monthCounts.isEmpty) {
    return null;
  }
  final firstDate = DateTime.tryParse(activity.firstMessageAtUtc);
  final lastDate = DateTime.tryParse(activity.lastMessageAtUtc);
  if (firstDate == null || lastDate == null) {
    return null;
  }

  final counts = <String, int>{
    for (final monthCount in activity.monthCounts)
      DateLabelFormatter.monthKey(DateTime(monthCount.year, monthCount.month)):
          monthCount.messageCount,
  };
  final firstYear = firstDate.year;
  final lastYear = lastDate.year;
  final contactStartMonth = DateTime(firstDate.year, firstDate.month);
  final yearRows = <YearRow>[];
  var totalMessages = 0;
  var maxMonthCount = 0;

  for (var year = firstYear; year <= lastYear; year++) {
    final months = <MonthData>[];
    var yearHasMessages = false;
    for (var month = 1; month <= 12; month++) {
      final monthDate = DateTime(year, month);
      final isBeforeStart = monthDate.isBefore(contactStartMonth);
      final key = DateLabelFormatter.monthKey(DateTime(year, month));
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
          chatId: contactId,
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

CalendarHeatmapTimelineData? _buildGraphTimelineFromEntries({
  required int contactId,
  required List<ContactGraphMessageTimelineEntry> entries,
}) {
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
    final key = entry.monthKey ?? DateLabelFormatter.monthKey(entry.date);
    counts[key] = (counts[key] ?? 0) + 1;
  }

  return _buildGraphTimelineFromMonthCounts(
    contactId: contactId,
    firstDate: firstDate,
    lastDate: lastDate,
    counts: counts,
  );
}

CalendarHeatmapTimelineData _buildGraphTimelineFromMonthCounts({
  required int contactId,
  required DateTime firstDate,
  required DateTime lastDate,
  required Map<String, int> counts,
}) {
  final firstYear = firstDate.year;
  final lastYear = lastDate.year;
  final contactStartMonth = DateTime(firstDate.year, firstDate.month);
  final yearRows = <YearRow>[];
  var totalMessages = 0;
  var maxMonthCount = 0;

  for (var year = firstYear; year <= lastYear; year++) {
    final months = <MonthData>[];
    var yearHasMessages = false;
    for (var month = 1; month <= 12; month++) {
      final monthDate = DateTime(year, month);
      final isBeforeStart = monthDate.isBefore(contactStartMonth);
      final key = DateLabelFormatter.monthKey(DateTime(year, month));
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
          chatId: contactId,
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
