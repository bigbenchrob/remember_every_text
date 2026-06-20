import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/picker_filter_actions_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';

void main() {
  test('selectMode delegates picker filter mutation to controller', () async {
    final overlayDb = OverlayDatabase(NativeDatabase.memory());
    addTearDown(overlayDb.close);
    final container = ProviderContainer(
      overrides: [
        overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(pickerFilterProvider), PickerFilterMode.all);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await container
        .read(pickerFilterActionsProvider.notifier)
        .selectMode(PickerFilterMode.favouritesOnly);

    expect(
      container.read(pickerFilterProvider),
      PickerFilterMode.favouritesOnly,
    );
  });
}
