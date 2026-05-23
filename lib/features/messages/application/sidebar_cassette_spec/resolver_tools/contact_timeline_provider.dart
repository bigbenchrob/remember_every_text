import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/conversation_graph/application/contacts/contact_graph.dart';
import '../../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../chats/application/chat_read_model_source_provider.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../timeline/contact_timeline_display_version_provider.dart';
import 'contact_timeline_calculator.dart';

part 'contact_timeline_provider.g.dart';

/// Provides calendar heatmap timeline data for a contact's message history
/// across all their chats/handles.
///
/// This is a resolver tool: a data-fetching provider used by resolvers and
/// widget builders. It queries date bounds from `contact_message_index` then
/// delegates computation to [calculateContactCalendarHeatmapTimeline].
@riverpod
Future<CalendarHeatmapTimelineData?> contactTimeline(
  Ref ref, {
  required int contactId,
}) async {
  ref.watch(
    contactTimelineDisplayVersionProvider(
      scope: MessageTimelineScope.contact(contactId: contactId),
    ),
  );

  if (ref.watch(chatReadModelSourceProvider) ==
      ChatReadModelSourceMode.conversationGraph) {
    try {
      final snapshot = await ref.watch(
        contactPageGraphSnapshotProvider(contactId: contactId).future,
      );
      final graphTimeline = _buildGraphContactTimeline(
        contactId: contactId,
        activity: snapshot.messageActivity,
      );
      if (graphTimeline != null) {
        return graphTimeline;
      }
    } on Object {
      // Graph contact identity is still being adopted by legacy contact pages.
      // Fall through to the legacy heatmap rather than rendering a blank card.
    }
  }

  final readiness = await ref.watch(workingProjectionReadinessProvider.future);
  if (!readiness.isReady) {
    return null;
  }

  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  final datesQuery = await db
      .customSelect(
        '''
    SELECT
      MIN(sent_at_utc) as first_date,
      MAX(sent_at_utc) as last_date
    FROM contact_message_index
    WHERE contact_id = ?
      AND sent_at_utc IS NOT NULL
      AND sent_at_utc != ''
    ''',
        variables: [drift.Variable.withInt(contactId)],
        readsFrom: {db.contactMessageIndex},
      )
      .getSingleOrNull();

  if (datesQuery == null) {
    return null;
  }

  final firstUtc = datesQuery.read<String?>('first_date');
  final lastUtc = datesQuery.read<String?>('last_date');

  final firstDate = (firstUtc != null && firstUtc.isNotEmpty)
      ? DateTime.tryParse(firstUtc)
      : null;
  final lastDate = (lastUtc != null && lastUtc.isNotEmpty)
      ? DateTime.tryParse(lastUtc)
      : null;

  if (firstDate == null || lastDate == null) {
    return null;
  }

  return calculateContactCalendarHeatmapTimeline(
    db,
    contactId,
    firstDate,
    lastDate,
  );
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
      '${monthCount.year}-${monthCount.month.toString().padLeft(2, '0')}':
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
      final key = '$year-${month.toString().padLeft(2, '0')}';
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
