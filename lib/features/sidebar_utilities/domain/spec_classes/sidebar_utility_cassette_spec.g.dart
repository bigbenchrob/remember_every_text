// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_utility_cassette_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SidebarUtilityCassetteSpecTopChatMenu
_$SidebarUtilityCassetteSpecTopChatMenuFromJson(Map<String, dynamic> json) =>
    _SidebarUtilityCassetteSpecTopChatMenu(
      selectedChoice:
          $enumDecodeNullable(
            _$TopChatMenuChoiceEnumMap,
            json['selectedChoice'],
          ) ??
          TopChatMenuChoice.conversations,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$SidebarUtilityCassetteSpecTopChatMenuToJson(
  _SidebarUtilityCassetteSpecTopChatMenu instance,
) => <String, dynamic>{
  'selectedChoice': _$TopChatMenuChoiceEnumMap[instance.selectedChoice]!,
  'runtimeType': instance.$type,
};

const _$TopChatMenuChoiceEnumMap = {
  TopChatMenuChoice.conversations: 'conversations',
  TopChatMenuChoice.contacts: 'contacts',
  TopChatMenuChoice.strayHandles: 'strayHandles',
  TopChatMenuChoice.searchAllMessages: 'searchAllMessages',
  TopChatMenuChoice.recoveredUnlinkedMessages: 'recoveredUnlinkedMessages',
  TopChatMenuChoice.recoveredNoHandleFromMeMessages:
      'recoveredNoHandleFromMeMessages',
};

_SidebarUtilityCassetteSpecSettingsMenu
_$SidebarUtilityCassetteSpecSettingsMenuFromJson(Map<String, dynamic> json) =>
    _SidebarUtilityCassetteSpecSettingsMenu(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$SidebarUtilityCassetteSpecSettingsMenuToJson(
  _SidebarUtilityCassetteSpecSettingsMenu instance,
) => <String, dynamic>{'runtimeType': instance.$type};
