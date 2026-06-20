import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/external_links/application/external_uri_opener.dart';
import 'package:remember_this_text/essentials/external_links/feature_level_providers.dart';

void main() {
  test('open delegates URL launch through action boundary', () async {
    final opener = _FakeExternalUriOpener(result: true);
    final container = ProviderContainer(
      overrides: [externalUriOpenerProvider.overrideWithValue(opener)],
    );
    addTearDown(container.dispose);

    final uri = Uri.parse('https://example.com/message');

    final opened = await container
        .read(externalLinkActionsProvider.notifier)
        .open(uri);

    expect(opened, isTrue);
    expect(opener.openedUris, [uri]);
  });
}

final class _FakeExternalUriOpener implements ExternalUriOpener {
  _FakeExternalUriOpener({required this.result});

  final bool result;
  final openedUris = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    openedUris.add(uri);
    return result;
  }
}
