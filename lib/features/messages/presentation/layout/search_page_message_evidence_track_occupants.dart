import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../application/message_evidence/global_messages_search_session_provider.dart';
import '../../domain/spec_classes/messages_view_spec.dart';
import '../view_model/global_messages_evidence_presentation_provider.dart';
import '../widgets/message_evidence/message_evidence_header_track_metrics.dart';
import '../widgets/message_evidence/message_evidence_track_occupants.dart';

/// Feature-prepared occupants consumed by the Search page composition.
///
/// Messages owns all wording, state, and presentation contracts. The page sees
/// only opaque occupants and decides where to place them.
final class SearchPageMessageEvidenceTrackOccupants {
  const SearchPageMessageEvidenceTrackOccupants({
    required this.title,
    required this.metadata,
    required this.searchControls,
    required this.investigationStatus,
    required this.investigationStatusMinimumReservedHeight,
  });

  final TrackOccupant title;
  final TrackOccupant metadata;
  final TrackOccupant searchControls;
  final TrackOccupant investigationStatus;
  final double investigationStatusMinimumReservedHeight;
}

SearchPageMessageEvidenceTrackOccupants
searchPageMessageEvidenceTrackOccupants({
  required WidgetRef ref,
  required ViewSpec? centerSpec,
  required ThemeColors colors,
  required ThemeTypography typography,
  required PresentationConstraints constraints,
}) {
  final monthAnchor = _globalTimelineMonthAnchor(centerSpec);
  final presentation = ref.watch(
    globalMessagesEvidencePresentationProvider(monthAnchor: monthAnchor),
  );
  final labels = presentation.labels;
  final secondaryStyle = typography.callout.copyWith(
    color: colors.content.textSecondary,
  );
  final supportingStyle = typography.caption.copyWith(
    color: colors.content.textSecondary,
  );
  final actions = ref.read(
    globalMessagesSearchSessionProvider(monthAnchor: monthAnchor).notifier,
  );

  return SearchPageMessageEvidenceTrackOccupants(
    title: TextTrackOccupant(text: 'All messages', style: typography.title1),
    metadata: TextTrackOccupant(
      text: labels?.metadata ?? '',
      style: secondaryStyle,
    ),
    searchControls: MessageEvidenceSearchControlsTrackOccupant(
      query: presentation.query,
      placeholder: 'Search these messages',
      mode: presentation.mode,
      onQueryChanged: actions.setQuery,
      onModeChanged: actions.setMode,
    ),
    investigationStatus: SearchInvestigationStatusTrackOccupant(
      description: presentation.investigationStatus?.description ?? '',
      isSearching: presentation.investigationStatus?.isSearching ?? false,
      style: supportingStyle,
    ),
    investigationStatusMinimumReservedHeight:
        MessageEvidenceHeaderTrackMetrics.investigationStatusMinimumNaturalHeight(
          style: supportingStyle,
          constraints: constraints,
        ),
  );
}

DateTime? _globalTimelineMonthAnchor(ViewSpec? spec) {
  return spec?.maybeWhen(
    messages: (messagesSpec) {
      return messagesSpec.maybeWhen(
        globalTimeline: (scrollToDate) => scrollToDate,
        orElse: () => null,
      );
    },
    orElse: () => null,
  );
}
