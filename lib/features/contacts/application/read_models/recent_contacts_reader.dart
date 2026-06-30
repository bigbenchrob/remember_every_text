import 'contact_summary.dart';
import 'recent_contact_summary.dart';

abstract interface class RecentContactsReader {
  Future<List<RecentContactSummary>> readRecentContacts({
    required List<ContactSummary> contacts,
  });
}
