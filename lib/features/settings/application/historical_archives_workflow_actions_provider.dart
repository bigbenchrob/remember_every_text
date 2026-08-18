import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'historical_archives_workflow_panel_model_provider.dart';

part 'historical_archives_workflow_actions_provider.g.dart';

@riverpod
class HistoricalArchivesWorkflowActions
    extends _$HistoricalArchivesWorkflowActions {
  @override
  FutureOr<void> build() {}

  Future<void> chooseMessagesFolder() async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .chooseMessagesFolder();
  }

  void clearSelection() {
    ref.read(historicalArchivesWorkflowProvider.notifier).clearSelection();
  }

  void dismissDuplicateFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .dismissDuplicateFolderNotice(
          noticeOccurrence: noticeOccurrence,
          presentationSessionOccurrence: presentationSessionOccurrence,
        );
  }

  void dismissInvalidFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .dismissInvalidFolderNotice(
          noticeOccurrence: noticeOccurrence,
          presentationSessionOccurrence: presentationSessionOccurrence,
        );
  }

  Future<void> showKnownSource({required String sourceKey}) async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .showKnownSource(sourceKey: sourceKey);
  }

  Future<void> retrySelectedFolderInspection() async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .retrySelectedFolderInspection();
  }

  Future<void> beginImportForSelectedSource() async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .beginImportForSelectedSource();
  }

  Future<void> removeImportedArchiveDataForSelectedSource() async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .removeImportedArchiveDataForSelectedSource();
  }
}
