import 'database_health_audit_models.dart';

abstract class DatabaseHealthQueryLayer {
  String get databaseKey;

  String get role;

  String get databasePath;

  Future<List<Map<String, Object?>>> query(String sql);

  Future<bool> ping() async {
    await query('SELECT 1 AS ok');
    return true;
  }

  Future<bool> databaseFileExists();

  Future<int?> schemaUserVersion() async {
    final rows = await query('PRAGMA user_version');
    if (rows.isEmpty) {
      return null;
    }
    return _coerceInt(rows.first['user_version']);
  }

  Future<List<String>> listTables() async {
    final rows = await query('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
      ORDER BY name
      ''');
    return rows
        .map((row) => row['name'] as String?)
        .whereType<String>()
        .toList();
  }

  Future<bool> tableExists(String tableName) async {
    final rows = await query('''
      SELECT COUNT(*) AS c
      FROM sqlite_master
      WHERE type = 'table'
        AND name = ${_stringLiteral(tableName)}
      ''');
    return (_coerceInt(rows.first['c']) ?? 0) > 0;
  }

  Future<List<String>> listColumns(String tableName) async {
    final rows = await query(
      'PRAGMA table_info(${_quotedIdentifier(tableName)})',
    );
    return rows
        .map((row) => row['name'] as String?)
        .whereType<String>()
        .toList();
  }

  Future<int> countRows(String tableName) async {
    final rows = await query(
      'SELECT COUNT(*) AS c FROM ${_quotedIdentifier(tableName)}',
    );
    return _coerceInt(rows.first['c']) ?? 0;
  }

  Future<DatabaseHealthPrimaryKeyInfo?> primaryKeyInfo(String tableName) async {
    final rows = await query(
      'PRAGMA table_info(${_quotedIdentifier(tableName)})',
    );
    final pkRows =
        rows.where((row) => (_coerceInt(row['pk']) ?? 0) > 0).toList()..sort(
          (a, b) =>
              (_coerceInt(a['pk']) ?? 0).compareTo(_coerceInt(b['pk']) ?? 0),
        );

    if (pkRows.length != 1) {
      return null;
    }

    final row = pkRows.first;
    final columnName = row['name'] as String?;
    if (columnName == null || columnName.isEmpty) {
      return null;
    }

    final type = ((row['type'] as String?) ?? '').toUpperCase();
    if (!type.contains('INT')) {
      return DatabaseHealthPrimaryKeyInfo(columnName: columnName);
    }

    final bounds = await query('''
      SELECT
        MIN(${_quotedIdentifier(columnName)}) AS min_value,
        MAX(${_quotedIdentifier(columnName)}) AS max_value
      FROM ${_quotedIdentifier(tableName)}
      ''');

    return DatabaseHealthPrimaryKeyInfo(
      columnName: columnName,
      minValue: _coerceInt(bounds.first['min_value']),
      maxValue: _coerceInt(bounds.first['max_value']),
    );
  }

  Future<DatabaseHealthImportantColumnSummary?> summarizeImportantColumn({
    required String tableName,
    required AuditImportantColumnSpec spec,
  }) async {
    final columns = await listColumns(tableName);
    if (!columns.contains(spec.columnName)) {
      return null;
    }

    if (spec.omittedForPrivacy) {
      return DatabaseHealthImportantColumnSummary(
        columnName: spec.columnName,
        omittedForPrivacy: true,
        notes: spec.notes,
      );
    }

    final rows = await query('''
      SELECT
        SUM(CASE WHEN ${_quotedIdentifier(spec.columnName)} IS NULL THEN 1 ELSE 0 END) AS null_count,
        SUM(CASE WHEN ${_quotedIdentifier(spec.columnName)} IS NOT NULL THEN 1 ELSE 0 END) AS non_null_count,
        COUNT(DISTINCT ${_quotedIdentifier(spec.columnName)}) AS distinct_count
      FROM ${_quotedIdentifier(tableName)}
      ''');

    final row = rows.first;
    return DatabaseHealthImportantColumnSummary(
      columnName: spec.columnName,
      nullCount: _coerceInt(row['null_count']),
      nonNullCount: _coerceInt(row['non_null_count']),
      distinctCount: _coerceInt(row['distinct_count']),
      notes: spec.notes,
    );
  }
}

class AuditTableSpec {
  const AuditTableSpec({
    required this.tableName,
    this.importantColumns = const <AuditImportantColumnSpec>[],
    this.notes = const <String>[],
  });

  final String tableName;
  final List<AuditImportantColumnSpec> importantColumns;
  final List<String> notes;
}

class AuditImportantColumnSpec {
  const AuditImportantColumnSpec(
    this.columnName, {
    this.omittedForPrivacy = false,
    this.notes = const <String>[],
  });

  final String columnName;
  final bool omittedForPrivacy;
  final List<String> notes;
}

int? _coerceInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is BigInt) {
    return value.toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

String _quotedIdentifier(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

String _stringLiteral(String value) {
  final escaped = value.replaceAll("'", "''");
  return "'$escaped'";
}
