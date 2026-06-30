import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_info_cassette_spec.dart';

void main() {
  group('contacts message-scope topology regression', () {
    test('messageScopeToggle immediate child matches current app topology', () {
      const currentSpec = CassetteSpec.contacts(
        ContactsCassetteSpec.messageScopeToggle(contactId: 42),
      );

      const regularContext = StableCassetteTopologyContext(
        messageScope: StableCascadeMessageScope.regular,
      );
      const recoveredContext = StableCassetteTopologyContext(
        messageScope: StableCascadeMessageScope.recoveredDeleted,
      );

      final regularChild = resolveStableCascadeChild(
        currentSpec,
        context: regularContext,
      );
      final recoveredChild = resolveStableCascadeChild(
        currentSpec,
        context: recoveredContext,
      );

      expect(
        regularChild,
        equals(
          const CassetteSpec.contacts(
            ContactsCassetteSpec.handleFilter(contactId: 42),
          ),
        ),
      );
      expect(
        recoveredChild,
        equals(
          const CassetteSpec.messagesInfo(
            MessagesInfoCassetteSpec.infoCard(
              key: MessagesInfoKey.recoveredDeletedMessages,
            ),
          ),
        ),
      );
    });

    test('contactHeroSummary cascades directly to message scope controls', () {
      const currentSpec = CassetteSpec.contacts(
        ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
      );

      const regularContext = StableCassetteTopologyContext(
        messageScope: StableCascadeMessageScope.regular,
      );
      const recoveredContext = StableCassetteTopologyContext(
        messageScope: StableCascadeMessageScope.recoveredDeleted,
      );

      final regularChild = resolveStableCascadeChild(
        currentSpec,
        context: regularContext,
      );
      final recoveredChild = resolveStableCascadeChild(
        currentSpec,
        context: recoveredContext,
      );

      const expectedChild = CassetteSpec.contacts(
        ContactsCassetteSpec.messageScopeToggle(contactId: 42),
      );

      expect(regularChild, equals(expectedChild));
      expect(recoveredChild, equals(expectedChild));
    });
  });
}
