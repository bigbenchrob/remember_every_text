import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../feature_level_providers.dart';
import '../../read_models/contact_summary_identity.dart';

part 'contact_is_favorite_provider.g.dart';

/// Whether [participantId] is currently in the user's favorites.
///
/// Reactivity is driven by explicit invalidation: after add/remove mutations
/// `ContactFavoriteActions` invalidates this provider and dependent picker
/// projections.
@riverpod
Future<bool> contactIsFavorite(Ref ref, {required int participantId}) async {
  final repository = await ref.watch(favoriteContactsRepositoryProvider.future);
  final favorites = await repository.getAllFavorites();
  for (final favorite in favorites) {
    if (contactIdentityIdsMatch(favorite.participantId, participantId)) {
      return true;
    }
  }
  return false;
}
