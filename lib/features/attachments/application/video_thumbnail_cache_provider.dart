import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/services/video_thumbnail_cache_service.dart';
import 'video_thumbnail_cache.dart';

part 'video_thumbnail_cache_provider.g.dart';

@Riverpod(keepAlive: true)
VideoThumbnailCache videoThumbnailCache(VideoThumbnailCacheRef ref) {
  return VideoThumbnailCacheService();
}
