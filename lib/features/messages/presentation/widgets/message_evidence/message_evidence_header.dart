import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos_ui;

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/layout/app_panel_bands.dart';
import '../../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../../config/theme/widgets/layout/vertical_column_bands.dart';
import '../../../domain/message_evidence/message_evidence_search_mode.dart';

class MessageEvidenceHeaderModel {
  const MessageEvidenceHeaderModel({
    required this.title,
    this.identityContextLine,
    this.scopeContextLine,
    this.dateRangeLabel,
    this.countLabel,
    this.scopeNote,
    this.activeScopeLabel,
    this.activeScopeIndicator,
    this.searchConfig,
    this.actions,
    this.details,
    this.supplementalMetricParts = const <String>[],
  });

  final String title;
  final String? identityContextLine;
  final String? scopeContextLine;
  final String? dateRangeLabel;
  final String? countLabel;
  final String? scopeNote;
  final String? activeScopeLabel;
  final Widget? activeScopeIndicator;
  final MessageEvidenceHeaderSearchConfig? searchConfig;
  final Widget? actions;
  final Widget? details;
  final List<String> supplementalMetricParts;
}

class MessageEvidenceHeaderSearchConfig {
  const MessageEvidenceHeaderSearchConfig({
    required this.controller,
    required this.placeholder,
    this.mode,
    this.onModeChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final MessageEvidenceSearchMode? mode;
  final ValueChanged<MessageEvidenceSearchMode>? onModeChanged;
}

class MessageEvidenceHeader extends ConsumerWidget {
  const MessageEvidenceHeader({
    required this.data,
    this.details,
    this.padding = AppPanelBands.centerPanelPadding,
    this.useFixedPanelFrame = false,
    super.key,
  });

  final MessageEvidenceHeaderModel data;
  final Widget? details;
  final EdgeInsets padding;
  final bool useFixedPanelFrame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final identityContextLine = data.identityContextLine?.trim();
    final scopeContextLine = data.scopeContextLine?.trim();
    final scopeNote = data.scopeNote?.trim();
    final activeScopeLabel = data.activeScopeLabel?.trim();
    final hasIdentityContext =
        identityContextLine != null && identityContextLine.isNotEmpty;
    final metricParts =
        [data.dateRangeLabel, data.countLabel, ...data.supplementalMetricParts]
            .whereType<String>()
            .where((part) => part.trim().isNotEmpty)
            .toList(growable: false);
    final resolvedDetails = data.details ?? details;

    final hasTrackPlan = ResolvedTrackPlanScope.maybeOf(context) != null;
    final title = hasTrackPlan
        ? TrackOccupantView(
            occupant: TextTrackOccupant(
              trackId: TrackId.trackA,
              text: data.title,
              style: typography.title1,
            ),
          )
        : Text(data.title, style: typography.title1);
    final metadataText = [
      if (hasIdentityContext) identityContextLine,
      ...metricParts,
    ].whereType<String>().join('   ');
    final primary = _MessageEvidencePrimaryBand(
      identityContextLine: identityContextLine,
      hasIdentityContext: hasIdentityContext,
      metricParts: metricParts,
      scopeContextLine: scopeContextLine,
      scopeNote: scopeNote,
      activeScopeLabel: activeScopeLabel,
      activeScopeIndicator: data.activeScopeIndicator,
    );
    final metadata = hasTrackPlan
        ? TrackOccupantView(
            occupant: TextTrackOccupant(
              trackId: TrackId.trackB,
              text: metadataText,
              style: typography.callout.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          )
        : _MessageEvidenceMetadataBand(
            identityContextLine: identityContextLine,
            hasIdentityContext: hasIdentityContext,
            metricParts: metricParts,
          );
    final supportingContext = _MessageEvidenceSupportingContextBand(
      scopeContextLine: scopeContextLine,
      scopeNote: scopeNote,
      activeScopeLabel: activeScopeLabel,
      activeScopeIndicator: data.activeScopeIndicator,
    );
    final secondary = _MessageEvidenceSecondaryBand(
      searchConfig: data.searchConfig,
      actions: data.actions,
      details: resolvedDetails,
    );
    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: useFixedPanelFrame
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TitleColumnBand(child: title),
                if (hasTrackPlan) ...[
                  ContextColumnBand(child: metadata),
                  TrackCellColumnBand(
                    trackId: TrackId.trackC,
                    childPlacement: const ColumnBandChildPlacement.bottomLeft(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                      child: _MessageEvidencePostTrackBContent(
                        supportingContext: supportingContext,
                        secondary: secondary,
                      ),
                    ),
                  ),
                ] else
                  ContextColumnBand(
                    child: _MessageEvidenceContextBand(
                      primary: primary,
                      secondary: secondary,
                    ),
                  ),
              ],
            )
          : AppPanelBandHeader(
              padding: padding,
              title: title,
              primary: primary,
              secondary: secondary,
            ),
    );
  }
}

class _MessageEvidencePostTrackBContent extends StatelessWidget {
  const _MessageEvidencePostTrackBContent({
    required this.supportingContext,
    required this.secondary,
  });

  final Widget supportingContext;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [supportingContext, secondary],
    );
  }
}

class _MessageEvidenceContextBand extends StatelessWidget {
  const _MessageEvidenceContextBand({
    required this.primary,
    required this.secondary,
  });

  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [primary, secondary],
    );
  }
}

class _MessageEvidenceMetadataBand extends ConsumerWidget {
  const _MessageEvidenceMetadataBand({
    required this.identityContextLine,
    required this.hasIdentityContext,
    required this.metricParts,
  });

  final String? identityContextLine;
  final bool hasIdentityContext;
  final List<String> metricParts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasIdentityContext)
          Flexible(
            child: Text(
              identityContextLine!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.callout.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ),
        if (hasIdentityContext && metricParts.isNotEmpty)
          const SizedBox(width: 14),
        if (metricParts.isNotEmpty)
          Flexible(
            child: Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                for (final part in metricParts)
                  Text(
                    part,
                    style: typography.callout.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MessageEvidenceSupportingContextBand extends ConsumerWidget {
  const _MessageEvidenceSupportingContextBand({
    required this.scopeContextLine,
    required this.scopeNote,
    required this.activeScopeLabel,
    required this.activeScopeIndicator,
  });

  final String? scopeContextLine;
  final String? scopeNote;
  final String? activeScopeLabel;
  final Widget? activeScopeIndicator;

  bool get _hasVisibleContent {
    return (scopeContextLine != null && scopeContextLine!.isNotEmpty) ||
        (scopeNote != null && scopeNote!.isNotEmpty) ||
        (activeScopeLabel != null && activeScopeLabel!.isNotEmpty) ||
        activeScopeIndicator != null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_hasVisibleContent) {
      return const SizedBox.shrink();
    }

    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (scopeContextLine != null && scopeContextLine!.isNotEmpty)
            Text(
              scopeContextLine!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          if (scopeNote != null && scopeNote!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              scopeNote!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
          if (activeScopeLabel != null && activeScopeLabel!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              activeScopeLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
          if (activeScopeIndicator != null) ...[
            const SizedBox(height: 8),
            activeScopeIndicator!,
          ],
        ],
      ),
    );
  }
}

class _MessageEvidencePrimaryBand extends ConsumerWidget {
  const _MessageEvidencePrimaryBand({
    required this.identityContextLine,
    required this.hasIdentityContext,
    required this.metricParts,
    required this.scopeContextLine,
    required this.scopeNote,
    required this.activeScopeLabel,
    required this.activeScopeIndicator,
  });

  final String? identityContextLine;
  final bool hasIdentityContext;
  final List<String> metricParts;
  final String? scopeContextLine;
  final String? scopeNote;
  final String? activeScopeLabel;
  final Widget? activeScopeIndicator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIdentityContext)
          Text(
            identityContextLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.callout.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        if (metricParts.isNotEmpty) ...[
          SizedBox(height: hasIdentityContext ? 7 : 0),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              for (final part in metricParts)
                Text(
                  part,
                  style: typography.callout.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
            ],
          ),
        ],
        if (scopeContextLine != null && scopeContextLine!.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            scopeContextLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
        if (scopeNote != null && scopeNote!.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            scopeNote!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
        if (activeScopeLabel != null && activeScopeLabel!.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            activeScopeLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
        if (activeScopeIndicator != null) ...[
          const SizedBox(height: 8),
          activeScopeIndicator!,
        ],
      ],
    );
  }
}

class _MessageEvidenceSecondaryBand extends StatelessWidget {
  const _MessageEvidenceSecondaryBand({
    required this.searchConfig,
    required this.actions,
    required this.details,
  });

  final MessageEvidenceHeaderSearchConfig? searchConfig;
  final Widget? actions;
  final Widget? details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (searchConfig != null)
          _MessageEvidenceHeaderSearchRow(config: searchConfig!),
        if (actions != null) ...[
          SizedBox(height: searchConfig == null ? 0 : 9),
          _MessageEvidenceHeaderActionRow(child: actions!),
        ],
        if (details != null) ...[
          SizedBox(height: searchConfig == null && actions == null ? 0 : 8),
          details!,
        ],
      ],
    );
  }
}

class _MessageEvidenceHeaderSearchRow extends ConsumerWidget {
  const _MessageEvidenceHeaderSearchRow({required this.config});

  final MessageEvidenceHeaderSearchConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            size: 15,
            color: colors.content.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: macos_ui.MacosTextField(
              controller: config.controller,
              placeholder: config.placeholder,
              clearButtonMode: macos_ui.OverlayVisibilityMode.editing,
            ),
          ),
          if (config.mode != null && config.onModeChanged != null) ...[
            const SizedBox(width: 8),
            _MessageEvidenceSearchModeToggle(
              mode: config.mode!,
              onModeChanged: config.onModeChanged!,
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageEvidenceSearchModeToggle extends ConsumerWidget {
  const _MessageEvidenceSearchModeToggle({
    required this.mode,
    required this.onModeChanged,
  });

  final MessageEvidenceSearchMode mode;
  final ValueChanged<MessageEvidenceSearchMode> onModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchModeSegment(
              label: 'AND',
              isSelected: mode == MessageEvidenceSearchMode.allTerms,
              onPressed: () {
                onModeChanged(MessageEvidenceSearchMode.allTerms);
              },
            ),
            _SearchModeSegment(
              label: 'OR',
              isSelected: mode == MessageEvidenceSearchMode.anyTerm,
              onPressed: () {
                onModeChanged(MessageEvidenceSearchMode.anyTerm);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchModeSegment extends ConsumerWidget {
  const _SearchModeSegment({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? colors.surfaces.selected
              : colors.surfaces.control.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            label,
            style: typography.caption.copyWith(
              color: isSelected
                  ? colors.content.textPrimary
                  : colors.content.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageEvidenceHeaderActionRow extends StatelessWidget {
  const _MessageEvidenceHeaderActionRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: child,
    );
  }
}

class MessageEvidenceDisclosureButton extends ConsumerWidget {
  const MessageEvidenceDisclosureButton({
    required this.label,
    required this.isExpanded,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isExpanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpanded
                ? CupertinoIcons.chevron_down
                : CupertinoIcons.chevron_right,
            size: 13,
            color: colors.content.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(label, style: typography.caption),
        ],
      ),
    );
  }
}
