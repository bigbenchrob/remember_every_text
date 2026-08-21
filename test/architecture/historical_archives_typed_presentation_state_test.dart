import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const providerPath =
      'lib/features/settings/application/'
      'historical_archives_workflow_panel_model_provider.dart';

  test('Historical Archives models presentation as sealed typed variants', () {
    final source = File(providerPath).readAsStringSync();

    expect(
      source,
      contains('sealed class HistoricalArchivesPresentationState'),
    );
    for (final variant in const <String>[
      'HistoricalArchivesHubState',
      'HistoricalArchivesDuplicateNoticeState',
      'HistoricalArchivesInvalidNoticeState',
      'HistoricalArchivesImportSuccessNoticeState',
      'HistoricalArchivesKnownSourceReferenceState',
      'HistoricalArchivesInspectingCandidateState',
      'HistoricalArchivesInspectionFailedState',
      'HistoricalArchivesReadyToAddState',
      'HistoricalArchivesExistingSourceState',
      'HistoricalArchivesImportingState',
      'HistoricalArchivesImportFailedState',
      'HistoricalArchivesRemovingState',
      'HistoricalArchivesRemovalFailedState',
    ]) {
      expect(source, contains('final class $variant'));
    }
    expect(source, isNot(contains('HistoricalArchivesPresentationContext')));
    expect(source, isNot(contains('HistoricalArchivesPresentationStage')));
  });

  test('workflow envelope cannot combine unrelated semantic fields', () {
    final source = File(providerPath).readAsStringSync();
    final workflowStateSource = _classSource(
      source,
      'final class HistoricalArchivesWorkflowState',
      'HistoricalArchivesPresentationState _withPresentationData',
    );

    expect(
      workflowStateSource,
      contains('final HistoricalArchivesPresentationState presentation;'),
    );
    expect(workflowStateSource, isNot(contains('HistoricalArchivesNotice?')));
    expect(
      workflowStateSource,
      isNot(
        contains(
          'final HistoricalArchivesKnownSourceReference? knownSourceReference;',
        ),
      ),
    );
    expect(
      workflowStateSource,
      isNot(contains('final HistoricalArchiveImportProgress? importProgress;')),
    );
    expect(
      workflowStateSource,
      isNot(
        contains('final HistoricalArchiveRemovalProgress? removalProgress;'),
      ),
    );
    expect(
      workflowStateSource,
      isNot(contains('final String? selectedSource')),
    );
    expect(
      workflowStateSource,
      isNot(contains('final String? selectedFolder')),
    );
  });

  test('notices and orange references are exclusive presentation variants', () {
    final source = File(providerPath).readAsStringSync();
    final duplicateSource = _classSource(
      source,
      'final class HistoricalArchivesDuplicateNoticeState',
      'final class HistoricalArchivesInvalidNoticeState',
    );
    final referenceSource = _classSource(
      source,
      'final class HistoricalArchivesKnownSourceReferenceState',
      'final class HistoricalArchivesInspectingCandidateState',
    );

    expect(
      duplicateSource,
      contains('HistoricalArchivesDuplicateFolderNotice notice'),
    );
    expect(duplicateSource, isNot(contains('HistoricalArchiveImportProgress')));
    expect(
      referenceSource,
      contains('HistoricalArchivesKnownSourceReference reference'),
    );
    expect(
      referenceSource,
      isNot(contains('HistoricalArchiveRemovalProgress')),
    );
  });

  test('import and removal progress belong to disjoint variants', () {
    final source = File(providerPath).readAsStringSync();
    final importingSource = _classSource(
      source,
      'final class HistoricalArchivesImportingState',
      'final class HistoricalArchivesImportFailedState',
    );
    final removingSource = _classSource(
      source,
      'final class HistoricalArchivesRemovingState',
      'final class HistoricalArchivesRemovalFailedState',
    );

    expect(
      importingSource,
      contains('HistoricalArchiveImportProgress progress'),
    );
    expect(
      importingSource,
      isNot(contains('HistoricalArchiveRemovalProgress')),
    );
    expect(
      removingSource,
      contains('HistoricalArchiveRemovalProgress progress'),
    );
    expect(removingSource, isNot(contains('HistoricalArchiveImportProgress')));
  });
}

String _classSource(String source, String startMarker, String endMarker) {
  final start = source.indexOf(startMarker);
  final end = source.indexOf(endMarker, start);
  expect(start, greaterThanOrEqualTo(0));
  expect(end, greaterThan(start));
  return source.substring(start, end);
}
