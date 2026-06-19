import '../../../source_scoped_import/domain/known_sources.dart';
import '../../../source_scoped_import/domain/source_scoped_row_key.dart';

/// Normalizes contact-page ids into graph contact identity.
///
/// Existing contact routes can still carry live AddressBook ROWIDs. Virtual
/// contacts already use app-owned ids and must not be source-scoped as if they
/// were AddressBook rows.
int graphContactIdForContactPage(int contactId) {
  const virtualContactIdFloor = 1000000000;
  if (contactId <= 0 || contactId >= virtualContactIdFloor) {
    return contactId;
  }

  return SourceScopedRowKey.pack(
    sourceId: liveAddressBookSourceId,
    sourceRowId: contactId,
  );
}
