import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../application/message_evidence/contact_evidence_header_context_provider.dart';
import '../../domain/spec_classes/messages_view_spec.dart';
import '../view_model/contact_messages_evidence_presentation.dart';
import '../view_model/recovered_evidence_presentation.dart';

/// Messages-owned Track occupants for center ViewSpecs shown from Contacts.
///
/// Navigation owns placement. Messages remains the sole source of the title
/// presentation contract for both ordinary contact evidence and recovered
/// contact evidence.
final class ContactsPageMessageTrackOccupants {
  const ContactsPageMessageTrackOccupants({required this.title});

  final TrackOccupant? title;
}

ContactsPageMessageTrackOccupants contactsPageMessageTrackOccupants({
  required WidgetRef ref,
  required ViewSpec? centerSpec,
  required ThemeTypography typography,
}) {
  final request = _contactMessagesRequest(centerSpec);
  if (request != null) {
    final headerContextAsync = ref.watch(
      contactEvidenceHeaderContextProvider(
        contactId: request.contactId,
        filterHandleId: request.filterHandleId,
      ),
    );
    final presentation = ContactMessagesEvidencePresentation.from(
      headerContext: headerContextAsync.valueOrNull,
      filterHandleId: request.filterHandleId,
      isHeaderLoading:
          headerContextAsync.isLoading && !headerContextAsync.hasValue,
    );
    return ContactsPageMessageTrackOccupants(
      title: TextTrackOccupant(
        text: presentation.title,
        style: typography.title1,
      ),
    );
  }

  final recoveredContactId = _recoveredContactId(centerSpec);
  if (recoveredContactId != null) {
    final presentation = RecoveredEvidencePresentation.from(
      contactId: recoveredContactId,
      onlyNoHandleFromMe: false,
    );
    return ContactsPageMessageTrackOccupants(
      title: TextTrackOccupant(
        text: presentation.title,
        style: typography.title1,
      ),
    );
  }

  return const ContactsPageMessageTrackOccupants(title: null);
}

({int contactId, int? filterHandleId})? _contactMessagesRequest(
  ViewSpec? spec,
) {
  return spec?.maybeWhen(
    messages: (messagesSpec) => messagesSpec.maybeWhen(
      forContact: (contactId, _, filterHandleId) =>
          (contactId: contactId, filterHandleId: filterHandleId),
      orElse: () => null,
    ),
    orElse: () => null,
  );
}

int? _recoveredContactId(ViewSpec? spec) {
  return spec?.maybeWhen(
    messages: (messagesSpec) => messagesSpec.maybeWhen(
      recoveredUnlinkedMessages: (contactId, _) => contactId,
      orElse: () => null,
    ),
    orElse: () => null,
  );
}
