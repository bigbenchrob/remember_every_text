import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/display_identity_repository.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;

  setUp(() async {
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    await overlayDatabase.customSelect('SELECT 1').get();
  });

  tearDown(() async {
    await graphDatabase.close();
    await overlayDatabase.close();
  });

  test(
    'canonical is_me identity overrides personal contact names and aliases',
    () async {
      await graphDatabase.executeSql('''
        INSERT INTO handles (ss_id, id, service, is_me)
        VALUES
          (1, '+16046858506', 'iMessage', 1),
          (2, 'tel:+16046858506', 'SMS', 0),
          (3, '+17789908506', 'iMessage', 0)
        ''');
      await graphDatabase.executeSql('''
        INSERT INTO canonical_handles (
          canonical_handle_ss_id,
          display_handle,
          normalized_identifier,
          service,
          alias_count
        ) VALUES
          (1, '+16046858506', '16046858506', 'iMessage', 2),
          (3, '+17789908506', '17789908506', 'iMessage', 1)
        ''');
      await graphDatabase.executeSql('''
        INSERT INTO handle_aliases (
          handle_ss_id,
          canonical_handle_ss_id,
          raw_identifier,
          normalized_identifier,
          alias_kind
        ) VALUES
          (1, 1, '+16046858506', '16046858506', 'canonical'),
          (2, 1, 'tel:+16046858506', '16046858506', 'telephone'),
          (3, 3, '+17789908506', '17789908506', 'canonical')
        ''');
      await graphDatabase.executeSql('''
        INSERT INTO contacts (
          contact_id,
          display_name,
          given_name,
          family_name,
          organization
        ) VALUES
          (10, 'Rob Campbell', 'Rob', 'Campbell', NULL),
          (20, 'Claire', 'Claire', NULL, NULL)
        ''');
      await graphDatabase.executeSql('''
        INSERT INTO contact_to_handle (
          contact_id,
          handle_ss_id,
          handle_value
        ) VALUES
          (10, 1, '+16046858506'),
          (20, 3, '+17789908506')
        ''');

      final resolver = await SqliteDisplayIdentityRepository(
        graphDatabase: graphDatabase,
        overlayDatabase: overlayDatabase,
      ).readResolver();

      expect(
        resolver.resolveParticipantForHandle('tel:+16046858506').primaryLabel,
        'Me',
      );
      expect(resolver.resolveContact(10).primaryLabel, 'Me');
      expect(
        resolver
            .resolveConversationFromHandles(
              conversationId: 1,
              handles: const ['tel:+16046858506'],
            )
            .title,
        'self',
      );
      expect(
        resolver
            .resolveConversationFromHandles(
              conversationId: 2,
              handles: const ['tel:+16046858506', '+17789908506'],
            )
            .title,
        'Me and Claire',
      );
    },
  );
}
