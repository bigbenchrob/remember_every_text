import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'attachment_info.dart';

final Map<String, ui.Size> _mediaSizeCache = <String, ui.Size>{};

Future<List<AttachmentInfo>> loadAttachmentsForMessage(
  WorkingDatabase db,
  String messageGuid,
) async {
  final attachmentRows = await (db.select(
    db.workingAttachments,
  )..where((attachment) => attachment.messageGuid.equals(messageGuid))).get();

  final results = <AttachmentInfo>[];
  for (final attachment in attachmentRows) {
    results.add(await loadAttachment(attachment));
  }
  return results;
}

Future<AttachmentInfo> loadAttachment(WorkingAttachment attachment) async {
  final resolvedPath = _resolvePath(attachment.localPath);
  ui.Size? cachedSize;
  double? width;
  double? height;

  if (resolvedPath != null) {
    cachedSize = _mediaSizeCache[resolvedPath];
    if (cachedSize == null) {
      final file = File(resolvedPath);
      if (file.existsSync()) {
        if (_looksLikeImage(attachment.mimeType, resolvedPath)) {
          final size = await _decodeImageSize(file);
          if (size != null) {
            cachedSize = size;
          }
        } else if (_looksLikeVideo(attachment.mimeType, resolvedPath)) {
          final size = await _readVideoSize(file);
          if (size != null) {
            cachedSize = size;
          }
        }
      }
      if (cachedSize != null) {
        _mediaSizeCache[resolvedPath] = cachedSize;
      }
    }

    if (cachedSize != null) {
      width = cachedSize.width;
      height = cachedSize.height;
    }
  }

  return AttachmentInfo(
    id: attachment.id,
    localPath: attachment.localPath,
    mimeType: attachment.mimeType,
    transferName: attachment.transferName,
    importAttachmentId: attachment.importAttachmentId,
    messageGuid: attachment.messageGuid,
    mediaWidth: width,
    mediaHeight: height,
  );
}

String? _resolvePath(String? path) {
  if (path == null || path.isEmpty) {
    return null;
  }
  if (path.startsWith('~/')) {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) {
      return path;
    }
    return path.replaceFirst('~', home);
  }
  return path;
}

bool _looksLikeImage(String? mimeType, String resolvedPath) {
  if (mimeType != null && mimeType.isNotEmpty) {
    return mimeType.toLowerCase().startsWith('image/');
  }
  final lower = resolvedPath.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.heic') ||
      lower.endsWith('.heif') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.webp');
}

bool _looksLikeVideo(String? mimeType, String resolvedPath) {
  if (mimeType != null && mimeType.isNotEmpty) {
    return mimeType.toLowerCase().startsWith('video/');
  }
  final lower = resolvedPath.toLowerCase();
  return lower.endsWith('.mov') ||
      lower.endsWith('.mp4') ||
      lower.endsWith('.m4v') ||
      lower.endsWith('.avi') ||
      lower.endsWith('.mkv') ||
      lower.endsWith('.webm');
}

Future<ui.Size?> _decodeImageSize(File file) async {
  try {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;
    final size = ui.Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();
    codec.dispose();
    return size;
  } catch (_) {
    return null;
  }
}

Future<ui.Size?> _readVideoSize(File file) async {
  VideoPlayerController? controller;
  try {
    controller = VideoPlayerController.file(file);
    await controller.initialize();
    final value = controller.value;
    if (value.size.width <= 0 || value.size.height <= 0) {
      return null;
    }
    return value.size;
  } catch (_) {
    return null;
  } finally {
    await controller?.dispose();
  }
}

/// For each attachment whose Messages local file is missing, query the overlay
/// DB for an archived copy and populate [AttachmentInfo.archiveResolvedPath].
///
/// Attachments whose local file exists are returned unchanged.
/// Uses a single batched query per message GUID to avoid N+1 DB roundtrips.
Future<List<AttachmentInfo>> resolveArchivePaths({
  required List<AttachmentInfo> attachments,
  required OverlayDatabase overlayDb,
  required String archiveDir,
}) async {
  if (attachments.isEmpty) {
    return attachments;
  }

  // Partition: attachments needing archive lookup vs ones that resolve locally.
  final needsLookup = <AttachmentInfo>[];
  final resolvedLocally = <int, bool>{}; // index → true if resolved locally

  for (var i = 0; i < attachments.length; i++) {
    final attachment = attachments[i];
    final localPath = attachment.resolvedLocalPath();
    if (localPath != null && File(localPath).existsSync()) {
      resolvedLocally[i] = true;
      continue;
    }
    if (attachment.messageGuid != null &&
        attachment.importAttachmentId != null) {
      needsLookup.add(attachment);
    }
  }

  // Batch-query archive records for all attachments that need lookup.
  // Group by messageGuid to issue one query per distinct GUID.
  final archiveIndex =
      <String, Map<int, String>>{}; // guid → {importId → relativePath}

  if (needsLookup.isNotEmpty) {
    final byGuid = <String, List<int>>{};
    for (final a in needsLookup) {
      byGuid.putIfAbsent(a.messageGuid!, () => []).add(a.importAttachmentId!);
    }

    for (final entry in byGuid.entries) {
      final guid = entry.key;
      final importIds = entry.value;

      final records =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals(guid) &
                    t.importAttachmentId.isIn(importIds),
              ))
              .get();

      if (records.isNotEmpty) {
        final guidMap = archiveIndex.putIfAbsent(guid, () => {});
        for (final r in records) {
          guidMap[r.importAttachmentId] = r.archiveRelativePath;
        }
      }
    }
  }

  // Rebuild the list, enriching with archive paths where available.
  final results = <AttachmentInfo>[];
  for (var i = 0; i < attachments.length; i++) {
    final attachment = attachments[i];

    if (resolvedLocally[i] == true) {
      results.add(attachment);
      continue;
    }

    final guid = attachment.messageGuid;
    final importId = attachment.importAttachmentId;
    if (guid == null || importId == null) {
      results.add(attachment);
      continue;
    }

    final relativePath = archiveIndex[guid]?[importId];
    if (relativePath != null) {
      results.add(
        AttachmentInfo(
          id: attachment.id,
          localPath: attachment.localPath,
          mimeType: attachment.mimeType,
          transferName: attachment.transferName,
          importAttachmentId: importId,
          messageGuid: guid,
          archiveResolvedPath: '$archiveDir/$relativePath',
          mediaWidth: attachment.mediaWidth,
          mediaHeight: attachment.mediaHeight,
        ),
      );
    } else {
      results.add(attachment);
    }
  }

  return results;
}
