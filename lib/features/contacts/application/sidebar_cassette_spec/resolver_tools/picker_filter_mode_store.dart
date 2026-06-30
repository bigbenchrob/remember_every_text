abstract interface class PickerFilterModeStore {
  Future<String?> readMode();

  Future<void> writeMode(String storageValue);
}
