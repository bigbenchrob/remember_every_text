import '../../../core/util/date_converter.dart';
import '../../db/application/read_only_sql_guard.dart';
import '../application/message_coverage/current_messages_source_coverage_reader.dart';
import '../domain/ports/source_database_port.dart';

final class SourceDatabaseCurrentMessagesCoverageReader
    implements CurrentMessagesSourceCoverageReader {
  const SourceDatabaseCurrentMessagesCoverageReader({
    required SourceDatabaseOpener sourceDatabaseOpener,
  }) : _sourceDatabaseOpener = sourceDatabaseOpener;

  final SourceDatabaseOpener _sourceDatabaseOpener;

  @override
  Future<CurrentMessagesSourceCoverageEvidence> read({
    required String databasePath,
  }) async {
    final database = await _sourceDatabaseOpener.openReadOnly(databasePath);
    try {
      const identitySql =
          'SELECT ROWID AS source_rowid FROM message ORDER BY ROWID ASC';
      assertReadOnlySql(
        identitySql,
        boundary: 'Current Messages coverage identity query',
      );
      final identityRows = await database.rawQuery(identitySql);
      final sourceRowIds = <int>{};
      for (final row in identityRows) {
        final sourceRowId = _requiredPositiveInt(row, 'source_rowid');
        if (!sourceRowIds.add(sourceRowId)) {
          throw StateError(
            'Current Messages coverage observed duplicate ROWID $sourceRowId.',
          );
        }
      }

      const dateRangeSql = '''
        SELECT
          MIN(CASE WHEN date IS NOT NULL AND date != 0 THEN date END)
            AS first_date,
          MAX(CASE WHEN date IS NOT NULL AND date != 0 THEN date END)
            AS last_date
        FROM message
      ''';
      assertReadOnlySql(
        dateRangeSql,
        boundary: 'Current Messages coverage date-range query',
      );
      final dateRows = await database.rawQuery(dateRangeSql);
      if (dateRows.length != 1) {
        throw StateError(
          'Current Messages coverage expected one date-range row.',
        );
      }
      final dateRow = dateRows.single;

      return CurrentMessagesSourceCoverageEvidence(
        sourceRowIds: sourceRowIds,
        earliestMessageDate: DateConverter.appleToDateTime(
          dateRow['first_date'],
        )?.toUtc(),
        latestMessageDate: DateConverter.appleToDateTime(
          dateRow['last_date'],
        )?.toUtc(),
      );
    } finally {
      await database.close();
    }
  }
}

int _requiredPositiveInt(Map<String, Object?> row, String key) {
  final value = row[key];
  final result = switch (value) {
    int() => value,
    num() => value.toInt(),
    _ => null,
  };
  if (result == null || result <= 0) {
    throw StateError('$key must be a positive integer.');
  }
  return result;
}
