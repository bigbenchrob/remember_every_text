abstract interface class ContactAccessStore {
  Future<void> trackContactAccess(int contactId);
}
