import 'package:flutter/widgets.dart';

import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../features/messages/presentation/widgets/message_evidence/message_evidence_header_track_metrics.dart';
import '../../../../features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../domain/sidebar_mode.dart';

/// Builds the Search page's resolved track plan from declarative occupants.
///
/// Current Search-page cell mapping:
/// - A1: sidebar top menu.
/// - A2: center title.
/// - A3: right title.
/// - B1: no occupant.
/// - B2: center metadata line.
/// - B3: no occupant.
/// - C1: no occupant.
/// - C2: message-evidence post-metadata controls occupant.
/// - C3: optional right-panel Conversation Card occupant when an excerpt is
///   visible.
///
/// Tracks are ordinal geometry only. Page-specific meaning belongs to the
/// occupants placed into track cells, not to the track letters themselves.
///
/// Empty cells contribute no occupant and no requirement.
ResolvedTrackPlan resolveSearchPageTrackPlan({
  required BuildContext context,
  required ThemeTypography typography,
  Iterable<TrackOccupant> additionalOccupants = const <TrackOccupant>[],
  double trackRequirementAvailableWidth = double.infinity,
}) {
  final requirementContext = TrackRequirementContext.fromBuildContext(
    context,
    availableWidth: trackRequirementAvailableWidth,
  );
  final metadataStyle = typography.callout;
  final occupants = <TrackOccupant>[
    TopMenuTrackOccupant(
      currentChoice: TopChatMenuChoice.searchAllMessages,
      cassetteIndex: 0,
      sidebarMode: SidebarMode.messages,
      selectedValueStyle: typography.controlValue,
    ),
    TextTrackOccupant(
      trackId: TrackId.trackA,
      text: 'All messages',
      style: typography.title1,
    ),
    TextTrackOccupant(
      trackId: TrackId.trackA,
      text: 'Conversation',
      style: typography.title1,
    ),
    TextTrackOccupant(
      trackId: TrackId.trackB,
      // The Track B requirement is a single metadata line. The live metadata
      // text is rendered by MessageEvidenceHeader; its height is governed by
      // the same typography contract used here.
      text: 'Search result metadata',
      style: metadataStyle,
    ),
    const MessageEvidencePostMetadataControlsTrackOccupant(),
    ...additionalOccupants,
  ];

  return ResolvedTrackPlan.fromOccupants(
    occupants: occupants,
    context: requirementContext,
  );
}
