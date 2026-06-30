import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'conversation_favourites_provider.dart';

part 'conversation_favourite_actions_provider.g.dart';

@riverpod
class ConversationFavouriteActions extends _$ConversationFavouriteActions {
  @override
  FutureOr<void> build() {}

  Future<void> toggleCoreFavourite(int conversationId) async {
    await ref
        .read(conversationFavouritesControllerProvider.notifier)
        .toggleCoreFavourite(conversationId);
  }
}
