import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../view_model/recovered_evidence_presentation.dart';

/// Messages-owned presentation occupants for a recovered-message page.
///
/// Navigation decides where these occupants are placed. Messages remains the
/// sole source of the wording and presentation contract used by its complete
/// center-panel rendering.
final class RecoveredMessagesPageTrackOccupants {
  const RecoveredMessagesPageTrackOccupants({required this.title});

  final TrackOccupant title;
}

RecoveredMessagesPageTrackOccupants recoveredMessagesPageTrackOccupants({
  required bool onlyNoHandleFromMe,
  required ThemeTypography typography,
}) {
  final presentation = RecoveredEvidencePresentation.from(
    contactId: null,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );

  return RecoveredMessagesPageTrackOccupants(
    title: TextTrackOccupant(
      text: presentation.title,
      style: typography.title1,
    ),
  );
}
