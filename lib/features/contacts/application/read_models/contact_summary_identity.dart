import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
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
  if (contactId <= 0 || contactId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveAddressBookSourceId,
    sourceRowId: contactId,
  );
}

int? _retainedContactIdForGraphContactId(int contactId) {
  if (SourceScopedRowKey.unpackSourceId(contactId) != liveAddressBookSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(contactId);
}
