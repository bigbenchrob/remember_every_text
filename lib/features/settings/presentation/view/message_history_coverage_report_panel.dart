import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/presentation/view/center_panel_report_layout.dart';
import '../../application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import '../view_model/message_history_coverage_panel_model_provider.dart';

class MessageHistoryCoverageReportPanel extends ConsumerWidget {
  const MessageHistoryCoverageReportPanel({super.key});

  static const accountingBarKey = Key(
    'message-history-coverage-accounting-bar',
  );
  static const zeroMissingBadgeKey = Key(
    'message-history-coverage-zero-missing-badge',
  );

  static Key segmentKey(CoverageSegmentId id) {
    return Key('message-history-coverage-segment-${id.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final panelModelAsync = ref.watch(messageHistoryCoveragePanelModelProvider);

    return panelModelAsync.when(
      data: (panelModel) {
        return ColoredBox(
          color: colors.surfaces.canvas,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child:
                    CenterPanelReportLayout<MessageCoveragePanelSectionChild>(
                      sections: panelModel.sections,
                      sectionSpacing: 20,
                      columnSpacing: 16,
                      childBuilder: (context, layoutStyle, child) {
                        return _buildSectionChild(
                          panelModel: panelModel,
                          colors: colors,
                          typography: typography,
                          layoutStyle: layoutStyle,
                          child: child,
                        );
                      },
                    ),
              ),
            ),
          ),
        );
      },
      loading: () {
        return ColoredBox(
          color: colors.surfaces.canvas,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Loading Message History Coverage…',
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
      error: (error, _) {
        return ColoredBox(
          color: colors.surfaces.canvas,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'MessageLens could not build the Message History Coverage panel: $error',
                style: typography.body.copyWith(
                  color: colors.buttons.destructiveForeground,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionChild({
    required MessageCoveragePanelViewModel panelModel,
    required ThemeColors colors,
    required ThemeTypography typography,
    required PanelSectionLayoutStyle layoutStyle,
    required MessageCoveragePanelSectionChild child,
  }) {
    return switch (child) {
      MessageCoveragePanelSectionChild.hero => _HeroCard(
        panelModel: panelModel,
        colors: colors,
        typography: typography,
      ),
      MessageCoveragePanelSectionChild.accounting => _SectionCard(
        style: _SectionCardStyle.emphasized,
        colors: colors,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Message Accounting',
              style: typography.title3.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All messages on this Mac are accounted for as:',
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _AccountingBar(
              panelModel: panelModel,
              colors: colors,
              typography: typography,
            ),
          ],
        ),
      ),
      MessageCoveragePanelSectionChild.reconciliation => _SectionCard(
        colors: colors,
        child: _ReconciliationSummary(
          panelModel: panelModel,
          colors: colors,
          typography: typography,
        ),
      ),
      MessageCoveragePanelSectionChild.timelineCoverage => _SectionCard(
        colors: colors,
        child: _TimelineCoverageSummary(
          panelModel: panelModel,
          colors: colors,
          typography: typography,
        ),
      ),
      MessageCoveragePanelSectionChild.recoveredMessages => _SectionCard(
        colors: colors,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recovered Messages',
              style: typography.title3.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              panelModel.recoveredExplanation,
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
      MessageCoveragePanelSectionChild.notes => _SectionCard(
        style: layoutStyle == PanelSectionLayoutStyle.compactFullWidth
            ? _SectionCardStyle.compact
            : _SectionCardStyle.standard,
        colors: colors,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: typography.title3.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < panelModel.notes.length; index++) ...[
              Text(
                panelModel.notes[index],
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
              if (index < panelModel.notes.length - 1)
                const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    };
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.panelModel,
    required this.colors,
    required this.typography,
  });

  final MessageCoveragePanelViewModel panelModel;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final badgeBackground = _statusTint(colors).withValues(alpha: 0.12);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              panelModel.title,
              style: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: badgeBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _statusTint(colors).withValues(alpha: 0.30),
                  width: 0.8,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  panelModel.statusLabel,
                  style: typography.caption.copyWith(
                    color: _statusTint(colors),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              panelModel.headline,
              style: typography.heroTitle.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              panelModel.summaryText,
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            if (panelModel.generatedAtLabel != null) ...[
              const SizedBox(height: 12),
              Text(
                'Generated ${panelModel.generatedAtLabel}',
                style: typography.caption1.copyWith(
                  color: colors.content.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusTint(ThemeColors colors) {
    return switch (panelModel.status) {
      MessageHistoryCoverageStatus.complete => colors.accents.primary,
      MessageHistoryCoverageStatus.incompleteImport =>
        colors.buttons.destructiveForeground,
      MessageHistoryCoverageStatus.incompleteSourceHistory =>
        colors.accents.secondary,
      MessageHistoryCoverageStatus.unknown => colors.content.textSecondary,
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.colors,
    required this.child,
    this.style = _SectionCardStyle.standard,
  });

  final ThemeColors colors;
  final Widget child;
  final _SectionCardStyle style;

  @override
  Widget build(BuildContext context) {
    final (
      backgroundColor,
      borderColor,
      borderWidth,
      padding,
    ) = switch (style) {
      _SectionCardStyle.standard => (
        colors.surfaces.surface,
        colors.lines.borderSubtle,
        0.8,
        const EdgeInsets.all(20),
      ),
      _SectionCardStyle.emphasized => (
        colors.surfaces.surfaceRaised,
        colors.accents.primary.withValues(alpha: 0.16),
        1.0,
        const EdgeInsets.all(20),
      ),
      _SectionCardStyle.compact => (
        colors.surfaces.surface,
        colors.lines.borderSubtle,
        0.8,
        const EdgeInsets.all(16),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

enum _SectionCardStyle { standard, emphasized, compact }

class _AccountingBar extends StatelessWidget {
  const _AccountingBar({
    required this.panelModel,
    required this.colors,
    required this.typography,
  });

  final MessageCoveragePanelViewModel panelModel;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final segments = panelModel.segments;
    final totalFraction = segments.fold<double>(
      0,
      (sum, segment) => sum + segment.fraction,
    );
    final remainingFraction = math.max(0.0, 1.0 - totalFraction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            key: MessageHistoryCoverageReportPanel.accountingBarKey,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(color: colors.surfaces.control),
              child: Row(
                children: [
                  for (final segment in segments)
                    Expanded(
                      flex: math.max(1, (segment.fraction * 1000).round()),
                      child: ColoredBox(
                        key: MessageHistoryCoverageReportPanel.segmentKey(
                          segment.id,
                        ),
                        color: _segmentColor(segment.semanticKind),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  if (remainingFraction > 0)
                    Expanded(
                      flex: math.max(1, (remainingFraction * 1000).round()),
                      child: const SizedBox.expand(),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final segment in segments)
              _LegendChip(
                label: '${segment.label}: ${segment.count}',
                color: _segmentColor(segment.semanticKind),
                colors: colors,
                typography: typography,
              ),
            if (panelModel.missingCount == 0)
              _LegendChip(
                key: MessageHistoryCoverageReportPanel.zeroMissingBadgeKey,
                label: '0 missing',
                color: colors.content.textSecondary,
                colors: colors,
                typography: typography,
              ),
          ],
        ),
      ],
    );
  }

  Color _segmentColor(CoverageSegmentSemanticKind kind) {
    return switch (kind) {
      CoverageSegmentSemanticKind.visible => colors.accents.primary,
      CoverageSegmentSemanticKind.recovered => colors.accents.secondary,
      CoverageSegmentSemanticKind.missing =>
        colors.buttons.destructiveForeground,
    };
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    super.key,
    required this.label,
    required this.color,
    required this.colors,
    required this.typography,
  });

  final String label;
  final Color color;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(width: 8, height: 8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconciliationSummary extends StatelessWidget {
  const _ReconciliationSummary({
    required this.panelModel,
    required this.colors,
    required this.typography,
  });

  final MessageCoveragePanelViewModel panelModel;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reconciliation',
          style: typography.title3.copyWith(color: colors.content.textPrimary),
        ),
        const SizedBox(height: 12),
        _MetricLine(
          label: 'Messages in chat.db',
          value: panelModel.chatDbTotalLabel,
          colors: colors,
          typography: typography,
        ),
        _MetricLine(
          label: 'Visible in timelines',
          value: panelModel.visibleCountLabel,
          colors: colors,
          typography: typography,
        ),
        _MetricLine(
          label: 'Recovered / unlinked',
          value: panelModel.recoveredCountLabel,
          colors: colors,
          typography: typography,
        ),
        _MetricLine(
          label: 'Accounted for',
          value: panelModel.accountedCountLabel,
          colors: colors,
          typography: typography,
        ),
        _MetricLine(
          label: 'Missing',
          value: panelModel.missingCountLabel,
          colors: colors,
          typography: typography,
          emphasize:
              panelModel.missingCount != null && panelModel.missingCount! > 0,
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.messagePanels.supportSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              panelModel.reconciliationResultLabel,
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final ThemeTypography typography;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: typography.body.copyWith(
              color: emphasize
                  ? colors.buttons.destructiveForeground
                  : colors.content.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCoverageSummary extends StatelessWidget {
  const _TimelineCoverageSummary({
    required this.panelModel,
    required this.colors,
    required this.typography,
  });

  final MessageCoveragePanelViewModel panelModel;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline Coverage',
          style: typography.title3.copyWith(color: colors.content.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          panelModel.timelineCoverageLabel,
          style: typography.caption1.copyWith(
            color: colors.content.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              panelModel.earliestLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 14,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 4,
                      child: ColoredBox(color: colors.lines.borderSubtle),
                    ),
                    Positioned(
                      left: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.accents.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const SizedBox(width: 12, height: 12),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.accents.secondary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const SizedBox(width: 12, height: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              panelModel.latestLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
        if (panelModel.timelineCoverageDetail != null) ...[
          const SizedBox(height: 12),
          Text(
            panelModel.timelineCoverageDetail!,
            style: typography.caption1.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
