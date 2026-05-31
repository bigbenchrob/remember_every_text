import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/application/user_metadata/message_overlay_controller.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;
  late ProviderContainer container;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    await overlayDatabase.customSelect('SELECT 1').get();
    container = ProviderContainer(
      overrides: <Override>[
        driftConversationGraphDatabaseProvider.overrideWith((ref) async {
          return graphDatabase;
        }),
        overlayDatabaseProvider.overrideWith((ref) async {
          return overlayDatabase;
        }),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await graphDatabase.close();
    await overlayDatabase.close();
  });

  test('reads and writes message overlay state by graph message id', () async {
    final messageId = SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 77);
    await graphDatabase.database.insert('messages', <String, Object?>{
      'ss_id': messageId,
      'guid': 'message-77',
      'is_from_me': 0,
    });

    final initial = await container.read(
      messageOverlayProvider(messageId).future,
    );
    expect(initial.hasUserIntent, isFalse);

    final controller = container.read(
      messageOverlayProvider(messageId).notifier,
    );
    await controller.setSaved(isSaved: true);
    await controller.setStarred(isStarred: true);
    await controller.addTags(<String>['Review']);

    final updated = await container.read(
      messageOverlayProvider(messageId).future,
    );
    final legacyGuidFlag = await overlayDatabase.getMessageUserFlag(
      'message-77',
    );

    expect(updated.isSaved, isTrue);
    expect(updated.isStarred, isTrue);
    expect(updated.tags, contains('Review'));
    expect(updated.hasGraphNativeOverlay, isTrue);
    expect(legacyGuidFlag, isNull);
  });
}
