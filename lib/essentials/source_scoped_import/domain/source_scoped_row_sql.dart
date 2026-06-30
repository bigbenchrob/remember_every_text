import 'source_scoped_row_key.dart';

/// SQL expression helpers for reading parts of a packed source-scoped row key.
///
/// Use these only with trusted SQL identifiers or expressions from repository
/// code. User input must still be supplied through query variables.
class SourceScopedRowSql {
  SourceScopedRowSql._();

  static String sourceId(String packedExpression) {
    return '($packedExpression >> ${SourceScopedRowKey.sourceRowIdBits})';
  }

  static String sourceRowId(String packedExpression) {
    return '($packedExpression & ${SourceScopedRowKey.maxSourceRowId})';
  }
}
