import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/importers/chat_importer.dart';

void main() {
  test('ChatImporter descriptor documents importer contract', () {
    const descriptor = ChatImporter.descriptor;

    expect(descriptor.importerName, 'chat_importer');
    expect(descriptor.sourceTables, <String>['chat']);
    expect(descriptor.targetTables, <String>['chats']);
    expect(descriptor.prerequisites, isEmpty);
    expect(
      descriptor.continuationStrategy,
      'MAX(chats.source_rowid) scoped by source_id',
    );
    expect(
      descriptor.idempotenceStrategy,
      'INSERT OR IGNORE / conflict ignore',
    );
    expect(
      descriptor.validationStrategy,
      'cursor/count convergence validation',
    );
  });
}
