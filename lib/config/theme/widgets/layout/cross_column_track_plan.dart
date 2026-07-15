import 'package:flutter/widgets.dart';

/// Shared horizontal layout tracks used to coordinate peer page columns.
enum TrackId { trackA, trackB }

/// A declarative requirement contributed by a column for a shared track.
class TrackRequirement {
  const TrackRequirement({required this.trackId, required this.height});

  final TrackId trackId;
  final double height;
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

/// Natural Search-page track occupant contracts.
///
/// These values describe the visible occupants themselves, not page spacing:
/// - sidebar top menu: dropdown trigger vertical padding (10 + 10) plus the
///   chevron capsule (14 icon + 4 + 4 padding);
/// - panel title: `ThemeTypography.title1` line contract (20 * 1.15);
/// - metadata row: `ThemeTypography.callout` line contract (14 * 1.25).
///
/// Occupied tracks contain no discretionary spacing. Their height is the
/// maximum natural requirement declared by their occupants. All intentional
/// cross-column spacing is modeled as explicit empty tracks.
abstract final class SearchPageTrackRequirements {
  const SearchPageTrackRequirements._();

  static const double pageTopInset = 0;
  static const double sidebarTopMenuTrigger = 42;
  static const double panelTitleLine = 23;
  static const double metadataLine = 17.5;
}

/// Search page Track A/B proof slice.
///
/// Track A is the identity track. The Search page currently has three
/// participants: the sidebar top menu, the center "All messages" title, and
/// the right "Conversation" title.
///
/// Track B is the supporting identity track. In the second slice, only the
/// center metadata subheader renders visible content in Track B. The sidebar
/// and right panel still declare empty requirements so the page proves empty
/// track participation without moving cassette or Conversation Card content.
final ResolvedTrackPlan searchPageTrackPlan = ResolvedTrackPlan.resolve(
  pageTopInset: SearchPageTrackRequirements.pageTopInset,
  requirements: const <TrackRequirement>[
    TrackRequirement(
      trackId: TrackId.trackA,
      height: SearchPageTrackRequirements.sidebarTopMenuTrigger,
    ),
    TrackRequirement(
      trackId: TrackId.trackA,
      height: SearchPageTrackRequirements.panelTitleLine,
    ),
    TrackRequirement(
      trackId: TrackId.trackA,
      height: SearchPageTrackRequirements.panelTitleLine,
    ),
    TrackRequirement(trackId: TrackId.trackB, height: 0),
    TrackRequirement(
      trackId: TrackId.trackB,
      height: SearchPageTrackRequirements.metadataLine,
    ),
    TrackRequirement(trackId: TrackId.trackB, height: 0),
  ],
);
