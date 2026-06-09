import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import 'favorite_contacts_repository_provider.dart';

part 'favorite_contacts_provider.freezed.dart';
part 'favorite_contacts_provider.g.dart';

/// Favorite contact resolved with display metadata from graph contact facts.
@freezed
abstract class FavoriteContactEntry with _$FavoriteContactEntry {
  const factory FavoriteContactEntry({
    required ContactSummary contact,
    required DateTime favoritedAt,
    DateTime? lastInteractionAt,
    required DateTime updatedAt,
  }) = _FavoriteContactEntry;
}

@riverpod
Future<List<FavoriteContactEntry>> favoriteContacts(
  FavoriteContactsRef ref,
) async {
  final repository = await ref.watch(favoriteContactsRepositoryProvider.future);
  final favorites = await repository.getAllFavorites();

  if (favorites.isEmpty) {
    return const [];
  }

  final contacts = await ref.watch(contactsListRepositoryProvider.future);

  final resolved = <FavoriteContactEntry>[];
  for (final favorite in favorites) {
    final contact = _findContactForFavorite(contacts, favorite.participantId);
    if (contact == null) {
      continue;
    }

    resolved.add(
      FavoriteContactEntry(
        contact: contact,
        favoritedAt: favorite.favoritedAt,
        lastInteractionAt: favorite.lastInteractionAt,
        updatedAt: favorite.updatedAt,
      ),
    );
  }

  return resolved;
}

ContactSummary? _findContactForFavorite(
  List<ContactSummary> contacts,
  int favoriteParticipantId,
) {
  for (final contact in contacts) {
    if (contactIdsRepresentSamePerson(
      contact.participantId,
      favoriteParticipantId,
    )) {
      return contact;
    }
  }
  return null;
}
