// lib/features/attachments/domain/entities/attachment.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain_driven_development/value_transformers.dart';
// Value objects from their feature folders
import '../../../messages/domain/value_objects/message_id.dart';
import '../constants.dart';
import '../value_objects/attachment_id.dart';

part 'attachment.freezed.dart';
part 'attachment.g.dart';

@freezed
abstract class Attachment with _$Attachment {
  const factory Attachment({
    @AttachmentIdConverter() required AttachmentId id,
    @MessageIdConverter() required MessageId messageId,
    String? filename,
    String? mimeType,
    int? sizeBytes,
    int? width,
    int? height,
    int? durationMs,
    String? uri,
    @Default(AttachmentStatus.available) AttachmentStatus status,
    DateTime? createdAt,
    String? checksum,
  }) = _Attachment;

  const Attachment._();

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}
