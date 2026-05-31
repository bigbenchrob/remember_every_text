import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';
import '../../../domain/message_evidence/message_evidence_scope.dart';
import '../../../presentation/view_model/timeline/current_visible_month_provider.dart';
import '../../../presentation/widgets/calendar_heatmap_timeline_widget.dart';
import '../../../presentation/widgets/contact_graph_conversation_section.dart';
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
    if (contactId != null) {
      return _ContactEvidenceContent(contactId: contactId!);
    }

    final timelineAsync = ref.watch(globalMessagesHeatmapProvider);

    return timelineAsync.when(
      data: (timeline) {
        return _GlobalHeatmapContent(data: timeline);
      },
      loading: () => const _HeatmapLoadingCard(),
      error: (error, _) => _HeatmapErrorCard(
        message: 'Unable to load heatmap data. $error',
        onRetry: () {
          ref.invalidate(globalMessagesHeatmapProvider);
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

    final selectedMonthKey = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: const GlobalMessagesEvidenceScope(),
      ),
    );
    return MessageHeatmapContent(
      data: timeline,
      selectedMonthKey: selectedMonthKey,
      onMonthTap: (year, month, count) {
        if (count <= 0) {
          return;
        }

        final isLastMonth =
            year == timeline.lastMessageDate.year &&
            month == timeline.lastMessageDate.month;
        final monthAnchor = isLastMonth ? null : DateTime(year, month, 1);

        ref
            .read(sidebarActionDispatcherProvider.notifier)
            .dispatch(
              intent: HeatMapMonthFocused(monthAnchor: monthAnchor),
              context: const SidebarActionDispatchContext(
                sidebarMode: SidebarMode.messages,
              ),
            );
      },
    );
  }
}

enum _ContactEvidenceMode { allMessages, conversations }

class _ContactEvidenceContent extends ConsumerWidget {
  const _ContactEvidenceContent({required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final mode =
        flowState.topMenuChoice == TopChatMenuChoice.contacts &&
            _isSameContactContext(flowState.chosenContactId, contactId) &&
            flowState.contactProjection ==
                SidebarFlowContactProjection.conversations
        ? _ContactEvidenceMode.conversations
        : _ContactEvidenceMode.allMessages;

    final body = switch (mode) {
      _ContactEvidenceMode.allMessages => _ContactAllMessagesEvidence(
        contactId: contactId,
      ),
      _ContactEvidenceMode.conversations => ContactGraphConversationSection(
        contactId: contactId,
        padding: EdgeInsets.zero,
        maxHeight: 360,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContactEvidenceModeToggle(
          mode: mode,
          onChanged: (mode) {
            if (mode == _ContactEvidenceMode.allMessages) {
              ref
                  .read(sidebarFlowProvider.notifier)
                  .showContactTimelineAt(contactId: contactId);
            } else {
              ref
                  .read(sidebarFlowProvider.notifier)
                  .showContactConversationNavigator(contactId: contactId);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(width: double.infinity, child: body),
      ],
    );
  }
}

bool _isSameContactContext(int? selectedContactId, int cassetteContactId) {
  if (selectedContactId == null) {
    return false;
  }
  return selectedContactId == cassetteContactId ||
      graphContactIdForContactPage(selectedContactId) == cassetteContactId ||
      graphContactIdForContactPage(cassetteContactId) == selectedContactId ||
      graphContactIdForContactPage(selectedContactId) ==
          graphContactIdForContactPage(cassetteContactId);
}

class _ContactAllMessagesEvidence extends ConsumerWidget {
  const _ContactAllMessagesEvidence({required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final selectedHandleId = flowState.chosenContactId == contactId
        ? flowState.selectedHandleId
        : null;
    final timelineAsync = ref.watch(
      contactTimelineProvider(
        contactId: contactId,
        filterHandleId: selectedHandleId,
      ),
    );

    return timelineAsync.when(
      data: (timeline) {
        if (timeline == null) {
          return const _EmptyHeatmapCard(
            message: 'Select a contact or choose one with messages to plot.',
            icon: CupertinoIcons.person_crop_circle_badge_exclam,
          );
        }

        return _ContactAllMessagesHeatmap(
          contactId: contactId,
          timeline: timeline,
        );
      },
      loading: () => const _HeatmapLoadingCard(),
      error: (error, _) => _HeatmapErrorCard(
        message: 'Unable to load heatmap data. $error',
        onRetry: () {
          ref.invalidate(
            contactTimelineProvider(
              contactId: contactId,
              filterHandleId: selectedHandleId,
            ),
          );
        },
      ),
    );
  }
}

class _ContactAllMessagesHeatmap extends ConsumerWidget {
  const _ContactAllMessagesHeatmap({
    required this.contactId,
    required this.timeline,
  });

  final int contactId;
  final CalendarHeatmapTimelineData timeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(sidebarFlowProvider);
    final selectedHandleId = flowState.chosenContactId == contactId
        ? flowState.selectedHandleId
        : null;
    final selectedMonthKey = ref.watch(
      currentVisibleMonthForScopeProvider(
        scope: _contactEvidenceScope(
          contactId: contactId,
          selectedHandleId: selectedHandleId,
        ),
      ),
    );

    return MessageHeatmapContent(
      data: timeline,
      selectedMonthKey: selectedMonthKey,
      onMonthTap: (year, month, count) {
        if (count <= 0) {
          return;
        }

        final isLastMonth =
            year == timeline.lastMessageDate.year &&
            month == timeline.lastMessageDate.month;

        ref
            .read(sidebarActionDispatcherProvider.notifier)
            .dispatch(
              intent: HeatMapMonthFocused(
                contactId: contactId,
                monthAnchor: isLastMonth ? null : DateTime(year, month, 1),
              ),
              context: const SidebarActionDispatchContext(
                sidebarMode: SidebarMode.messages,
              ),
            );
      },
    );
  }
}

MessageEvidenceScope _contactEvidenceScope({
  required int contactId,
  required int? selectedHandleId,
}) {
  if (selectedHandleId == null) {
    return ContactAllMessagesEvidenceScope(contactId: contactId);
  }
  return ContactHandleMessagesEvidenceScope(
    contactId: contactId,
    handleId: selectedHandleId,
  );
}

class _ContactEvidenceModeToggle extends ConsumerWidget {
  const _ContactEvidenceModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final _ContactEvidenceMode mode;
  final ValueChanged<_ContactEvidenceMode> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return CupertinoSlidingSegmentedControl<_ContactEvidenceMode>(
      groupValue: mode,
      thumbColor: colors.surfaces.selected,
      backgroundColor: colors.surfaces.control,
      children: {
        _ContactEvidenceMode.allMessages: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text('All messages', style: typography.caption),
        ),
        _ContactEvidenceMode.conversations: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text('By conversation', style: typography.caption),
        ),
      },
      onValueChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
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
    final visualizationGap = sidebarCassetteContentGapForSemanticStyle(
      SidebarCassetteSemanticStyle.visualization,
    );
    final summaryText =
        '${NumberFormat.decimalPattern().format(data.totalMessages)} messages '
        '• ${_formatDateRange(data.firstMessageDate, data.lastMessageDate)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final railWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(
                0.0,
                _messageHeatmapVisualizationRailWidth,
              )
            : _messageHeatmapVisualizationRailWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: railWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(summaryText, style: typography.vizMeta),
                SizedBox(height: visualizationGap),
                SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CalendarHeatmapTimelineWidget(
                      data: data,
                      monthSize: 12,
                      monthSpacing: 2,
                      selectedMonthKey: selectedMonthKey,
                      monthTooltipBuilder: monthTooltipBuilder,
                      onMonthTap: onMonthTap,
                    ),
                  ),
                ),
                if (legend != null) ...[
                  SizedBox(height: visualizationGap),
                  legend!,
                ],
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.cassetteHintGap,
                  ),
                  child: Text(
                    hintText,
                    style: typography.caption,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const double _messageHeatmapVisualizationRailWidth = 252;

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
