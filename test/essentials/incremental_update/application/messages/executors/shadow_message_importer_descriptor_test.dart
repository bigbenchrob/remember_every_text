import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/shadow_message_importer.dart';

void main() {
  group('ShadowMessageImporter descriptor', () {
    test('documents importer identity and table ownership', () {
      const descriptor = ShadowMessageImporter.descriptor;

      expect(descriptor.importerName, 'shadow_message_importer');
      expect(descriptor.sourceTables, <String>['message']);
      expect(descriptor.targetTables, <String>['messages']);
    });

    test('documents continuation, idempotence, and validation strategies', () {
      const descriptor = ShadowMessageImporter.descriptor;

      expect(descriptor.prerequisites, isEmpty);
      expect(descriptor.continuationStrategy, 'MAX(messages.source_rowid)');
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
