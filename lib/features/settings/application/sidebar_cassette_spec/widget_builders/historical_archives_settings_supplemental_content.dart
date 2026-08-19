import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/referential_correspondence_decoration.dart';
import '../../historical_archives_workflow_actions_provider.dart';
import '../../historical_archives_workflow_panel_model_provider.dart';
import '../payloads/historical_archives_settings_cassette_payload.dart';

class HistoricalArchivesSettingsSupplementalContent extends ConsumerWidget {
  const HistoricalArchivesSettingsSupplementalContent({
    super.key,
    required this.payload,
  });

  final HistoricalArchivesSettingsCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final showAddArchiveFolder = ref.watch(
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
        const SizedBox(height: 16),
        Text(
          'Folders Already Added',
          style: typography.controlValue.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
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
          for (final source in payload.knownSources) ...[
            _HistoricalArchiveSourceTile(
              key: ValueKey<String>(source.sourceKey),
              source: source,
            ),
            const SizedBox(height: 10),
          ],
        if (showAddArchiveFolder) ...[
          const SizedBox(height: 14),
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
                    'Add an Archive Folder',
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
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: historicalArchivesReferenceLifetime,
  );
  late final Animation<double> _pulse = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 150,
    ),
    TweenSequenceItem(tween: ConstantTween<double>(1), weight: 360),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 250,
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(0),
      weight:
          (historicalArchivesReferenceLingerDuration.inMilliseconds +
                  historicalArchivesReferenceFadeDuration.inMilliseconds)
              .toDouble(),
    ),
  ]).animate(_pulseController);
  late final Animation<double> _referenceStrength = TweenSequence<double>([
    TweenSequenceItem(
      tween: ConstantTween<double>(1),
      weight:
          (historicalArchivesReferencePulseDuration.inMilliseconds +
                  historicalArchivesReferenceLingerDuration.inMilliseconds)
              .toDouble(),
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: historicalArchivesReferenceFadeDuration.inMilliseconds.toDouble(),
    ),
  ]).animate(_pulseController);
  var _lastPulseOccurrence = 0;

  @override
  void initState() {
    super.initState();
    _lastPulseOccurrence = widget.source.referencePulseOccurrence;
  }

  @override
  void didUpdateWidget(covariant _HistoricalArchiveSourceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.source.isReferenced) {
      _pulseController.stop();
      _pulseController.value = 0;
      _lastPulseOccurrence = widget.source.referencePulseOccurrence;
      return;
    }

    if (widget.source.referencePulseOccurrence != _lastPulseOccurrence) {
      _lastPulseOccurrence = widget.source.referencePulseOccurrence;
      if (_motionDisabled(context)) {
        _pulseController.value = 0;
        return;
      }
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = widget.source.isReferenced ? _pulse.value : 0.0;
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
                    ? BoxDecoration.lerp(
                        ordinaryDecoration,
                        referentialCorrespondenceDecoration(
                          colors: colors.messagePanels,
                          pulse: pulse,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        referenceStrength,
                      )!
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
              style: typography.controlValue.copyWith(
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

bool _motionDisabled(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
