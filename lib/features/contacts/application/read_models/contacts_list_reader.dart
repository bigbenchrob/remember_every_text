import 'contact_summary.dart';

abstract interface class ContactsListReader {
  Future<List<ContactSummary>> readContacts();
}
