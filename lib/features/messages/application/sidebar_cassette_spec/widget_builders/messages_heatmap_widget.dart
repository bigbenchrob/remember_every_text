import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../../presentation/view_model/timeline/message_timeline_view_model_provider.dart';
import '../../../presentation/view_model/timeline/ordinal/current_visible_month_provider.dart';
import '../../../presentation/widgets/calendar_heatmap_timeline_widget.dart';
import '../resolver_tools/contact_timeline_provider.dart';
import '../resolver_tools/global_messages_heatmap_provider.dart';

/// Widget builder for the messages heatmap cassette.
///
/// Displays a calendar heatmap of message activity, either globally or scoped
/// to a specific contact.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
/// - Never make branching decisions about which UI to show
class MessagesHeatmapWidget extends ConsumerWidget {
  const MessagesHeatmapWidget({this.contactId, super.key});

  final int? contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = contactId == null
        ? ref.watch(globalMessagesHeatmapProvider)
        : ref.watch(contactTimelineProvider(contactId: contactId!));

    return timelineAsync.when(
      data: (timeline) {
        if (contactId == null) {
          return _GlobalHeatmapContent(data: timeline);
        }

        return _ContactHeatmapContent(contactId: contactId!, data: timeline);
      },
      loading: () => const _HeatmapLoadingCard(),
      error: (error, _) => _HeatmapErrorCard(
        message: 'Unable to load heatmap data. $error',
        onRetry: () {
          if (contactId == null) {
            ref.invalidate(globalMessagesHeatmapProvider);
          } else {
            ref.invalidate(contactTimelineProvider(contactId: contactId!));
          }
        },
      ),
    );
  }
}

class _GlobalHeatmapContent extends ConsumerWidget {
  const _GlobalHeatmapContent({required this.data});

  final CalendarHeatmapTimelineData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data == null) {
      return const _EmptyHeatmapCard(
        message: 'Import messages to see how your conversations ebb and flow.',
        icon: CupertinoIcons.chart_bar_alt_fill,
      );
    }

    final timeline = data!;

    final selectedMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: const MessageTimelineScope.global(),
      ),
    );
    return MessageHeatmapContent(
      data: timeline,
      selectedMonthKey: selectedMonthAsync.valueOrNull,
      onMonthTap: (year, month, count) {
        if (count <= 0) {
          return;
        }

        final isLastMonth =
            year == timeline.lastMessageDate.year &&
            month == timeline.lastMessageDate.month;
        final startDate = isLastMonth ? null : DateTime(year, month, 1);

        ref.read(sidebarFlowProvider.notifier).showGlobalTimelineAt(startDate);
      },
    );
  }
}

class _ContactHeatmapContent extends ConsumerWidget {
  const _ContactHeatmapContent({required this.contactId, required this.data});

  final int contactId;
  final CalendarHeatmapTimelineData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data == null) {
      return const _EmptyHeatmapCard(
        message: 'Select a contact or choose one with messages to plot.',
        icon: CupertinoIcons.person_crop_circle_badge_exclam,
      );
    }

    final timeline = data!;
    final selectedMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: MessageTimelineScope.contact(contactId: contactId),
      ),
    );
    return MessageHeatmapContent(
      data: timeline,
      selectedMonthKey: selectedMonthAsync.valueOrNull,
      onMonthTap: (year, month, count) {
        if (count <= 0) {
          return;
        }

        final isLastMonth =
            year == timeline.lastMessageDate.year &&
            month == timeline.lastMessageDate.month;

        if (isLastMonth) {
          final scope = MessageTimelineScope.contact(contactId: contactId);
          ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .jumpToLatest();
        } else {
          final startDate = DateTime(year, month, 1);
          final scope = MessageTimelineScope.contact(contactId: contactId);
          ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .jumpToDate(startDate);
        }
      },
    );
  }
}

class MessageHeatmapContent extends ConsumerWidget {
  const MessageHeatmapContent({
    required this.data,
    required this.selectedMonthKey,
    required this.onMonthTap,
    this.monthTooltipBuilder,
    this.legend = const MessageHeatmapLegend(),
    this.hintText = 'Tap a square to jump to that month',
    super.key,
  });

  final CalendarHeatmapTimelineData data;
  final String? selectedMonthKey;
  final void Function(int year, int month, int count) onMonthTap;
  final String? Function(MonthData monthData)? monthTooltipBuilder;
  final Widget? legend;
  final String hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    final summaryText =
        '${NumberFormat.decimalPattern().format(data.totalMessages)} messages '
        '• ${_formatDateRange(data.firstMessageDate, data.lastMessageDate)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(summaryText, style: typography.vizMeta),
        const SizedBox(height: AppSpacing.cassetteContentGap),
        CalendarHeatmapTimelineWidget(
          data: data,
          monthSize: 12,
          monthSpacing: 2,
          selectedMonthKey: selectedMonthKey,
          monthTooltipBuilder: monthTooltipBuilder,
          onMonthTap: onMonthTap,
        ),
        if (legend != null) ...[
          const SizedBox(height: AppSpacing.cassetteContentGap),
          legend!,
        ],
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.cassetteHintGap),
          child: Text(hintText, style: typography.caption, softWrap: true),
        ),
      ],
    );
  }
}

class MessageHeatmapLegend extends ConsumerWidget {
  const MessageHeatmapLegend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _LegendItem(label: '1-3', swatch: _DotLegendSwatch()),
        _LegendItem(label: '4-10', intensity: MonthIntensity.lightGray),
        _LegendItem(label: '11-30', intensity: MonthIntensity.mediumGray),
        _LegendItem(label: '31-50', intensity: MonthIntensity.darkGray),
        _LegendItem(label: '51-75', intensity: MonthIntensity.paleYellow),
        _LegendItem(label: '76-100', intensity: MonthIntensity.lightYellow),
        _LegendItem(label: '101-150', intensity: MonthIntensity.mediumYellow),
        _LegendItem(label: '151-200', intensity: MonthIntensity.darkYellow),
        _LegendItem(label: '201-500', intensity: MonthIntensity.lightGreen),
        _LegendItem(label: '501-1K', intensity: MonthIntensity.mediumGreen),
        _LegendItem(label: '1K-2K', intensity: MonthIntensity.darkGreen),
      ],
    );
  }
}

class _LegendItem extends ConsumerWidget {
  const _LegendItem({required this.label, this.intensity, this.swatch});

  final String label;
  final MonthIntensity? intensity;
  final Widget? swatch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch ?? _ColorLegendSwatch(intensity: intensity!),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: typography.caption),
      ],
    );
  }
}

class _ColorLegendSwatch extends StatelessWidget {
  const _ColorLegendSwatch({required this.intensity});

  final MonthIntensity intensity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: calendarHeatmapColorForIntensity(intensity),
        borderRadius: BorderRadius.circular(2),
      ),
      child: const SizedBox(width: 10, height: 10),
    );
  }
}

class _DotLegendSwatch extends StatelessWidget {
  const _DotLegendSwatch();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 10,
      height: 10,
      child: Center(
        child: Text(
          '...',
          style: TextStyle(fontSize: 8, height: 1, color: Color(0xFF999999)),
        ),
      ),
    );
  }
}

class _HeatmapLoadingCard extends StatelessWidget {
  const _HeatmapLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: ProgressCircle(radius: 10),
      ),
    );
  }
}

class _HeatmapErrorCard extends ConsumerWidget {
  const _HeatmapErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: CupertinoColors.systemRed,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: t.caption.copyWith(color: CupertinoColors.systemRed),
                ),
                const SizedBox(height: AppSpacing.sm),
                PushButton(
                  controlSize: ControlSize.small,
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHeatmapCard extends ConsumerWidget {
  const _EmptyHeatmapCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final t = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.content.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: t.caption.copyWith(color: colors.content.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateRange(DateTime start, DateTime end) {
  final formatter = DateFormat('MMM yyyy');
  final startLabel = formatter.format(start);
  final endLabel = formatter.format(end);
  return startLabel == endLabel ? startLabel : '$startLabel → $endLabel';
}
