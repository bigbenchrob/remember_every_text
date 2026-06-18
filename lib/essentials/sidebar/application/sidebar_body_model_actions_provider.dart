import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../navigation/domain/sidebar_mode.dart';
import '../domain/sidebar_body_option.dart';
import 'sidebar_action_dispatcher.dart';

part 'sidebar_body_model_actions_provider.g.dart';

@riverpod
class SidebarBodyModelActions extends _$SidebarBodyModelActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectDropdownOption({
    required SidebarDropdownOption? option,
    required SidebarMode sidebarMode,
    required int cassetteIndex,
  }) async {
    if (option == null || option.isDisabled) {
      return;
    }

    await ref
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: option.selectionIntent,
          context: SidebarActionDispatchContext(
            sidebarMode: sidebarMode,
            cassetteIndex: cassetteIndex,
          ),
        );
  }
}
