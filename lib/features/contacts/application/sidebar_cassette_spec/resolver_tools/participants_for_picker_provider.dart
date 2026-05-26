import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/participant_origin.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';

part 'participants_for_picker_provider.g.dart';

/// Data model for a participant in the contact picker
class ParticipantForPicker {
  const ParticipantForPicker({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.handleCount,
    required this.origin,
  });

  final int id;
  final String displayName;
  final String shortName;
  final int handleCount;
  final ParticipantOrigin origin;

  bool get isVirtual => origin == ParticipantOrigin.overlayVirtual;
}

/// Provider that fetches participants filtered by search query
///
/// This is used by the ContactPickerDialog to show searchable participants.
/// The search is case-insensitive and matches against display_name and short_name.
@riverpod
Future<List<ParticipantForPicker>> participantsForPicker(
  ParticipantsForPickerRef ref, {
  required String searchQuery,
}) async {
  final normalizedQuery = searchQuery.trim().toLowerCase();
  final contacts = await ref.watch(contactsListRepositoryProvider.future);

  return contacts
      .where(
        (contact) =>
            normalizedQuery.isEmpty ||
            contact.displayName.toLowerCase().contains(normalizedQuery) ||
            contact.shortName.toLowerCase().contains(normalizedQuery),
      )
      .map(
        (contact) => ParticipantForPicker(
          id: contact.participantId,
          displayName: contact.displayName,
          shortName: contact.shortName,
          handleCount: contact.handleCount,
          origin: contact.origin,
        ),
      )
      .toList(growable: false);
}
