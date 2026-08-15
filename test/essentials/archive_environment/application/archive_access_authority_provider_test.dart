import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/application/archive_access_authority_provider.dart';

void main() {
  test('fails closed when bootstrap did not inject archive authority', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(archiveAccessAuthorityProvider),
      throwsA(isA<StateError>()),
    );
  });
}
