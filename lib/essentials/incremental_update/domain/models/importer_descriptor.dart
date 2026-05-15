final class ImporterDescriptor {
  const ImporterDescriptor({
    required this.importerName,
    required this.sourceTables,
    required this.targetTables,
    required this.prerequisites,
    required this.continuationStrategy,
    required this.idempotenceStrategy,
    required this.validationStrategy,
  });

  final String importerName;
  final List<String> sourceTables;
  final List<String> targetTables;
  final List<String> prerequisites;
  final String continuationStrategy;
  final String idempotenceStrategy;
  final String validationStrategy;
}
