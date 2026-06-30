import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/attachments/infrastructure/services/video_thumbnail_cache_service.dart';

void main() {
  late Directory tempDir;
  late Directory cacheDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'video_thumbnail_cache_service_test_',
    );
    cacheDir = Directory(path.join(tempDir.path, 'thumbnails'));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns null when source video is missing', () async {
    var generatorCalls = 0;
    final cache = VideoThumbnailCacheService(
      cacheDirectoryLoader: () async => cacheDir,
      thumbnailGenerator:
          ({
            required srcFile,
            required destFile,
            required width,
            required height,
          }) async {
            generatorCalls++;
            return true;
          },
    );

    final thumbnailPath = await cache.getOrCreateThumbnailPath(
      videoPath: path.join(tempDir.path, 'missing.mov'),
    );

    expect(thumbnailPath, isNull);
    expect(generatorCalls, 0);
  });

  test('returns null when source video path is a symlink', () async {
    final sourceTarget = File(path.join(tempDir.path, 'target.mov'));
    await sourceTarget.writeAsString('video bytes');
    final sourceLink = Link(path.join(tempDir.path, 'linked.mov'));
    await sourceLink.create(sourceTarget.path);
    var generatorCalls = 0;
    final cache = VideoThumbnailCacheService(
      cacheDirectoryLoader: () async => cacheDir,
      thumbnailGenerator:
          ({
            required srcFile,
            required destFile,
            required width,
            required height,
          }) async {
            generatorCalls++;
            return true;
          },
    );

    final thumbnailPath = await cache.getOrCreateThumbnailPath(
      videoPath: sourceLink.path,
    );

    expect(thumbnailPath, isNull);
    expect(generatorCalls, 0);
  });

  test('creates thumbnail once and reuses cached file', () async {
    final sourceFile = File(path.join(tempDir.path, 'video.mov'));
    await sourceFile.writeAsString('video bytes');
    var generatorCalls = 0;
    final cache = VideoThumbnailCacheService(
      cacheDirectoryLoader: () async => cacheDir,
      thumbnailGenerator:
          ({
            required srcFile,
            required destFile,
            required width,
            required height,
          }) async {
            generatorCalls++;
            await File(destFile).writeAsString('$srcFile|$width|$height');
            return true;
          },
    );

    final firstPath = await cache.getOrCreateThumbnailPath(
      videoPath: sourceFile.path,
      width: 320,
      height: 240,
    );
    final secondPath = await cache.getOrCreateThumbnailPath(
      videoPath: sourceFile.path,
      width: 320,
      height: 240,
    );

    expect(firstPath, isNotNull);
    expect(secondPath, firstPath);
    expect(generatorCalls, 1);
    expect(File(firstPath!).readAsStringSync(), '${sourceFile.path}|320|240');
  });

  test(
    'returns null when generator reports failure or creates no file',
    () async {
      final sourceFile = File(path.join(tempDir.path, 'video.mov'));
      await sourceFile.writeAsString('video bytes');
      final cache = VideoThumbnailCacheService(
        cacheDirectoryLoader: () async => cacheDir,
        thumbnailGenerator:
            ({
              required srcFile,
              required destFile,
              required width,
              required height,
            }) async {
              return false;
            },
      );

      final thumbnailPath = await cache.getOrCreateThumbnailPath(
        videoPath: sourceFile.path,
      );

      expect(thumbnailPath, isNull);
      expect(cacheDir.existsSync(), isTrue);
      expect(cacheDir.listSync(), isEmpty);
    },
  );

  test('returns null when cache directory path is a symlink', () async {
    final sourceFile = File(path.join(tempDir.path, 'video.mov'));
    await sourceFile.writeAsString('video bytes');
    final realCacheDir = Directory(path.join(tempDir.path, 'real_cache'));
    await realCacheDir.create();
    final cacheLink = Link(path.join(tempDir.path, 'cache_link'));
    await cacheLink.create(realCacheDir.path);
    var generatorCalls = 0;
    final cache = VideoThumbnailCacheService(
      cacheDirectoryLoader: () async => Directory(cacheLink.path),
      thumbnailGenerator:
          ({
            required srcFile,
            required destFile,
            required width,
            required height,
          }) async {
            generatorCalls++;
            return true;
          },
    );

    final thumbnailPath = await cache.getOrCreateThumbnailPath(
      videoPath: sourceFile.path,
    );

    expect(thumbnailPath, isNull);
    expect(generatorCalls, 0);
    expect(realCacheDir.listSync(), isEmpty);
  });

  test('returns null when cached thumbnail target is a symlink', () async {
    final sourceFile = File(path.join(tempDir.path, 'video.mov'));
    await sourceFile.writeAsString('video bytes');
    final redirectedTarget = File(path.join(tempDir.path, 'redirected.jpg'));
    await redirectedTarget.writeAsString('protected');
    var generatorCalls = 0;
    final cache = VideoThumbnailCacheService(
      cacheDirectoryLoader: () async => cacheDir,
      thumbnailGenerator:
          ({
            required srcFile,
            required destFile,
            required width,
            required height,
          }) async {
            generatorCalls++;
            await Link(destFile).create(redirectedTarget.path);
            return true;
          },
    );

    final thumbnailPath = await cache.getOrCreateThumbnailPath(
      videoPath: sourceFile.path,
    );

    expect(thumbnailPath, isNull);
    expect(generatorCalls, 1);
    expect(redirectedTarget.readAsStringSync(), 'protected');
  });

  test('coalesces concurrent thumbnail requests for the same source', () async {
    final sourceFile = File(path.join(tempDir.path, 'video.mov'));
    await sourceFile.writeAsString('video bytes');
    var generatorCalls = 0;
    final releaseGenerator = Completer<void>();
    final cache = VideoThumbnailCacheService(
      cacheDirectoryLoader: () async => cacheDir,
      thumbnailGenerator:
          ({
            required srcFile,
            required destFile,
            required width,
            required height,
          }) async {
            generatorCalls++;
            await releaseGenerator.future;
            await File(destFile).writeAsString('thumbnail');
            return true;
          },
    );

    final first = cache.getOrCreateThumbnailPath(videoPath: sourceFile.path);
    final second = cache.getOrCreateThumbnailPath(videoPath: sourceFile.path);
    releaseGenerator.complete();

    final paths = await Future.wait(<Future<String?>>[first, second]);

    expect(paths[0], isNotNull);
    expect(paths[1], paths[0]);
    expect(generatorCalls, 1);
  });
}
