import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';

void main() {
  test(
    'preferred participant label treats user override as semantic identity',
    () {
      expect(
        preferredParticipantPrimaryLabel(
          displayNameOverride: 'Claire',
          participantDisplayName: 'Claire Merriman Campbell',
        ),
        'Claire',
      );
    },
  );

  test('preferred participant label falls back to imported display name', () {
    expect(
      preferredParticipantPrimaryLabel(
        displayNameOverride: null,
        participantDisplayName: 'Cathie Campbell',
      ),
      'Cathie Campbell',
    );
  });

  test(
    'resolver resolves contact ids through the same semantic identity map',
    () {
      const resolver = DisplayIdentityResolver(
        identitiesByHandleKey: {},
        identitiesByContactId: {
          17: ParticipantDisplayIdentity(
            primaryLabel: 'Claire',
            source: DisplayIdentitySource.userOverride,
            isKnownContact: true,
            contactId: 17,
          ),
        },
      );

      final identity = resolver.resolveContact(17);

      expect(identity.primaryLabel, 'Claire');
      expect(identity.source, DisplayIdentitySource.userOverride);
      expect(identity.isKnownContact, isTrue);
    },
  );

  test('resolver answers what the user should see for handle inputs', () {
    const resolver = DisplayIdentityResolver(
      identitiesByHandleKey: {
        '17789908506': ParticipantDisplayIdentity(
          primaryLabel: 'Claire',
          source: DisplayIdentitySource.userOverride,
          isKnownContact: true,
          contactId: 17,
        ),
      },
    );

    final identity = resolver.resolveParticipantForHandle('+1 (778) 990-8506');

    expect(identity.primaryLabel, 'Claire');
    expect(identity.isKnownContact, isTrue);
    expect(identity.rawHandleLabel, '+1 (778) 990-8506');
  });

  test(
    'conversation titles are composed from resolved participant identities',
    () {
      const resolver = DisplayIdentityResolver(
        identitiesByHandleKey: {
          '17789908506': ParticipantDisplayIdentity(
            primaryLabel: 'Claire',
            source: DisplayIdentitySource.userOverride,
            isKnownContact: true,
            contactId: 17,
          ),
          '16049995969': ParticipantDisplayIdentity(
            primaryLabel: 'Cathie',
            source: DisplayIdentitySource.graphContact,
            isKnownContact: true,
            contactId: 24,
          ),
        },
      );

      final identity = resolver.resolveConversationFromHandles(
        conversationId: 42,
        handles: const ['+17789908506', '+16049995969'],
      );

      expect(identity.title, 'Claire and Cathie');
      expect(identity.participantLabels, ['Claire', 'Cathie']);
    },
  );

  test(
    'raw handles are fallback labels only when no known identity exists',
    () {
      const resolver = DisplayIdentityResolver(identitiesByHandleKey: {});

      final identity = resolver.resolveConversationFromHandles(
        conversationId: 42,
        handles: const ['+15551234567'],
      );

      expect(identity.title, '+15551234567');
      expect(identity.participantLabels, ['+15551234567']);
    },
  );

  test(
    'known sender resolves to contact identity and keeps raw handle metadata',
    () {
      const resolver = DisplayIdentityResolver(
        identitiesByHandleKey: {},
        identitiesByHandleId: {
          8796093022209: ParticipantDisplayIdentity(
            primaryLabel: 'Claire',
            source: DisplayIdentitySource.userOverride,
            isKnownContact: true,
            contactId: 17,
          ),
        },
      );

      final sender = resolver.resolveSender(
        isFromMe: false,
        senderCanonicalHandleId: 8796093022209,
        senderHandleId: 8796093022212,
        rawHandleLabel: '1 (778) 990-8506',
      );

      expect(sender.primaryLabel, 'Claire');
      expect(sender.rawHandleLabel, '1 (778) 990-8506');
      expect(sender.isKnownContact, isTrue);
    },
  );

  test(
    'unknown sender falls back to raw handle without duplicating metadata',
    () {
      const resolver = DisplayIdentityResolver(identitiesByHandleKey: {});

      final sender = resolver.resolveSender(
        isFromMe: false,
        senderHandleId: 42,
        rawHandleLabel: '+15551234567',
      );

      expect(sender.primaryLabel, '+15551234567');
      expect(sender.rawHandleLabel, isNull);
      expect(sender.isKnownContact, isFalse);
    },
  );

  test('from-me sender remains me', () {
    const resolver = DisplayIdentityResolver(identitiesByHandleKey: {});

    final sender = resolver.resolveSender(
      isFromMe: true,
      rawHandleLabel: '+15551234567',
    );

    expect(sender.primaryLabel, 'me');
    expect(sender.rawHandleLabel, isNull);
    expect(sender.isKnownContact, isTrue);
  });
}
