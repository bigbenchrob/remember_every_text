import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../features/conversations/domain/spec_classes/conversations_view_spec.dart';
import '../../../../features/conversations/feature_level_providers.dart'
    show
        ConversationSignatureDisplayByIdsRequest,
        conversationExcerptAnchorDateProvider,
        conversationSignatureDisplayByIdsProvider;
import '../../../../features/conversations/presentation/view/conversation_excerpt_panel_track_metrics.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card_presentation.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card_track_occupant.dart';
import '../../domain/entities/view_spec.dart';

final class SearchPageConversationExcerptTrackOccupants {
  const SearchPageConversationExcerptTrackOccupants({
    required this.title,
    required this.card,
    required this.temporalOrientation,
    required this.cardMinimumReservedHeight,
  });

  final TrackOccupant title;
  final TrackOccupant? card;
  final TrackOccupant? temporalOrientation;
  final double cardMinimumReservedHeight;
}

SearchPageConversationExcerptTrackOccupants
searchPageConversationExcerptTrackOccupants({
  required WidgetRef ref,
  required ViewSpec? rightSpec,
  required ThemeColors colors,
  required ThemeTypography typography,
  required PresentationConstraints constraints,
}) {
  final request = _conversationExcerptRequest(rightSpec);
  final cardStyle = conversationSignatureContextHeaderCardStyle(
    colors,
    typography,
  );
  final cardMinimumReservedHeight =
      ConversationSignatureCardTrackOccupant.minimumNaturalHeight(
        style: cardStyle,
        constraints: constraints,
      );
  final title = TextTrackOccupant(
    text: 'Conversation excerpt',
    style: typography.title1,
  );
  if (request == null) {
    return SearchPageConversationExcerptTrackOccupants(
      title: title,
      card: null,
      temporalOrientation: null,
      cardMinimumReservedHeight: cardMinimumReservedHeight,
    );
  }

  final anchorDate = ref
      .watch(
        conversationExcerptAnchorDateProvider(
          conversationId: request.conversationId,
          anchorMessageId: request.anchorMessageId,
        ),
      )
      .valueOrNull;
  final temporalOrientationLabel = conversationExcerptTemporalOrientationLabel(
    anchorDate,
  );
  final temporalOrientation = temporalOrientationLabel == null
      ? null
      : ConversationExcerptTemporalOrientationTrackOccupant(
          label: temporalOrientationLabel,
          style: conversationExcerptTemporalOrientationStyle(
            colors,
            typography,
          ),
        );

  final signatures = ref
      .watch(
        conversationSignatureDisplayByIdsProvider(
          request: ConversationSignatureDisplayByIdsRequest(
            conversationIds: [request.conversationId],
          ),
        ),
      )
      .valueOrNull;

  if (signatures == null || signatures.isEmpty) {
    return SearchPageConversationExcerptTrackOccupants(
      title: title,
      card: null,
      temporalOrientation: temporalOrientation,
      cardMinimumReservedHeight: cardMinimumReservedHeight,
    );
  }

  final signature = signatures.first;
  return SearchPageConversationExcerptTrackOccupants(
    title: title,
    card: ConversationSignatureCardTrackOccupant(
      signature: conversationSignatureCardDataFromDisplay(signature),
      style: cardStyle,
      horizontalPlacement: Alignment.center,
    ),
    temporalOrientation: temporalOrientation,
    cardMinimumReservedHeight: cardMinimumReservedHeight,
  );
}

({int conversationId, int anchorMessageId})? _conversationExcerptRequest(
  ViewSpec? spec,
) {
  return spec?.maybeWhen(
    conversations: (conversationsSpec) => conversationsSpec.when(
      conversationMessages: (_, __, ___) => null,
      conversationExcerpt: (conversationId, anchorMessageId, _, __, ___) =>
          (conversationId: conversationId, anchorMessageId: anchorMessageId),
    ),
    orElse: () => null,
  );
}
