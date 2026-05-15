import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/executors/shadow_message_importer.dart';

void main() {
  group('ShadowMessageImporter descriptor', () {
    test('documents importer identity and table ownership', () {
      const descriptor = ShadowMessageImporter.descriptor;

      expect(descriptor.importerName, 'ShadowMessageImporter');
      expect(descriptor.sourceTables, <String>['message']);
      expect(descriptor.targetTables, <String>[
        'import_batches',
        'chats',
        'messages',
      ]);
    });

    test('documents continuation, idempotence, and validation strategies', () {
      const descriptor = ShadowMessageImporter.descriptor;

      expect(
        descriptor.prerequisites,
        containsAll(<String>[
          'live chat.db message table readable',
          'macos_import_shadow.db schema initialized',
        ]),
      );
      expect(descriptor.continuationStrategy, contains('source_rowid'));
      expect(descriptor.idempotenceStrategy, contains('ConflictAlgorithm'));
      expect(descriptor.validationStrategy, contains('convergence'));
    });
  });
}
