// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Attachment _$AttachmentFromJson(Map<String, dynamic> json) => _Attachment(
  id: const AttachmentIdConverter().fromJson(json['id'] as String),
  messageId: const MessageIdConverter().fromJson(json['messageId'] as String),
  filename: json['filename'] as String?,
  mimeType: json['mimeType'] as String?,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
  uri: json['uri'] as String?,
  status:
      $enumDecodeNullable(_$AttachmentStatusEnumMap, json['status']) ??
      AttachmentStatus.available,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  checksum: json['checksum'] as String?,
);

Map<String, dynamic> _$AttachmentToJson(_Attachment instance) =>
    <String, dynamic>{
      'id': const AttachmentIdConverter().toJson(instance.id),
      'messageId': const MessageIdConverter().toJson(instance.messageId),
      'filename': instance.filename,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'width': instance.width,
      'height': instance.height,
      'durationMs': instance.durationMs,
      'uri': instance.uri,
      'status': _$AttachmentStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'checksum': instance.checksum,
    };

const _$AttachmentStatusEnumMap = {
  AttachmentStatus.pending: 'pending',
  AttachmentStatus.downloading: 'downloading',
  AttachmentStatus.available: 'available',
  AttachmentStatus.missing: 'missing',
  AttachmentStatus.failed: 'failed',
};
