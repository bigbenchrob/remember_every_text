import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/application/read_models/handles_for_contact_provider.dart';
import 'package:remember_this_text/features/contacts/application/services/manual_handle_link_service.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_display_name_provider.dart';

void main() {
  group('ManualHandleLinkService', () {
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    });

    tearDown(() async {
      await overlayDb.close();
      container.dispose();
    });

    test('linkHandleToParticipant creates link successfully', () async {
      const handleId = 8796093022212;
      const participantId = 42;
      final graphParticipantId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: participantId,
      );

      final service = container.read(manualHandleLinkServiceProvider.notifier);
      final result = await service.linkHandleToParticipant(
        handleId: handleId,
        participantId: participantId,
      );

      expect(result.isRight(), isTrue);

      final overlayLink = await overlayDb.getHandleOverride(handleId);
      expect(overlayLink, isNotNull);
      expect(overlayLink!.handleId, handleId);
      expect(overlayLink.participantId, graphParticipantId);
    });

    test(
      'linkHandleToParticipant invalidates affected contact and handle reads',
      () async {
        const handleId = 8796093022212;
        const participantId = 42;
        var handlesReadCount = 0;
        var displayNameReadCount = 0;

        final container = ProviderContainer(
          overrides: [
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            handlesForContactProvider(contactId: participantId).overrideWith((
              ref,
            ) async {
              handlesReadCount += 1;
              return const [];
            }),
            handleDisplayNameProvider(handleId: handleId).overrideWith((
              ref,
            ) async {
              displayNameReadCount += 1;
              return 'Before';
            }),
          ],
        );
        addTearDown(container.dispose);

        await container.read(
          handlesForContactProvider(contactId: participantId).future,
        );
        await container.read(
          handleDisplayNameProvider(handleId: handleId).future,
        );

        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );
        final result = await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participantId,
        );
        expect(result.isRight(), isTrue);

        await container.read(
          handlesForContactProvider(contactId: participantId).future,
        );
        await container.read(
          handleDisplayNameProvider(handleId: handleId).future,
        );

        expect(handlesReadCount, 2);
        expect(displayNameReadCount, 2);
      },
    );

    test(
      'linkHandleToParticipant preserves different existing manual link',
      () async {
        const handleId = 8796093022212;
        const wrongParticipantId = 41;
        const correctParticipantId = 42;
        await overlayDb.setHandleOverride(handleId, wrongParticipantId);

        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );
        final result = await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: correctParticipantId,
        );

        expect(result.isLeft(), isTrue);
        final overlayLink = await overlayDb.getHandleOverride(handleId);
        expect(overlayLink, isNotNull);
        expect(overlayLink!.participantId, wrongParticipantId);
      },
    );

    test(
      'linkHandleToParticipant prevents duplicate manual link to different participant',
      () async {
        const handleId = 8796093022212;
        const participant1 = 42;
        const participant2 = 43;
        final graphParticipant1 = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: participant1,
        );

        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );
        await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participant1,
        );

        final result = await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participant2,
        );

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(
            failure.message,
            contains('already manually linked to a different contact'),
          );
        }, (_) => fail('Expected Left(Failure) but got Right(Unit)'));

        // Verify original link unchanged
        final overlayLink = await overlayDb.getHandleOverride(handleId);
        expect(overlayLink!.participantId, graphParticipant1);
      },
    );

    test(
      'linkHandleToParticipant allows re-linking to same participant',
      () async {
        const handleId = 8796093022212;
        const participantId = 42;

        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );
        await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participantId,
        );

        final result = await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participantId,
        );

        expect(result.isRight(), isTrue);
      },
    );

    test('unlinkHandle removes manual link successfully', () async {
      const handleId = 8796093022212;
      const participantId = 42;

      final service = container.read(manualHandleLinkServiceProvider.notifier);
      await service.linkHandleToParticipant(
        handleId: handleId,
        participantId: participantId,
      );

      final result = await service.unlinkHandle(handleId: handleId);

      expect(result.isRight(), isTrue);

      final overlayLink = await overlayDb.getHandleOverride(handleId);
      expect(overlayLink, isNull);
    });

    test('unlinkHandle invalidates previous contact handle reads', () async {
      const handleId = 8796093022212;
      const participantId = 42;
      var handlesReadCount = 0;

      await overlayDb.setHandleOverride(handleId, participantId);

      final container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          handlesForContactProvider(contactId: participantId).overrideWith((
            ref,
          ) async {
            handlesReadCount += 1;
            return const [];
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(
        handlesForContactProvider(contactId: participantId).future,
      );

      final service = container.read(manualHandleLinkServiceProvider.notifier);
      final result = await service.unlinkHandle(handleId: handleId);
      expect(result.isRight(), isTrue);

      await container.read(
        handlesForContactProvider(contactId: participantId).future,
      );

      expect(handlesReadCount, 2);
    });

    test('unlinkHandle returns error when no manual link exists', () async {
      final service = container.read(manualHandleLinkServiceProvider.notifier);
      final result = await service.unlinkHandle(handleId: 999);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure.message, contains('No manual link found'));
      }, (_) => fail('Expected Left(Failure) but got Right(Unit)'));
    });
  });
}
