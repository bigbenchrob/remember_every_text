import 'package:flutter/widgets.dart';

/// Shared horizontal layout tracks used to coordinate peer page columns.
enum TrackId { trackA, trackB, trackC, trackD, trackE }

/// Genuine presentation inputs needed to calculate dimensional truth.
///
/// This is deliberately a plain value object rather than a BuildContext. The
/// page resolves framework state once, then occupants translate their
/// presentation contracts into claims.
class PresentationConstraints {
  const PresentationConstraints({
    required this.availableWidth,
    required this.textScaler,
    required this.textDirection,
    this.locale,
  });

  factory PresentationConstraints.fromBuildContext(
    BuildContext context, {
    required double availableWidth,
  }) {
    return PresentationConstraints(
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

/// Placement-independent dimensional truth for one prepared presentation.
class OccupantDimensionalClaim {
  const OccupantDimensionalClaim({
    required this.naturalHeight,
    this.preferredWidth,
    this.minimumWidth,
  });

  final double naturalHeight;
  final double? preferredWidth;
  final double? minimumWidth;
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
/// Occupants own dimensional calculation and construction of the approved
/// feature presentation. Page composition supplies all placement.
abstract interface class TrackOccupant {
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  );

  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  );
}

/// Text presentation occupant for one shared track cell.
class TextTrackOccupant implements TrackOccupant {
  const TextTrackOccupant({
    required this.text,
    required this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = false,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
      textDirection: constraints.textDirection,
      textScaler: constraints.textScaler,
      locale: constraints.locale,
    )..layout(maxWidth: constraints.availableWidth);

    return OccupantDimensionalClaim(
      naturalHeight: painter.height,
      preferredWidth: painter.width,
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
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
  const FixedHeightTrackOccupant({required this.height});

  final double height;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    return OccupantDimensionalClaim(naturalHeight: height);
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return SizedBox(height: height);
  }
}
