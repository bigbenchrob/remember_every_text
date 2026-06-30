import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/application/app_mode_actions_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';

void main() {
  test('selectMode delegates mode selection through action boundary', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(activeSidebarModeProvider), SidebarMode.messages);

    container
        .read(appModeActionsProvider.notifier)
        .selectMode(SidebarMode.settings);

    expect(container.read(activeSidebarModeProvider), SidebarMode.settings);
  });
}
