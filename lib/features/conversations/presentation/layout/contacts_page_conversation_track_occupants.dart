import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../application/message_evidence/conversation_evidence_header_context_provider.dart';
import '../../domain/spec_classes/conversations_view_spec.dart';
import '../view_model/conversation_messages_evidence_presentation.dart';

/// Conversations-owned Track occupants for center ViewSpecs shown from Contacts.
final class ContactsPageConversationTrackOccupants {
  const ContactsPageConversationTrackOccupants({required this.title});

  final TrackOccupant? title;
}

ContactsPageConversationTrackOccupants contactsPageConversationTrackOccupants({
  required WidgetRef ref,
  required ViewSpec? centerSpec,
  required ThemeTypography typography,
}) {
  final conversationId = _conversationId(centerSpec);
  if (conversationId == null) {
    return const ContactsPageConversationTrackOccupants(title: null);
  }

  final headerContext = ref
      .watch(
        conversationEvidenceHeaderContextProvider(
          conversationId: conversationId,
        ),
      )
      .valueOrNull;
  final presentation = ConversationMessagesEvidencePresentation.from(
    headerContext: headerContext,
  );
  return ContactsPageConversationTrackOccupants(
    title: TextTrackOccupant(
      text: presentation.title,
      style: typography.title1,
    ),
  );
}

int? _conversationId(ViewSpec? spec) {
  return spec?.maybeWhen(
    conversations: (conversationsSpec) => conversationsSpec.maybeWhen(
      conversationMessages: (conversationId, _, __) => conversationId,
      orElse: () => null,
    ),
    orElse: () => null,
  );
}
