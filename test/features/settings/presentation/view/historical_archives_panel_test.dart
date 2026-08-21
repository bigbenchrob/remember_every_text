import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/config/theme/widgets/buttons/app_primary_button.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/debug/feature_level_providers.dart';
import 'package:remember_this_text/essentials/navigation/presentation/layout/historical_archives_page_track_plan.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_actions_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/presentation/view/historical_archives_panel.dart';

void main() {
  group('HistoricalArchivesPanel', () {
    testWidgets('hub renders an empty center panel', (tester) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(isHub: true, presentation: null),
      );

      expect(
        find.byKey(const Key('historical-archives-empty-hub')),
        findsOneWidget,
      );
      expect(find.text('Historical Archives'), findsNothing);
      expect(find.textContaining('Choose an existing archive'), findsNothing);
    });

    testWidgets('hub consumes the complete empty A-I center skeleton', (
      tester,
    ) async {
      final resolved = _resolvedTestTrackMatrix();

      await _pumpPanel(
        tester,
        resolvedTrackMatrix: resolved,
        model: _narratorPanelModel(isHub: true, presentation: null),
      );

      final skeleton = find.byKey(
        const Key('historical-archives-center-track-skeleton'),
      );
      final cells = tester
          .widgetList<TrackCellView>(
            find.descendant(of: skeleton, matching: find.byType(TrackCellView)),
          )
          .map((view) => view.cellId)
          .toList();

      expect(
        cells,
        historicalArchivesCenterSharedTrackIds
            .map(
              (trackId) =>
                  CellId(trackId: trackId, columnId: TrackColumnId.column2),
            )
            .toList(),
      );
      expect(find.text('Historical Archives'), findsNothing);
    });

    testWidgets(
      'duplicate folder is modal-only and points after dismissal from the hub',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';
        final workflow = _DuplicateNoticeHistoricalArchivesWorkflow();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              historicalArchivesWorkflowProvider.overrideWith(() => workflow),
              historicalArchivesWorkflowPanelModelProvider.overrideWith(
                (ref) => _narratorPanelModel(isHub: true, presentation: null),
              ),
              developerModeProvider.overrideWith(
                () => _FakeDeveloperMode(DeveloperModeValue.user),
              ),
            ],
            child: const CupertinoApp(home: HistoricalArchivesPanel()),
          ),
        );
        await tester.pump();

        workflow.emitDuplicateNotice(sourceKey: sourceKey);
        await tester.pump();
        await tester.pump();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(
          find.text('This folder has already been added to MessageLens.'),
          findsOneWidget,
        );
        expect(
          find.text('You can find it under Folders Already Added.'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('historical-archives-empty-hub')),
          findsOneWidget,
        );
        expect(workflow.state.knownSourceReference, isNull);
        expect(workflow.state.selectedKnownSourceKey, isNull);
        expect(find.text('Choose Another Folder'), findsNothing);
        expect(find.text('Import Archive'), findsNothing);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsNothing);
        expect(workflow.dismissCallCount, 1);
        expect(
          workflow.state.presentation,
          isA<HistoricalArchivesKnownSourceReferenceState>(),
        );
        expect(workflow.state.duplicateFolderNotice, isNull);
        expect(workflow.state.knownSourceReference?.sourceKey, sourceKey);
        expect(workflow.state.selectedKnownSourceKey, isNull);

        workflow.emitDuplicateNotice(sourceKey: sourceKey);
        await tester.pump();
        await tester.pump();
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(workflow.dismissCallCount, 2);
        expect(workflow.state.knownSourceReference?.referenceOccurrence, 2);
      },
    );

    testWidgets('invalid folder is modal-only and leaves the hub unselected', (
      tester,
    ) async {
      final workflow = _InvalidFolderNoticeHistoricalArchivesWorkflow();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(() => workflow),
            historicalArchivesWorkflowPanelModelProvider.overrideWith(
              (ref) => _narratorPanelModel(isHub: true, presentation: null),
            ),
            developerModeProvider.overrideWith(
              () => _FakeDeveloperMode(DeveloperModeValue.user),
            ),
          ],
          child: const CupertinoApp(home: HistoricalArchivesPanel()),
        ),
      );
      await tester.pump();

      workflow.emitInvalidFolderNotice();
      await tester.pump();
      await tester.pump();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(
        find.text('This folder doesn’t appear to contain a Messages archive.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Choose a folder that contains Messages data. It must contain the file chat.db.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('historical-archives-empty-hub')),
        findsOneWidget,
      );
      expect(find.text('Choose Another Folder'), findsNothing);
      expect(find.text('Import Archive'), findsNothing);
      expect(find.text('Details'), findsNothing);
      expect(find.textContaining('chat.db'), findsOneWidget);
      expect(workflow.state.knownSourceReference, isNull);
      expect(workflow.state.selectedKnownSourceKey, isNull);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(workflow.dismissCallCount, 1);
      expect(workflow.state.presentation, isA<HistoricalArchivesHubState>());
      expect(workflow.state.invalidFolderNotice, isNull);
      expect(workflow.state.knownSourceReference, isNull);
      expect(workflow.state.selectedKnownSourceKey, isNull);
      expect(
        find.byKey(const Key('historical-archives-empty-hub')),
        findsOneWidget,
      );
    });

    testWidgets(
      'terminal import success is acknowledged over the restored empty hub',
      (tester) async {
        final workflow = _ImportSuccessNoticeHistoricalArchivesWorkflow();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              historicalArchivesWorkflowProvider.overrideWith(() => workflow),
              historicalArchivesWorkflowPanelModelProvider.overrideWith(
                (ref) => _narratorPanelModel(isHub: true, presentation: null),
              ),
              developerModeProvider.overrideWith(
                () => _FakeDeveloperMode(DeveloperModeValue.user),
              ),
            ],
            child: const CupertinoApp(home: HistoricalArchivesPanel()),
          ),
        );
        await tester.pump();

        workflow.emitImportSuccessNotice();
        await tester.pump();
        await tester.pump();

        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('Messages folder added'), findsOneWidget);
        expect(
          find.text(
            'The Messages folder you selected has been successfully added to MessageLens.\n\n'
            'You should now see the additional messages in your message timelines and heatmaps.',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('historical-archives-empty-hub')),
          findsOneWidget,
        );
        expect(
          workflow.state.presentation,
          isA<HistoricalArchivesImportSuccessNoticeState>(),
        );
        expect(workflow.state.selectedKnownSourceKey, isNull);
        expect(workflow.state.knownSourceReference, isNull);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoAlertDialog), findsNothing);
        expect(workflow.dismissCallCount, 1);
        expect(workflow.state.importSuccessNotice, isNull);
        expect(workflow.state.presentation, isA<HistoricalArchivesHubState>());
        expect(workflow.state.selectedKnownSourceKey, isNull);
        expect(workflow.state.knownSourceReference, isNull);
      },
    );

    testWidgets('no-source narrator shows only the truthful invitation', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.noSource,
            narratorText:
                'Add an older Messages archive to extend your history.',
            instrumentationRows: [],
            detailsLines: ['No archive selected.'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('Historical Archives'), findsOneWidget);
      expect(
        find.text('Add an older Messages archive to extend your history.'),
        findsOneWidget,
      );
      expect(find.text('Choose Messages Folder...'), findsNothing);
      expect(find.text('Execution Gate'), findsNothing);
      expect(find.text('Preflight Summary'), findsNothing);
      expect(find.text('Activity Log'), findsNothing);
      expect(find.text('Progress'), findsNothing);
      expect(find.textContaining('Next'), findsNothing);
    });

    testWidgets('selected existing source is a management context, not recognition', (
      tester,
    ) async {
      final actions = _RecordingHistoricalArchivesWorkflowActions();
      await _pumpPanel(
        tester,
        actions: actions,
        model: _narratorPanelModel(
          presentation: null,
          existingSourcePresentation:
              const HistoricalArchivesExistingSourcePresentationViewModel(
                sourceTypeStatement: 'This is a Mac Messages folder.',
                importDateStatement:
                    'You added it to MessageLens on Aug 10, 2026.',
                contentsStatement:
                    'It contains 8,882 messages sent or received between July 2012 and June 2017.',
                detailsLines: ['Folder: /Archives/Messages_2012-IMPORT_SOURCE'],
              ),
          removalTarget: '/Archives/Messages_2012-IMPORT_SOURCE/chat.db',
          removalEnabled: true,
        ),
      );

      expect(
        find.byKey(const Key('historical-archives-existing-source-story')),
        findsOneWidget,
      );
      expect(find.text('This is a Mac Messages folder.'), findsOneWidget);
      expect(
        find.text('You added it to MessageLens on Aug 10, 2026.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'It contains 8,882 messages sent or received between July 2012 and June 2017.',
        ),
        findsOneWidget,
      );
      expect(find.text('Historical Archives'), findsNothing);
      expect(find.text('HISTORICAL MESSAGES ARCHIVE'), findsNothing);
      expect(find.text('Messages_2012-IMPORT_SOURCE'), findsNothing);
      expect(
        find.byKey(const Key('historical-archives-directed-instrumentation')),
        findsNothing,
      );
      expect(
        find.byIcon(CupertinoIcons.check_mark_circled_solid),
        findsNothing,
      );
      expect(find.text('More Details'), findsOneWidget);
      expect(find.text('Remove this folder…'), findsOneWidget);
      expect(find.text('Choose Messages Folder...'), findsNothing);
      expect(find.text('Choose Another Folder'), findsNothing);
      expect(find.text('Import Archive'), findsNothing);
      expect(find.text('2,369'), findsNothing);

      final container = ProviderScope.containerOf(
        tester.element(find.text('Remove this folder…')),
      );
      final colors = container.read(themeColorsProvider.notifier);
      expect(
        tester.widget<Text>(find.text('Remove this folder…')).style?.color,
        colors.buttons.destructiveForeground,
      );

      await tester.tap(find.text('More Details'));
      await tester.pump();
      expect(
        find.text('Folder: /Archives/Messages_2012-IMPORT_SOURCE'),
        findsOneWidget,
      );

      await tester.tap(find.text('Remove this folder…'));
      await tester.pump();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Remove this folder from MessageLens?'), findsOneWidget);
      expect(
        find.text(
          'The messages added from this folder will be removed from MessageLens. Your original Messages folder will not be changed.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(actions.removeCallCount, 0);
    });

    testWidgets('confirmation invokes removal exactly once', (tester) async {
      final actions = _RecordingHistoricalArchivesWorkflowActions();
      await _pumpPanel(
        tester,
        actions: actions,
        model: _narratorPanelModel(
          presentation: null,
          existingSourcePresentation:
              const HistoricalArchivesExistingSourcePresentationViewModel(
                sourceTypeStatement: 'This is a Mac Messages folder.',
                importDateStatement: null,
                contentsStatement: 'It contains 42 messages.',
                detailsLines: [],
              ),
          removalTarget: '/Archives/Archive-2017/chat.db',
          removalEnabled: true,
        ),
      );

      await tester.tap(find.text('Remove this folder…'));
      await tester.pumpAndSettle();
      expect(actions.removeCallCount, 0);

      await tester.tap(find.text('Remove Folder'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(actions.removeCallCount, 1);
    });

    testWidgets(
      'removal operation shows real resolved current and waiting rows',
      (tester) async {
        final matrix = buildHistoricalArchivesPageTrackLayoutMatrix(
          umbrella: const FixedHeightTrackOccupant(height: 24),
          sourceTypeControl: const FixedHeightTrackOccupant(height: 30),
          sourceToKnownFoldersSpacing: const FixedHeightTrackOccupant(
            height: 56,
          ),
          knownFoldersHeading: const FixedHeightTrackOccupant(height: 18),
          knownFoldersHeadingToListSpacing: const FixedHeightTrackOccupant(
            height: 8,
          ),
          centerPageTitle: const FixedHeightTrackOccupant(height: 30),
          titleToNarratorSpacing: const FixedHeightTrackOccupant(height: 44),
          centerNarrator: const FixedHeightTrackOccupant(height: 60),
          narratorToInstrumentationSpacing: const FixedHeightTrackOccupant(
            height: 40,
          ),
        );
        final resolved = ResolvedTrackLayoutMatrix.resolve(
          matrix: matrix,
          constraints: const PresentationConstraints(
            availableWidth: 900,
            textScaler: TextScaler.noScaling,
            textDirection: TextDirection.ltr,
          ),
        );
        await _pumpPanel(
          tester,
          resolvedTrackMatrix: resolved,
          model: _narratorPanelModel(
            presentation: const HistoricalArchivesNarratorPresentationViewModel(
              kind: HistoricalArchivesNarratorPresentationKind.removingSource,
              narratorText: 'Removing this folder from MessageLens.',
              instrumentationRows: [
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Removing messages added from this folder',
                  value: 'Done',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Updating your MessageLens history',
                  value: 'Working',
                  status: HistoricalArchivesInstrumentationStatus.working,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Checking that removal finished',
                  value: 'Waiting',
                  status: HistoricalArchivesInstrumentationStatus.waiting,
                ),
              ],
              detailsLines: [],
              retryInspectionEnabled: false,
            ),
          ),
        );

        expect(find.text('REMOVING MESSAGES FOLDER'), findsOneWidget);
        expect(
          find.text('Removing messages added from this folder'),
          findsOneWidget,
        );
        expect(find.text('Updating your MessageLens history'), findsOneWidget);
        expect(find.text('Checking that removal finished'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        expect(find.text('Working'), findsOneWidget);
        expect(find.text('Waiting'), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.text('Remove this folder…'), findsNothing);
        expect(find.text('Import Archive'), findsNothing);
        expect(find.textContaining('Reprojecting'), findsNothing);
        expect(find.text('Complete'), findsNothing);

        final nativeFlow = find.byKey(
          const Key('historical-archives-removal-native-flow'),
        );
        expect(
          tester.getTopLeft(nativeFlow).dy,
          moreOrLessEquals(
            historicalArchivesPageTrackIds.fold(
              0,
              (height, trackId) => height + resolved.heightFor(trackId),
            ),
          ),
        );
      },
    );

    testWidgets(
      'Narrator Track keeps instrumentation fixed while commentary changes or is silent',
      (tester) async {
        final matrix = buildHistoricalArchivesPageTrackLayoutMatrix(
          umbrella: const FixedHeightTrackOccupant(height: 24),
          sourceTypeControl: const FixedHeightTrackOccupant(height: 30),
          sourceToKnownFoldersSpacing: const FixedHeightTrackOccupant(
            height: 56,
          ),
          knownFoldersHeading: const FixedHeightTrackOccupant(height: 18),
          knownFoldersHeadingToListSpacing: const FixedHeightTrackOccupant(
            height: 8,
          ),
          centerPageTitle: const FixedHeightTrackOccupant(height: 30),
          titleToNarratorSpacing: const FixedHeightTrackOccupant(height: 44),
          centerNarrator: const FixedHeightTrackOccupant(height: 60),
          narratorToInstrumentationSpacing: const FixedHeightTrackOccupant(
            height: 40,
          ),
        );
        final resolved = ResolvedTrackLayoutMatrix.resolve(
          matrix: matrix,
          constraints: const PresentationConstraints(
            availableWidth: 900,
            textScaler: TextScaler.noScaling,
            textDirection: TextDirection.ltr,
          ),
        );

        await _pumpPanel(
          tester,
          resolvedTrackMatrix: resolved,
          model: _narratorPanelModel(
            presentation: const HistoricalArchivesNarratorPresentationViewModel(
              kind: HistoricalArchivesNarratorPresentationKind.importingArchive,
              narratorText: null,
              instrumentationRows: [
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Checking that import finished',
                  value: 'Working',
                  status: HistoricalArchivesInstrumentationStatus.working,
                ),
              ],
              detailsLines: [],
              retryInspectionEnabled: false,
            ),
          ),
        );

        final nativeFlow = find.byKey(
          const Key('historical-archives-narrator-native-flow'),
        );
        expect(
          tester.getTopLeft(nativeFlow).dy,
          moreOrLessEquals(
            historicalArchivesPageTrackIds.fold(
              0,
              (height, trackId) => height + resolved.heightFor(trackId),
            ),
          ),
        );
        expect(resolved.heightFor(TrackId.trackH), 60);
        expect(
          find.byKey(const Key('historical-archives-narrator')),
          findsNothing,
        );
      },
    );

    testWidgets('selected-source native flow begins after stable Track I', (
      tester,
    ) async {
      final matrix = buildHistoricalArchivesPageTrackLayoutMatrix(
        umbrella: const FixedHeightTrackOccupant(height: 24),
        sourceTypeControl: const FixedHeightTrackOccupant(height: 30),
        sourceToKnownFoldersSpacing: const FixedHeightTrackOccupant(height: 56),
        knownFoldersHeading: const FixedHeightTrackOccupant(height: 18),
        knownFoldersHeadingToListSpacing: const FixedHeightTrackOccupant(
          height: 8,
        ),
        centerPageTitle: const FixedHeightTrackOccupant(height: 30),
        titleToNarratorSpacing: const FixedHeightTrackOccupant(height: 44),
        centerNarrator: const FixedHeightTrackOccupant(height: 60),
        narratorToInstrumentationSpacing: const FixedHeightTrackOccupant(
          height: 40,
        ),
      );
      final resolved = ResolvedTrackLayoutMatrix.resolve(
        matrix: matrix,
        constraints: const PresentationConstraints(
          availableWidth: 900,
          textScaler: TextScaler.noScaling,
          textDirection: TextDirection.ltr,
        ),
      );

      await _pumpPanel(
        tester,
        resolvedTrackMatrix: resolved,
        model: _narratorPanelModel(
          presentation: null,
          existingSourcePresentation:
              const HistoricalArchivesExistingSourcePresentationViewModel(
                sourceTypeStatement: 'This is a Mac Messages folder.',
                importDateStatement: null,
                contentsStatement: 'It contains 8,882 messages.',
                detailsLines: [],
              ),
        ),
      );

      final nativeFlow = find.byKey(
        const Key('historical-archives-existing-source-native-flow'),
      );
      expect(
        tester.getTopLeft(nativeFlow).dy,
        moreOrLessEquals(
          historicalArchivesCenterSharedTrackIds.fold(
            0,
            (height, trackId) => height + resolved.heightFor(trackId),
          ),
        ),
      );
      expect(find.text('Historical Archives'), findsNothing);
    });

    testWidgets(
      'selected existing source omits unsupported import and contribution facts',
      (tester) async {
        await _pumpPanel(
          tester,
          model: _narratorPanelModel(
            presentation: null,
            existingSourcePresentation:
                const HistoricalArchivesExistingSourcePresentationViewModel(
                  sourceTypeStatement: 'This is a Mac Messages folder.',
                  importDateStatement: null,
                  contentsStatement: 'It contains 42 messages.',
                  detailsLines: ['Folder: /Archives/2017'],
                ),
          ),
        );

        expect(find.text('This is a Mac Messages folder.'), findsOneWidget);
        expect(find.text('It contains 42 messages.'), findsOneWidget);
        expect(find.textContaining('You added it'), findsNothing);
        expect(find.textContaining('additional messages'), findsNothing);
        expect(find.textContaining('-6,513'), findsNothing);
        expect(find.text('Remove this folder…'), findsNothing);
      },
    );

    testWidgets('inspection shows one current truthful instrumentation row', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.inspectingSource,
            narratorText: 'Let’s see what’s in this Messages folder.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Inspecting archive source',
                value: 'Working',
                status: HistoricalArchivesInstrumentationStatus.working,
              ),
            ],
            detailsLines: ['Folder: /tmp/archive'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('Inspecting archive source'), findsOneWidget);
      expect(find.text('Working'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.text('Importing archive messages'), findsNothing);
      expect(find.text('Preparing archive records'), findsNothing);
      expect(find.textContaining('Next'), findsNothing);
    });

    testWidgets('ready state presents typed evidence and hides diagnostics', (
      tester,
    ) async {
      const path = '/tmp/archive/chat.db';
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          importButtonEnabled: true,
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.readyForImport,
            narratorText:
                'Good. This archive can extend your history back to July 2012.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages database',
                value: 'Found',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages',
                value: '8,882',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Dates',
                value: 'Jul 2012 – Jun 2017',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'New to MessageLens',
                value: '2,369',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Already represented',
                value: '6,513',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
            ],
            detailsLines: ['Messages database: $path'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('8,882'), findsOneWidget);
      expect(find.text('Jul 2012 – Jun 2017'), findsOneWidget);
      expect(find.text('2,369'), findsOneWidget);
      expect(find.text('6,513'), findsOneWidget);
      expect(find.text('Add Messages to MessageLens'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Choose Another Folder'), findsNothing);
      expect(find.byType(AppPrimaryButton), findsOneWidget);
      expect(
        tester
            .widget<AppPrimaryButton>(find.byType(AppPrimaryButton))
            .onPressed,
        isNotNull,
      );
      expect(find.text('Messages database: $path'), findsNothing);

      await tester.tap(
        find.byKey(const Key('historical-archives-details-toggle')),
      );
      await tester.pump();

      expect(find.text('Messages database: $path'), findsOneWidget);
    });

    testWidgets('ready evidence does not expose unavailable import authority', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.readyForImport,
            narratorText: 'Good. This archive is understood.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages database',
                value: 'Found',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
            ],
            detailsLines: ['Import authorization: not currently available'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('Add Messages to MessageLens'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Choose Another Folder'), findsNothing);
      expect(find.byType(AppPrimaryButton), findsOneWidget);
      expect(
        tester
            .widget<AppPrimaryButton>(find.byType(AppPrimaryButton))
            .onPressed,
        isNull,
      );
      expect(
        find.byKey(const Key('historical-archives-details-toggle')),
        findsOneWidget,
      );
    });

    testWidgets(
      'active import shows only real directed instrumentation and no decisions',
      (tester) async {
        await _pumpPanel(
          tester,
          model: _narratorPanelModel(
            presentation: const HistoricalArchivesNarratorPresentationViewModel(
              kind: HistoricalArchivesNarratorPresentationKind.importingArchive,
              narratorText:
                  'The messages from this folder are added. Now I\u2019m updating your combined MessageLens history so everything appears together.',
              instrumentationRows: [
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Adding messages from this folder',
                  value: 'Done',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Preparing conversations for browsing',
                  value: 'Working',
                  status: HistoricalArchivesInstrumentationStatus.working,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Participants',
                  value: 'Done',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                  indentationLevel: 1,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Conversations',
                  value: 'Done',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                  indentationLevel: 1,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Messages',
                  value: '4,250 / 8,882',
                  status: HistoricalArchivesInstrumentationStatus.working,
                  indentationLevel: 1,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Attachments',
                  value: 'Waiting',
                  status: HistoricalArchivesInstrumentationStatus.waiting,
                  indentationLevel: 1,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Relationships',
                  value: 'Waiting',
                  status: HistoricalArchivesInstrumentationStatus.waiting,
                  indentationLevel: 1,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Checking that import finished',
                  value: 'Waiting',
                  status: HistoricalArchivesInstrumentationStatus.waiting,
                ),
              ],
              detailsLines: ['Source key: archive:/tmp/archive/chat.db'],
              retryInspectionEnabled: false,
            ),
          ),
        );

        expect(find.text('ADDING MESSAGES FOLDER'), findsOneWidget);
        expect(
          find.text(
            'The messages from this folder are added. Now I\u2019m updating your combined MessageLens history so everything appears together.',
          ),
          findsOneWidget,
        );
        expect(find.text('Adding messages from this folder'), findsOneWidget);
        expect(
          find.text('Preparing conversations for browsing'),
          findsOneWidget,
        );
        expect(find.text('Checking that import finished'), findsOneWidget);
        expect(find.text('4,250 / 8,882'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Messages')).dx,
          greaterThan(
            tester
                .getTopLeft(find.text('Preparing conversations for browsing'))
                .dx,
          ),
        );
        expect(find.text('Add Messages to MessageLens'), findsNothing);
        expect(find.text('Cancel'), findsNothing);
        expect(find.text('Choose Another Folder'), findsNothing);
        expect(find.text('Execution Gate Blocked'), findsNothing);
        expect(find.text('Activity Log'), findsNothing);
        expect(find.text('Progress'), findsNothing);
        expect(find.text('Result Summary'), findsNothing);
        expect(find.textContaining('%'), findsNothing);
      },
    );

    testWidgets('failed import offers bounded retry without claiming success', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          importButtonEnabled: true,
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.importFailed,
            narratorText:
                'The messages from this folder are added. Now I\u2019m updating your combined MessageLens history so everything appears together.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Adding messages from this folder',
                value: 'Done',
                status: HistoricalArchivesInstrumentationStatus.resolved,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Preparing conversations for browsing',
                value: 'Failed',
                status: HistoricalArchivesInstrumentationStatus.failed,
              ),
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Checking that import finished',
                value: 'Waiting',
                status: HistoricalArchivesInstrumentationStatus.waiting,
              ),
            ],
            detailsLines: ['Graph projection failed.'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Choose Another Folder'), findsOneWidget);
      expect(find.textContaining('part of MessageLens'), findsNothing);
    });

    testWidgets(
      'final verification is narrator-silent and keeps instrumentation visible',
      (tester) async {
        await _pumpPanel(
          tester,
          model: _narratorPanelModel(
            presentation: const HistoricalArchivesNarratorPresentationViewModel(
              kind: HistoricalArchivesNarratorPresentationKind.importingArchive,
              narratorText: null,
              instrumentationRows: [
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Adding messages from this folder',
                  value: 'Done',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Preparing conversations for browsing',
                  value: 'Done',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Checking that import finished',
                  value: 'Working',
                  status: HistoricalArchivesInstrumentationStatus.working,
                ),
              ],
              detailsLines: [],
              retryInspectionEnabled: false,
            ),
          ),
        );

        expect(
          find.byKey(const Key('historical-archives-narrator')),
          findsNothing,
        );
        expect(
          find.text(
            'The messages from this folder are added. Now I\u2019m updating your combined MessageLens history so everything appears together.',
          ),
          findsNothing,
        );
        expect(find.text('ADDING MESSAGES FOLDER'), findsOneWidget);
        expect(find.text('Checking that import finished'), findsOneWidget);
        expect(find.text('Working'), findsOneWidget);
      },
    );

    testWidgets(
      'known-source state requires a fresh folder choice before import',
      (tester) async {
        await _pumpPanel(
          tester,
          model: _narratorPanelModel(
            presentation: const HistoricalArchivesNarratorPresentationViewModel(
              kind: HistoricalArchivesNarratorPresentationKind.knownSource,
              narratorText: 'This archive is known to MessageLens.',
              instrumentationRows: [
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Messages',
                  value: '8,882',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
                HistoricalArchivesInstrumentationRowViewModel(
                  label: 'Status',
                  value: 'Preflight complete',
                  status: HistoricalArchivesInstrumentationStatus.resolved,
                ),
              ],
              detailsLines: [
                'Choose the archive folder again to establish current source truth before importing.',
              ],
              retryInspectionEnabled: false,
            ),
          ),
        );

        expect(
          find.text('This archive is known to MessageLens.'),
          findsOneWidget,
        );
        expect(find.text('8,882'), findsOneWidget);
        expect(find.text('Preflight complete'), findsOneWidget);
        expect(find.text('Import Archive'), findsNothing);
        expect(find.text('Choose Archive Folder'), findsOneWidget);
      },
    );

    testWidgets('failed inspection offers only the truthful recovery action', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        model: _narratorPanelModel(
          presentation: const HistoricalArchivesNarratorPresentationViewModel(
            kind: HistoricalArchivesNarratorPresentationKind.inspectionFailed,
            narratorText: 'This folder does not contain a Messages database.',
            instrumentationRows: [
              HistoricalArchivesInstrumentationRowViewModel(
                label: 'Messages database',
                value: 'Missing',
                status: HistoricalArchivesInstrumentationStatus.failed,
              ),
            ],
            detailsLines: ['Folder: /tmp/not-an-archive'],
            retryInspectionEnabled: false,
          ),
        ),
      );

      expect(
        find.text('This folder does not contain a Messages database.'),
        findsOneWidget,
      );
      expect(find.text('Missing'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Choose Another Folder'), findsOneWidget);
      expect(find.text('Import Archive'), findsNothing);
    });

    testWidgets('renders execution gate, preflight-ready, dry run, and log state', (
      tester,
    ) async {
      const model = HistoricalArchivesWorkflowPanelViewModel(
        statusLabel: 'Ready For Import',
        summaryText:
            'A previously selected archive has completed preflight and is ready for source-scoped import.',
        executionGate: HistoricalArchivesExecutionGateViewModel(
          status: HistoricalArchivesExecutionGateStatus.available,
          statusLabel: 'Available',
          detail: 'No other operation currently owns the execution gate.',
        ),
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.completeReadyToImport,
          statusLabel: 'Preflight complete — ready to import',
          detail:
              'Source checks succeeded, dry-run estimates are available, and the import action can proceed.',
        ),
        selectedFolderPath: '/Users/rob/Library/Messages/Archive-2017/messages',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Found and readable',
        sourceLabel: 'archive-2017-macbook',
        preflightSummaryLines: [
          'Total messages: 8,882',
          'Total chats: 142',
          'Total handles: 311',
        ],
        dryRunSummaryLines: [
          'Estimated new messages: 8,120',
          'Estimated duplicates: 762',
        ],
        importSafetySummaryLines: [
          'Begin Import adds messages from "archive-2017-macbook" without replacing current message data.',
          'The live Messages database is not modified.',
        ],
        importButtonEnabled: true,
        importButtonDetail:
            'Preflight is complete and the execution gate is available.',
        archiveRemovalTargetChatDbPath:
            '/Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        archiveManagementSummaryLines: [
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          'Source-scoped archive removal: available after preflight',
        ],
        removeImportedArchiveDataEnabled: true,
        removeImportedArchiveDataDetail:
            'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.',
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Reading archive…',
            message: 'chat.db and Attachments metadata were read successfully.',
          ),
          HistoricalArchivesLogEntryViewModel(
            label: 'Source-scoped graph import started…',
            message:
                'Source-scoped archive import and graph projection have been requested and are awaiting execution ownership.',
          ),
        ],
        resultSummaryLines: ['The previous import completed successfully.'],
        centerPageTitleVisible: false,
        phases: [
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Reading archive source',
            status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
            detail: 'Archive source metadata was read successfully.',
          ),
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Normalizing records for source-scoped import',
            status: HistoricalArchivesWorkflowPhaseStatus.running,
            detail: 'Normalization is in progress.',
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowPanelModelProvider.overrideWith(
            (ref) => model,
          ),
          developerModeProvider.overrideWith(
            () => _FakeDeveloperMode(DeveloperModeValue.user),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CupertinoApp(home: HistoricalArchivesPanel()),
        ),
      );
      await tester.pump();

      expect(
        find.text(
          'Import historical Messages folders without replacing current message data.',
        ),
        findsOneWidget,
      );
      expect(find.text('Execution Gate'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Preflight complete — ready to import'), findsWidgets);
      expect(find.text('Dry Run Summary'), findsOneWidget);
      expect(find.text('Estimated new messages: 8,120'), findsOneWidget);
      expect(find.text('Estimated duplicates: 762'), findsOneWidget);
      expect(find.text('Import safety'), findsOneWidget);
      expect(
        find.text(
          'Begin Import adds messages from "archive-2017-macbook" without replacing current message data.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('The live Messages database is not modified.'),
        findsOneWidget,
      );
      expect(find.text('Clear Selected Folder'), findsOneWidget);
      expect(
        find.text('Clear Imported Archive Data for This Source'),
        findsNothing,
      );
      expect(
        find.text(
          'This only clears the currently selected folder from the workflow UI. It does not delete imported archive records or reset MessageLens data.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Developer/testing only. This deletes source-scoped import rows from MessageLens for the selected archive source, then reprojects the conversation graph.',
        ),
        findsNothing,
      );
      expect(
        find.text(
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        ),
        findsNothing,
      );
      expect(
        find.text('Source-scoped archive removal: available after preflight'),
        findsNothing,
      );
      expect(
        find.text(
          'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.',
        ),
        findsNothing,
      );
      expect(find.text('Activity Log'), findsOneWidget);
      expect(find.text('Reading archive…'), findsOneWidget);
      expect(find.text('Source-scoped graph import started…'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog before removing imported archive data', (
      tester,
    ) async {
      const model = HistoricalArchivesWorkflowPanelViewModel(
        statusLabel: 'Ready For Import',
        summaryText: 'Archive testing controls are available.',
        executionGate: HistoricalArchivesExecutionGateViewModel(
          status: HistoricalArchivesExecutionGateStatus.available,
          statusLabel: 'Available',
          detail: 'No other operation currently owns the execution gate.',
        ),
        preflight: HistoricalArchivesPreflightViewModel(
          status: HistoricalArchivesPreflightStatus.completeReadyToImport,
          statusLabel: 'Preflight complete',
          detail: 'Source checks succeeded.',
        ),
        selectedFolderPath: '/Users/rob/Library/Messages/Archive-2017/messages',
        chatDbStatusLabel: 'Found and readable',
        attachmentsStatusLabel: 'Found and readable',
        sourceLabel: 'archive-2017-macbook',
        preflightSummaryLines: ['Total messages: 8,882'],
        dryRunSummaryLines: ['Estimated new messages: 8,120'],
        importSafetySummaryLines: ['Import safety fixture line.'],
        importButtonEnabled: false,
        importButtonDetail: 'Disabled in this shell.',
        archiveRemovalTargetChatDbPath:
            '/Users/rob/Library/Messages/Archive-2017/messages/chat.db',
        archiveManagementSummaryLines: [
          'Removal target chat.db: /Users/rob/Library/Messages/Archive-2017/messages/chat.db',
          'Source-scoped archive removal: available after preflight',
        ],
        removeImportedArchiveDataEnabled: true,
        removeImportedArchiveDataDetail:
            'Removing imported archive data will delete source-scoped import rows for this selected source, then reproject the conversation graph from the remaining import facts.',
        activityLog: [
          HistoricalArchivesLogEntryViewModel(
            label: 'Ready',
            message: 'Awaiting confirmation.',
          ),
        ],
        resultSummaryLines: ['No archive import has run yet.'],
        centerPageTitleVisible: false,
        phases: [
          HistoricalArchivesWorkflowPhaseViewModel(
            label: 'Reading archive source',
            status: HistoricalArchivesWorkflowPhaseStatus.succeeded,
            detail: 'Archive source metadata was read successfully.',
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          historicalArchivesWorkflowPanelModelProvider.overrideWith(
            (ref) => model,
          ),
          developerModeProvider.overrideWith(
            () => _FakeDeveloperMode(DeveloperModeValue.developer),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CupertinoApp(home: HistoricalArchivesPanel()),
        ),
      );
      await tester.pump();

      final clearImportedArchiveDataButton = find.text(
        'Clear Imported Archive Data for This Source',
      );
      await tester.ensureVisible(clearImportedArchiveDataButton);
      await tester.tap(clearImportedArchiveDataButton);
      await tester.pumpAndSettle();

      final confirmationDialog = find.byType(CupertinoAlertDialog);

      expect(find.text('Remove this folder from MessageLens?'), findsOneWidget);
      expect(
        find.descendant(
          of: confirmationDialog,
          matching: find.text(
            'The messages added from this folder will be removed from MessageLens. Your original Messages folder will not be changed.',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Remove Folder'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  required HistoricalArchivesWorkflowPanelViewModel model,
  ResolvedTrackLayoutMatrix? resolvedTrackMatrix,
  _RecordingHistoricalArchivesWorkflowActions? actions,
}) async {
  final container = ProviderContainer(
    overrides: [
      historicalArchivesWorkflowPanelModelProvider.overrideWith((ref) => model),
      developerModeProvider.overrideWith(
        () => _FakeDeveloperMode(DeveloperModeValue.user),
      ),
      if (actions != null)
        historicalArchivesWorkflowActionsProvider.overrideWith(() => actions),
    ],
  );
  addTearDown(container.dispose);

  Widget panel = const HistoricalArchivesPanel();
  if (resolvedTrackMatrix case final matrix?) {
    panel = ResolvedTrackLayoutMatrixScope(matrix: matrix, child: panel);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: CupertinoApp(home: panel),
    ),
  );
  await tester.pump();
}

ResolvedTrackLayoutMatrix _resolvedTestTrackMatrix() {
  final matrix = buildHistoricalArchivesPageTrackLayoutMatrix(
    umbrella: const FixedHeightTrackOccupant(height: 24),
    sourceTypeControl: const FixedHeightTrackOccupant(height: 30),
    sourceToKnownFoldersSpacing: const FixedHeightTrackOccupant(height: 56),
    knownFoldersHeading: const FixedHeightTrackOccupant(height: 18),
    knownFoldersHeadingToListSpacing: const FixedHeightTrackOccupant(height: 8),
    centerPageTitle: const FixedHeightTrackOccupant(height: 30),
    titleToNarratorSpacing: const FixedHeightTrackOccupant(height: 44),
    centerNarrator: const FixedHeightTrackOccupant(height: 60),
    narratorToInstrumentationSpacing: const FixedHeightTrackOccupant(
      height: 40,
    ),
  );
  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 900,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}

final class _RecordingHistoricalArchivesWorkflowActions
    extends HistoricalArchivesWorkflowActions {
  var removeCallCount = 0;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> removeImportedArchiveDataForSelectedSource() async {
    removeCallCount += 1;
  }
}

HistoricalArchivesWorkflowPanelViewModel _narratorPanelModel({
  required HistoricalArchivesNarratorPresentationViewModel? presentation,
  HistoricalArchivesExistingSourcePresentationViewModel?
  existingSourcePresentation,
  bool importButtonEnabled = false,
  bool isHub = false,
  bool removalEnabled = false,
  String? removalTarget,
}) {
  return HistoricalArchivesWorkflowPanelViewModel(
    statusLabel: 'Unused legacy status',
    summaryText: 'Unused legacy summary',
    executionGate: const HistoricalArchivesExecutionGateViewModel(
      status: HistoricalArchivesExecutionGateStatus.available,
      statusLabel: 'Available',
      detail: 'No other operation owns mutation authority.',
    ),
    preflight: const HistoricalArchivesPreflightViewModel(
      status: HistoricalArchivesPreflightStatus.waitingForFolder,
      statusLabel: 'Waiting',
      detail: 'Waiting.',
    ),
    selectedFolderPath: null,
    chatDbStatusLabel: 'Not checked yet',
    attachmentsStatusLabel: 'Not checked yet',
    sourceLabel: 'Not proposed yet',
    preflightSummaryLines: const [],
    dryRunSummaryLines: const [],
    importSafetySummaryLines: const [],
    importButtonEnabled: importButtonEnabled,
    importButtonDetail: 'Unused legacy detail',
    archiveRemovalTargetChatDbPath: removalTarget,
    archiveManagementSummaryLines: const [],
    removeImportedArchiveDataEnabled: removalEnabled,
    removeImportedArchiveDataDetail: 'Unused legacy detail',
    activityLog: const [],
    resultSummaryLines: const [],
    phases: const [],
    centerPageTitleVisible: presentation != null,
    isHub: isHub,
    narratorPresentation: presentation,
    existingSourcePresentation: existingSourcePresentation,
  );
}

final class _DuplicateNoticeHistoricalArchivesWorkflow
    extends HistoricalArchivesWorkflow {
  var dismissCallCount = 0;
  var _noticeOccurrence = 0;

  @override
  HistoricalArchivesWorkflowState build() =>
      buildInitialHistoricalArchivesWorkflowState();

  void emitDuplicateNotice({required String sourceKey}) {
    final identity = HistoricalArchiveSourceIdentity.fromPersistedValue(
      sourceKey,
    );
    _noticeOccurrence += 1;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesDuplicateNoticeState(
        notice: HistoricalArchivesDuplicateFolderNotice(
          identity: identity,
          noticeOccurrence: _noticeOccurrence,
          presentationSessionOccurrence: 0,
        ),
      ),
    );
  }

  @override
  void dismissDuplicateFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    dismissCallCount += 1;
    final identity = state.duplicateFolderNotice!.identity;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesKnownSourceReferenceState(
        reference: HistoricalArchivesKnownSourceReference(
          identity: identity,
          referenceOccurrence: noticeOccurrence,
        ),
      ),
    );
  }
}

final class _InvalidFolderNoticeHistoricalArchivesWorkflow
    extends HistoricalArchivesWorkflow {
  var dismissCallCount = 0;
  var _noticeOccurrence = 0;

  @override
  HistoricalArchivesWorkflowState build() =>
      buildInitialHistoricalArchivesWorkflowState();

  void emitInvalidFolderNotice() {
    _noticeOccurrence += 1;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesInvalidNoticeState(
        notice: HistoricalArchivesInvalidFolderNotice(
          noticeOccurrence: _noticeOccurrence,
          presentationSessionOccurrence: 0,
        ),
      ),
    );
  }

  @override
  void dismissInvalidFolderNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    dismissCallCount += 1;
    state = buildInitialHistoricalArchivesWorkflowState();
  }
}

final class _ImportSuccessNoticeHistoricalArchivesWorkflow
    extends HistoricalArchivesWorkflow {
  var dismissCallCount = 0;
  var _noticeOccurrence = 0;

  @override
  HistoricalArchivesWorkflowState build() =>
      buildInitialHistoricalArchivesWorkflowState();

  void emitImportSuccessNotice() {
    _noticeOccurrence += 1;
    state = HistoricalArchivesWorkflowState(
      presentation: HistoricalArchivesImportSuccessNoticeState(
        notice: HistoricalArchivesImportSuccessNotice(
          noticeOccurrence: _noticeOccurrence,
          presentationSessionOccurrence: 0,
        ),
      ),
    );
  }

  @override
  void dismissImportSuccessNotice({
    required int noticeOccurrence,
    required int presentationSessionOccurrence,
  }) {
    dismissCallCount += 1;
    state = buildInitialHistoricalArchivesWorkflowState();
  }
}

final class _FakeDeveloperMode extends DeveloperMode {
  _FakeDeveloperMode(this._value);

  final DeveloperModeValue _value;

  @override
  Future<DeveloperModeValue> build() async => _value;
}
