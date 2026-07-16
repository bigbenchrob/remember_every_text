import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart';
import '../../../../features/conversations/domain/spec_classes/conversations_view_spec.dart';
import '../../../../features/conversations/presentation/view/conversation_excerpt_panel_track_metrics.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card_presentation.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card_track_occupant.dart';
import '../../domain/entities/view_spec.dart';

final class SearchPageConversationExcerptTrackOccupants {
  const SearchPageConversationExcerptTrackOccupants({
    required this.title,
    required this.card,
    required this.excerptLabel,
    required this.cardMinimumReservedHeight,
    required this.excerptLabelMinimumReservedHeight,
  });

  final TrackOccupant title;
  final TrackOccupant? card;
  final TrackOccupant? excerptLabel;
  final double cardMinimumReservedHeight;
  final double excerptLabelMinimumReservedHeight;
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
  final excerptStyle = conversationExcerptLabelStyle(colors, typography);
  final cardMinimumReservedHeight =
      ConversationSignatureCardTrackOccupant.minimumNaturalHeight(
        style: cardStyle,
        constraints: constraints,
      );
  final excerptLabelMinimumReservedHeight =
      ConversationExcerptPanelTrackMetrics.excerptLabelMinimumNaturalHeight(
        style: excerptStyle,
        constraints: constraints,
      );
  final title = TextTrackOccupant(
    text: 'Conversation',
    style: typography.title1,
  );
  if (request == null) {
    return SearchPageConversationExcerptTrackOccupants(
      title: title,
      card: null,
      excerptLabel: null,
      cardMinimumReservedHeight: cardMinimumReservedHeight,
      excerptLabelMinimumReservedHeight: excerptLabelMinimumReservedHeight,
    );
  }

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
      excerptLabel: ConversationExcerptLabelTrackOccupant(
        label: conversationExcerptLabel(request.messageCount),
        style: excerptStyle,
      ),
      cardMinimumReservedHeight: cardMinimumReservedHeight,
      excerptLabelMinimumReservedHeight: excerptLabelMinimumReservedHeight,
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
    excerptLabel: ConversationExcerptLabelTrackOccupant(
      label: conversationExcerptLabel(request.messageCount),
      style: excerptStyle,
    ),
    cardMinimumReservedHeight: cardMinimumReservedHeight,
    excerptLabelMinimumReservedHeight: excerptLabelMinimumReservedHeight,
  );
}

({int conversationId, int messageCount})? _conversationExcerptRequest(
  ViewSpec? spec,
) {
  return spec?.maybeWhen(
    conversations: (conversationsSpec) => conversationsSpec.when(
      conversationMessages: (_, __, ___) => null,
      conversationExcerpt: (conversationId, _, beforeCount, afterCount) => (
        conversationId: conversationId,
        messageCount: beforeCount + afterCount + 1,
      ),
    ),
    orElse: () => null,
  );
}
