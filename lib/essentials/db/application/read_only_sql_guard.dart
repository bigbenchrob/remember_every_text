void assertReadOnlySql(String sql, {required String boundary}) {
  final normalized = sql.trimLeft().toLowerCase();
  if (normalized.startsWith('select ') ||
      normalized.startsWith('select\n') ||
      normalized.startsWith('pragma ') ||
      normalized.startsWith('pragma\n') ||
      normalized.startsWith('with ') ||
      normalized.startsWith('with\n')) {
    return;
  }

  throw StateError('$boundary only accepts read queries');
}
