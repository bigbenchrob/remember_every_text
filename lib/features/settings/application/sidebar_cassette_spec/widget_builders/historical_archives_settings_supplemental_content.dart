import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../../essentials/sidebar/presentation/view/sidebar_info_card.dart';
import '../../../presentation/layout/historical_archives_track_occupants.dart';
import '../../historical_archives_workflow_actions_provider.dart';
import '../../historical_archives_workflow_panel_model_provider.dart';
import '../payloads/historical_archives_settings_cassette_payload.dart';

class HistoricalArchivesSettingsTrackedCassette extends StatelessWidget {
  const HistoricalArchivesSettingsTrackedCassette({
    super.key,
    required this.payload,
  });

  final HistoricalArchivesSettingsCassettePayload payload;

  @override
  Widget build(BuildContext context) {
    if (ResolvedTrackLayoutMatrixScope.maybeOf(context) == null) {
      return SidebarInfoCard(
        bodyText: payload.bodyText,
        content: HistoricalArchivesSettingsSupplementalContent(
          payload: payload,
        ),
      );
    }

    return Column(
      key: const ValueKey<String>(
        'historical-archives-tracked-sidebar-cassette',
      ),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final trackId in const [
          TrackId.trackA,
          TrackId.trackB,
          TrackId.trackC,
          TrackId.trackD,
          TrackId.trackE,
        ])
          TrackCellView(
            cellId: CellId(trackId: trackId, columnId: TrackColumnId.column1),
          ),
        Padding(
          key: const ValueKey<String>(
            'historical-archives-sidebar-native-flow',
          ),
          padding: const EdgeInsets.fromLTRB(
            historicalArchivesSidebarHorizontalInset,
            0,
            historicalArchivesSidebarHorizontalInset,
            historicalArchivesSidebarBottomInset,
          ),
          child: HistoricalArchivesSettingsSupplementalContent(
            payload: payload,
            includeFixedTrackContent: false,
          ),
        ),
      ],
    );
  }
}

class HistoricalArchivesSettingsSupplementalContent extends ConsumerWidget {
  const HistoricalArchivesSettingsSupplementalContent({
    super.key,
    required this.payload,
    this.includeFixedTrackContent = true,
  });

  final HistoricalArchivesSettingsCassettePayload payload;
  final bool includeFixedTrackContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final showAddMessagesFolder = ref.watch(
      historicalArchivesWorkflowProvider.select(
        (state) =>
            state.presentationContext !=
            HistoricalArchivesPresentationContext.addArchive,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (includeFixedTrackContent) ...[
          const HistoricalArchivesSourceTypeControl(),
          const SizedBox(
            key: ValueKey<String>(
              'historical-archives-source-to-known-folders-gap',
            ),
            height: historicalArchivesSourceToKnownFoldersGap,
          ),
          HistoricalArchivesKnownFoldersHeading(
            style: typography.controlValue.copyWith(
              color: colors.content.textPrimary,
            ),
          ),
          const SizedBox(
            height: historicalArchivesKnownFoldersHeadingToListGap,
          ),
        ],
        if (payload.knownSources.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No archive folders have been added yet.',
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ),
          )
        else
          for (var index = 0; index < payload.knownSources.length; index++) ...[
            _HistoricalArchiveSourceTile(
              key: ValueKey<String>(payload.knownSources[index].sourceKey),
              source: payload.knownSources[index],
            ),
            if (index < payload.knownSources.length - 1)
              const SizedBox(height: AppSpacing.cassetteGap),
          ],
        if (showAddMessagesFolder) ...[
          const SizedBox(
            key: ValueKey<String>(
              'historical-archives-known-folders-to-add-gap',
            ),
            height: historicalArchivesSourceToKnownFoldersGap,
          ),
          Text(
            'Add from a Messages Folder',
            style: typography.controlValue.copyWith(
              color: colors.content.textPrimary,
            ),
          ),
          const SizedBox(
            key: ValueKey<String>(
              'historical-archives-add-heading-to-content-gap',
            ),
            height: AppSpacing.sm,
          ),
          Text(
            'Choose the folder containing chat.db, not the chat.db file itself.',
            key: const ValueKey<String>(
              'historical-archives-messages-folder-guidance',
            ),
            style: typography.caption1.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(
            key: ValueKey<String>('historical-archives-guidance-paragraph-gap'),
            height: AppSpacing.lg,
          ),
          Text(
            'Usually: Home → Library → Messages',
            style: typography.caption1.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Older copies can be on another drive, moved, or renamed. An '
            "Attachments folder may also be present, but it isn't required.",
            style: typography.caption1.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(
            key: ValueKey<String>(
              'historical-archives-guidance-to-chooser-gap',
            ),
            height: AppSpacing.xl,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  await ref
                      .read(historicalArchivesWorkflowActionsProvider.notifier)
                      .chooseMessagesFolder();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    'Choose Messages Folder...',
                    style: typography.controlValue.copyWith(
                      color: colors.accents.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HistoricalArchiveSourceTile extends ConsumerStatefulWidget {
  const _HistoricalArchiveSourceTile({required this.source, super.key});

  final HistoricalArchiveSidebarSourceSummary source;

  @override
  ConsumerState<_HistoricalArchiveSourceTile> createState() =>
      _HistoricalArchiveSourceTileState();
}

class _HistoricalArchiveSourceTileState
    extends ConsumerState<_HistoricalArchiveSourceTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _referenceController = AnimationController(
    vsync: this,
    duration: historicalArchivesReferenceLifetime,
  );
  late final Animation<double> _referenceStrength = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: historicalArchivesReferenceFadeInDuration.inMilliseconds
          .toDouble(),
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(1),
      weight: historicalArchivesReferenceHoldDuration.inMilliseconds.toDouble(),
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: historicalArchivesReferenceFadeOutDuration.inMilliseconds
          .toDouble(),
    ),
  ]).animate(_referenceController);
  var _lastReferenceOccurrence = 0;

  @override
  void initState() {
    super.initState();
    _lastReferenceOccurrence = widget.source.referenceOccurrence;
  }

  @override
  void didUpdateWidget(covariant _HistoricalArchiveSourceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.source.isReferenced) {
      _referenceController.stop();
      _referenceController.value = 0;
      _lastReferenceOccurrence = widget.source.referenceOccurrence;
      return;
    }

    if (widget.source.referenceOccurrence != _lastReferenceOccurrence) {
      _lastReferenceOccurrence = widget.source.referenceOccurrence;
      if (_motionDisabled(context)) {
        _referenceController.value =
            historicalArchivesReferenceFadeInDuration.inMilliseconds /
            historicalArchivesReferenceLifetime.inMilliseconds;
        return;
      }
      _referenceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return AnimatedBuilder(
      animation: _referenceController,
      builder: (context, child) {
        final referenceStrength = widget.source.isReferenced
            ? _referenceStrength.value
            : 0.0;
        final ordinaryDecoration = BoxDecoration(
          color: colors.surfaces.control,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
        );
        return Semantics(
          button: true,
          label: 'Show archive ${widget.source.label}',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await ref
                    .read(historicalArchivesWorkflowActionsProvider.notifier)
                    .showKnownSource(sourceKey: widget.source.sourceKey);
              },
              child: DecoratedBox(
                key: ValueKey<String>(
                  'historical-archive-source-chrome:${widget.source.sourceKey}',
                ),
                decoration: widget.source.isSelected
                    ? BoxDecoration(
                        color: colors.surfaces.selected,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.accents.selection.withValues(
                            alpha: 0.58,
                          ),
                        ),
                      )
                    : widget.source.isReferenced
                    ? _historicalArchivesReferenceDecoration(
                        colors: colors.messagePanels,
                        ordinaryBackground: colors.surfaces.control,
                        ordinaryBorder: colors.lines.borderSubtle,
                        borderRadius: BorderRadius.circular(12),
                        strength: referenceStrength,
                      )
                    : ordinaryDecoration,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.source.label,
              style: typography.headline.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            if (widget.source.dateRangeLabel case final dateRangeLabel?)
              Text(
                dateRangeLabel,
                style: typography.caption1.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            Text(
              widget.source.messageCountLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            if (widget.source.importedOnLabel case final importedOnLabel?)
              Text(
                importedOnLabel,
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

BoxDecoration _historicalArchivesReferenceDecoration({
  required MessagePanels colors,
  required Color ordinaryBackground,
  required Color ordinaryBorder,
  required BorderRadius borderRadius,
  required double strength,
}) {
  final boundedStrength = strength.clamp(0.0, 1.0);
  return BoxDecoration(
    color: Color.alphaBlend(
      colors.contextAnchorBackground.withValues(alpha: 0.18 * boundedStrength),
      ordinaryBackground,
    ),
    border: Border.all(
      color: Color.alphaBlend(
        colors.contextAnchorBorder.withValues(alpha: 0.72 * boundedStrength),
        ordinaryBorder,
      ),
      width: 0.8 + (0.2 * boundedStrength),
    ),
    borderRadius: borderRadius,
  );
}

bool _motionDisabled(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
