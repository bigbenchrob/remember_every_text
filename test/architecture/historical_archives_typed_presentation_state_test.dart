import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const providerPath =
      'lib/features/settings/application/'
      'historical_archives_workflow_panel_model_provider.dart';
  const panelPath =
      'lib/features/settings/presentation/view/historical_archives_panel.dart';
  const trackPlanPath =
      'lib/essentials/navigation/presentation/layout/'
      'historical_archives_page_track_plan.dart';
  const sidebarSupplementalPath =
      'lib/features/settings/application/sidebar_cassette_spec/'
      'widget_builders/historical_archives_settings_supplemental_content.dart';

  test('Historical Archives models presentation as sealed typed variants', () {
    final source = File(providerPath).readAsStringSync();

    expect(
      source,
      contains('sealed class HistoricalArchivesPresentationState'),
    );
    for (final variant in const <String>[
      'HistoricalArchivesHubState',
      'HistoricalArchivesMessageLensNoticeState',
      'HistoricalArchivesMessageLensInspectingState',
      'HistoricalArchivesMessageLensReadyState',
      'HistoricalArchivesMessageLensRecoveringState',
      'HistoricalArchivesMessageLensRecoveryFailedState',
      'HistoricalArchivesDuplicateNoticeState',
      'HistoricalArchivesInvalidNoticeState',
      'HistoricalArchivesLineageNoticeState',
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

  test('all center variants share one structural A-I renderer boundary', () {
    final panelSource = File(panelPath).readAsStringSync();
    final trackPlanSource = File(trackPlanPath).readAsStringSync();

    expect(
      trackPlanSource,
      contains(
        'const historicalArchivesCenterSharedTrackIds = '
        'historicalArchivesPageTrackIds;',
      ),
    );
    expect(
      panelSource,
      contains('for (final trackId in resolvedMatrix.trackIds)'),
    );
    expect(
      'for (final trackId in resolvedMatrix.trackIds)'.allMatches(panelSource),
      hasLength(1),
    );
    expect(
      '_HistoricalArchivesCenterTrackScaffold('.allMatches(panelSource),
      hasLength(4),
      reason:
          'hub, existing-source, and Narrator routes use the one scaffold; '
          'the fourth occurrence is its constructor declaration',
    );
    expect(panelSource, isNot(contains('historicalArchivesSharedTrackIds')));
    expect(panelSource, isNot(contains('TrackId.trackA')));
    expect(
      panelSource,
      contains("'historical-archives-center-track-skeleton'"),
    );
  });

  test('superseded generic control panel cannot return to ordinary UI', () {
    final panelSource = File(panelPath).readAsStringSync();

    for (final obsoleteText in const <String>[
      'Execution Gate',
      'Preflight Summary',
      'Dry Run Summary',
      'Clear Selected Folder',
      'Developer Testing Controls',
      'Activity Log',
      'Result Summary',
      'Choose Another Folder',
    ]) {
      expect(panelSource, isNot(contains(obsoleteText)));
    }
    expect(panelSource, isNot(contains('class _ShellHeroCard')));
    expect(panelSource, isNot(contains('class _ShellSectionCard')));
    expect(panelSource, isNot(contains('developerModeProvider')));
    expect(
      panelSource,
      contains(
        'Historical Archives presentation has no canonical center projection.',
      ),
    );
  });

  test(
    'custom Historical Archives controls expose accessibility semantics',
    () {
      final panelSource = File(panelPath).readAsStringSync();
      final sidebarSource = File(sidebarSupplementalPath).readAsStringSync();

      expect(panelSource, contains('expanded: _isExpanded'));
      expect(panelSource, contains('enabled: isInteractive'));
      expect(panelSource, contains('label: label'));
      expect(sidebarSource, contains("label: 'Choose MessageLens Folder'"));
      expect(
        sidebarSource,
        contains("label: 'Choose a Messages Folder to add'"),
      );
    },
  );
}

String _classSource(String source, String startMarker, String endMarker) {
  final start = source.indexOf(startMarker);
  final end = source.indexOf(endMarker, start);
  expect(start, greaterThanOrEqualTo(0));
  expect(end, greaterThan(start));
  return source.substring(start, end);
}
