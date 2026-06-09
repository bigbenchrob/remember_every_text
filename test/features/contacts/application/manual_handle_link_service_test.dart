import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/application/services/manual_handle_link_service.dart';

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

      final service = container.read(manualHandleLinkServiceProvider.notifier);
      final result = await service.linkHandleToParticipant(
        handleId: handleId,
        participantId: participantId,
      );

      expect(result.isRight(), isTrue);

      final overlayLink = await overlayDb.getHandleOverride(handleId);
      expect(overlayLink, isNotNull);
      expect(overlayLink!.handleId, handleId);
      expect(overlayLink.participantId, participantId);
    });

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
        expect(overlayLink!.participantId, participant1);
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
