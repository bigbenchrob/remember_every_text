import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/db_importers/application/import_execution_gate_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/navigation/feature_level_providers.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/ephemeral_cassette_projection_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/handles/application/state/stray_handle_mode_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_cassette_spec.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_merge/historical_archive_import_result.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_merge/historical_archive_merge_service_provider.dart';
import 'package:remember_this_text/features/settings/application/historical_archive_merge/historical_archive_preflight_summary.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../../test_support/cassette_rack_test_harness.dart';

void main() {
  group('sidebarActionDispatcherProvider', () {
    late ProviderContainer container;
    late SidebarActionDispatcher dispatcher;
    late _FakeMessageDataResetService resetService;
    late _FakeHistoricalArchiveMergeService archiveService;
    late HistoricalArchivePreflightSummary preflightSummary;
    late HistoricalArchiveImportResult importResult;

    setUp(() {
      resetService = _FakeMessageDataResetService();
      preflightSummary = HistoricalArchivePreflightSummary(
        archiveLabel: 'Messages_2012',
        archivePath: '/tmp/Messages_2012',
        totalMessages: 10,
        duplicateMessages: 4,
        newMessages: 6,
        earliestDate: DateTime.utc(2012, 1, 1),
        latestDate: DateTime.utc(2012, 12, 31),
        canImport: true,
        rowsWithoutGuidCount: 1,
        warnings: const ['No Attachments folder was found.'],
      );
      importResult = const HistoricalArchiveImportResult(
        archiveLabel: 'Messages_2012',
        archivePath: '/tmp/Messages_2012',
        stagedMessages: 6,
        importedMessages: 6,
        skippedDuplicates: 4,
        failedRows: 1,
        rowsWithoutGuidCount: 1,
        batchId: 77,
        warnings: ['No Attachments folder was found.'],
      );
      container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
          historicalArchiveMergeServiceProvider.overrideWith((ref) {
            archiveService = _FakeHistoricalArchiveMergeService(
              ref,
              preflightSummary,
              importResult,
            );
            return archiveService;
          }),
          ...cassetteRackTestHarnessOverrides(),
        ],
      );
      dispatcher = container.read(sidebarActionDispatcherProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('dispatches top menu changes through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      await dispatcher.dispatch(
        intent: const TopMenuChanged(
          choice: SidebarTopMenuChoice.searchAllMessages,
        ),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
          cassetteIndex: 0,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      final centerSpec = _activeSpec(container, WindowPanel.center);

      expect(flowState.topMenuChoice.name, 'searchAllMessages');
      expect(
        centerSpec,
        equals(const ViewSpec.messages(MessagesSpec.globalTimeline())),
      );
    });

    test(
      'dispatches stray handle filter changes via cassette replacement',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.messages).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesTypeSwitcher(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const StrayHandleFilterChanged(
            filter: SidebarStrayHandleFilter.emails,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.messages))
              .cassettes,
          equals([
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesTypeSwitcher(
                selectedFilter: StrayHandleFilter.emails,
              ),
            ),
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesModeSwitcher(
                filter: StrayHandleFilter.emails,
              ),
            ),
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesReview(
                filter: StrayHandleFilter.emails,
              ),
            ),
          ]),
        );
      },
    );

    test('dispatches stray handle mode changes through mode state', () async {
      await dispatcher.dispatch(
        intent: const StrayHandleModeChanged(
          mode: SidebarStrayHandleMode.dismissed,
        ),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      expect(
        container.read(strayHandleModeSettingProvider),
        StrayHandleMode.dismissed,
      );
    });

    test('dispatches reset message data through reset service', () async {
      await dispatcher.dispatch(
        intent: const ResetMessageDataRequested(),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.settings,
          cassetteIndex: 1,
        ),
      );

      expect(resetService.confirmResetAndPrepareReimportCalls, 1);
    });

    test(
      'dispatches persistent settings selection to flow state and child cascade',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.textSize,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.textSizePlaceholder(),
            ),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          SettingsMenuActionId.textSize,
        );
      },
    );

    test(
      'dispatches send logs transient selection into ephemeral projection and clears durable settings context',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(SettingsMenuActionId.textSize);
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          const CassetteSpec.settings(
            SettingsCassetteSpec.textSizePlaceholder(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const ShowSendLogsFlow(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
      },
    );

    test(
      'dispatches import historical archive transient selection into ephemeral projection and clears durable settings context',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(SettingsMenuActionId.textSize);
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          const CassetteSpec.settings(
            SettingsCassetteSpec.textSizePlaceholder(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const ShowImportHistoricalArchiveFlow(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.settings(
              SettingsCassetteSpec.importHistoricalArchivePanel(),
            ),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
      },
    );

    test(
      'dispatches archive folder selection into preflight projection',
      () async {
        container
            .read(
              ephemeralCassetteProjectionProvider(
                SidebarMode.settings,
              ).notifier,
            )
            .replaceProjection(
              const CassetteSpec.settings(
                SettingsCassetteSpec.importHistoricalArchivePanel(),
              ),
            );

        await dispatcher.dispatch(
          intent: const ChooseHistoricalArchiveFolderRequested(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 1,
          ),
        );

        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            CassetteSpec.settings(
              SettingsCassetteSpec.importHistoricalArchivePreflight(
                preflightSummary,
              ),
            ),
          ]),
        );
      },
    );

    test(
      'dispatches archive import into progress projection immediately',
      () async {
        container
            .read(
              ephemeralCassetteProjectionProvider(
                SidebarMode.settings,
              ).notifier,
            )
            .replaceProjection(
              CassetteSpec.settings(
                SettingsCassetteSpec.importHistoricalArchivePreflight(
                  preflightSummary,
                ),
              ),
            );

        await dispatcher.dispatch(
          intent: ImportHistoricalArchiveRequested(
            archivePath: preflightSummary.archivePath,
            archiveLabel: preflightSummary.archiveLabel,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 1,
          ),
        );

        final projectionSubscription = container.listen(
          ephemeralCassetteProjectionProvider(SidebarMode.settings),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(projectionSubscription.close);

        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            CassetteSpec.settings(
              SettingsCassetteSpec.importHistoricalArchiveInProgress(
                preflightSummary.archiveLabel,
              ),
            ),
          ]),
        );
        expect(container.read(dbMaintenanceLockProvider), isTrue);

        archiveService.completeImport();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            CassetteSpec.settings(
              SettingsCassetteSpec.importHistoricalArchiveResult(importResult),
            ),
          ]),
        );
        expect(container.read(dbMaintenanceLockProvider), isFalse);
      },
    );

    test(
      'dispatches archive cache clear into refreshed preflight projection',
      () async {
        container
            .read(
              ephemeralCassetteProjectionProvider(
                SidebarMode.settings,
              ).notifier,
            )
            .replaceProjection(
              CassetteSpec.settings(
                SettingsCassetteSpec.importHistoricalArchivePreflight(
                  preflightSummary,
                ),
              ),
            );

        await dispatcher.dispatch(
          intent: ClearHistoricalArchiveCacheRequested(
            archivePath: preflightSummary.archivePath,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 1,
          ),
        );

        final projection = container.read(
          ephemeralCassetteProjectionProvider(SidebarMode.settings),
        );
        expect(projection.cassettes, hasLength(1));

        final settingsSpec = projection.cassettes.single.maybeMap(
          settings: (value) => value.spec,
          orElse: () => null,
        );
        final refreshedSummary = settingsSpec?.maybeWhen(
          importHistoricalArchivePreflight: (summary) => summary,
          orElse: () => null,
        );

        expect(refreshedSummary, isNotNull);
        expect(
          refreshedSummary!.warnings.first,
          'Archive cache cleared. The dedicated archive import database is now empty.',
        );
        expect(refreshedSummary.archivePath, preflightSummary.archivePath);
        expect(
          (container.read(historicalArchiveMergeServiceProvider)
                  as _FakeHistoricalArchiveMergeService)
              .clearArchiveImportDatabaseCalls,
          1,
        );
      },
    );

    test(
      'archive import yields a failure result when execution gate is busy',
      () async {
        final projectionSubscription = container.listen(
          ephemeralCassetteProjectionProvider(SidebarMode.settings),
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(projectionSubscription.close);

        container
            .read(
              ephemeralCassetteProjectionProvider(
                SidebarMode.settings,
              ).notifier,
            )
            .replaceProjection(
              CassetteSpec.settings(
                SettingsCassetteSpec.importHistoricalArchivePreflight(
                  preflightSummary,
                ),
              ),
            );

        final acquired = container
            .read(importExecutionGateProvider.notifier)
            .tryAcquire('chat-db-monitor');
        expect(acquired, isTrue);
        addTearDown(() {
          container
              .read(importExecutionGateProvider.notifier)
              .release('chat-db-monitor');
        });

        await dispatcher.dispatch(
          intent: ImportHistoricalArchiveRequested(
            archivePath: preflightSummary.archivePath,
            archiveLabel: preflightSummary.archiveLabel,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 1,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        final projection = container.read(
          ephemeralCassetteProjectionProvider(SidebarMode.settings),
        );
        final result = projection.cassettes.single.maybeMap(
          settings: (value) => value.spec.maybeWhen(
            importHistoricalArchiveResult: (result) => result,
            orElse: () => null,
          ),
          orElse: () => null,
        );

        expect(result, isNotNull);
        expect(result!.importedMessages, 0);
        expect(result.failedRows, 1);
        expect(result.warnings.single, contains('chat-db-monitor'));
        expect(archiveService.importCalls, 0);
        expect(container.read(dbMaintenanceLockProvider), isFalse);
      },
    );

    test(
      'dispatches message history coverage durable selection into stable cascade and derived center panel',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.messageHistoryCoverage,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOverview(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageHowToRead(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOlderMessagesNote(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.settings),
          ),
          equals(
            const ViewSpec.settings(
              SettingsViewSpec.messageHistoryCoverageReport(),
            ),
          ),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          SettingsMenuActionId.messageHistoryCoverage,
        );
      },
    );

    test(
      'dispatches reset transient selection into ephemeral projection and clears durable settings context',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(SettingsMenuActionId.textSize);
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          const CassetteSpec.settings(
            SettingsCassetteSpec.textSizePlaceholder(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const ShowResetMessageDataFlow(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.settings(
              SettingsCassetteSpec.resetMessageDataPanel(),
            ),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
      },
    );

    test(
      'cancelling reset transient projection leaves settings at the root menu',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(SettingsMenuActionId.textSize);
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          const CassetteSpec.settings(
            SettingsCassetteSpec.textSizePlaceholder(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const ShowResetMessageDataFlow(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        await dispatcher.dispatch(
          intent: const SettingsTransientActionCancelled(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 1,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
      },
    );

    test(
      'changing persistent settings context clears incompatible ephemeral projection',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        ]);
        container
            .read(
              ephemeralCassetteProjectionProvider(
                SidebarMode.settings,
              ).notifier,
            )
            .replaceProjection(
              const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
            );

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.textSize,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.textSizePlaceholder(),
            ),
          ]),
        );
      },
    );

    testWidgets('dispatches heat map month focus through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      final anchor = DateTime(2024, 04, 01);

      await dispatcher.dispatch(
        intent: HeatMapMonthFocused(contactId: 42, monthAnchor: anchor),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          ViewSpec.messages(
            MessagesSpec.forContact(contactId: 42, scrollToDate: anchor),
          ),
        ),
      );
    });

    test(
      'dispatches choose another contact from downstream cassette context',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.messages).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.topChatMenu(),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
          ),
          const CassetteSpec.contactsInfo(
            ContactsInfoCassetteSpec.infoCard(
              key: ContactsInfoKey.chosenContact,
              chosenContactId: 42,
            ),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.messageScopeToggle(contactId: 42),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.handleFilter(contactId: 42),
          ),
          const CassetteSpec.messages(
            MessagesCassetteSpec.heatMap(contactId: 42),
          ),
        ]);
        container
            .read(sidebarFlowProvider.notifier)
            .contactChosen(contactId: 42, infoCardIndex: 1);

        await dispatcher.dispatch(
          intent: const ChooseAnotherContact(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: 4,
          ),
        );

        expect(container.read(sidebarFlowProvider).chosenContactId, isNull);
        final cassettes = container
            .read(cassetteRackStateProvider(SidebarMode.messages))
            .cassettes;

        expect(
          cassettes.first,
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.topChatMenu(),
          ),
        );
        expect(
          cassettes,
          contains(
            const CassetteSpec.contactsInfo(
              ContactsInfoCassetteSpec.infoCard(
                key: ContactsInfoKey.pickerContentSources,
              ),
            ),
          ),
        );
        expect(
          cassettes,
          contains(
            const CassetteSpec.contacts(ContactsCassetteSpec.contactChooser()),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactSelectionControl(
                  chosenContactId: 42,
                ),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contactsInfo(
                ContactsInfoCassetteSpec.infoCard(
                  key: ContactsInfoKey.chosenContact,
                  chosenContactId: 42,
                ),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.messageScopeToggle(contactId: 42),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.handleFilter(contactId: 42),
              ),
            ),
          ),
        );
      },
    );

    testWidgets('dispatches contact handle selection through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      container
          .read(sidebarFlowProvider.notifier)
          .contactChosen(contactId: 42, infoCardIndex: 1);

      await dispatcher.dispatch(
        intent: const ContactHandleSelected(contactId: 42, handleId: 7),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
          cassetteIndex: 5,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      expect(container.read(sidebarFlowProvider).selectedHandleId, 7);
      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          const ViewSpec.messages(
            MessagesSpec.forContact(contactId: 42, filterHandleId: 7),
          ),
        ),
      );
    });

    testWidgets(
      'dispatches contact message scope changes through sidebar flow',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        container
            .read(sidebarFlowProvider.notifier)
            .contactChosen(contactId: 42, infoCardIndex: 1);

        await dispatcher.dispatch(
          intent: const ContactMessageScopeChanged(
            contactId: 42,
            scope: SidebarMessageScope.recoveredDeleted,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: 4,
          ),
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(
          container.read(sidebarFlowProvider).messageScope,
          SidebarFlowMessageScope.recoveredDeleted,
        );
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            const ViewSpec.messages(
              MessagesSpec.recoveredUnlinkedMessages(contactId: 42),
            ),
          ),
        );
      },
    );
  });
}

Future<void> _mountMessagesPanelReconciliation(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: _MessagesPanelReconciliationHost(),
      ),
    ),
  );
}

Future<void> _flushMessagesPanelReconciliation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

class _MessagesPanelReconciliationHost extends ConsumerWidget {
  const _MessagesPanelReconciliationHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sidebarFlowProvider);
    ref.watch(cassetteRackStateProvider(SidebarMode.messages));
    ref.watch(effectiveCenterPanelSpecProvider(SidebarMode.messages));
    ref.watch(effectiveRightPanelSpecProvider(SidebarMode.messages));
    return const SizedBox.shrink();
  }
}

ViewSpec? _activeSpec(ProviderContainer container, WindowPanel panel) {
  if (panel == WindowPanel.center) {
    return container.read(
      effectiveCenterPanelSpecProvider(SidebarMode.messages),
    );
  }

  final stacks = container.read(panelsViewStateProvider(SidebarMode.messages));
  return stacks[panel]?.activePage?.spec;
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
}

final class _FakeMessageDataResetService implements MessageDataResetService {
  int resetDerivedDataCalls = 0;
  int confirmResetAndPrepareReimportCalls = 0;

  @override
  Future<void> resetDerivedData() async {
    resetDerivedDataCalls += 1;
  }

  @override
  Future<void> confirmResetAndPrepareReimport() async {
    confirmResetAndPrepareReimportCalls += 1;
  }
}

class _FakeHistoricalArchiveMergeService extends HistoricalArchiveMergeService {
  _FakeHistoricalArchiveMergeService(super.ref, this.summary, this.importResult)
    : importCompleter = Completer<HistoricalArchiveImportResult>();

  final HistoricalArchivePreflightSummary summary;
  final HistoricalArchiveImportResult importResult;
  final Completer<HistoricalArchiveImportResult> importCompleter;
  int clearArchiveImportDatabaseCalls = 0;
  int importCalls = 0;

  @override
  Future<HistoricalArchivePreflightSummary> runPreflightForFolder(
    String folderPath,
  ) async {
    return summary;
  }

  @override
  Future<HistoricalArchivePreflightSummary?>
  pickArchiveFolderAndRunPreflight() async {
    return summary;
  }

  @override
  Future<HistoricalArchiveImportResult> importArchiveForFutureMerge({
    required String archivePath,
    required String archiveLabel,
  }) async {
    importCalls += 1;
    return importCompleter.future;
  }

  @override
  Future<void> clearArchiveImportDatabase() async {
    clearArchiveImportDatabaseCalls += 1;
  }

  void completeImport() {
    if (importCompleter.isCompleted) {
      return;
    }

    importCompleter.complete(importResult);
  }
}
