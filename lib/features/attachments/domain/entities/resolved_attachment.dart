import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../messages/domain/entities/attachment_info.dart';
import '../constants.dart';
import '../constants/attachment_provenance.dart';

part 'resolved_attachment.freezed.dart';

/// The result of resolving an attachment through the multi-source pipeline.
///
/// Combines the attachment metadata with its runtime availability state,
/// the provenance of the resolved file (if any), and the actual [File]
/// handle for rendering.
@freezed
abstract class ResolvedAttachment with _$ResolvedAttachment {
  const factory ResolvedAttachment({
    required AttachmentInfo attachmentInfo,
    required AttachmentStatus status,
    AttachmentProvenance? provenance,
    File? resolvedFile,
  }) = _ResolvedAttachment;

  const ResolvedAttachment._();
}
