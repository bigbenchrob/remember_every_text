import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/persistent_database_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';

void main() {
  group('PickerFilter', () {
    late OverlayDatabase overlayDb;

    ProviderContainer buildContainer() {
      return ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    }

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await overlayDb.close();
    });

    test('defaults to all contacts', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(container.read(pickerFilterProvider), PickerFilterMode.all);
    });

    test('persists and restores favourites-only mode', () async {
      final firstContainer = buildContainer();
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(pickerFilterProvider.notifier)
          .setMode(PickerFilterMode.favouritesOnly);

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);

      expect(
        restoredContainer.read(pickerFilterProvider),
        PickerFilterMode.all,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        restoredContainer.read(pickerFilterProvider),
        PickerFilterMode.favouritesOnly,
      );
    });

    test('falls back to all contacts for unknown stored values', () {
      expect(PickerFilterMode.fromStorage('unknown'), PickerFilterMode.all);
    });

    test('does not let delayed restore overwrite local mode choice', () async {
      final firstContainer = buildContainer();
      addTearDown(firstContainer.dispose);

      await firstContainer
          .read(pickerFilterProvider.notifier)
          .setMode(PickerFilterMode.favouritesOnly);

      final restoredContainer = buildContainer();
      addTearDown(restoredContainer.dispose);

      restoredContainer.read(pickerFilterProvider);
      await restoredContainer
          .read(pickerFilterProvider.notifier)
          .setMode(PickerFilterMode.all);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        restoredContainer.read(pickerFilterProvider),
        PickerFilterMode.all,
      );
    });
  });
}
