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
    required this.trackId,
    required this.signature,
    required this.style,
    this.includeFavouriteButton = true,
  });

  @override
  final TrackId trackId;
  final ConversationSignatureCardData signature;
  final ConversationSignatureCardStyle style;
  final bool includeFavouriteButton;

  @override
  TrackRequirement requirement(TrackRequirementContext context) {
    return TrackRequirement(
      trackId: trackId,
      height: ConversationSignatureCardPresentationMetrics.naturalHeight(
        signature: signature,
        style: style,
        context: context,
        trailingHeight: includeFavouriteButton
            ? ConversationFavouriteButton.defaultSize
            : 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context, ResolvedTrackAllocation allocation) {
    return ConversationSignatureCard(
      signature: signature,
      style: style,
      monthColorForMessageCount: conversationSignatureMonthColorForMessageCount,
      trailing: includeFavouriteButton
          ? ConversationFavouriteButton(
              conversationId: signature.conversationId,
            )
          : null,
    );
  }
}
