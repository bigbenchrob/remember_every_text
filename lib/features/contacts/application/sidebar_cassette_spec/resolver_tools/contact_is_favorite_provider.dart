import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../infrastructure/repositories/favorite_contacts_repository_provider.dart';

part 'contact_is_favorite_provider.g.dart';

/// Whether [participantId] is currently in the user's favorites.
///
/// Reactivity is driven by explicit invalidation: after add/remove mutations
/// the caller must `ref.invalidate(contactIsFavoriteProvider(participantId))`.
@riverpod
Future<bool> contactIsFavorite(Ref ref, {required int participantId}) async {
  final repository = await ref.watch(favoriteContactsRepositoryProvider.future);
  final favorites = await repository.getAllFavorites();
  for (final favorite in favorites) {
    if (contactIdsRepresentSamePerson(favorite.participantId, participantId)) {
      return true;
    }
  }
  return false;
}
