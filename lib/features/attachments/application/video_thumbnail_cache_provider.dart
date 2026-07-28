import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../infrastructure/services/video_thumbnail_cache_service.dart';
import 'video_thumbnail_cache.dart';

part 'video_thumbnail_cache_provider.g.dart';

@Riverpod(keepAlive: true)
VideoThumbnailCache videoThumbnailCache(VideoThumbnailCacheRef ref) {
  final authority = ref.watch(archiveAccessAuthorityProvider);
  return VideoThumbnailCacheService(
    cacheDirectoryLoader: () async =>
        Directory(authority.resolvePath('derived_media/video_thumbnails')),
  );
}
