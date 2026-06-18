import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../feature_level_providers.dart';
import '../../read_models/contact_summary_identity.dart';
import 'contact_is_favorite_provider.dart';
import 'favorite_contacts_provider.dart';
import 'unified_picker_sections_provider.dart';

part 'contact_favorite_actions_provider.g.dart';

@riverpod
class ContactFavoriteActions extends _$ContactFavoriteActions {
  @override
  FutureOr<void> build() {}

  Future<void> setFavorite({
    required int contactId,
    required bool isFavorite,
  }) async {
    final repository = await ref.read(
      favoriteContactsRepositoryProvider.future,
    );

    if (isFavorite) {
      await repository.addFavorite(participantId: contactId);
    } else {
      for (final key in contactIdentityKeyVariants(contactId)) {
        await repository.removeFavorite(key);
      }
    }

    for (final key in contactIdentityKeyVariants(contactId)) {
      ref.invalidate(contactIsFavoriteProvider(participantId: key));
    }
    ref.invalidate(favoriteContactsProvider);
    ref.invalidate(unifiedPickerSectionsProvider);
  }
}
