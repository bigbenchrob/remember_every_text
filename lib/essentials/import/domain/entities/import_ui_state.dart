import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_ui_state.freezed.dart';
part 'import_ui_state.g.dart';

/// Import progress stages (names must match application service stage keys)
@JsonEnum(alwaysCreate: true)
enum ImportStage {
  idle,
  clearingData,
  importingHandles,
  importingChats,
  importingChatHandleJoins,
  analyzingMessages,
  extractingRichContent,
  importingMessages,
  importingAttachments,
  importingAddressBook,
  linkingContacts,
  completed,
  error,
}

/// Database statistics for display in UI
@freezed
abstract class ImportDatabaseStats with _$ImportDatabaseStats {
  const factory ImportDatabaseStats({
    required int totalRecords,
    required int contacts,
    required int messages,
    required int chats,
    required int handles,
    DateTime? lastModified,
  }) = _ImportDatabaseStats;

  factory ImportDatabaseStats.fromJson(Map<String, dynamic> json) =>
      _$ImportDatabaseStatsFromJson(json);
}

/// Import UI state for tracking progress and status
/// Note: This entity stays presentation-agnostic and serializable.
@freezed
abstract class ImportUiState with _$ImportUiState {
  const factory ImportUiState({
    @Default(false) bool isImporting,
    @Default(ImportStage.idle) ImportStage currentStage,
    @Default(0.0) double progress, // 0.0 to 1.0
    String? statusMessage,
    String? errorMessage,
    DateTime? lastImportDate,
    ImportDatabaseStats? importDbStats,
    ImportDatabaseStats? workingDbStats,
    // Sub-stage progress tracking
    double? stageProgress, // 0.0 to 1.0 within current stage
    int? stageCurrent, // Current item being processed
    int? stageTotal, // Total items to process in current stage
  }) = _ImportUiState;

  factory ImportUiState.fromJson(Map<String, dynamic> json) =>
      _$ImportUiStateFromJson(json);
}
