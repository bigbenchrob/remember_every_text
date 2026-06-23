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

  test('open returns false when URL launch fails', () async {
    final opener = _FakeExternalUriOpener(result: false);
    final container = ProviderContainer(
      overrides: [externalUriOpenerProvider.overrideWithValue(opener)],
    );
    addTearDown(container.dispose);

    final uri = Uri.parse('https://example.com/missing');

    final opened = await container
        .read(externalLinkActionsProvider.notifier)
        .open(uri);

    expect(opened, isFalse);
    expect(opener.openedUris, [uri]);
  });

  test('openString parses URL before delegating', () async {
    final opener = _FakeExternalUriOpener(result: true);
    final container = ProviderContainer(
      overrides: [externalUriOpenerProvider.overrideWithValue(opener)],
    );
    addTearDown(container.dispose);

    final opened = await container
        .read(externalLinkActionsProvider.notifier)
        .openString('https://example.com/from-string');

    expect(opened, isTrue);
    expect(opener.openedUris, [Uri.parse('https://example.com/from-string')]);
  });

  test('openString returns false for invalid URL strings', () async {
    final opener = _FakeExternalUriOpener(result: true);
    final container = ProviderContainer(
      overrides: [externalUriOpenerProvider.overrideWithValue(opener)],
    );
    addTearDown(container.dispose);

    final opened = await container
        .read(externalLinkActionsProvider.notifier)
        .openString('http://[invalid');

    expect(opened, isFalse);
    expect(opener.openedUris, isEmpty);
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
