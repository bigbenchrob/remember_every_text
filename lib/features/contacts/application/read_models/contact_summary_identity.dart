import '../../../../essentials/conversation_graph/application/identity/contact_page_graph_identity.dart';
import 'contact_summary.dart';

/// Overlay compatibility bridge for contact identity.
///
/// Ordinary contact identity is the graph `ss_id`. These helpers exist so
/// older rowid-keyed overlay rows can still resolve to graph
/// contacts while the app continues to write and present canonical graph ids.
bool contactIdentityIdsMatch(int first, int second) {
  return contactIdentityKeyVariants(first).contains(second) ||
      contactIdentityKeyVariants(second).contains(first);
}

Set<int> contactIdentityKeyVariants(int contactId) {
  final ids = <int>{contactId};
  final graphContactId = _graphContactIdForRowidKeyedContactId(contactId);
  if (graphContactId != null) {
    ids.add(graphContactId);
  }
  final rowidKeyedContactId = _rowidKeyedContactIdForGraphContactId(contactId);
  if (rowidKeyedContactId != null) {
    ids.add(rowidKeyedContactId);
  }
  return ids;
}

int canonicalContactIdentityKey(int contactId) {
  return _graphContactIdForRowidKeyedContactId(contactId) ?? contactId;
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

int? _graphContactIdForRowidKeyedContactId(int contactId) {
  final graphContactId = graphContactIdForContactPage(contactId);
  return graphContactId == contactId ? null : graphContactId;
}

int? _rowidKeyedContactIdForGraphContactId(int contactId) {
  return liveAddressBookRowIdForGraphContactId(contactId);
}
