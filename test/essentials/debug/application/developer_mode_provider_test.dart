import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_provider.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_store.dart';
import 'package:remember_this_text/essentials/debug/feature_level_providers.dart';

void main() {
  test(
    'developer mode defaults to developer when no setting is stored',
    () async {
      final store = _FakeDeveloperModeStore();
      final container = ProviderContainer(
        overrides: [
          developerModeStoreProvider.overrideWith((ref) async => store),
        ],
      );
      addTearDown(container.dispose);

      final mode = await container.read(developerModeProvider.future);

      expect(mode, DeveloperModeValue.developer);
    },
  );

  test('developer mode reads persisted user mode', () async {
    final store = _FakeDeveloperModeStore(initialMode: 'user');
    final container = ProviderContainer(
      overrides: [
        developerModeStoreProvider.overrideWith((ref) async => store),
      ],
    );
    addTearDown(container.dispose);

    final mode = await container.read(developerModeProvider.future);

    expect(mode, DeveloperModeValue.user);
  });

  test('developer mode writes through the store boundary', () async {
    final store = _FakeDeveloperModeStore();
    final container = ProviderContainer(
      overrides: [
        developerModeStoreProvider.overrideWith((ref) async => store),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(developerModeProvider.notifier)
        .setMode(DeveloperModeValue.user);

    expect(store.mode, 'user');
    expect(
      container.read(developerModeProvider).valueOrNull,
      DeveloperModeValue.user,
    );
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
