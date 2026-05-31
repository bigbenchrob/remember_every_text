import 'dart:io';

import '../../../../attachments/domain/constants/attachment_provenance.dart';
import '../../../../attachments/domain/constants/resolved_attachment_availability.dart';
import '../../../../attachments/domain/entities/attachment_recovery_metadata.dart';

/// Media tile DTO used by shared image and video presentation widgets.
///
/// This is a presentation adapter, not source truth and not graph truth.
/// Graph-backed evidence may convert into this type only at the media tile
/// boundary.
class MediaTileAttachment {
  const MediaTileAttachment({
    required this.id,
    required this.localPath,
    required this.mimeType,
    required this.transferName,
    this.importAttachmentId,
    this.messageGuid,
    this.resolvedDisplayPath,
    this.availability,
    this.provenance,
    this.recoveryMetadata,
    this.mediaWidth,
    this.mediaHeight,
  });

  final int id;
  final String? localPath;
  final String? mimeType;
  final String? transferName;
  final int? importAttachmentId;
  final String? messageGuid;
  final String? resolvedDisplayPath;
  final ResolvedAttachmentAvailability? availability;
  final AttachmentProvenance? provenance;
  final AttachmentRecoveryMetadata? recoveryMetadata;

  final double? mediaWidth;
  final double? mediaHeight;

  MediaTileAttachment copyWith({
    int? id,
    String? localPath,
    String? mimeType,
    String? transferName,
    int? importAttachmentId,
    String? messageGuid,
    String? resolvedDisplayPath,
    ResolvedAttachmentAvailability? availability,
    AttachmentProvenance? provenance,
    AttachmentRecoveryMetadata? recoveryMetadata,
    double? mediaWidth,
    double? mediaHeight,
  }) {
    return MediaTileAttachment(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      transferName: transferName ?? this.transferName,
      importAttachmentId: importAttachmentId ?? this.importAttachmentId,
      messageGuid: messageGuid ?? this.messageGuid,
      resolvedDisplayPath: resolvedDisplayPath ?? this.resolvedDisplayPath,
      availability: availability ?? this.availability,
      provenance: provenance ?? this.provenance,
      recoveryMetadata: recoveryMetadata ?? this.recoveryMetadata,
      mediaWidth: mediaWidth ?? this.mediaWidth,
      mediaHeight: mediaHeight ?? this.mediaHeight,
    );
  }

  bool get hasLocalFile => localPath != null && localPath!.isNotEmpty;

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

  /// Returns the expanded absolute path if the [localPath] begins with `~/`.
  /// Otherwise, returns [localPath] unchanged.
  String? resolvedLocalPath() {
    if (!hasLocalFile) {
      return null;
    }
    final rawPath = localPath!;
    if (rawPath.startsWith('~/')) {
      final home = Platform.environment['HOME'] ?? '';
      if (home.isEmpty) {
        return rawPath;
      }
      return rawPath.replaceFirst('~', home);
    }
    return rawPath;
  }

  bool get isDisplayable {
    return availability == ResolvedAttachmentAvailability.available &&
        resolvedDisplayPath != null;
  }

  /// Returns the file selected by resolver-backed hydration.
  ///
  /// Directly-constructed legacy instances fall back to the local path so
  /// existing tests and demo content continue to render.
  File? displayableFile() {
    final explicitPath = resolvedDisplayPath;
    if (explicitPath != null && explicitPath.isNotEmpty) {
      final file = File(explicitPath);
      if (file.existsSync()) {
        return file;
      }
      return null;
    }

    if (availability != null) {
      return null;
    }

    final localResolved = resolvedLocalPath();
    if (localResolved != null) {
      final file = File(localResolved);
      if (file.existsSync()) {
        return file;
      }
    }

    return null;
  }
}
