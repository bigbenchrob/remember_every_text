import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('debugAssertValidSidebarFlowState', () {
    test('allows canonical chooser state', () {
      expect(
        () => debugAssertValidSidebarFlowState(const SidebarFlowState()),
        returnsNormally,
      );
    });

    test('rejects selected handle without chosen contact', () {
      expect(
        () => debugAssertValidSidebarFlowState(
          const SidebarFlowState(selectedHandleId: 7),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('selectedHandleId requires a chosen contact'),
          ),
        ),
      );
    });

    test('rejects contact recovered scope without chosen contact', () {
      expect(
        () => debugAssertValidSidebarFlowState(
          const SidebarFlowState(
            messageScope: SidebarFlowMessageScope.recoveredDeleted,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Recovered contact scope requires a chosen contact'),
          ),
        ),
      );
    });

    test('rejects global recovered branch outside recovered scope', () {
      expect(
        () => debugAssertValidSidebarFlowState(
          const SidebarFlowState(
            topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Global recovered branch must remain in recoveredDeleted'),
          ),
        ),
      );
    });

    test(
      'rejects transient settings action as persistent settings context',
      () {
        expect(
          () => debugAssertValidSidebarFlowState(
            const SidebarFlowState(
              persistentSettingsContext: SettingsMenuActionId.sendLogs,
            ),
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('persistentSettingsContext cannot hold transient'),
            ),
          ),
        );
      },
    );
  });

  group('sidebarFlowProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets(
      'contactChosen resets subordinate state and builds chosen-contact branch',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        container
            .read(sidebarFlowProvider.notifier)
            .contactChosen(contactId: 42, infoCardIndex: 1);

        await _flushMessagesPanelReconciliation(tester);

        final flowState = container.read(sidebarFlowProvider);
        final rack = container.read(
          cassetteRackStateProvider(SidebarMode.messages),
        );
        final centerSpec = _activeSpec(container, WindowPanel.center);

        expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
        expect(flowState.chosenContactId, 42);
        expect(flowState.selectedHandleId, isNull);
        expect(flowState.messageScope, SidebarFlowMessageScope.regular);

        expect(
          rack.cassettes,
          equals([
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
          ]),
        );
        expect(
          centerSpec,
          equals(
            const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
          ),
        );
      },
    );

    test('setPersistentSettingsContext stores durable settings context', () {
      container
          .read(sidebarFlowProvider.notifier)
          .setPersistentSettingsContext(SettingsMenuActionId.textSize);

      expect(
        container.read(sidebarFlowProvider).persistentSettingsContext,
        SettingsMenuActionId.textSize,
      );
    });

    test('message history coverage projects a settings-mode center spec', () {
      container
          .read(sidebarFlowProvider.notifier)
          .setPersistentSettingsContext(
            SettingsMenuActionId.messageHistoryCoverage,
          );

      expect(
        container.read(sidebarFlowProvider).projectedSettingsCenterSpec,
        equals(
          const ViewSpec.settings(
            SettingsViewSpec.messageHistoryCoverageReport(),
          ),
        ),
      );
      expect(
        container
            .read(sidebarFlowProvider)
            .projectedCenterSpecForMode(SidebarMode.settings),
        equals(
          const ViewSpec.settings(
            SettingsViewSpec.messageHistoryCoverageReport(),
          ),
        ),
      );
    });

    testWidgets(
      'chooseAnotherContact restores picker branch and clears panels',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final panels = container.read(
          panelsViewStateProvider(SidebarMode.messages).notifier,
        );

        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        panels.show(
          panel: WindowPanel.right,
          spec: const ViewSpec.messages(MessagesSpec.forHandle(handleId: 9001)),
        );

        flow.chooseAnotherContact(infoCardIndex: 1);

        await _flushMessagesPanelReconciliation(tester);

        final flowState = container.read(sidebarFlowProvider);
        final rack = container.read(
          cassetteRackStateProvider(SidebarMode.messages),
        );
        final panelState = container.read(
          panelsViewStateProvider(SidebarMode.messages),
        );

        expect(flowState.chosenContactId, isNull);
        expect(flowState.selectedHandleId, isNull);
        expect(flowState.messageScope, SidebarFlowMessageScope.regular);

        expect(
          rack.cassettes,
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
        expect(panelState[WindowPanel.center]?.isEmpty, isTrue);
        expect(panelState[WindowPanel.right]?.isEmpty, isTrue);
      },
    );

    testWidgets(
      'chooseAnotherContact clears incompatible stored flow-managed center panel',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final panels = container.read(
          panelsViewStateProvider(SidebarMode.messages).notifier,
        );

        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        panels.show(
          panel: WindowPanel.center,
          spec: const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
        );

        flow.chooseAnotherContact(infoCardIndex: 1);

        await _flushMessagesPanelReconciliation(tester);

        final panelState = container.read(
          panelsViewStateProvider(SidebarMode.messages),
        );

        expect(_activeSpec(container, WindowPanel.center), isNull);
        expect(panelState[WindowPanel.center]?.isEmpty, isTrue);
      },
    );

    testWidgets('handleSelected updates selected handle and center panel', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      final flow = container.read(sidebarFlowProvider.notifier);

      flow.contactChosen(contactId: 42, infoCardIndex: 1);
      flow.handleSelected(contactId: 42, handleId: 7, cassetteIndex: 5);

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      final rack = container.read(
        cassetteRackStateProvider(SidebarMode.messages),
      );
      final centerSpec = _activeSpec(container, WindowPanel.center);

      expect(flowState.chosenContactId, 42);
      expect(flowState.selectedHandleId, 7);
      expect(flowState.messageScope, SidebarFlowMessageScope.regular);
      expect(
        rack.cassettes[5],
        equals(
          const CassetteSpec.contacts(
            ContactsCassetteSpec.handleFilter(
              contactId: 42,
              selectedHandleId: 7,
            ),
          ),
        ),
      );
      expect(
        centerSpec,
        equals(
          const ViewSpec.messages(
            MessagesSpec.forContact(contactId: 42, filterHandleId: 7),
          ),
        ),
      );
    });

    testWidgets(
      'setContactMessageScope switches recovered mode and back to regular',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);

        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        flow.setContactMessageScope(
          contactId: 42,
          messageScope: SidebarFlowMessageScope.recoveredDeleted,
          cassetteIndex: 4,
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).selectedHandleId, isNull);
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

        flow.setContactMessageScope(
          contactId: 42,
          messageScope: SidebarFlowMessageScope.regular,
          cassetteIndex: 4,
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(
          container.read(sidebarFlowProvider).messageScope,
          SidebarFlowMessageScope.regular,
        );
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
          ),
        );
      },
    );

    testWidgets(
      'showContactTimelineAt clears handle filter in projected center spec',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final anchorDate = DateTime(2024, 05, 01);

        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        flow.handleSelected(contactId: 42, handleId: 7, cassetteIndex: 5);
        flow.showContactTimelineAt(contactId: 42, scrollToDate: anchorDate);

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).selectedHandleId, isNull);
        expect(container.read(sidebarFlowProvider).scrollToDate, anchorDate);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            ViewSpec.messages(
              MessagesSpec.forContact(contactId: 42, scrollToDate: anchorDate),
            ),
          ),
        );
      },
    );

    testWidgets(
      'projected center change clears stored right panel immediately',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final panels = container.read(
          panelsViewStateProvider(SidebarMode.messages).notifier,
        );

        flow.showGlobalTimeline();
        panels.show(
          panel: WindowPanel.right,
          spec: const ViewSpec.messages(
            MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
          ),
        );

        expect(_activeSpec(container, WindowPanel.right), isNotNull);

        flow.showContactTimelineAt(contactId: 42);

        await _flushMessagesPanelReconciliation(tester);

        expect(_activeSpec(container, WindowPanel.right), isNull);
        expect(
          container
              .read(
                panelsViewStateProvider(SidebarMode.messages),
              )[WindowPanel.right]
              ?.isEmpty,
          isTrue,
        );
      },
    );

    testWidgets('top menu recovered no-handle branch projects center panel', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      container
          .read(sidebarFlowProvider.notifier)
          .topMenuChanged(
            choice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
            cassetteIndex: 0,
          );

      await _flushMessagesPanelReconciliation(tester);

      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          const ViewSpec.messages(
            MessagesSpec.recoveredNoHandleFromMeMessages(),
          ),
        ),
      );
    });

    test('top menu stray handles branch cascades the full review stack', () {
      container
          .read(sidebarFlowProvider.notifier)
          .topMenuChanged(
            choice: TopChatMenuChoice.strayHandles,
            cassetteIndex: 0,
          );

      final flowState = container.read(sidebarFlowProvider);
      final rack = container.read(
        cassetteRackStateProvider(SidebarMode.messages),
      );

      expect(flowState.topMenuChoice, TopChatMenuChoice.strayHandles);
      expect(_activeSpec(container, WindowPanel.center), isNull);
      expect(
        rack.cassettes,
        equals([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.topChatMenu(
              selectedChoice: TopChatMenuChoice.strayHandles,
            ),
          ),
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesTypeSwitcher(),
          ),
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesModeSwitcher(
              filter: StrayHandleFilter.phones,
            ),
          ),
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesReview(
              filter: StrayHandleFilter.phones,
            ),
          ),
        ]),
      );
    });

    testWidgets(
      'showRecoveredDeletedAt stores month anchor in projected center spec',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final anchorDate = DateTime(2021, 09, 01);

        flow.showRecoveredDeletedAt(contactId: 42, startDate: anchorDate);

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).scrollToDate, anchorDate);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            ViewSpec.messages(
              MessagesSpec.recoveredUnlinkedMessages(
                contactId: 42,
                scrollToDate: anchorDate,
              ),
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
