import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import 'external_uri_opener_provider.dart';

part 'external_link_actions_provider.g.dart';

@riverpod
class ExternalLinkActions extends _$ExternalLinkActions {
  @override
  Future<void> build() async {}

  Future<bool> openString(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'External link URL was invalid',
            source: 'ExternalLinkActions',
            context: <String, Object?>{'url': url},
          );
      return false;
    }
    return open(uri);
  }

  Future<bool> open(Uri uri) async {
    try {
      final opened = await ref.read(externalUriOpenerProvider).open(uri);
      if (!opened) {
        ref
            .read(appLoggerProvider.notifier)
            .warn(
              'External link open failed',
              source: 'ExternalLinkActions',
              context: <String, Object?>{'uri': uri.toString()},
            );
      }
      return opened;
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'External link open threw',
            source: 'ExternalLinkActions',
            context: <String, Object?>{
              'uri': uri.toString(),
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
      return false;
    }
  }
}
