import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/navigation/feature_level_providers.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_settings_spec.dart';
import 'package:remember_this_text/features/handles/application/state/stray_handle_mode_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('sidebarActionDispatcherProvider', () {
    late ProviderContainer container;
    late SidebarActionDispatcher dispatcher;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
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
        rackNotifier.setRack([
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

    test('dispatches settings menu changes via cassette replacement', () async {
      final rackNotifier = container.read(
        cassetteRackStateProvider(SidebarMode.settings).notifier,
      );
      rackNotifier.setRack([
        const CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.settingsMenu(),
        ),
      ]);

      await dispatcher.dispatch(
        intent: const SettingsMenuChanged(
          choice: SidebarSettingsMenuChoice.actions,
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
            SidebarUtilityCassetteSpec.settingsMenu(
              selectedChoice: SettingsMenuChoice.actions,
            ),
          ),
          const CassetteSpec.contactsSettings(
            ContactsSettingsSpec.actionsMenu(),
          ),
        ]),
      );
    });

    test(
      'dispatches settings action choices via cassette replacement',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        rackNotifier.setRack([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(
              selectedChoice: SettingsMenuChoice.actions,
            ),
          ),
          const CassetteSpec.contactsSettings(
            ContactsSettingsSpec.actionsMenu(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const SettingsActionChosen(
            choice: SidebarSettingsActionChoice.sendLogs,
          ),
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
              SidebarUtilityCassetteSpec.settingsMenu(
                selectedChoice: SettingsMenuChoice.actions,
              ),
            ),
            const CassetteSpec.contactsSettings(
              ContactsSettingsSpec.actionsMenu(
                selectedChoice: ActionsMenuChoice.sendLogs,
              ),
            ),
            const CassetteSpec.contactsSettings(
              ContactsSettingsSpec.sendLogsInfo(),
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
        rackNotifier.setRack([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.topChatMenu(),
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
            ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
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
        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.messages))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.topChatMenu(),
            ),
            const CassetteSpec.contactsInfo(
              ContactsInfoCassetteSpec.infoCard(
                key: ContactsInfoKey.pickerContentSources,
              ),
            ),
            const CassetteSpec.contacts(ContactsCassetteSpec.contactChooser()),
          ]),
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
    ref.watch(reconcileSidebarPanelsProvider(SidebarMode.messages));
    return const SizedBox.shrink();
  }
}

ViewSpec? _activeSpec(ProviderContainer container, WindowPanel panel) {
  final stacks = container.read(panelsViewStateProvider(SidebarMode.messages));
  return stacks[panel]?.activePage?.spec;
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
}
