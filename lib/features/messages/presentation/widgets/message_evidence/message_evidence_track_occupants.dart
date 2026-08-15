import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../domain/message_evidence/message_evidence_search_mode.dart';
import 'message_evidence_header.dart';
import 'message_evidence_header_track_metrics.dart';

/// Track adapter for the approved Message Evidence Search controls.
final class MessageEvidenceSearchControlsTrackOccupant
    implements TrackOccupant {
  const MessageEvidenceSearchControlsTrackOccupant({
    required this.query,
    required this.placeholder,
    required this.mode,
    required this.onQueryChanged,
    required this.onModeChanged,
  });

  final String query;
  final String placeholder;
  final MessageEvidenceSearchMode mode;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MessageEvidenceSearchMode> onModeChanged;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    return const OccupantDimensionalClaim(
      naturalHeight: MessageEvidenceHeaderTrackMetrics.searchControlsRowHeight,
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return MessageEvidenceSearchControlsPresentation(
      query: query,
      placeholder: placeholder,
      mode: mode,
      onQueryChanged: onQueryChanged,
      onModeChanged: onModeChanged,
    );
  }
}

/// Track adapter for the current Search investigation status presentation.
final class SearchInvestigationStatusTrackOccupant implements TrackOccupant {
  const SearchInvestigationStatusTrackOccupant({
    required this.description,
    required this.isSearching,
    required this.style,
  });

  final String description;
  final bool isSearching;
  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final visibleText = description.isEmpty
        ? 'M'
        : '$description · Searching...';
    final textClaim = TextTrackOccupant(text: visibleText, style: style)
        .dimensionalClaim(
          PresentationConstraints(
            availableWidth: math.max(
              0.0,
              constraints.availableWidth -
                  MessageEvidenceHeaderTrackMetrics.searchLeadingSlotWidth -
                  MessageEvidenceHeaderTrackMetrics.searchLeadingGap -
                  MessageEvidenceHeaderTrackMetrics
                      .searchStatusFieldChromeInset,
            ),
            textScaler: constraints.textScaler,
            textDirection: constraints.textDirection,
            locale: constraints.locale,
          ),
        );
    return OccupantDimensionalClaim(
      naturalHeight: math.max(
        textClaim.naturalHeight,
        MessageEvidenceHeaderTrackMetrics.investigationStatusIndicatorRadius *
            2,
      ),
      preferredWidth:
          MessageEvidenceHeaderTrackMetrics.searchLeadingSlotWidth +
          MessageEvidenceHeaderTrackMetrics.searchLeadingGap +
          MessageEvidenceHeaderTrackMetrics.searchStatusFieldChromeInset +
          (textClaim.preferredWidth ?? 0),
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return SearchInvestigationStatusPresentation(
      description: description,
      isSearching: isSearching,
      style: style,
    );
  }
}
