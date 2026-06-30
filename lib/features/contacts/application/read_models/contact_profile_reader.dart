import '../../domain/overlay_virtual_contact.dart';
import 'contact_profile_summary.dart';

abstract interface class ContactProfileReader {
  Future<ContactProfileSummary?> readContactProfile({
    required int contactId,
    required Iterable<OverlayVirtualContact> virtualContacts,
  });
}
