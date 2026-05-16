import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/importers/handle_importer.dart';

void main() {
  group('HandleImporter descriptor', () {
    test('documents importer metadata', () {
      const descriptor = HandleImporter.descriptor;

      expect(descriptor.importerName, 'handle_importer');
      expect(descriptor.sourceTables, <String>['handle']);
      expect(descriptor.targetTables, <String>['handles']);
      expect(descriptor.prerequisites, isEmpty);
      expect(descriptor.continuationStrategy, 'MAX(handles.source_rowid)');
      expect(
        descriptor.idempotenceStrategy,
        'INSERT OR IGNORE / conflict ignore on already-imported source rows',
      );
      expect(
        descriptor.validationStrategy,
        'cursor/count convergence validation',
      );
    });
  });
}
