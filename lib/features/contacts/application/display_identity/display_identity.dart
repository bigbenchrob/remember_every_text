import '../../../../essentials/conversation_graph/application/contacts/contact_handle_keys.dart';

enum DisplayIdentitySource {
  userOverride,
  overlayVirtual,
  graphContact,
  handleFallback,
  unknown,
}

class ParticipantDisplayIdentity {
  const ParticipantDisplayIdentity({
    required this.primaryLabel,
    required this.source,
    required this.isKnownContact,
    this.contactId,
    this.rawHandleLabel,
  });

  final String primaryLabel;
  final DisplayIdentitySource source;
  final bool isKnownContact;
  final int? contactId;
  final String? rawHandleLabel;

  bool get isFallback => source == DisplayIdentitySource.handleFallback;
}

class ConversationDisplayIdentity {
  const ConversationDisplayIdentity({
    required this.conversationId,
    required this.title,
    required this.participantLabels,
  });

  final int? conversationId;
  final String title;
  final List<String> participantLabels;
}

class MessageSenderDisplayIdentity {
  const MessageSenderDisplayIdentity({
    required this.primaryLabel,
    required this.isKnownContact,
    this.rawHandleLabel,
    this.contactId,
  });

  final String primaryLabel;
  final bool isKnownContact;
  final String? rawHandleLabel;
  final int? contactId;
}

class DisplayIdentityResolver {
  const DisplayIdentityResolver({
    required Map<String, ParticipantDisplayIdentity> identitiesByHandleKey,
    Map<int, ParticipantDisplayIdentity> identitiesByHandleId =
        const <int, ParticipantDisplayIdentity>{},
    Map<int, ParticipantDisplayIdentity> identitiesByContactId =
        const <int, ParticipantDisplayIdentity>{},
  }) : _identitiesByHandleKey = identitiesByHandleKey,
       _identitiesByHandleId = identitiesByHandleId,
       _identitiesByContactId = identitiesByContactId;

  final Map<String, ParticipantDisplayIdentity> _identitiesByHandleKey;
  final Map<int, ParticipantDisplayIdentity> _identitiesByHandleId;
  final Map<int, ParticipantDisplayIdentity> _identitiesByContactId;

  ParticipantDisplayIdentity resolveContact(int contactId) {
    final identity = _identitiesByContactId[contactId];
    if (identity != null) {
      return identity;
    }

    return ParticipantDisplayIdentity(
      primaryLabel: 'contact $contactId',
      source: DisplayIdentitySource.unknown,
      isKnownContact: false,
      contactId: contactId,
    );
  }

  ParticipantDisplayIdentity resolveParticipantForHandle(String handle) {
    final trimmed = handle.trim();
    if (trimmed.isEmpty) {
      return const ParticipantDisplayIdentity(
        primaryLabel: 'Unknown Contact',
        source: DisplayIdentitySource.unknown,
        isKnownContact: false,
      );
    }

    for (final key in contactHandleKeys(trimmed)) {
      final identity = _identitiesByHandleKey[key];
      if (identity != null) {
        return ParticipantDisplayIdentity(
          primaryLabel: identity.primaryLabel,
          source: identity.source,
          isKnownContact: identity.isKnownContact,
          contactId: identity.contactId,
          rawHandleLabel: trimmed,
        );
      }
    }

    return ParticipantDisplayIdentity(
      primaryLabel: trimmed,
      source: DisplayIdentitySource.handleFallback,
      isKnownContact: false,
      rawHandleLabel: trimmed,
    );
  }

  List<ParticipantDisplayIdentity> resolveParticipantsForHandles(
    Iterable<String> handles,
  ) {
    final identities = <ParticipantDisplayIdentity>[];
    final seenLabels = <String>{};

    for (final handle in handles) {
      final identity = resolveParticipantForHandle(handle);
      final labelKey = identity.primaryLabel.trim().toLowerCase();
      if (labelKey.isEmpty) {
        continue;
      }
      if (seenLabels.add(labelKey)) {
        identities.add(identity);
      }
    }

    return identities;
  }

  ConversationDisplayIdentity resolveConversationFromHandles({
    required int? conversationId,
    required Iterable<String> handles,
  }) {
    final participants = resolveParticipantsForHandles(handles);
    final labels = participants.isEmpty
        ? const ['Unknown Contact']
        : List<String>.unmodifiable([
            for (final participant in participants) participant.primaryLabel,
          ]);

    return ConversationDisplayIdentity(
      conversationId: conversationId,
      title: conversationTitleForParticipantLabels(labels),
      participantLabels: labels,
    );
  }

  MessageSenderDisplayIdentity resolveSender({
    required bool isFromMe,
    int? senderCanonicalHandleId,
    int? senderHandleId,
    String? rawHandleLabel,
  }) {
    final normalizedRawHandle = rawHandleLabel?.trim();
    if (isFromMe) {
      return const MessageSenderDisplayIdentity(
        primaryLabel: 'me',
        isKnownContact: true,
      );
    }

    final identity = _identityForSender(
      senderCanonicalHandleId: senderCanonicalHandleId,
      senderHandleId: senderHandleId,
      rawHandleLabel: normalizedRawHandle,
    );
    if (identity != null) {
      return MessageSenderDisplayIdentity(
        primaryLabel: identity.primaryLabel,
        isKnownContact: identity.isKnownContact,
        rawHandleLabel:
            normalizedRawHandle == null || normalizedRawHandle.isEmpty
            ? identity.rawHandleLabel
            : normalizedRawHandle,
        contactId: identity.contactId,
      );
    }

    if (normalizedRawHandle != null && normalizedRawHandle.isNotEmpty) {
      return MessageSenderDisplayIdentity(
        primaryLabel: normalizedRawHandle,
        isKnownContact: false,
      );
    }

    if (senderCanonicalHandleId != null) {
      return MessageSenderDisplayIdentity(
        primaryLabel: 'canonical handle $senderCanonicalHandleId',
        isKnownContact: false,
      );
    }
    if (senderHandleId != null) {
      return MessageSenderDisplayIdentity(
        primaryLabel: 'handle $senderHandleId',
        isKnownContact: false,
      );
    }
    return const MessageSenderDisplayIdentity(
      primaryLabel: 'unknown sender',
      isKnownContact: false,
    );
  }

  ParticipantDisplayIdentity? _identityForSender({
    required int? senderCanonicalHandleId,
    required int? senderHandleId,
    required String? rawHandleLabel,
  }) {
    if (senderCanonicalHandleId != null) {
      final identity = _identitiesByHandleId[senderCanonicalHandleId];
      if (identity != null) {
        return identity;
      }
    }
    if (senderHandleId != null) {
      final identity = _identitiesByHandleId[senderHandleId];
      if (identity != null) {
        return identity;
      }
    }
    if (rawHandleLabel != null && rawHandleLabel.isNotEmpty) {
      final identity = resolveParticipantForHandle(rawHandleLabel);
      return identity.isFallback ? null : identity;
    }
    return null;
  }

  Map<String, ParticipantDisplayIdentity> get identitiesByHandleKey =>
      Map<String, ParticipantDisplayIdentity>.unmodifiable(
        _identitiesByHandleKey,
      );

  Map<int, ParticipantDisplayIdentity> get identitiesByHandleId =>
      Map<int, ParticipantDisplayIdentity>.unmodifiable(_identitiesByHandleId);

  Map<int, ParticipantDisplayIdentity> get identitiesByContactId =>
      Map<int, ParticipantDisplayIdentity>.unmodifiable(_identitiesByContactId);
}

String conversationTitleForParticipantLabels(List<String> participants) {
  if (participants.isEmpty) {
    return 'Unknown Conversation';
  }
  if (participants.length == 1) {
    return participants.first;
  }
  if (participants.length == 2) {
    return '${participants[0]} and ${participants[1]}';
  }
  return '${participants[0]}, ${participants[1]} + ${participants.length - 2}';
}

String preferredParticipantPrimaryLabel({
  required String? displayNameOverride,
  required String participantDisplayName,
}) {
  final trimmedDisplayNameOverride = displayNameOverride?.trim();
  if (trimmedDisplayNameOverride != null &&
      trimmedDisplayNameOverride.isNotEmpty) {
    return trimmedDisplayNameOverride;
  }

  return participantDisplayName;
}
