abstract interface class ContactAccessStore {
  Future<void> clearContactAccess(int contactId);

  Future<void> trackContactAccess(int contactId);
}
