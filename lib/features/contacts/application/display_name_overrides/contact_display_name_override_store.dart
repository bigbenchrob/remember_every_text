/// Persistence boundary for user-assigned contact display names.
abstract interface class ContactDisplayNameOverrideStore {
  Future<void> setDisplayNameOverride({
    required int contactId,
    required String? displayName,
  });
}
