import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/historical_archives_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content.dart';

void main() {
  group('HistoricalArchivesSettingsSupplementalContent', () {
    testWidgets('renders only durable human archive metadata', (tester) async {
      const payload = HistoricalArchivesSettingsCassettePayload(
        knownSources: [
          HistoricalArchiveSidebarSourceSummary(
            sourceKey: 'historical-messages-archive:/Archives/2017/chat.db',
            label: 'Jan 2017 MacBook Archive',
            dateRangeLabel: 'Range: Jan 2014 -> Nov 2017',
            messageCountLabel: 'Source messages: 8,882',
            importedOnLabel: 'Imported on: Apr 29, 2026',
          ),
        ],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: payload,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Folders Already Added'), findsOneWidget);
      expect(find.text('Jan 2017 MacBook Archive'), findsOneWidget);
      expect(find.text('Range: Jan 2014 -> Nov 2017'), findsOneWidget);
      expect(find.text('Source messages: 8,882'), findsOneWidget);
      expect(find.text('Imported on: Apr 29, 2026'), findsOneWidget);
      final sectionHeadingStyle = tester
          .widget<Text>(find.text('Folders Already Added'))
          .style!;
      final archiveTitleStyle = tester
          .widget<Text>(find.text('Jan 2017 MacBook Archive'))
          .style!;
      expect(
        archiveTitleStyle.fontSize,
        lessThan(sectionHeadingStyle.fontSize!),
      );
      expect(archiveTitleStyle.fontWeight, FontWeight.w600);
      expect(find.textContaining('Last dry run'), findsNothing);
      expect(find.textContaining('Last imported'), findsNothing);
      expect(find.textContaining('not yet imported'), findsNothing);
      expect(find.text('Add from a Messages Folder'), findsOneWidget);
      expect(find.text('Choose Messages Folder...'), findsOneWidget);
      expect(find.textContaining('Choose Messages Folder'), findsOneWidget);
      expect(find.text('Add a Messages Folder'), findsNothing);
      expect(find.text('Add an Archive Folder'), findsNothing);
    });

    testWidgets('omits imported-on when no trustworthy date is supplied', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(
                knownSources: [
                  HistoricalArchiveSidebarSourceSummary(
                    sourceKey:
                        'historical-messages-archive:/Archives/2017/chat.db',
                    label: 'Archive-2017',
                    dateRangeLabel: 'Date range: Jul 2012 – Jun 2017',
                    messageCountLabel: 'Messages: 8,882',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Archive-2017'), findsOneWidget);
      expect(find.text('Date range: Jul 2012 – Jun 2017'), findsOneWidget);
      expect(find.text('Messages: 8,882'), findsOneWidget);
      expect(find.textContaining('Imported on'), findsNothing);
      expect(find.textContaining('not yet imported'), findsNothing);
    });

    testWidgets(
      'source-type control selects Mac Messages and disables MessageLens',
      (tester) async {
        final workflow = _TestHistoricalArchivesWorkflow();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              historicalArchivesWorkflowProvider.overrideWith(() => workflow),
            ],
            child: const CupertinoApp(
              home: HistoricalArchivesSettingsSupplementalContent(
                payload: HistoricalArchivesSettingsCassettePayload(),
              ),
            ),
          ),
        );

        expect(find.text('Mac Messages'), findsOneWidget);
        expect(find.text('MessageLens'), findsOneWidget);
        expect(find.text('Messages Folders'), findsNothing);
        expect(find.text('MessageLens Folders'), findsNothing);
        expect(tester.widget<Text>(find.text('MessageLens')).maxLines, 1);

        TextStyle segmentStyle(String label) {
          return tester
              .widget<AnimatedDefaultTextStyle>(
                find.ancestor(
                  of: find.text(label),
                  matching: find.byType(AnimatedDefaultTextStyle),
                ),
              )
              .style;
        }

        final container = ProviderScope.containerOf(
          tester.element(find.text('Mac Messages')),
        );
        final colors = container.read(themeColorsProvider.notifier);
        expect(
          segmentStyle('Mac Messages').color,
          colors.buttons.primaryForeground,
        );
        expect(segmentStyle('MessageLens').color, colors.content.textDisabled);

        final stateBeforeTap = workflow.state;
        await tester.tap(find.text('MessageLens'));
        await tester.pumpAndSettle();

        expect(workflow.state, stateBeforeTap);
        expect(workflow.chooseMessagesFolderCallCount, 0);
        expect(find.text('Mac Messages'), findsOneWidget);
        expect(find.text('Folders Already Added'), findsOneWidget);
      },
    );

    testWidgets('messages-folder guidance states the truthful source contract', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(),
            ),
          ),
        ),
      );

      expect(find.text('Add from a Messages Folder'), findsOneWidget);
      expect(
        find.text(
          'Choose the folder containing chat.db, not the chat.db file itself.',
        ),
        findsOneWidget,
      );
      expect(find.text('Usually: Home → Library → Messages'), findsOneWidget);
      expect(find.textContaining('/Users/'), findsNothing);
      expect(find.textContaining('rob'), findsNothing);
      expect(
        find.text(
          'Older copies can be on another drive, moved, or renamed. An '
          "Attachments folder may also be present, but it isn't required.",
        ),
        findsOneWidget,
      );
      expect(find.text('Usually found at'), findsNothing);
      expect(find.text('Using an older copy?'), findsNothing);
      expect(find.text('Attachments'), findsNothing);
      expect(find.textContaining('Attachments is required'), findsNothing);

      final sourceTypeControl = find.byKey(
        const ValueKey<String>('historical-archives-source-type-control'),
      );
      final guidance = find.byKey(
        const ValueKey<String>('historical-archives-messages-folder-guidance'),
      );
      expect(
        tester.getBottomLeft(sourceTypeControl).dy,
        lessThan(tester.getTopLeft(guidance).dy),
      );
      expect(
        tester.getTopLeft(find.text('Add from a Messages Folder')).dy,
        lessThan(tester.getTopLeft(guidance).dy),
      );
      expect(
        tester.getTopLeft(guidance).dy,
        lessThan(tester.getTopLeft(find.text('Choose Messages Folder...')).dy),
      );
      expect(find.textContaining('Choose Messages Folder'), findsOneWidget);

      double gapHeight(String key) {
        return tester
            .widget<SizedBox>(find.byKey(ValueKey<String>(key)))
            .height!;
      }

      final sourceToKnownFolders = gapHeight(
        'historical-archives-source-to-known-folders-gap',
      );
      final knownFoldersToAdd = gapHeight(
        'historical-archives-known-folders-to-add-gap',
      );
      final guidanceParagraph = gapHeight(
        'historical-archives-guidance-paragraph-gap',
      );
      final headingToContent = gapHeight(
        'historical-archives-add-heading-to-content-gap',
      );
      final guidanceToChooser = gapHeight(
        'historical-archives-guidance-to-chooser-gap',
      );

      expect(sourceToKnownFolders, greaterThan(guidanceParagraph));
      expect(knownFoldersToAdd, greaterThan(guidanceParagraph));
      expect(guidanceParagraph, greaterThan(headingToContent));
      expect(guidanceToChooser, greaterThan(guidanceParagraph));
    });

    testWidgets('tapping choose messages folder triggers workflow chooser', (
      tester,
    ) async {
      final workflow = _TestHistoricalArchivesWorkflow();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(() => workflow),
          ],
          child: const CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Choose Messages Folder...'));
      await tester.pump();

      expect(workflow.chooseMessagesFolderCallCount, 1);
    });

    testWidgets('existing-source context keeps add action available', (
      tester,
    ) async {
      final workflow = _TestHistoricalArchivesWorkflow(
        initialState: buildInitialHistoricalArchivesWorkflowState().copyWith(
          presentationContext:
              HistoricalArchivesPresentationContext.existingSource,
          presentationStage: HistoricalArchivesPresentationStage.knownSource,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(() => workflow),
          ],
          child: const CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(),
            ),
          ),
        ),
      );

      expect(find.text('Choose Messages Folder...'), findsOneWidget);
    });

    testWidgets('invalid-folder notice leaves the stable hub action visible', (
      tester,
    ) async {
      final workflow = _TestHistoricalArchivesWorkflow(
        initialState: buildInitialHistoricalArchivesWorkflowState().copyWith(
          invalidFolderNotice: const HistoricalArchivesInvalidFolderNotice(
            noticeOccurrence: 1,
            presentationSessionOccurrence: 0,
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(() => workflow),
          ],
          child: const CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(),
            ),
          ),
        ),
      );

      expect(find.text('Choose Messages Folder...'), findsOneWidget);
      expect(find.text('Choose Another Folder'), findsNothing);
    });

    testWidgets('add-archive context hides the competing add action', (
      tester,
    ) async {
      final workflow = _TestHistoricalArchivesWorkflow(
        initialState: buildInitialHistoricalArchivesWorkflowState().copyWith(
          presentationContext: HistoricalArchivesPresentationContext.addArchive,
          presentationStage:
              HistoricalArchivesPresentationStage.inspectingSource,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(() => workflow),
          ],
          child: const CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(),
            ),
          ),
        ),
      );

      expect(find.text('Choose Messages Folder...'), findsNothing);
      expect(
        find.byKey(
          const ValueKey<String>(
            'historical-archives-messages-folder-guidance',
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('known-source cartouche requests exact-key navigation', (
      tester,
    ) async {
      const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';
      final workflow = _TestHistoricalArchivesWorkflow();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historicalArchivesWorkflowProvider.overrideWith(() => workflow),
          ],
          child: const CupertinoApp(
            home: HistoricalArchivesSettingsSupplementalContent(
              payload: HistoricalArchivesSettingsCassettePayload(
                knownSources: [
                  HistoricalArchiveSidebarSourceSummary(
                    sourceKey: sourceKey,
                    label: 'Archive-2017',
                    dateRangeLabel: 'Date range: 2012 to 2017',
                    messageCountLabel: 'Total messages: 8,882',
                    importedOnLabel: 'Imported on: today',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Archive-2017'));
      await tester.pump();

      expect(workflow.shownSourceKeys, [sourceKey]);
      expect(workflow.chooseMessagesFolderCallCount, 0);
    });

    testWidgets(
      'selected source uses blue selection without orange reference',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';
        await tester.pumpWidget(
          const ProviderScope(
            child: CupertinoApp(
              home: HistoricalArchivesSettingsSupplementalContent(
                payload: HistoricalArchivesSettingsCassettePayload(
                  knownSources: [
                    HistoricalArchiveSidebarSourceSummary(
                      sourceKey: sourceKey,
                      label: 'Archive-2017',
                      dateRangeLabel: 'Date range: 2012 to 2017',
                      messageCountLabel: 'Total messages: 8,882',
                      importedOnLabel: 'Imported on: today',
                      isSelected: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final decoration =
            tester
                    .widget<DecoratedBox>(
                      find.byKey(
                        const ValueKey<String>(
                          'historical-archive-source-chrome:$sourceKey',
                        ),
                      ),
                    )
                    .decoration
                as BoxDecoration;
        final container = ProviderScope.containerOf(
          tester.element(find.text('Archive-2017')),
        );
        final colors = container.read(themeColorsProvider.notifier);

        expect(decoration.color, colors.surfaces.selected);
        expect(
          decoration.border?.top.color,
          colors.accents.selection.withValues(alpha: 0.58),
        );
        expect(decoration.boxShadow, isNull);
      },
    );

    testWidgets(
      'reference gently fades once per occurrence and returns to ordinary chrome',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';

        Future<void> pumpSource({
          required bool isReferenced,
          required int referenceOccurrence,
        }) async {
          await tester.pumpWidget(
            ProviderScope(
              child: CupertinoApp(
                home: HistoricalArchivesSettingsSupplementalContent(
                  payload: HistoricalArchivesSettingsCassettePayload(
                    knownSources: [
                      HistoricalArchiveSidebarSourceSummary(
                        sourceKey: sourceKey,
                        label: 'Archive-2017',
                        dateRangeLabel: 'Date range: 2012 to 2017',
                        messageCountLabel: 'Total messages: 8,882',
                        importedOnLabel: 'Imported on: today',
                        isReferenced: isReferenced,
                        referenceOccurrence: referenceOccurrence,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        BoxDecoration decoration() {
          final decoratedBox = tester.widget<DecoratedBox>(
            find.byKey(
              const ValueKey<String>(
                'historical-archive-source-chrome:$sourceKey',
              ),
            ),
          );
          return decoratedBox.decoration as BoxDecoration;
        }

        double borderWidth() => decoration().border!.top.width;

        await pumpSource(isReferenced: false, referenceOccurrence: 0);
        expect(borderWidth(), 0.8);
        final ordinaryBackground = decoration().color!;

        await pumpSource(isReferenced: true, referenceOccurrence: 1);
        await tester.pump(const Duration(milliseconds: 375));
        expect(borderWidth(), allOf(greaterThan(0.8), lessThan(1.0)));
        final fadeInBackground = decoration().color!;
        expect(fadeInBackground.a, 1.0);
        final container = ProviderScope.containerOf(
          tester.element(find.text('Archive-2017')),
        );
        final colors = container.read(themeColorsProvider.notifier);
        final archiveLabel = tester.widget<Text>(find.text('Archive-2017'));
        expect(archiveLabel.style?.color, colors.content.textPrimary);
        await tester.pump(const Duration(milliseconds: 375));
        expect(borderWidth(), 1.0);
        final maximumBackground = Color.alphaBlend(
          colors.messagePanels.contextAnchorBackground.withValues(alpha: 0.18),
          colors.surfaces.control,
        );
        expect(decoration().color, maximumBackground);
        expect(
          decoration().border!.top.color,
          Color.alphaBlend(
            colors.messagePanels.contextAnchorBorder.withValues(alpha: 0.72),
            colors.lines.borderSubtle,
          ),
        );
        expect(decoration().boxShadow, isNull);
        expect(decoration().color, isNot(colors.surfaces.selected));
        final maximumDistance = _colorDistance(
          ordinaryBackground,
          maximumBackground,
        );
        expect(
          _colorDistance(ordinaryBackground, fadeInBackground),
          allOf(greaterThan(0), lessThan(maximumDistance)),
        );

        await tester.pump(const Duration(milliseconds: 1000));
        expect(borderWidth(), 1.0);
        await tester.pump(const Duration(milliseconds: 1000));
        expect(borderWidth(), allOf(greaterThan(0.8), lessThan(1.0)));
        final fadeOutBackground = decoration().color!;
        expect(fadeOutBackground.a, 1.0);
        expect(
          _colorDistance(ordinaryBackground, fadeOutBackground),
          allOf(greaterThan(0), lessThan(maximumDistance)),
        );
        await tester.pump(const Duration(milliseconds: 1000));
        expect(borderWidth(), 0.8);
        expect(decoration().color, colors.surfaces.control);
        expect(decoration().boxShadow, isNull);

        await pumpSource(isReferenced: true, referenceOccurrence: 1);
        await tester.pump(const Duration(milliseconds: 375));
        expect(borderWidth(), 0.8);

        await pumpSource(isReferenced: true, referenceOccurrence: 2);
        await tester.pump(const Duration(milliseconds: 375));
        expect(borderWidth(), allOf(greaterThan(0.8), lessThan(1.0)));

        await pumpSource(isReferenced: false, referenceOccurrence: 0);
        expect(borderWidth(), 0.8);
      },
    );

    testWidgets('reduced motion shows a bounded static gentle reference', (
      tester,
    ) async {
      const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';

      HistoricalArchivesSettingsSupplementalContent content({
        required bool isReferenced,
        required int referenceOccurrence,
      }) {
        return HistoricalArchivesSettingsSupplementalContent(
          payload: HistoricalArchivesSettingsCassettePayload(
            knownSources: [
              HistoricalArchiveSidebarSourceSummary(
                sourceKey: sourceKey,
                label: 'Archive-2017',
                dateRangeLabel: 'Date range: 2012 to 2017',
                messageCountLabel: 'Total messages: 8,882',
                importedOnLabel: 'Imported on: today',
                isReferenced: isReferenced,
                referenceOccurrence: referenceOccurrence,
              ),
            ],
          ),
        );
      }

      Future<void> pumpSource({
        required bool isReferenced,
        required int referenceOccurrence,
      }) async {
        await tester.pumpWidget(
          ProviderScope(
            child: CupertinoApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: content(
                isReferenced: isReferenced,
                referenceOccurrence: referenceOccurrence,
              ),
            ),
          ),
        );
      }

      double borderWidth() {
        final decoratedBox = tester.widget<DecoratedBox>(
          find.byKey(
            const ValueKey<String>(
              'historical-archive-source-chrome:$sourceKey',
            ),
          ),
        );
        return (decoratedBox.decoration as BoxDecoration).border!.top.width;
      }

      await pumpSource(isReferenced: false, referenceOccurrence: 0);
      await pumpSource(isReferenced: true, referenceOccurrence: 1);
      await tester.pump();

      expect(borderWidth(), 1.0);
      await tester.pump(const Duration(milliseconds: 2000));
      expect(borderWidth(), 1.0);
      await pumpSource(isReferenced: false, referenceOccurrence: 0);
      expect(borderWidth(), 0.8);
    });
  });
}

double _colorDistance(Color first, Color second) {
  return (first.a - second.a).abs() +
      (first.r - second.r).abs() +
      (first.g - second.g).abs() +
      (first.b - second.b).abs();
}

class _TestHistoricalArchivesWorkflow extends HistoricalArchivesWorkflow {
  _TestHistoricalArchivesWorkflow({
    HistoricalArchivesWorkflowState? initialState,
  }) : _initialState =
           initialState ?? buildInitialHistoricalArchivesWorkflowState();

  final HistoricalArchivesWorkflowState _initialState;
  int chooseMessagesFolderCallCount = 0;
  final List<String> shownSourceKeys = [];

  @override
  HistoricalArchivesWorkflowState build() {
    return _initialState;
  }

  @override
  Future<void> chooseMessagesFolder() async {
    chooseMessagesFolderCallCount += 1;
  }

  @override
  Future<void> showKnownSource({required String sourceKey}) async {
    shownSourceKeys.add(sourceKey);
  }
}
