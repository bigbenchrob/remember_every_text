import 'package:flutter/widgets.dart';

import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import 'conversation_favourite_button.dart';
import 'conversation_signature_card.dart';
import 'conversation_signature_card_presentation.dart';

/// Track occupant for the Conversation Card used by the excerpt panel.
///
/// The page knows only that this occupant contributes a requirement to a track.
/// Conversation semantics, card presentation, and favourite affordance remain
/// owned by the Conversations feature.
class ConversationSignatureCardTrackOccupant implements TrackOccupant {
  const ConversationSignatureCardTrackOccupant({
    required this.signature,
    required this.style,
    this.includeFavouriteButton = true,
    this.horizontalPlacement = Alignment.centerLeft,
  });

  final ConversationSignatureCardData signature;
  final ConversationSignatureCardStyle style;
  final bool includeFavouriteButton;
  final AlignmentGeometry horizontalPlacement;

  static double minimumNaturalHeight({
    required ConversationSignatureCardStyle style,
    required PresentationConstraints constraints,
    bool includeFavouriteButton = true,
  }) {
    return ConversationSignatureCardPresentationMetrics.minimumNaturalHeight(
      style: style,
      constraints: constraints,
      trailingHeight: includeFavouriteButton
          ? ConversationFavouriteButton.defaultSize
          : 0,
    );
  }

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    return OccupantDimensionalClaim(
      naturalHeight: ConversationSignatureCardPresentationMetrics.naturalHeight(
        signature: signature,
        style: style,
        constraints: constraints,
        trailingHeight: includeFavouriteButton
            ? ConversationFavouriteButton.defaultSize
            : 0,
      ),
      preferredWidth:
          ConversationSignatureCardPresentationMetrics.canonicalWidth,
      minimumWidth: ConversationSignatureCardPresentationMetrics.canonicalWidth,
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return ConversationSignatureCard(
      signature: signature,
      style: style,
      monthColorForMessageCount: conversationSignatureMonthColorForMessageCount,
      trailing: includeFavouriteButton
          ? ConversationFavouriteButton(
              conversationId: signature.conversationId,
            )
          : null,
      horizontalPlacement: horizontalPlacement,
    );
  }
}
