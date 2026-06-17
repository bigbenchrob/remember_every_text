import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'contact_message_scope_actions_provider.g.dart';

enum ContactMessageScopeChoice { regular, recoveredDeleted }

@riverpod
class ContactMessageScopeActions extends _$ContactMessageScopeActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectScope({
    required int contactId,
    required int cassetteIndex,
    required ContactMessageScopeChoice scope,
  }) async {
    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: ContactMessageScopeChanged(
            contactId: contactId,
            scope: switch (scope) {
              ContactMessageScopeChoice.regular => SidebarMessageScope.regular,
              ContactMessageScopeChoice.recoveredDeleted =>
                SidebarMessageScope.recoveredDeleted,
            },
          ),
          context: SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: cassetteIndex,
          ),
        );
  }
}
