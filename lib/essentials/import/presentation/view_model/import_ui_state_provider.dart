import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/import_ui_state.dart' as iui;
import '../../feature_level_providers.dart';

part 'import_ui_state_provider.g.dart';

/// Import UI state notifier following Riverpod code generation patterns
@riverpod
class ImportUiState extends _$ImportUiState {
  @override
  iui.ImportUiState build() {
    return const iui.ImportUiState();
  }

  /// Start import process
  Future<void> startImport() async {
    state = state.copyWith(
      isImporting: true,
      currentStage: iui.ImportStage.clearingData,
      progress: 0.0,
      errorMessage: null,
      statusMessage: 'Starting import process...',
      stageProgress: null,
      stageCurrent: null,
      stageTotal: null,
    );

    try {
      // ignore: avoid_manual_providers_as_generated_provider_dependency
      final importService = ref.read(importServiceProvider);

      final result = await importService.importAllData(
        onProgress:
            (
              String stageString,
              double progress,
              String message, {
              double? stageProgress,
              int? stageCurrent,
              int? stageTotal,
            }) {
              // Map string stages to ImportStage enum
              final stage = _mapStageFromString(stageString);

              if (state.isImporting) {
                state = state.copyWith(
                  currentStage: stage,
                  progress: progress,
                  statusMessage: message,
                  stageProgress: stageProgress,
                  stageCurrent: stageCurrent,
                  stageTotal: stageTotal,
                );
              }
            },
      );

      if (result.success) {
        state = state.copyWith(
          isImporting: false,
          currentStage: iui.ImportStage.completed,
          progress: 1.0,
          statusMessage: 'Import completed successfully',
          lastImportDate: DateTime.now(),
          stageProgress: null,
          stageCurrent: null,
          stageTotal: null,
        );
      } else {
        state = state.copyWith(
          isImporting: false,
          currentStage: iui.ImportStage.error,
          progress: 0.0,
          statusMessage: 'Import failed',
          errorMessage: result.error,
          stageProgress: null,
          stageCurrent: null,
          stageTotal: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        currentStage: iui.ImportStage.error,
        progress: 0.0,
        statusMessage: 'Import failed',
        errorMessage: e.toString(),
        stageProgress: null,
        stageCurrent: null,
        stageTotal: null,
      );
    }
  }

  /// Map stage strings from import service to ImportStage enum
  iui.ImportStage _mapStageFromString(String stageString) {
    switch (stageString) {
      case 'clearingData':
        return iui.ImportStage.clearingData;
      case 'importingHandles':
        return iui.ImportStage.importingHandles;
      case 'importingChats':
        return iui.ImportStage.importingChats;
      case 'importingChatHandleJoins':
        return iui.ImportStage.importingChatHandleJoins;
      case 'analyzingMessages':
        return iui.ImportStage.analyzingMessages;
      case 'extractingRichContent':
        return iui.ImportStage.extractingRichContent;
      case 'importingMessages':
        return iui.ImportStage.importingMessages;
      case 'importingAttachments':
        return iui.ImportStage.importingAttachments;
      case 'importingAddressBook':
        return iui.ImportStage.importingAddressBook;
      case 'linkingContacts':
        return iui.ImportStage.linkingContacts;
      case 'completed':
        return iui.ImportStage.completed;
      default:
        return iui.ImportStage.clearingData; // fallback
    }
  }

  /// Reset import state
  void reset() {
    state = const iui.ImportUiState();
  }
}
