import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../application/video_thumbnail_cache.dart';

typedef VideoThumbnailFileGenerator =
    Future<bool> Function({
      required String srcFile,
      required String destFile,
      required int width,
      required int height,
    });

class VideoThumbnailCacheService implements VideoThumbnailCache {
  VideoThumbnailCacheService({
    VideoThumbnailFileGenerator? thumbnailGenerator,
    Future<Directory> Function()? cacheDirectoryLoader,
  }) : _thumbnailGenerator = thumbnailGenerator ?? _defaultGenerateThumbnail,
       _cacheDirectoryLoader =
           cacheDirectoryLoader ?? _defaultCacheDirectoryLoader;

  final VideoThumbnailFileGenerator _thumbnailGenerator;
  final Future<Directory> Function() _cacheDirectoryLoader;
  final Map<String, Future<File?>> _inFlight = <String, Future<File?>>{};

  @override
  Future<String?> getOrCreateThumbnailPath({
    required String videoPath,
    int width = 640,
    int height = 640,
  }) async {
    final file = await _getOrCreateThumbnail(
      videoPath: videoPath,
      width: width,
      height: height,
    );
    return file?.path;
  }

  Future<File?> _getOrCreateThumbnail({
    required String videoPath,
    required int width,
    required int height,
  }) async {
    final normalizedVideoPath = p.normalize(videoPath);
    final inFlightKey = '$normalizedVideoPath|$width|$height';
    final existing = _inFlight[inFlightKey];
    if (existing != null) {
      return existing;
    }

    final future = _getOrCreateThumbnailInternal(
      videoPath: normalizedVideoPath,
      width: width,
      height: height,
    );
    _inFlight[inFlightKey] = future;

    try {
      return await future;
    } finally {
      _inFlight.remove(inFlightKey);
    }
  }

  Future<File?> _getOrCreateThumbnailInternal({
    required String videoPath,
    required int width,
    required int height,
  }) async {
    final sourceFile = File(videoPath);
    if (!sourceFile.existsSync()) {
      return null;
    }

    final sourceStat = sourceFile.statSync();
    if (sourceStat.type == FileSystemEntityType.notFound) {
      return null;
    }

    final cacheDir = await _cacheDirectoryLoader();
    await cacheDir.create(recursive: true);

    final cacheKey = sha1
        .convert(
          utf8.encode(
            '$videoPath|${sourceStat.size}|${sourceStat.modified.millisecondsSinceEpoch}|$width|$height',
          ),
        )
        .toString();
    final thumbnailFile = File(p.join(cacheDir.path, '$cacheKey.jpg'));
    if (thumbnailFile.existsSync()) {
      return thumbnailFile;
    }

    final created = await _thumbnailGenerator(
      srcFile: sourceFile.path,
      destFile: thumbnailFile.path,
      width: width,
      height: height,
    );
    if (!created || !thumbnailFile.existsSync()) {
      return null;
    }

    return thumbnailFile;
  }

  static Future<bool> _defaultGenerateThumbnail({
    required String srcFile,
    required String destFile,
    required int width,
    required int height,
  }) async {
    final plugin = FcNativeVideoThumbnail();
    return plugin.saveThumbnailToFile(
      srcFile: srcFile,
      destFile: destFile,
      width: width,
      height: height,
      format: 'jpeg',
      quality: 80,
    );
  }

  static Future<Directory> _defaultCacheDirectoryLoader() async {
    final appSupportDirectory = await getApplicationSupportDirectory();
    return Directory(
      p.join(appSupportDirectory.path, 'derived_media', 'video_thumbnails'),
    );
  }
}
