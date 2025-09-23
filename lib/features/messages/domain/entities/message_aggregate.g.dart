// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_aggregate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: MessageId.fromJson(json['id'] as Map<String, dynamic>),
  content: MessageContent.fromJson(json['content'] as Map<String, dynamic>),
  sender: MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
  timestamp: MessageTimestamp.fromJson(
    json['timestamp'] as Map<String, dynamic>,
  ),
  direction: $enumDecode(_$MessageDirectionEnumMap, json['direction']),
  status: MessageStatus.fromJson(json['status'] as Map<String, dynamic>),
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  replyTo: json['replyTo'] == null
      ? null
      : MessageReply.fromJson(json['replyTo'] as Map<String, dynamic>),
  editing: json['editing'] == null
      ? null
      : MessageEditing.fromJson(json['editing'] as Map<String, dynamic>),
  importMetadata: json['importMetadata'] == null
      ? null
      : ImportMetadata.fromJson(json['importMetadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'sender': instance.sender,
  'timestamp': instance.timestamp,
  'direction': _$MessageDirectionEnumMap[instance.direction]!,
  'status': instance.status,
  'attachments': instance.attachments,
  'replyTo': instance.replyTo,
  'editing': instance.editing,
  'importMetadata': instance.importMetadata,
};

const _$MessageDirectionEnumMap = {
  MessageDirection.incoming: 'incoming',
  MessageDirection.outgoing: 'outgoing',
};

_MessageId _$MessageIdFromJson(Map<String, dynamic> json) =>
    _MessageId(json['value'] as String);

Map<String, dynamic> _$MessageIdToJson(_MessageId instance) =>
    <String, dynamic>{'value': instance.value};

_MessageContent _$MessageContentFromJson(Map<String, dynamic> json) =>
    _MessageContent(
      plainText: json['plainText'] as String?,
      richText: json['richText'] as String?,
      contentType: $enumDecodeNullable(
        _$MessageContentTypeEnumMap,
        json['contentType'],
      ),
    );

Map<String, dynamic> _$MessageContentToJson(_MessageContent instance) =>
    <String, dynamic>{
      'plainText': instance.plainText,
      'richText': instance.richText,
      'contentType': _$MessageContentTypeEnumMap[instance.contentType],
    };

const _$MessageContentTypeEnumMap = {
  MessageContentType.plainText: 'plainText',
  MessageContentType.richText: 'richText',
  MessageContentType.attachmentOnly: 'attachmentOnly',
  MessageContentType.system: 'system',
};

_MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) =>
    _MessageSender(
      contactId: json['contactId'] == null
          ? null
          : ContactId.fromJson(json['contactId'] as Map<String, dynamic>),
      handleId: HandleId.fromJson(json['handleId'] as Map<String, dynamic>),
      displayName: json['displayName'] as String?,
    );

Map<String, dynamic> _$MessageSenderToJson(_MessageSender instance) =>
    <String, dynamic>{
      'contactId': instance.contactId,
      'handleId': instance.handleId,
      'displayName': instance.displayName,
    };

_MessageTimestamp _$MessageTimestampFromJson(Map<String, dynamic> json) =>
    _MessageTimestamp(
      value: DateTime.parse(json['value'] as String),
      precision: $enumDecodeNullable(
        _$TimestampPrecisionEnumMap,
        json['precision'],
      ),
    );

Map<String, dynamic> _$MessageTimestampToJson(_MessageTimestamp instance) =>
    <String, dynamic>{
      'value': instance.value.toIso8601String(),
      'precision': _$TimestampPrecisionEnumMap[instance.precision],
    };

const _$TimestampPrecisionEnumMap = {
  TimestampPrecision.second: 'second',
  TimestampPrecision.millisecond: 'millisecond',
  TimestampPrecision.nanosecond: 'nanosecond',
};

_MessageStatus _$MessageStatusFromJson(Map<String, dynamic> json) =>
    _MessageStatus(
      delivery:
          $enumDecodeNullable(_$DeliveryStatusEnumMap, json['delivery']) ??
          DeliveryStatus.unknown,
      read:
          $enumDecodeNullable(_$ReadStatusEnumMap, json['read']) ??
          ReadStatus.unknown,
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$MessageStatusToJson(_MessageStatus instance) =>
    <String, dynamic>{
      'delivery': _$DeliveryStatusEnumMap[instance.delivery]!,
      'read': _$ReadStatusEnumMap[instance.read]!,
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

const _$DeliveryStatusEnumMap = {
  DeliveryStatus.unknown: 'unknown',
  DeliveryStatus.pending: 'pending',
  DeliveryStatus.sent: 'sent',
  DeliveryStatus.delivered: 'delivered',
  DeliveryStatus.failed: 'failed',
};

const _$ReadStatusEnumMap = {
  ReadStatus.unknown: 'unknown',
  ReadStatus.unread: 'unread',
  ReadStatus.read: 'read',
};

_MessageAttachment _$MessageAttachmentFromJson(Map<String, dynamic> json) =>
    _MessageAttachment(
      id: AttachmentId.fromJson(json['id'] as Map<String, dynamic>),
      filename: json['filename'] as String,
      type: $enumDecode(_$AttachmentTypeEnumMap, json['type']),
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      mimeType: json['mimeType'] as String?,
      localPath: json['localPath'] as String?,
      cloudUrl: json['cloudUrl'] as String?,
      metadata: json['metadata'] == null
          ? null
          : AttachmentMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MessageAttachmentToJson(_MessageAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'type': _$AttachmentTypeEnumMap[instance.type]!,
      'sizeBytes': instance.sizeBytes,
      'mimeType': instance.mimeType,
      'localPath': instance.localPath,
      'cloudUrl': instance.cloudUrl,
      'metadata': instance.metadata,
    };

const _$AttachmentTypeEnumMap = {
  AttachmentType.image: 'image',
  AttachmentType.video: 'video',
  AttachmentType.audio: 'audio',
  AttachmentType.document: 'document',
  AttachmentType.contact: 'contact',
  AttachmentType.location: 'location',
  AttachmentType.other: 'other',
};

_AttachmentId _$AttachmentIdFromJson(Map<String, dynamic> json) =>
    _AttachmentId(json['value'] as String);

Map<String, dynamic> _$AttachmentIdToJson(_AttachmentId instance) =>
    <String, dynamic>{'value': instance.value};

_AttachmentMetadata _$AttachmentMetadataFromJson(Map<String, dynamic> json) =>
    _AttachmentMetadata(
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      durationMs: (json['durationMs'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$AttachmentMetadataToJson(_AttachmentMetadata instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'durationMs': instance.durationMs,
      'title': instance.title,
      'description': instance.description,
    };

_MessageReply _$MessageReplyFromJson(Map<String, dynamic> json) =>
    _MessageReply(
      originalMessageId: MessageId.fromJson(
        json['originalMessageId'] as Map<String, dynamic>,
      ),
      originalText: json['originalText'] as String?,
      originalSenderId: json['originalSenderId'] == null
          ? null
          : ContactId.fromJson(
              json['originalSenderId'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MessageReplyToJson(_MessageReply instance) =>
    <String, dynamic>{
      'originalMessageId': instance.originalMessageId,
      'originalText': instance.originalText,
      'originalSenderId': instance.originalSenderId,
    };

_MessageEditing _$MessageEditingFromJson(Map<String, dynamic> json) =>
    _MessageEditing(
      originalContent: MessageContent.fromJson(
        json['originalContent'] as Map<String, dynamic>,
      ),
      edits: (json['edits'] as List<dynamic>)
          .map((e) => MessageEdit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessageEditingToJson(_MessageEditing instance) =>
    <String, dynamic>{
      'originalContent': instance.originalContent,
      'edits': instance.edits,
    };

_MessageEdit _$MessageEditFromJson(Map<String, dynamic> json) => _MessageEdit(
  content: MessageContent.fromJson(json['content'] as Map<String, dynamic>),
  editedAt: DateTime.parse(json['editedAt'] as String),
);

Map<String, dynamic> _$MessageEditToJson(_MessageEdit instance) =>
    <String, dynamic>{
      'content': instance.content,
      'editedAt': instance.editedAt.toIso8601String(),
    };

_ContactId _$ContactIdFromJson(Map<String, dynamic> json) =>
    _ContactId(json['value'] as String);

Map<String, dynamic> _$ContactIdToJson(_ContactId instance) =>
    <String, dynamic>{'value': instance.value};

_HandleId _$HandleIdFromJson(Map<String, dynamic> json) =>
    _HandleId(json['value'] as String);

Map<String, dynamic> _$HandleIdToJson(_HandleId instance) => <String, dynamic>{
  'value': instance.value,
};

_ImportMetadata _$ImportMetadataFromJson(Map<String, dynamic> json) =>
    _ImportMetadata(
      sourceSystem: json['sourceSystem'] as String,
      sourceId: (json['sourceId'] as num).toInt(),
      importedAt: DateTime.parse(json['importedAt'] as String),
      sourceHash: json['sourceHash'] as String?,
      sourceVersion: (json['sourceVersion'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImportMetadataToJson(_ImportMetadata instance) =>
    <String, dynamic>{
      'sourceSystem': instance.sourceSystem,
      'sourceId': instance.sourceId,
      'importedAt': instance.importedAt.toIso8601String(),
      'sourceHash': instance.sourceHash,
      'sourceVersion': instance.sourceVersion,
    };
