// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_aggregate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Contact _$ContactFromJson(Map<String, dynamic> json) => _Contact(
  id: ContactId.fromJson(json['id'] as Map<String, dynamic>),
  displayName: ContactDisplayName.fromJson(
    json['displayName'] as Map<String, dynamic>,
  ),
  handles: (json['handles'] as List<dynamic>)
      .map((e) => ContactHandle.fromJson(e as Map<String, dynamic>))
      .toList(),
  details: json['details'] == null
      ? null
      : ContactDetails.fromJson(json['details'] as Map<String, dynamic>),
  preferences: json['preferences'] == null
      ? null
      : ContactPreferences.fromJson(
          json['preferences'] as Map<String, dynamic>,
        ),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  importMetadata: json['importMetadata'] == null
      ? null
      : ImportMetadata.fromJson(json['importMetadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContactToJson(_Contact instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'handles': instance.handles,
  'details': instance.details,
  'preferences': instance.preferences,
  'tags': instance.tags,
  'importMetadata': instance.importMetadata,
};

_ContactId _$ContactIdFromJson(Map<String, dynamic> json) =>
    _ContactId(json['value'] as String);

Map<String, dynamic> _$ContactIdToJson(_ContactId instance) =>
    <String, dynamic>{'value': instance.value};

_ContactDisplayName _$ContactDisplayNameFromJson(Map<String, dynamic> json) =>
    _ContactDisplayName(
      value: json['value'] as String,
      source: $enumDecode(_$DisplayNameSourceEnumMap, json['source']),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      nickname: json['nickname'] as String?,
      company: json['company'] as String?,
    );

Map<String, dynamic> _$ContactDisplayNameToJson(_ContactDisplayName instance) =>
    <String, dynamic>{
      'value': instance.value,
      'source': _$DisplayNameSourceEnumMap[instance.source]!,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'nickname': instance.nickname,
      'company': instance.company,
    };

const _$DisplayNameSourceEnumMap = {
  DisplayNameSource.explicit: 'explicit',
  DisplayNameSource.contact: 'contact',
  DisplayNameSource.handle: 'handle',
  DisplayNameSource.fallback: 'fallback',
};

_ContactHandle _$ContactHandleFromJson(Map<String, dynamic> json) =>
    _ContactHandle(
      id: HandleId.fromJson(json['id'] as Map<String, dynamic>),
      address: json['address'] as String,
      service: json['service'] as String,
      isPreferred: json['isPreferred'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      metadata: json['metadata'] == null
          ? null
          : HandleMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContactHandleToJson(_ContactHandle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'service': instance.service,
      'isPreferred': instance.isPreferred,
      'isVerified': instance.isVerified,
      'metadata': instance.metadata,
    };

_HandleId _$HandleIdFromJson(Map<String, dynamic> json) =>
    _HandleId(json['value'] as String);

Map<String, dynamic> _$HandleIdToJson(_HandleId instance) => <String, dynamic>{
  'value': instance.value,
};

_HandleMetadata _$HandleMetadataFromJson(Map<String, dynamic> json) =>
    _HandleMetadata(
      label: json['label'] as String?,
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      verified: json['verified'] == null
          ? null
          : DateTime.parse(json['verified'] as String),
      countryCode: json['countryCode'] as String?,
      region: json['region'] as String?,
    );

Map<String, dynamic> _$HandleMetadataToJson(_HandleMetadata instance) =>
    <String, dynamic>{
      'label': instance.label,
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'verified': instance.verified?.toIso8601String(),
      'countryCode': instance.countryCode,
      'region': instance.region,
    };

_ContactDetails _$ContactDetailsFromJson(Map<String, dynamic> json) =>
    _ContactDetails(
      organization: json['organization'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      address: json['address'] == null
          ? null
          : ContactAddress.fromJson(json['address'] as Map<String, dynamic>),
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      notes: json['notes'] as String?,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ContactDetailsToJson(_ContactDetails instance) =>
    <String, dynamic>{
      'organization': instance.organization,
      'jobTitle': instance.jobTitle,
      'department': instance.department,
      'address': instance.address,
      'birthday': instance.birthday?.toIso8601String(),
      'notes': instance.notes,
      'categories': instance.categories,
    };

_ContactAddress _$ContactAddressFromJson(Map<String, dynamic> json) =>
    _ContactAddress(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$ContactAddressToJson(_ContactAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'postalCode': instance.postalCode,
      'country': instance.country,
    };

_ContactPreferences _$ContactPreferencesFromJson(Map<String, dynamic> json) =>
    _ContactPreferences(
      isFavorite: json['isFavorite'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      allowNotifications: json['allowNotifications'] as bool? ?? true,
      customRingtone: json['customRingtone'] as String?,
      customTextTone: json['customTextTone'] as String?,
    );

Map<String, dynamic> _$ContactPreferencesToJson(_ContactPreferences instance) =>
    <String, dynamic>{
      'isFavorite': instance.isFavorite,
      'isBlocked': instance.isBlocked,
      'allowNotifications': instance.allowNotifications,
      'customRingtone': instance.customRingtone,
      'customTextTone': instance.customTextTone,
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
