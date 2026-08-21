import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
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

  void cancelAddArchive() {
    ref.read(historicalArchivesWorkflowProvider.notifier).cancelAddArchive();
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

  void dismissLineageNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .dismissLineageNotice(
          noticeOccurrence: noticeOccurrence,
          presentationSessionOccurrence: presentationSessionOccurrence,
        );
  }

  void dismissImportSuccessNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .dismissImportSuccessNotice(
          noticeOccurrence: noticeOccurrence,
          presentationSessionOccurrence: presentationSessionOccurrence,
        );
  }

  Future<void> showKnownSource({
    required HistoricalArchiveSourceIdentity identity,
  }) async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .showKnownSource(identity: identity);
  }

  Future<void> retrySelectedFolderInspection() async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .retrySelectedFolderInspection();
  }

  Future<void> beginImportForSelectedSource({
    Future<void> Function()? waitForOperationPresentation,
  }) async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .beginImportForSelectedSource(
          waitForOperationPresentation: waitForOperationPresentation,
        );
  }

  Future<void> removeImportedArchiveDataForSelectedSource() async {
    await ref
        .read(historicalArchivesWorkflowProvider.notifier)
        .removeImportedArchiveDataForSelectedSource();
  }
}
