abstract interface class ConversationSignaturePreferencesStore {
  Future<String?> readPreferences();

  Future<void> writePreferences(String storageValue);
}
