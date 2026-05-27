import 'dart:io';

import '../../../../essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import '../../../attachments/domain/constants/attachment_provenance.dart';
import '../../../attachments/domain/constants/resolved_attachment_availability.dart';

class GraphAttachmentEvidence {
  const GraphAttachmentEvidence({
    required this.attachmentSsId,
    required this.displayName,
    required this.mimeType,
    required this.uti,
    required this.transferName,
    required this.sourcePathHint,
    required this.displayPath,
    required this.availability,
    required this.provenance,
    required this.totalBytes,
    this.sourceRecordCount = 1,
  });

  final int attachmentSsId;
  final String displayName;
  final String? mimeType;
  final String? uti;
  final String? transferName;
  final String? sourcePathHint;
  final String? displayPath;
  final ResolvedAttachmentAvailability availability;
  final AttachmentProvenance? provenance;
  final int? totalBytes;
  final int sourceRecordCount;

  bool get isDisplayable =>
      availability == ResolvedAttachmentAvailability.available &&
      displayPath != null &&
      displayPath!.isNotEmpty;

  bool get isImage {
    final normalizedMimeType = mimeType?.toLowerCase();
    if (normalizedMimeType != null && normalizedMimeType.isNotEmpty) {
      return normalizedMimeType.startsWith('image/');
    }
    final normalizedUti = uti?.toLowerCase();
    if (normalizedUti != null && normalizedUti.contains('image')) {
      return true;
    }
    return _hasAnyExtension([
      '.jpg',
      '.jpeg',
      '.png',
      '.heic',
      '.gif',
      '.webp',
    ]);
  }

  bool get isVideo {
    final normalizedMimeType = mimeType?.toLowerCase();
    if (normalizedMimeType != null && normalizedMimeType.isNotEmpty) {
      return normalizedMimeType.startsWith('video/');
    }
    final normalizedUti = uti?.toLowerCase();
    if (normalizedUti != null && normalizedUti.contains('video')) {
      return true;
    }
    return _hasAnyExtension(['.mov', '.mp4', '.m4v', '.avi', '.webm']);
  }

  bool get isUrlPreview {
    return _hasAnyExtension(['.pluginpayloadattachment']);
  }

  String get availabilityLabel {
    return switch (availability) {
      ResolvedAttachmentAvailability.available =>
        provenance == AttachmentProvenance.archived ? 'archived' : 'available',
      ResolvedAttachmentAvailability.pendingArchive => 'pending archive',
      ResolvedAttachmentAvailability.unavailableAwaitingRecovery =>
        'unavailable',
      ResolvedAttachmentAvailability.nonRecoverable => 'not recoverable',
    };
  }

  bool _hasAnyExtension(List<String> extensions) {
    final candidates = [
      displayName,
      transferName,
      sourcePathHint,
      displayPath,
    ].whereType<String>().map((value) => value.toLowerCase());
    for (final candidate in candidates) {
      for (final extension in extensions) {
        if (candidate.endsWith(extension)) {
          return true;
        }
      }
    }
    return false;
  }
}

String? firstUrlInGraphMessageText(String? text) {
  final normalized = text?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  final urlPattern = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );
  return urlPattern.firstMatch(normalized)?.group(0);
}

List<GraphAttachmentEvidence> graphAttachmentEvidenceFromMessageAttachments(
  List<MessageAttachment> attachments,
) {
  final evidence = attachments
      .map(graphAttachmentEvidenceFromMessageAttachment)
      .toList(growable: false);
  if (evidence.length < 2) {
    return evidence;
  }

  final collapsed = <GraphAttachmentEvidence>[];
  var urlPreviewResourceCount = 0;
  for (final attachment in evidence) {
    if (attachment.isUrlPreview) {
      urlPreviewResourceCount += 1;
      if (urlPreviewResourceCount == 1) {
        collapsed.add(attachment);
      }
      continue;
    }
    collapsed.add(attachment);
  }

  if (urlPreviewResourceCount < 2) {
    return evidence;
  }

  final firstUrlPreviewIndex = collapsed.indexWhere(
    (attachment) => attachment.isUrlPreview,
  );
  if (firstUrlPreviewIndex < 0) {
    return evidence;
  }

  final firstUrlPreview = collapsed[firstUrlPreviewIndex];
  collapsed[firstUrlPreviewIndex] = GraphAttachmentEvidence(
    attachmentSsId: firstUrlPreview.attachmentSsId,
    displayName: firstUrlPreview.displayName,
    mimeType: firstUrlPreview.mimeType,
    uti: firstUrlPreview.uti,
    transferName: firstUrlPreview.transferName,
    sourcePathHint: firstUrlPreview.sourcePathHint,
    displayPath: firstUrlPreview.displayPath,
    availability: firstUrlPreview.availability,
    provenance: firstUrlPreview.provenance,
    totalBytes: firstUrlPreview.totalBytes,
    sourceRecordCount: urlPreviewResourceCount,
  );

  return collapsed;
}

GraphAttachmentEvidence graphAttachmentEvidenceFromMessageAttachment(
  MessageAttachment attachment,
) {
  final sourcePathHint = attachment.filename;
  final archivedPath = attachment.archiveAbsolutePath;
  final hasArchivedFile =
      attachment.archiveFileExists &&
      archivedPath != null &&
      archivedPath.isNotEmpty;
  final expandedSourcePath = _expandedExistingPath(sourcePathHint);
  final displayPath = hasArchivedFile ? archivedPath : expandedSourcePath;
  final hasDisplayFile = displayPath != null && displayPath.isNotEmpty;

  return GraphAttachmentEvidence(
    attachmentSsId: attachment.attachmentSsId,
    displayName: _attachmentDisplayName(attachment),
    mimeType: attachment.mimeType,
    uti: attachment.uti,
    transferName: attachment.transferName,
    sourcePathHint: sourcePathHint,
    displayPath: displayPath,
    availability: hasDisplayFile
        ? ResolvedAttachmentAvailability.available
        : attachment.hasArchiveRecord || attachment.hasSourcePathHint
        ? ResolvedAttachmentAvailability.unavailableAwaitingRecovery
        : ResolvedAttachmentAvailability.nonRecoverable,
    provenance: hasArchivedFile
        ? AttachmentProvenance.archived
        : expandedSourcePath != null
        ? AttachmentProvenance.messagesLive
        : null,
    totalBytes: attachment.totalBytes,
  );
}

String _attachmentDisplayName(MessageAttachment attachment) {
  final transferName = attachment.transferName?.trim();
  if (transferName != null && transferName.isNotEmpty) {
    return transferName;
  }
  final filename = attachment.filename?.trim();
  if (filename != null && filename.isNotEmpty) {
    return filename.split('/').last;
  }
  final guid = attachment.guid?.trim();
  if (guid != null && guid.isNotEmpty) {
    return guid;
  }
  return 'attachment ${attachment.attachmentSsId}';
}

String? _expandedExistingPath(String? rawPath) {
  if (rawPath == null || rawPath.isEmpty) {
    return null;
  }
  final expanded = rawPath.startsWith('~/')
      ? rawPath.replaceFirst('~', Platform.environment['HOME'] ?? '')
      : rawPath;
  if (expanded.isEmpty) {
    return null;
  }
  return File(expanded).existsSync() ? expanded : null;
}
