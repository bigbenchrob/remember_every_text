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

/// Track adapter for the approved one-line Message Evidence scope context.
final class MessageEvidenceSupportingContextTrackOccupant
    implements TrackOccupant {
  const MessageEvidenceSupportingContextTrackOccupant({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final textClaim = TextTrackOccupant(
      text: text,
      style: style,
    ).dimensionalClaim(constraints);
    return OccupantDimensionalClaim(
      naturalHeight:
          textClaim.naturalHeight +
          MessageEvidenceHeaderTrackMetrics.supportingContextBottomInset,
      preferredWidth: textClaim.preferredWidth,
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: MessageEvidenceHeaderTrackMetrics.supportingContextBottomInset,
      ),
      child: Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
