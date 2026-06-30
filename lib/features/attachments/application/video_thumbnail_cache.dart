abstract interface class VideoThumbnailCache {
  Future<String?> getOrCreateThumbnailPath({
    required String videoPath,
    int width = 640,
    int height = 640,
  });
}
