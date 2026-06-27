import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../services/native_link_preview_service.dart';
import '../infrastructure/native_link_preview_metadata_reader.dart';
import 'link_preview_metadata_reader.dart';

part 'link_preview_metadata_provider.g.dart';

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
