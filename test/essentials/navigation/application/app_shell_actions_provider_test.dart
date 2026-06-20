import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_provider.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_store.dart';
import 'package:remember_this_text/essentials/debug/feature_level_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/app_shell_actions_provider.dart';
import 'package:remember_this_text/providers.dart';

void main() {
  test('toggleDeveloperMode delegates to developer mode boundary', () async {
    final store = _FakeDeveloperModeStore(initialMode: 'developer');
    final container = ProviderContainer(
      overrides: [
        developerModeStoreProvider.overrideWith((ref) async => store),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(developerModeProvider.future),
      DeveloperModeValue.developer,
    );

    await container
        .read(appShellActionsProvider.notifier)
        .toggleDeveloperMode();

    expect(store.mode, 'user');
    expect(
      container.read(developerModeProvider).valueOrNull,
      DeveloperModeValue.user,
    );
  });

  test('cycleThemeMode delegates to switchable theme boundary', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(switchableDarkModeProvider), ThemeMode.system);

    container.read(appShellActionsProvider.notifier).cycleThemeMode();

    expect(container.read(switchableDarkModeProvider), ThemeMode.light);

    container.read(appShellActionsProvider.notifier).cycleThemeMode();

    expect(container.read(switchableDarkModeProvider), ThemeMode.dark);
  });
}

final class _FakeDeveloperModeStore implements DeveloperModeStore {
  _FakeDeveloperModeStore({String? initialMode}) : mode = initialMode;

  String? mode;

  @override
  Future<String?> readMode() async {
    return mode;
  }

  @override
  Future<void> writeMode(String mode) async {
    this.mode = mode;
  }
}
