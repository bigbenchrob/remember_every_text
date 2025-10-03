import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remember_this_text/features/settings/application/contact_short_names/contact_short_names_controller.dart';
import 'package:remember_this_text/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => preferences),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('defaults to empty mapping when no settings are stored', () async {
    final result = await container.read(contactShortNamesProvider.future);
    expect(result, isEmpty);
  });

  test('setShortName persists entries and updates state', () async {
    final notifier = container.read(contactShortNamesProvider.notifier);

    await notifier.setShortName(
      contactKey: 'contact:abc123',
      shortName: 'Claire',
    );

    final stored = await container.read(contactShortNamesProvider.future);
    expect(stored['contact:abc123'], 'Claire');

    expect(preferences.getString('contact_short_names'), contains('Claire'));

    await notifier.setShortName(contactKey: 'contact:abc123', shortName: '');
    final afterClear = await container.read(contactShortNamesProvider.future);
    expect(afterClear.containsKey('contact:abc123'), isFalse);

    expect(preferences.getString('contact_short_names'), isNull);
  });

  test('refresh re-reads values from storage', () async {
    await preferences.setString('contact_short_names', '{"identity:1":"CJ"}');

    final notifier = container.read(contactShortNamesProvider.notifier);
    await notifier.refresh();

    final result = await container.read(contactShortNamesProvider.future);
    expect(result, equals({'identity:1': 'CJ'}));
  });
}
