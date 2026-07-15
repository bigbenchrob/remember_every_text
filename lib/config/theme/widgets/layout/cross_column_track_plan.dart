import 'package:flutter/widgets.dart';

/// Shared horizontal layout tracks used to coordinate peer page columns.
enum TrackId { trackA, trackB, trackC }

/// A declarative requirement contributed by a column for a shared track.
class TrackRequirement {
  const TrackRequirement({required this.trackId, required this.height});

  final TrackId trackId;
  final double height;
}

/// Environmental inputs needed to calculate track requirements.
///
/// This is deliberately a plain value object rather than a BuildContext. The
/// page resolves framework state once, then occupants translate their
/// presentation contracts into requirements.
class TrackRequirementContext {
  const TrackRequirementContext({
    required this.availableWidth,
    required this.textScaler,
    required this.textDirection,
    this.locale,
  });

  factory TrackRequirementContext.fromBuildContext(
    BuildContext context, {
    required double availableWidth,
  }) {
    return TrackRequirementContext(
      availableWidth: availableWidth,
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      locale: Localizations.maybeLocaleOf(context),
    );
  }

  final double availableWidth;
  final TextScaler textScaler;
  final TextDirection textDirection;
  final Locale? locale;
}

/// Resolved geometry for a single occupant's track cell.
class ResolvedTrackAllocation {
  const ResolvedTrackAllocation({
    required this.trackId,
    required this.height,
    required this.availableWidth,
  });

  final TrackId trackId;
  final double height;
  final double availableWidth;
}

/// Declarative presentation adapter for content placed in a shared track.
///
/// Occupants own requirement calculation and construction of the presentation
/// widget. The page coordinator only sees TrackRequirement values.
abstract interface class TrackOccupant {
  TrackId get trackId;

  TrackRequirement requirement(TrackRequirementContext context);

  Widget build(BuildContext context, ResolvedTrackAllocation allocation);
}

/// Page-resolved track geometry shared by participating columns.
class ResolvedTrackPlan {
  const ResolvedTrackPlan._({
    required Map<TrackId, double> heights,
    required this.pageTopInset,
  }) : _heights = heights;

  factory ResolvedTrackPlan.resolve({
    required Iterable<TrackRequirement> requirements,
    double pageTopInset = 0,
  }) {
    final heights = <TrackId, double>{};
    for (final requirement in requirements) {
      final current = heights[requirement.trackId];
      if (current == null || requirement.height > current) {
        heights[requirement.trackId] = requirement.height;
      }
    }
    return ResolvedTrackPlan._(
      heights: Map<TrackId, double>.unmodifiable(heights),
      pageTopInset: pageTopInset,
    );
  }

  factory ResolvedTrackPlan.fromOccupants({
    required Iterable<TrackOccupant> occupants,
    required TrackRequirementContext context,
    double pageTopInset = 0,
  }) {
    return ResolvedTrackPlan.resolve(
      requirements: occupants.map((occupant) => occupant.requirement(context)),
      pageTopInset: pageTopInset,
    );
  }

  final Map<TrackId, double> _heights;
  final double pageTopInset;

  double heightFor(TrackId trackId, {required double fallback}) {
    return _heights[trackId] ?? fallback;
  }
}

/// Makes a resolved page track plan available to descendant band wrappers.
class ResolvedTrackPlanScope extends InheritedWidget {
  const ResolvedTrackPlanScope({
    required this.plan,
    required super.child,
    super.key,
  });

  final ResolvedTrackPlan plan;

  static ResolvedTrackPlan? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ResolvedTrackPlanScope>()
        ?.plan;
  }

  @override
  bool updateShouldNotify(ResolvedTrackPlanScope oldWidget) {
    return plan != oldWidget.plan;
  }
}

/// Renders a track occupant inside the current resolved track allocation.
class TrackOccupantView extends StatelessWidget {
  const TrackOccupantView({required this.occupant, super.key});

  final TrackOccupant occupant;

  @override
  Widget build(BuildContext context) {
    final requirementContext = TrackRequirementContext.fromBuildContext(
      context,
      availableWidth: double.infinity,
    );
    final fallbackRequirement = occupant.requirement(requirementContext);
    final plan = ResolvedTrackPlanScope.maybeOf(context);
    final height =
        plan?.heightFor(
          occupant.trackId,
          fallback: fallbackRequirement.height,
        ) ??
        fallbackRequirement.height;
    return SizedBox(
      height: fallbackRequirement.height,
      child: occupant.build(
        context,
        ResolvedTrackAllocation(
          trackId: occupant.trackId,
          height: height,
          availableWidth: double.infinity,
        ),
      ),
    );
  }
}

/// Text presentation occupant for one shared track cell.
class TextTrackOccupant implements TrackOccupant {
  const TextTrackOccupant({
    required this.trackId,
    required this.text,
    required this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = false,
  });

  @override
  final TrackId trackId;
  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;

  @override
  TrackRequirement requirement(TrackRequirementContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
      textDirection: context.textDirection,
      textScaler: context.textScaler,
      locale: context.locale,
    )..layout(maxWidth: context.availableWidth);

    return TrackRequirement(trackId: trackId, height: painter.height);
  }

  @override
  Widget build(BuildContext context, ResolvedTrackAllocation allocation) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Fixed-height occupant for a cell that requires constant vertical allocation.
///
/// When used for page-specific spacing, it still participates through the same
/// track negotiation model as visible content.
class FixedHeightTrackOccupant implements TrackOccupant {
  const FixedHeightTrackOccupant({required this.trackId, required this.height});

  @override
  final TrackId trackId;
  final double height;

  @override
  TrackRequirement requirement(TrackRequirementContext context) {
    return TrackRequirement(trackId: trackId, height: height);
  }

  @override
  Widget build(BuildContext context, ResolvedTrackAllocation allocation) {
    return SizedBox(height: allocation.height);
  }
}
