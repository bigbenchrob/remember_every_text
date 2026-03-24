import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../../essentials/sidebar/presentation/view/sidebar_cassette_card.dart';
import '../../application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart';
import '../../application/view_spec/resolver_tools/recovered_messages_heatmap_data.dart';
import '../../application/view_spec/resolver_tools/recovered_visible_month_provider.dart';
import '../../domain/calendar_heatmap_timeline_data.dart';
import '../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';

class RecoveredMessagesHeatmapSidebar extends ConsumerWidget {
  const RecoveredMessagesHeatmapSidebar({
    this.contactId,
    this.scrollToDate,
    this.onlyNoHandleFromMe = false,
    super.key,
  });

  final int? contactId;
  final DateTime? scrollToDate;
  final bool onlyNoHandleFromMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    final visibleMonthKey = ref.watch(
      recoveredVisibleMonthProvider(
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ),
    );
    final asyncMessages = ref.watch(
      recoveredUnlinkedMessagesProvider(contactId: contactId),
    );

    return SidebarCassetteCard(
      title: '',
      child: asyncMessages.when(
        data: (messages) {
          final filteredMessages = _filterRecoveredMessages(
            messages: messages,
            onlyNoHandleFromMe: onlyNoHandleFromMe,
          );
          final sentDates = filteredMessages
              .map((message) => message.sentAt)
              .whereType<DateTime>()
              .toList(growable: false);
          final heatmapData = buildRecoveredMessagesHeatmapData(
            sentDates: sentDates,
          );

          if (heatmapData == null) {
            return Text(
              'No recovered messages with dates are available for a heatmap yet.',
              style: typography.caption1,
            );
          }

          return MessageHeatmapContent(
            data: heatmapData,
            selectedMonthKey: visibleMonthKey ?? _monthKeyFor(scrollToDate),
            monthTooltipBuilder: (monthData) {
              if (monthData.intensity.isNotYetStarted) {
                return null;
              }

              return _buildRecoveredMonthTooltip(
                monthData: monthData,
                onlyNoHandleFromMe: onlyNoHandleFromMe,
              );
            },
            onMonthTap: (year, month, count) {
              if (count <= 0) {
                return;
              }

              final startDate = DateTime(year, month, 1);
              if (onlyNoHandleFromMe) {
                ref
                    .read(sidebarFlowProvider.notifier)
                    .showRecoveredNoHandleFromMe(scrollToDate: startDate);
                return;
              }

              ref
                  .read(sidebarFlowProvider.notifier)
                  .showRecoveredDeletedAt(
                    contactId: contactId,
                    startDate: startDate,
                  );
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Center(child: ProgressCircle(radius: 10)),
        ),
        error: (error, _) => Text(
          'Unable to load recovered heatmap data. $error',
          style: typography.caption1,
        ),
      ),
    );
  }
}

List<RecoveredUnlinkedMessageItem> _filterRecoveredMessages({
  required List<RecoveredUnlinkedMessageItem> messages,
  required bool onlyNoHandleFromMe,
}) {
  if (!onlyNoHandleFromMe) {
    return messages;
  }

  return messages
      .where((message) {
        return message.isFromMe && message.senderHandleId == null;
      })
      .toList(growable: false);
}

String? _monthKeyFor(DateTime? date) {
  if (date == null) {
    return null;
  }
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

String _buildRecoveredMonthTooltip({
  required MonthData monthData,
  required bool onlyNoHandleFromMe,
}) {
  final monthLabel = DateFormat(
    'MMMM yyyy',
  ).format(DateTime(monthData.year, monthData.month));

  if (monthData.messageCount == 0) {
    return onlyNoHandleFromMe
        ? '$monthLabel\nNo recovered no-handle outgoing messages'
        : '$monthLabel\nNo recovered deleted messages';
  }

  final countLabel = NumberFormat.decimalPattern().format(
    monthData.messageCount,
  );

  return onlyNoHandleFromMe
      ? '$monthLabel\n$countLabel recovered no-handle outgoing messages'
      : '$monthLabel\n$countLabel recovered deleted messages';
}
