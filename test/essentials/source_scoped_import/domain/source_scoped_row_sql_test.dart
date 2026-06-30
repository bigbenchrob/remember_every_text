import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_sql.dart';

void main() {
  group('SourceScopedRowSql', () {
    test('names SQL source id extraction from a packed expression', () {
      expect(
        SourceScopedRowSql.sourceId('messages.ss_id'),
        '(messages.ss_id >> ${SourceScopedRowKey.sourceRowIdBits})',
      );
    });

    test('names SQL source rowid extraction from a packed expression', () {
      expect(
        SourceScopedRowSql.sourceRowId('attachments.ss_id'),
        '(attachments.ss_id & ${SourceScopedRowKey.maxSourceRowId})',
      );
    });
  });
}
