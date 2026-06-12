import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/conversation_graph/domain/identity_key_bridge.dart';
import '../../../infrastructure/repositories/favorite_contacts_repository_provider.dart';
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
      await repository.removeFavorite(contactId);
    }

    for (final key in contactOverlayKeyVariants(contactId)) {
      ref.invalidate(contactIsFavoriteProvider(participantId: key));
    }
    ref.invalidate(favoriteContactsProvider);
    ref.invalidate(unifiedPickerSectionsProvider);
  }
}
