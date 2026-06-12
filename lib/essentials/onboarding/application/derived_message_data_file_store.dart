abstract interface class DerivedMessageDataFileStore {
  bool databaseBaseFileExists(String baseName);

  Map<String, bool> databaseExistenceByBaseName(List<String> baseNames);

  Future<List<String>> deleteDatabaseBaseFiles(List<String> baseNames);
}
