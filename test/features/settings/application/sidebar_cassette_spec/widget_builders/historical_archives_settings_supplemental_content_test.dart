import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/config/theme/colors/theme_colors.dart';
import 'package:remember_this_text/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/historical_archives_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content.dart';

void main() {
  group('HistoricalArchivesSettingsSupplementalContent', () {
    testWidgets('renders known source last-run details', (tester) async {
      const payload = HistoricalArchivesSettingsCassettePayload(
        knownSources: [
          HistoricalArchiveSidebarSourceSummary(
            sourceKey: 'historical-messages-archive:/Archives/2017/chat.db',
            label: 'Jan 2017 MacBook Archive',
            dateRangeLabel: 'Range: Jan 2014 -> Nov 2017',
            messageCountLabel: 'Source messages: 8,882',
            lastRunSummaryLabel: 'Last run counts: 8,120 new, 762 duplicates',
            lastImportedLabel: 'Last imported: Apr 29, 2026 at 11:42 AM',
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
      expect(
        find.text('Last run counts: 8,120 new, 762 duplicates'),
        findsOneWidget,
      );
      expect(
        find.text('Last imported: Apr 29, 2026 at 11:42 AM'),
        findsOneWidget,
      );
      expect(find.text('Add an Archive Folder'), findsOneWidget);
    });

    testWidgets('tapping add archive folder triggers workflow chooser', (
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

      await tester.tap(find.text('Add an Archive Folder'));
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

      expect(find.text('Add an Archive Folder'), findsOneWidget);
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

      expect(find.text('Add an Archive Folder'), findsNothing);
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
                    lastRunSummaryLabel: 'Last run: imported 8,882 messages',
                    lastImportedLabel: 'Last imported: today',
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
                      lastRunSummaryLabel: 'Last run: imported 8,882 messages',
                      lastImportedLabel: 'Last imported: today',
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
      'canonical reference pulses once per occurrence and not per rebuild',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';

        Future<void> pumpSource({
          required bool isReferenced,
          required int pulseOccurrence,
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
                        lastRunSummaryLabel:
                            'Last run: imported 8,882 messages',
                        lastImportedLabel: 'Last imported: today',
                        isReferenced: isReferenced,
                        referencePulseOccurrence: pulseOccurrence,
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

        await pumpSource(isReferenced: false, pulseOccurrence: 0);
        expect(borderWidth(), 0.8);

        await pumpSource(isReferenced: true, pulseOccurrence: 1);
        await tester.pump(const Duration(milliseconds: 200));
        expect(borderWidth(), greaterThan(1.25));
        final container = ProviderScope.containerOf(
          tester.element(find.text('Archive-2017')),
        );
        final colors = container.read(themeColorsProvider.notifier);
        final archiveLabel = tester.widget<Text>(find.text('Archive-2017'));
        expect(archiveLabel.style?.color, colors.content.textPrimary);
        await tester.pumpAndSettle();
        expect(borderWidth(), 1.25);
        expect(
          decoration().color,
          colors.messagePanels.contextAnchorBackground.withValues(alpha: 0.10),
        );
        expect(
          decoration().border!.top.color,
          colors.messagePanels.contextAnchorBorder.withValues(alpha: 0.55),
        );
        expect(
          decoration().boxShadow!.single.color,
          colors.messagePanels.contextAnchorGlow.withValues(alpha: 0.18),
        );

        await pumpSource(isReferenced: true, pulseOccurrence: 1);
        await tester.pump(const Duration(milliseconds: 200));
        expect(borderWidth(), 1.25);

        await pumpSource(isReferenced: true, pulseOccurrence: 2);
        await tester.pump(const Duration(milliseconds: 200));
        expect(borderWidth(), greaterThan(1.25));

        await pumpSource(isReferenced: false, pulseOccurrence: 0);
        expect(borderWidth(), 0.8);
      },
    );

    testWidgets(
      'reduced motion keeps the reference without animating the pulse',
      (tester) async {
        const sourceKey = 'historical-messages-archive:/Archives/2017/chat.db';

        HistoricalArchivesSettingsSupplementalContent content({
          required bool isReferenced,
          required int pulseOccurrence,
        }) {
          return HistoricalArchivesSettingsSupplementalContent(
            payload: HistoricalArchivesSettingsCassettePayload(
              knownSources: [
                HistoricalArchiveSidebarSourceSummary(
                  sourceKey: sourceKey,
                  label: 'Archive-2017',
                  dateRangeLabel: 'Date range: 2012 to 2017',
                  messageCountLabel: 'Total messages: 8,882',
                  lastRunSummaryLabel: 'Last run: imported 8,882 messages',
                  lastImportedLabel: 'Last imported: today',
                  isReferenced: isReferenced,
                  referencePulseOccurrence: pulseOccurrence,
                ),
              ],
            ),
          );
        }

        Future<void> pumpSource({
          required bool isReferenced,
          required int pulseOccurrence,
        }) async {
          await tester.pumpWidget(
            ProviderScope(
              child: CupertinoApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: true),
                  child: child!,
                ),
                home: content(
                  isReferenced: isReferenced,
                  pulseOccurrence: pulseOccurrence,
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

        await pumpSource(isReferenced: false, pulseOccurrence: 0);
        await pumpSource(isReferenced: true, pulseOccurrence: 1);
        await tester.pump(const Duration(milliseconds: 200));

        expect(borderWidth(), 1.25);
      },
    );
  });
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
