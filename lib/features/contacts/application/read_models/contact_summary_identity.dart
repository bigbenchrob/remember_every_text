import '../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import 'contact_summary.dart';

bool contactIdentityIdsMatch(int first, int second) {
  return contactIdsRepresentSamePerson(first, second);
}

Set<int> contactIdentityKeyVariants(int contactId) {
  return contactOverlayKeyVariants(contactId);
}

bool contactSummaryMatchesId(ContactSummary contact, int contactId) {
  return contactIdentityIdsMatch(contact.participantId, contactId);
}

ContactSummary? findContactSummaryById(
  List<ContactSummary> contacts,
  int contactId,
) {
  for (final contact in contacts) {
    if (contactSummaryMatchesId(contact, contactId)) {
      return contact;
    }
  }
  return null;
}
