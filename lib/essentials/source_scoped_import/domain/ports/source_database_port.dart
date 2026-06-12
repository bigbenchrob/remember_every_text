abstract interface class ReadOnlySourceDatabase {
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<List<Map<String, Object?>>> query(String table, {String? orderBy});

  Future<void> close();
}

abstract interface class SourceDatabaseOpener {
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath);
}
