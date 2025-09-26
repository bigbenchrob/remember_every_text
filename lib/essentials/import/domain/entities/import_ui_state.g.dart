// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_ui_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportDatabaseStats _$ImportDatabaseStatsFromJson(Map<String, dynamic> json) =>
    _ImportDatabaseStats(
      totalRecords: (json['totalRecords'] as num).toInt(),
      contacts: (json['contacts'] as num).toInt(),
      messages: (json['messages'] as num).toInt(),
      chats: (json['chats'] as num).toInt(),
      handles: (json['handles'] as num).toInt(),
      lastModified: json['lastModified'] == null
          ? null
          : DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$ImportDatabaseStatsToJson(
  _ImportDatabaseStats instance,
) => <String, dynamic>{
  'totalRecords': instance.totalRecords,
  'contacts': instance.contacts,
  'messages': instance.messages,
  'chats': instance.chats,
  'handles': instance.handles,
  'lastModified': instance.lastModified?.toIso8601String(),
};

_ImportUiState _$ImportUiStateFromJson(Map<String, dynamic> json) =>
    _ImportUiState(
      isImporting: json['isImporting'] as bool? ?? false,
      currentStage:
          $enumDecodeNullable(_$ImportStageEnumMap, json['currentStage']) ??
          ImportStage.idle,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      statusMessage: json['statusMessage'] as String?,
      errorMessage: json['errorMessage'] as String?,
      lastImportDate: json['lastImportDate'] == null
          ? null
          : DateTime.parse(json['lastImportDate'] as String),
      importDbStats: json['importDbStats'] == null
          ? null
          : ImportDatabaseStats.fromJson(
              json['importDbStats'] as Map<String, dynamic>,
            ),
      workingDbStats: json['workingDbStats'] == null
          ? null
          : ImportDatabaseStats.fromJson(
              json['workingDbStats'] as Map<String, dynamic>,
            ),
      stageProgress: (json['stageProgress'] as num?)?.toDouble(),
      stageCurrent: (json['stageCurrent'] as num?)?.toInt(),
      stageTotal: (json['stageTotal'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImportUiStateToJson(_ImportUiState instance) =>
    <String, dynamic>{
      'isImporting': instance.isImporting,
      'currentStage': _$ImportStageEnumMap[instance.currentStage]!,
      'progress': instance.progress,
      'statusMessage': instance.statusMessage,
      'errorMessage': instance.errorMessage,
      'lastImportDate': instance.lastImportDate?.toIso8601String(),
      'importDbStats': instance.importDbStats,
      'workingDbStats': instance.workingDbStats,
      'stageProgress': instance.stageProgress,
      'stageCurrent': instance.stageCurrent,
      'stageTotal': instance.stageTotal,
    };

const _$ImportStageEnumMap = {
  ImportStage.idle: 'idle',
  ImportStage.clearingData: 'clearingData',
  ImportStage.importingHandles: 'importingHandles',
  ImportStage.importingChats: 'importingChats',
  ImportStage.importingChatHandleJoins: 'importingChatHandleJoins',
  ImportStage.analyzingMessages: 'analyzingMessages',
  ImportStage.extractingRichContent: 'extractingRichContent',
  ImportStage.importingMessages: 'importingMessages',
  ImportStage.importingAttachments: 'importingAttachments',
  ImportStage.importingAddressBook: 'importingAddressBook',
  ImportStage.linkingContacts: 'linkingContacts',
  ImportStage.completed: 'completed',
  ImportStage.error: 'error',
};
