// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_aggregate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Chat _$ChatFromJson(Map<String, dynamic> json) => _Chat(
  id: ChatId.fromJson(json['id'] as Map<String, dynamic>),
  guid: json['guid'] as String,
  displayName: ChatDisplayName.fromJson(
    json['displayName'] as Map<String, dynamic>,
  ),
  participants: (json['participants'] as List<dynamic>)
      .map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
      .toList(),
  timestamps: ChatTimestamps.fromJson(
    json['timestamps'] as Map<String, dynamic>,
  ),
  stats: ChatStats.fromJson(json['stats'] as Map<String, dynamic>),
  primaryContactId: json['primaryContactId'] == null
      ? null
      : ContactId.fromJson(json['primaryContactId'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  importMetadata: json['importMetadata'] == null
      ? null
      : ImportMetadata.fromJson(json['importMetadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatToJson(_Chat instance) => <String, dynamic>{
  'id': instance.id,
  'guid': instance.guid,
  'displayName': instance.displayName,
  'participants': instance.participants,
  'timestamps': instance.timestamps,
  'stats': instance.stats,
  'primaryContactId': instance.primaryContactId,
  'tags': instance.tags,
  'importMetadata': instance.importMetadata,
};

_ChatId _$ChatIdFromJson(Map<String, dynamic> json) =>
    _ChatId(json['value'] as String);

Map<String, dynamic> _$ChatIdToJson(_ChatId instance) => <String, dynamic>{
  'value': instance.value,
};

_ChatDisplayName _$ChatDisplayNameFromJson(Map<String, dynamic> json) =>
    _ChatDisplayName(
      value: json['value'] as String,
      source: $enumDecode(_$DisplayNameSourceEnumMap, json['source']),
    );

Map<String, dynamic> _$ChatDisplayNameToJson(_ChatDisplayName instance) =>
    <String, dynamic>{
      'value': instance.value,
      'source': _$DisplayNameSourceEnumMap[instance.source]!,
    };

const _$DisplayNameSourceEnumMap = {
  DisplayNameSource.explicit: 'explicit',
  DisplayNameSource.contact: 'contact',
  DisplayNameSource.handle: 'handle',
  DisplayNameSource.participants: 'participants',
  DisplayNameSource.fallback: 'fallback',
};

_ChatParticipant _$ChatParticipantFromJson(
  Map<String, dynamic> json,
) => _ChatParticipant(
  contactId: ContactId.fromJson(json['contactId'] as Map<String, dynamic>),
  handleId: HandleId.fromJson(json['handleId'] as Map<String, dynamic>),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  leftAt: json['leftAt'] == null
      ? null
      : DateTime.parse(json['leftAt'] as String),
  role: $enumDecodeNullable(_$ChatRoleEnumMap, json['role']) ?? ChatRole.member,
);

Map<String, dynamic> _$ChatParticipantToJson(_ChatParticipant instance) =>
    <String, dynamic>{
      'contactId': instance.contactId,
      'handleId': instance.handleId,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'leftAt': instance.leftAt?.toIso8601String(),
      'role': _$ChatRoleEnumMap[instance.role]!,
    };

const _$ChatRoleEnumMap = {
  ChatRole.member: 'member',
  ChatRole.admin: 'admin',
  ChatRole.owner: 'owner',
};

_ChatTimestamps _$ChatTimestampsFromJson(Map<String, dynamic> json) =>
    _ChatTimestamps(
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      firstMessageAt: json['firstMessageAt'] == null
          ? null
          : DateTime.parse(json['firstMessageAt'] as String),
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
    );

Map<String, dynamic> _$ChatTimestampsToJson(_ChatTimestamps instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'lastModified': instance.lastModified.toIso8601String(),
      'firstMessageAt': instance.firstMessageAt?.toIso8601String(),
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
    };

_ChatStats _$ChatStatsFromJson(Map<String, dynamic> json) => _ChatStats(
  messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  attachmentCount: (json['attachmentCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ChatStatsToJson(_ChatStats instance) =>
    <String, dynamic>{
      'messageCount': instance.messageCount,
      'unreadCount': instance.unreadCount,
      'attachmentCount': instance.attachmentCount,
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
