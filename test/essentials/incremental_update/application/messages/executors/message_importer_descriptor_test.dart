import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/message_importer.dart';

void main() {
  group('MessageImporter descriptor', () {
    test('documents importer identity and table ownership', () {
      const descriptor = MessageImporter.descriptor;

      expect(descriptor.importerName, 'message_importer');
      expect(descriptor.sourceTables, <String>['message']);
      expect(descriptor.targetTables, <String>['messages']);
    });

    test('documents continuation, idempotence, and validation strategies', () {
      const descriptor = MessageImporter.descriptor;

      expect(descriptor.prerequisites, isEmpty);
      expect(
        descriptor.continuationStrategy,
        'MAX(messages.source_rowid) scoped by source_id',
      );
      expect(
        descriptor.idempotenceStrategy,
        'INSERT OR IGNORE / conflict ignore on already-imported rows',
      );
      expect(
        descriptor.validationStrategy,
        'cursor/count convergence validation',
      );
    });
  });
}
