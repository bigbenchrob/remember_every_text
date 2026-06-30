abstract interface class DeveloperModeStore {
  Future<String?> readMode();

  Future<void> writeMode(String mode);
}
