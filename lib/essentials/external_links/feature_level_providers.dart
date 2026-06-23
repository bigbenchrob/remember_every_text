import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logging/feature_level_providers.dart';
import '../services/native_link_preview_service.dart';
import 'application/external_uri_opener.dart';
import 'application/link_preview_metadata_reader.dart';
import 'infrastructure/native_link_preview_metadata_reader.dart';
import 'infrastructure/url_launcher_external_uri_opener.dart';

part 'feature_level_providers.g.dart';

@riverpod
ExternalUriOpener externalUriOpener(Ref ref) {
  return const UrlLauncherExternalUriOpener();
}

@riverpod
LinkPreviewMetadataReader linkPreviewMetadataReader(Ref ref) {
  return NativeLinkPreviewMetadataReader(
    service: NativeLinkPreviewService(
      logFailure: (url, error, stackTrace) {
        ref
            .read(appLoggerProvider.notifier)
            .warn(
              'Native link preview metadata failed',
              source: 'NativeLinkPreviewService',
              context: <String, Object?>{
                'url': url,
                'error': error.toString(),
                'stackTrace': stackTrace.toString(),
              },
            );
      },
    ),
  );
}

@riverpod
Future<NativeLinkMetadata?> linkPreviewMetadata(Ref ref, String url) {
  return ref.watch(linkPreviewMetadataReaderProvider).fetchMetadata(url);
}

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
