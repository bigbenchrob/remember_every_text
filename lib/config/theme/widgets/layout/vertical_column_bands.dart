import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/debug/feature_level_providers.dart'
    show
        DeveloperModeValue,
        columnBandDebugMarginsProvider,
        developerModeProvider;
import 'cross_column_track_plan.dart';

/// Diagnostic interface for vertical column alignment bands.
///
/// The page-level layout experiment still renders through compatibility band
/// wrappers. These wrappers consume resolved track heights while callers decide
/// which page-specific occupants belong in each track cell.
abstract class VerticalColumnBand extends ConsumerWidget {
  const VerticalColumnBand({
    required this.child,
    required this.height,
    required this.padding,
    required this.borderColor,
    required this.childPlacement,
    required this.allowBandExpansion,
    this.trackId,
    this.overflowWarning = false,
    super.key,
  });

  final Widget child;
  final double height;
  final EdgeInsets padding;
  final Color borderColor;
  final ColumnBandChildPlacement childPlacement;
  final bool allowBandExpansion;
  final TrackId? trackId;
  final bool overflowWarning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeveloperMode =
        ref.watch(developerModeProvider).valueOrNull ==
        DeveloperModeValue.developer;
    final showDiagnosticMargins =
        isDeveloperMode && ref.watch(columnBandDebugMarginsProvider);
    final trackPlan = ResolvedTrackPlanScope.maybeOf(context);
    final resolvedHeight = switch (trackId) {
      final trackIdValue? =>
        trackPlan?.heightFor(trackIdValue, fallback: height) ?? height,
      null => height,
    };
    final usesResolvedTrack = trackPlan != null && trackId != null;
    final usesResolvedTrackA = trackPlan != null && trackId == TrackId.trackA;
    final effectivePadding = usesResolvedTrack
        ? EdgeInsets.fromLTRB(padding.left, 0, padding.right, 0)
        : padding;
    final effectiveAlignment = usesResolvedTrackA
        ? Alignment.centerLeft
        : childPlacement.alignment;
    final diagnosticBorderColor = switch (trackId) {
      TrackId.trackA => const Color(0xFFFF2D2D),
      TrackId.trackB => const Color(0xFF006CFF),
      TrackId.trackC => const Color(0xFF00A36C),
      null => borderColor,
    };

    final band = DecoratedBox(
      decoration: BoxDecoration(
        border: showDiagnosticMargins
            ? Border.all(
                color: overflowWarning
                    ? const Color(0xFFFFA000)
                    : diagnosticBorderColor,
              )
            : null,
      ),
      child: usesResolvedTrackA
          ? SizedBox(
              height: resolvedHeight,
              child: Padding(
                padding: effectivePadding,
                child: Align(alignment: effectiveAlignment, child: child),
              ),
            )
          : allowBandExpansion
          ? ConstrainedBox(
              constraints: BoxConstraints(minHeight: resolvedHeight),
              child: Padding(
                padding: effectivePadding,
                child: Align(alignment: effectiveAlignment, child: child),
              ),
            )
          : SizedBox(
              height: resolvedHeight,
              child: Padding(
                padding: effectivePadding,
                child: Align(alignment: effectiveAlignment, child: child),
              ),
            ),
    );

    if (!usesResolvedTrackA || trackPlan.pageTopInset == 0) {
      return band;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: trackPlan.pageTopInset),
        band,
      ],
    );
  }
}

class ColumnBandChildPlacement {
  const ColumnBandChildPlacement._(this.alignment);

  const ColumnBandChildPlacement.topLeft() : this._(Alignment.topLeft);

  const ColumnBandChildPlacement.centerLeft() : this._(Alignment.centerLeft);

  const ColumnBandChildPlacement.bottomLeft() : this._(Alignment.bottomLeft);

  ColumnBandChildPlacement.custom({required double x, required double y})
    : alignment = Alignment(x, y);

  final AlignmentGeometry alignment;
}

class TitleColumnBand extends VerticalColumnBand {
  const TitleColumnBand({
    required super.child,
    super.height = defaultHeight,
    super.padding = const EdgeInsets.fromLTRB(32, 24, 32, 0),
    super.borderColor = const Color(0xFFFF2D2D),
    super.childPlacement = const ColumnBandChildPlacement.topLeft(),
    super.allowBandExpansion = true,
    super.trackId = TrackId.trackA,
    super.overflowWarning = false,
    super.key,
  });

  static const double defaultHeight = 72;
}

class ContextColumnBand extends VerticalColumnBand {
  const ContextColumnBand({
    required super.child,
    super.height = defaultHeight,
    super.padding = const EdgeInsets.fromLTRB(32, 10, 32, 0),
    super.borderColor = const Color(0xFF7B61FF),
    super.childPlacement = const ColumnBandChildPlacement.topLeft(),
    super.allowBandExpansion = false,
    super.trackId = TrackId.trackB,
    super.overflowWarning = false,
    super.key,
  });

  static const double defaultHeight = 166;
}

/// Renders one column cell for a resolved track allocation.
///
/// This widget does not contribute a [TrackRequirement]. It only honors the
/// resolved height supplied by [ResolvedTrackPlanScope].
class TrackCellColumnBand extends VerticalColumnBand {
  const TrackCellColumnBand({
    required TrackId trackId,
    Widget child = const SizedBox.shrink(),
    ColumnBandChildPlacement childPlacement =
        const ColumnBandChildPlacement.topLeft(),
    super.key,
  }) : super(
         child: child,
         height: 0,
         padding: EdgeInsets.zero,
         borderColor: const Color(0xFF00A36C),
         childPlacement: childPlacement,
         allowBandExpansion: false,
         trackId: trackId,
         overflowWarning: false,
       );
}
