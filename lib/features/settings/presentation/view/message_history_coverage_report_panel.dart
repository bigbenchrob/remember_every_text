import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../application/sidebar_cassette_spec/actions/message_history_coverage_report_actions_provider.dart';
import '../../application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import '../layout/message_history_coverage_track_occupants.dart';
import '../view_model/message_history_coverage_panel_model_provider.dart';

class MessageHistoryCoverageReportPanel extends ConsumerWidget {
  const MessageHistoryCoverageReportPanel({super.key});

  static const loadingBodyKey = Key('message-history-coverage-loading-body');
  static const detailsToggleKey = Key(
    'message-history-coverage-details-toggle',
  );
  static const headlineKey = Key('message-history-coverage-headline');
  static const reportBodyKey = Key('message-history-coverage-report-body');
  static const retryButtonKey = Key('message-history-coverage-retry-button');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final panelModelAsync = ref.watch(messageHistoryCoveragePanelModelProvider);

    final body = panelModelAsync.when(
      data: (panelModel) => _CoverageResult(
        panelModel: panelModel,
        onRetry: panelModel.status == MessageHistoryCoverageStatus.failed
            ? () {
                ref
                    .read(messageHistoryCoverageReportActionsProvider.notifier)
                    .retry();
              }
            : null,
      ),
      loading: () => const _CoverageLoadingState(),
      error: (_, __) => _CoverageUnexpectedFailure(
        onRetry: () {
          ref
              .read(messageHistoryCoverageReportActionsProvider.notifier)
              .retry();
        },
      ),
    );

    return _CoveragePanelScaffold(
      colors: colors,
      typography: typography,
      child: body,
    );
  }
}

class _CoveragePanelScaffold extends StatelessWidget {
  const _CoveragePanelScaffold({
    required this.colors,
    required this.typography,
    required this.child,
  });

  final ThemeColors colors;
  final ThemeTypography typography;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hasResolvedTracks =
        ResolvedTrackLayoutMatrixScope.maybeOf(context) != null;

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SingleChildScrollView(
        child: Column(
          key: const Key('message-history-coverage-track-skeleton'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasResolvedTracks)
              const TrackCellView(
                cellId: CellId(
                  trackId: TrackId.trackA,
                  columnId: TrackColumnId.column2,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: MessageHistoryCoverageTitle(
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.xl,
              ),
              child: MessageHistoryCoverageCenterColumn(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageLoadingState extends ConsumerWidget {
  const _CoverageLoadingState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Semantics(
      label: 'Checking message history coverage',
      child: Row(
        key: MessageHistoryCoverageReportPanel.loadingBodyKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: 7),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Checking messages on this Mac…',
            style: typography.body.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageResult extends ConsumerWidget {
  const _CoverageResult({required this.panelModel, required this.onRetry});

  final MessageCoveragePanelViewModel panelModel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final statusColor = _statusColor(panelModel.status, colors: colors);

    return Column(
      key: MessageHistoryCoverageReportPanel.reportBodyKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: panelModel.headline,
          header: true,
          excludeSemantics: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Icon(
                  _statusIcon(panelModel.status),
                  size: 20,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  panelModel.headline,
                  key: MessageHistoryCoverageReportPanel.headlineKey,
                  style: typography.title2.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          panelModel.summaryText,
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
        if (panelModel.hasCoverageCounts) ...[
          const SizedBox(height: AppSpacing.lg),
          _CoverageCountSummary(panelModel: panelModel),
        ],
        if (onRetry case final retry?) ...[
          const SizedBox(height: AppSpacing.lg),
          CupertinoButton(
            key: MessageHistoryCoverageReportPanel.retryButtonKey,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: colors.surfaces.control,
            onPressed: retry,
            child: Text(
              'Try Again',
              style: typography.controlValue.copyWith(
                color: colors.accents.primary,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _CoverageDetails(lines: panelModel.detailLines),
      ],
    );
  }
}

class _CoverageCountSummary extends ConsumerWidget {
  const _CoverageCountSummary({required this.panelModel});

  final MessageCoveragePanelViewModel panelModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Semantics(
      label:
          '${panelModel.totalCountLabel} messages on this Mac. '
          '${panelModel.conversationCountLabel} in conversations. '
          '${panelModel.recoveredCountLabel} in Recovered Messages. '
          '${panelModel.unaccountedCountLabel} unaccounted.',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaces.control,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.lines.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CoverageCountRow(
                label: 'Messages on this Mac',
                value: panelModel.totalCountLabel,
                emphasized: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              ColoredBox(
                color: colors.lines.dividerQuiet,
                child: const SizedBox(height: 1),
              ),
              const SizedBox(height: AppSpacing.sm),
              _CoverageCountRow(
                label: 'In conversations',
                value: panelModel.conversationCountLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CoverageCountRow(
                label: 'Recovered Messages',
                value: panelModel.recoveredCountLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CoverageCountRow(
                label: 'Unaccounted',
                value: panelModel.unaccountedCountLabel,
                valueColor: panelModel.unaccountedCount == 0
                    ? colors.content.textTertiary
                    : colors.status.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverageCountRow extends ConsumerWidget {
  const _CoverageCountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasized;
  final Color? valueColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final style = emphasized ? typography.headline : typography.body;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style.copyWith(
              color: emphasized
                  ? colors.content.textPrimary
                  : colors.content.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          style: style.copyWith(
            color: valueColor ?? colors.content.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _CoverageDetails extends ConsumerStatefulWidget {
  const _CoverageDetails({required this.lines});

  final List<String> lines;

  @override
  ConsumerState<_CoverageDetails> createState() => _CoverageDetailsState();
}

class _CoverageDetailsState extends ConsumerState<_CoverageDetails> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          expanded: _isExpanded,
          label: 'Details',
          excludeSemantics: true,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              key: MessageHistoryCoverageReportPanel.detailsToggleKey,
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpanded
                          ? CupertinoIcons.chevron_down
                          : CupertinoIcons.chevron_right,
                      size: 14,
                      color: colors.content.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Details',
                      style: typography.controlValue.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.sm),
          for (final line in widget.lines) ...[
            Text(
              line,
              key: ValueKey<String>('message-history-coverage-detail-$line'),
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

class _CoverageUnexpectedFailure extends StatelessWidget {
  const _CoverageUnexpectedFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CoverageResult(
      panelModel: const MessageCoveragePanelViewModel(
        title: 'Message History Coverage',
        status: MessageHistoryCoverageStatus.failed,
        headline: 'Message history coverage could not be checked',
        summaryText:
            'MessageLens could not safely compare the messages on this Mac with its current message accounting.',
        totalCount: null,
        totalCountLabel: 'Unknown',
        conversationCount: null,
        conversationCountLabel: 'Unknown',
        recoveredCount: null,
        recoveredCountLabel: 'Unknown',
        accountedCount: null,
        accountedCountLabel: 'Unknown',
        unaccountedCount: null,
        unaccountedCountLabel: 'Unknown',
        dateRangeLabel: 'Unavailable',
        generatedAtLabel: null,
        detailLines: ['The report could not be prepared. Try again.'],
      ),
      onRetry: onRetry,
    );
  }
}

IconData _statusIcon(MessageHistoryCoverageStatus status) {
  return switch (status) {
    MessageHistoryCoverageStatus.complete =>
      CupertinoIcons.check_mark_circled_solid,
    MessageHistoryCoverageStatus.incomplete =>
      CupertinoIcons.exclamationmark_circle_fill,
    MessageHistoryCoverageStatus.temporarilyUnavailable =>
      CupertinoIcons.clock_fill,
    MessageHistoryCoverageStatus.failed => CupertinoIcons.xmark_circle_fill,
  };
}

Color _statusColor(
  MessageHistoryCoverageStatus status, {
  required ThemeColors colors,
}) {
  return switch (status) {
    MessageHistoryCoverageStatus.complete => colors.status.success,
    MessageHistoryCoverageStatus.incomplete => colors.status.warning,
    MessageHistoryCoverageStatus.temporarilyUnavailable =>
      colors.content.textSecondary,
    MessageHistoryCoverageStatus.failed => colors.status.error,
  };
}
