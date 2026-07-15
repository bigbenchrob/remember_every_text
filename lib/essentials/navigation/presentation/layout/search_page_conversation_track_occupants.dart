import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart';
import '../../../../features/conversations/domain/spec_classes/conversations_view_spec.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card_presentation.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card_track_occupant.dart';
import '../../domain/entities/view_spec.dart';

List<TrackOccupant> searchPageConversationExcerptTrackOccupants({
  required WidgetRef ref,
  required ViewSpec? rightSpec,
  required ThemeColors colors,
  required ThemeTypography typography,
}) {
  final conversationId = _conversationExcerptId(rightSpec);
  if (conversationId == null) {
    return const <TrackOccupant>[];
  }

  final signatures = ref
      .watch(
        conversationSignatureDisplayByIdsProvider(
          request: ConversationSignatureDisplayByIdsRequest(
            conversationIds: [conversationId],
          ),
        ),
      )
      .valueOrNull;

  if (signatures == null || signatures.isEmpty) {
    return const <TrackOccupant>[];
  }

  final signature = signatures.first;
  return <TrackOccupant>[
    ConversationSignatureCardTrackOccupant(
      trackId: TrackId.trackC,
      signature: conversationSignatureCardDataFromDisplay(signature),
      style: conversationSignatureContextHeaderCardStyle(colors, typography),
    ),
  ];
}

int? _conversationExcerptId(ViewSpec? spec) {
  return spec?.maybeWhen(
    conversations: (conversationsSpec) => conversationsSpec.when(
      conversationMessages: (_, __, ___) => null,
      conversationExcerpt: (conversationId, _, __, ___) => conversationId,
    ),
    orElse: () => null,
  );
}
