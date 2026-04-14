import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/onboarding/domain/import_spec.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_widget_coordinator_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_option.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/messages/application/timeline/ordinal/message_timeline_ordinal_provider.dart';
import 'package:remember_this_text/features/messages/application/view_spec/coordinators/view_spec_coordinator.dart'
    as messages_view_spec;
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

final _testSidebarResolutionStateProvider =
    StateProvider<SidebarCassetteResolutionState>((ref) {
      return const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[],
        expectedVisibleCount: 0,
        isLoading: false,
      );
    });

void main() {
  group('isPinnedAppControlCassette', () {
    test('returns true only for app-control resolved cassettes', () {
      final appControlCassette = _resolvedCassette(
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'top-menu',
          role: SidebarCassetteRole.appControl,
        ),
      );
      final contextCassette = _resolvedCassette(
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'context',
          role: SidebarCassetteRole.contextPrimary,
        ),
      );

      expect(isPinnedAppControlCassette(appControlCassette), isTrue);
      expect(isPinnedAppControlCassette(contextCassette), isFalse);
    });
  });

  group('shouldExpandSidebarCassette', () {
    test('reads expansion directly from resolved cassette payloads', () {
      final expandingCassette = _resolvedCassette(
        payload: const SharedBodyModelSidebarCassettePayload(
          bodyModel: SidebarInfoBodyModel(bodyText: 'body'),
          shouldExpand: true,
        ),
      );
      final intrinsicCassette = _resolvedCassette(
        payload: const SharedBodyModelSidebarCassettePayload(
          bodyModel: SidebarInfoBodyModel(bodyText: 'body'),
        ),
      );
      final infoCassette = _resolvedCassette(
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'info',
        ),
      );

      expect(shouldExpandSidebarCassette(expandingCassette), isTrue);
      expect(shouldExpandSidebarCassette(intrinsicCassette), isFalse);
      expect(shouldExpandSidebarCassette(infoCassette), isFalse);
    });
  });

  group('left sidebar layout contract', () {
    testWidgets(
      'pins app controls and uses expanding layout from descriptors',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const heroSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
        );
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([topMenuSpec, heroSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: heroSpec,
              cassetteIndex: 1,
              payload: SharedBodyModelSidebarCassettePayload(
                bodyModel: SidebarDropdownBodyModel(
                  promptLabel: '',
                  selectedOptionId: 'hero',
                  options: <SidebarDropdownOption>[
                    SidebarDropdownOption(
                      id: 'hero',
                      label: 'hero',
                      selectionIntent: ChooseAnotherContact(),
                    ),
                  ],
                ),
                shouldExpand: true,
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('top-menu'), findsOneWidget);
        expect(find.text('hero'), findsOneWidget);
        expect(find.byType(CustomScrollView), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Expanded &&
                widget.child.runtimeType.toString() == '_ContentFillColumn',
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );
  });

  group('effectiveCenterPanelSpec', () {
    test(
      'derives flow-managed messages center without stored center stack',
      () {
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();

        final storedCenter = container.read(
          panelsViewStateProvider(SidebarMode.messages),
        )[WindowPanel.center];

        expect(storedCenter?.isEmpty ?? true, isTrue);
        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.messages),
          ),
          equals(const ViewSpec.messages(MessagesSpec.globalTimeline())),
        );

        container.dispose();
      },
    );

    testWidgets(
      'center panel host renders derived flow-managed messages view',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            messages_view_spec.viewSpecCoordinatorProvider.overrideWith(
              _FakeMessagesViewSpecCoordinator.new,
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: CenterPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        await tester.pump();

        expect(find.text('global'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        container.dispose();
        await tester.pump();
      },
    );

    test('preserves sidebar-independent center stack over flow projection', () {
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
        ],
      );

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.center,
            spec: const ViewSpec.import(ImportSpec.forImport()),
          );

      expect(
        container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
        equals(const ViewSpec.import(ImportSpec.forImport())),
      );

      container.dispose();
    });

    test(
      'stored flow-managed center cannot override projected center spec',
      () {
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.center,
              spec: const ViewSpec.messages(
                MessagesSpec.forContact(contactId: 42),
              ),
            );

        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.messages),
          ),
          equals(const ViewSpec.messages(MessagesSpec.globalTimeline())),
        );
        expect(
          container
              .read(
                panelsViewStateProvider(SidebarMode.messages),
              )[WindowPanel.center]
              ?.activePage
              ?.spec,
          equals(
            const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
          ),
        );

        container.dispose();
      },
    );
  });

  group('effectiveRightPanelSpec', () {
    test('derives stored right panel when effective center supports it', () {
      const globalScope = MessageTimelineScope.global();
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          messageTimelineViewModelProvider(
            scope: globalScope,
          ).overrideWith(_FakeSearchingGlobalTimelineViewModel.new),
        ],
      );

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.messages(
              MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
            ),
          );

      expect(
        container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
        equals(
          const ViewSpec.messages(
            MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
          ),
        ),
      );

      container.dispose();
    });

    test(
      'flow-managed center change clears incompatible stored right panel',
      () {
        const globalScope = MessageTimelineScope.global();
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            messageTimelineViewModelProvider(
              scope: globalScope,
            ).overrideWith(_FakeSearchingGlobalTimelineViewModel.new),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.right,
              spec: const ViewSpec.messages(
                MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
              ),
            );

        container
            .read(sidebarFlowProvider.notifier)
            .showContactTimelineAt(contactId: 42);

        expect(
          container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
          isNull,
        );
        expect(
          container
              .read(
                panelsViewStateProvider(SidebarMode.messages),
              )[WindowPanel.right]
              ?.isEmpty,
          isTrue,
        );

        container.dispose();
      },
    );

    test('clearing global search hides search-result context right panel', () {
      const globalScope = MessageTimelineScope.global();
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          messageTimelineViewModelProvider(
            scope: globalScope,
          ).overrideWith(_FakeSearchingGlobalTimelineViewModel.new),
        ],
      );

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.messages(
              MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
            ),
          );

      expect(
        container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
        equals(
          const ViewSpec.messages(
            MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
          ),
        ),
      );
      expect(
        container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
        isTrue,
      );

      final notifier =
          container.read(
                messageTimelineViewModelProvider(scope: globalScope).notifier,
              )
              as _FakeSearchingGlobalTimelineViewModel;
      notifier.setSearchActive(isActive: false);

      expect(
        container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
        isNull,
      );
      expect(
        container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
        isFalse,
      );

      container.dispose();
    });

    test('active contact search keeps search-result context right panel', () {
      const contactScope = MessageTimelineScope.contact(contactId: 42);
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          messageTimelineViewModelProvider(
            scope: contactScope,
          ).overrideWith(_FakeSearchingContactTimelineViewModel.new),
        ],
      );

      container
          .read(sidebarFlowProvider.notifier)
          .showContactTimelineAt(contactId: 42);
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.messages(
              MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
            ),
          );

      expect(
        container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
        equals(
          const ViewSpec.messages(
            MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
          ),
        ),
      );
      expect(
        container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
        isTrue,
      );

      container.dispose();
    });

    test('clearing contact search hides search-result context right panel', () {
      const contactScope = MessageTimelineScope.contact(contactId: 42);
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          messageTimelineViewModelProvider(
            scope: contactScope,
          ).overrideWith(_FakeSearchingContactTimelineViewModel.new),
        ],
      );

      container
          .read(sidebarFlowProvider.notifier)
          .showContactTimelineAt(contactId: 42);
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.messages(
              MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
            ),
          );

      expect(
        container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
        isTrue,
      );

      final notifier =
          container.read(
                messageTimelineViewModelProvider(scope: contactScope).notifier,
              )
              as _FakeSearchingContactTimelineViewModel;
      notifier.setSearchActive(isActive: false);

      expect(
        container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
        isNull,
      );
      expect(
        container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
        isFalse,
      );

      container.dispose();
    });

    testWidgets('right panel host renders derived right content', (
      tester,
    ) async {
      const globalScope = MessageTimelineScope.global();
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          messageTimelineViewModelProvider(
            scope: globalScope,
          ).overrideWith(_FakeSearchingGlobalTimelineViewModel.new),
          messages_view_spec.viewSpecCoordinatorProvider.overrideWith(
            _FakeMessagesViewSpecCoordinator.new,
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: RightPanelHost(mode: SidebarMode.messages),
          ),
        ),
      );
      await tester.pump();

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.messages(
              MessagesSpec.searchResultContext(messageId: 99, chatId: 5),
            ),
          );
      await tester.pump();

      expect(find.text('search:99'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
      await tester.pump();
    });
  });

  group('panel host coordination', () {
    testWidgets('keeps prior sidebar content during same-rack async reloads', (
      tester,
    ) async {
      const chooserSpec = CassetteSpec.contacts(
        ContactsCassetteSpec.contactChooser(),
      );
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          sidebarCassetteResolutionStateProvider(
            SidebarMode.messages,
          ).overrideWith((ref) {
            return ref.watch(_testSidebarResolutionStateProvider);
          }),
        ],
      );
      final rackSubscription = container.listen(
        cassetteRackStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );
      final resolutionSubscription = container.listen(
        sidebarCassetteResolutionStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(rackSubscription.close);
      addTearDown(resolutionSubscription.close);
      container
          .read(_testSidebarResolutionStateProvider.notifier)
          .state = const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[
          ResolvedSidebarCassette(
            spec: chooserSpec,
            cassetteIndex: 0,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'loading-payload',
            ),
          ),
        ],
        expectedVisibleCount: 1,
        isLoading: false,
      );

      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([chooserSpec]);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: LeftPanelHost(mode: SidebarMode.messages),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('loading-payload'), findsOneWidget);

      container
          .read(_testSidebarResolutionStateProvider.notifier)
          .state = const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[
          ResolvedSidebarCassette(
            spec: chooserSpec,
            cassetteIndex: 0,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'loading-payload',
            ),
          ),
        ],
        expectedVisibleCount: 1,
        isLoading: true,
      );
      await tester.pump();

      expect(find.text('loading-payload'), findsOneWidget);

      container
          .read(_testSidebarResolutionStateProvider.notifier)
          .state = const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[
          ResolvedSidebarCassette(
            spec: chooserSpec,
            cassetteIndex: 0,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'ready-payload',
            ),
          ),
        ],
        expectedVisibleCount: 1,
        isLoading: false,
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: LeftPanelHost(mode: SidebarMode.messages),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('ready-payload'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      container.dispose();
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'center host removes rendered contact panel after choosing another contact',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const pickerInfoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
            messages_view_spec.viewSpecCoordinatorProvider.overrideWith(
              _FakeMessagesViewSpecCoordinator.new,
            ),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(rackSubscription.close);
        addTearDown(resolutionSubscription.close);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
          ],
          expectedVisibleCount: 1,
          isLoading: false,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([topMenuSpec]);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('top-menu'), findsOneWidget);

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([topMenuSpec, pickerInfoSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: true,
        );

        await tester.pump();

        expect(find.text('top-menu'), findsNothing);
        expect(find.text('picker'), findsNothing);

        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: pickerInfoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'picker',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('picker'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
        container.dispose();
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets(
      'does not reuse picker widgets during selected-contact transition',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const pickerInfoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        const heroSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
        );
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(rackSubscription.close);
        addTearDown(resolutionSubscription.close);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: pickerInfoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'picker',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([topMenuSpec, pickerInfoSpec]);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('picker'), findsOneWidget);

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([topMenuSpec, heroSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: true,
        );

        await tester.pump();

        expect(find.text('picker'), findsNothing);
        expect(find.text('hero'), findsNothing);

        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: heroSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'hero',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('hero'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
        container.dispose();
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  });
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
}

class _FakeSearchingGlobalTimelineViewModel extends MessageTimelineViewModel {
  @override
  MessageTimelineViewModelState build({required MessageTimelineScope scope}) {
    final searchController = TextEditingController(text: 'anchor');
    ref.onDispose(searchController.dispose);

    return MessageTimelineViewModelState(
      scope: scope,
      searchController: searchController,
      searchQuery: 'anchor',
      debouncedQuery: 'anchor',
      searchMode: MessageSearchMode.allTerms,
      searchResultIds: const AsyncValue<List<int>>.data(<int>[99]),
      ordinal: const AsyncValue<MessageTimelineOrdinalState>.loading(),
    );
  }

  void setSearchActive({required bool isActive}) {
    state = MessageTimelineViewModelState(
      scope: state.scope,
      searchController: state.searchController,
      searchQuery: isActive ? 'anchor' : '',
      debouncedQuery: isActive ? 'anchor' : '',
      searchMode: state.searchMode,
      searchResultIds: isActive
          ? const AsyncValue<List<int>>.data(<int>[99])
          : const AsyncValue<List<int>>.data(<int>[]),
      ordinal: state.ordinal,
    );
  }
}

class _FakeSearchingContactTimelineViewModel extends MessageTimelineViewModel {
  @override
  MessageTimelineViewModelState build({required MessageTimelineScope scope}) {
    final searchController = TextEditingController(text: 'anchor');
    ref.onDispose(searchController.dispose);

    return MessageTimelineViewModelState(
      scope: scope,
      searchController: searchController,
      searchQuery: 'anchor',
      debouncedQuery: 'anchor',
      searchMode: MessageSearchMode.allTerms,
      searchResultIds: const AsyncValue<List<int>>.data(<int>[99]),
      ordinal: const AsyncValue<MessageTimelineOrdinalState>.loading(),
    );
  }

  void setSearchActive({required bool isActive}) {
    state = MessageTimelineViewModelState(
      scope: state.scope,
      searchController: state.searchController,
      searchQuery: isActive ? 'anchor' : '',
      debouncedQuery: isActive ? 'anchor' : '',
      searchMode: state.searchMode,
      searchResultIds: isActive
          ? const AsyncValue<List<int>>.data(<int>[99])
          : const AsyncValue<List<int>>.data(<int>[]),
      ordinal: state.ordinal,
    );
  }
}

ResolvedSidebarCassette _resolvedCassette({
  required SidebarCassettePayload payload,
}) {
  return ResolvedSidebarCassette(
    spec: const CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.settingsMenu(),
    ),
    cassetteIndex: 0,
    payload: payload,
    topSpacing: payload.topSpacing,
  );
}

class _FakeMessagesViewSpecCoordinator
    extends messages_view_spec.ViewSpecCoordinator {
  @override
  void build() {}

  @override
  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forChat: (chatId) => Text('chat:$chatId'),
      forContact: (contactId, scrollToDate, filterHandleId) =>
          Text('contact:$contactId'),
      globalTimeline: (scrollToDate) => const Text('global'),
      forHandle: (handleId) => Text('handle:$handleId'),
      recoveredUnlinkedMessages: (contactId, scrollToDate) =>
          Text('recovered:${contactId ?? 'global'}'),
      recoveredNoHandleFromMeMessages: (scrollToDate) =>
          const Text('recovered:no-handle-from-me'),
      recoveredAttachmentViewer: (messageId, attachment) =>
          Text('attachment:$messageId'),
      searchResultContext: (messageId, chatId, beforeCount, afterCount) =>
          Text('search:$messageId'),
      handleLens: (handleId) => Text('lens:$handleId'),
      forChatInDateRange: (chatId, startDate, endDate) =>
          Text('chat-range:$chatId'),
    );
  }
}
