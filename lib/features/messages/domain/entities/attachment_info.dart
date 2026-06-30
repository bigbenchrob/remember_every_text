import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';

class AttachmentInfo {
  const AttachmentInfo({
    required this.id,
    required this.localPath,
    required this.mimeType,
    required this.transferName,
    this.archiveCompatibilityKey,
    this.mediaWidth,
    this.mediaHeight,
  });

  final int id;
  final String? localPath;
  final String? mimeType;
  final String? transferName;

  /// Current archive compatibility key.
  ///
  /// This is archive compatibility identity for existing archive records, not
  /// canonical graph attachment identity.
  final ArchiveCompatibilityKey? archiveCompatibilityKey;
  final double? mediaWidth;
  final double? mediaHeight;

  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;

  bool get hasArchiveCompatibilityKey => archiveCompatibilityKey != null;

  bool get hasDimensions =>
      mediaWidth != null &&
      mediaWidth! > 0 &&
      mediaHeight != null &&
      mediaHeight! > 0;

  double? get aspectRatio {
    if (!hasDimensions) {
      return null;
    }
    return mediaWidth! / mediaHeight!;
  }

  bool get isImage {
    if (mimeType != null && mimeType!.isNotEmpty) {
      return mimeType!.toLowerCase().startsWith('image/');
    }
    if (!hasLocalFile) {
      return false;
    }
    final path = localPath!.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.heic') ||
        path.endsWith('.heif') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp');
  }

  bool get isVideo {
    if (mimeType != null && mimeType!.isNotEmpty) {
      return mimeType!.toLowerCase().startsWith('video/');
    }
    if (!hasLocalFile) {
      return false;
    }
    final path = localPath!.toLowerCase();
    return path.endsWith('.mov') ||
        path.endsWith('.mp4') ||
        path.endsWith('.m4v') ||
        path.endsWith('.avi') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm');
  }

  bool get isUrlPreview {
    if (!hasLocalFile) {
      return false;
    }
    return localPath!.toLowerCase().endsWith('.pluginpayloadattachment');
  }
}
