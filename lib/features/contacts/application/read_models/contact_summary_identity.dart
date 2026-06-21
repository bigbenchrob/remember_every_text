import '../../../../essentials/conversation_graph/application/identity/contact_page_graph_identity.dart';
import 'contact_summary.dart';

/// Overlay compatibility bridge for contact identity.
///
/// Ordinary contact identity is the graph `ss_id`. These helpers exist so
/// retained overlay rows keyed by older contact ids can still resolve to graph
/// contacts while the app continues to write and present canonical graph ids.
bool contactIdentityIdsMatch(int first, int second) {
  return contactIdentityKeyVariants(first).contains(second) ||
      contactIdentityKeyVariants(second).contains(first);
}

Set<int> contactIdentityKeyVariants(int contactId) {
  final ids = <int>{contactId};
  final graphContactId = _graphContactIdForRetainedContactId(contactId);
  if (graphContactId != null) {
    ids.add(graphContactId);
  }
  final retainedContactId = _retainedContactIdForGraphContactId(contactId);
  if (retainedContactId != null) {
    ids.add(retainedContactId);
  }
  return ids;
}

int canonicalContactIdentityKey(int contactId) {
  return _graphContactIdForRetainedContactId(contactId) ?? contactId;
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

int? _graphContactIdForRetainedContactId(int contactId) {
  final graphContactId = graphContactIdForContactPage(contactId);
  return graphContactId == contactId ? null : graphContactId;
}

int? _retainedContactIdForGraphContactId(int contactId) {
  return liveAddressBookRowIdForGraphContactId(contactId);
}
