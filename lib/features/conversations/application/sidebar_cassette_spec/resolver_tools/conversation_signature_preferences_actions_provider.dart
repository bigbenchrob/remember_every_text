import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../conversation_signatures/conversation_signature_display_provider.dart'
    show ConversationSignatureFilter, ConversationSignatureSort;
import 'conversation_signature_preferences_provider.dart';

part 'conversation_signature_preferences_actions_provider.g.dart';

@riverpod
class ConversationSignaturePreferencesActions
    extends _$ConversationSignaturePreferencesActions {
  @override
  FutureOr<void> build() {}

  Future<void> setFilter(ConversationSignatureFilter filter) async {
    await ref
        .read(conversationSignaturePreferencesControllerProvider.notifier)
        .setFilter(filter);
  }

  Future<void> setSort(ConversationSignatureSort sort) async {
    await ref
        .read(conversationSignaturePreferencesControllerProvider.notifier)
        .setSort(sort);
  }

  Future<void> setMode(ConversationSignatureMode mode) async {
    await ref
        .read(conversationSignaturePreferencesControllerProvider.notifier)
        .setMode(mode);
  }
}
