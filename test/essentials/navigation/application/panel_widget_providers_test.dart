import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_widget_coordinator_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_cassette_card.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/messages/application/view_spec/coordinators/view_spec_coordinator.dart'
    as messages_view_spec;
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('isPinnedAppControlCassette', () {
    test('returns true only for app control cassette cards', () {
      final appControlCard = SidebarCassetteCard(
        title: '',
        role: SidebarCassetteRole.appControl,
        isNaked: true,
        child: const SizedBox.shrink(),
      );
      final contextCard = SidebarCassetteCard(
        title: '',
        role: SidebarCassetteRole.contextPrimary,
        isNaked: true,
        child: const SizedBox.shrink(),
      );

      expect(isPinnedAppControlCassette(appControlCard), isTrue);
      expect(isPinnedAppControlCassette(contextCard), isFalse);
      expect(isPinnedAppControlCassette(const SizedBox.shrink()), isFalse);
    });

    test('unwraps padded cassette cards before checking pinned role', () {
      final wrappedAppControlCard = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(
          title: '',
          role: SidebarCassetteRole.appControl,
          isNaked: true,
          child: const SizedBox.shrink(),
        ),
      );

      expect(isPinnedAppControlCassette(wrappedAppControlCard), isTrue);
    });
  });

  group('shouldExpandSidebarCassette', () {
    test('unwraps padded cassette cards before checking expansion', () {
      final wrappedExpandingCard = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(
          title: '',
          shouldExpand: true,
          child: const SizedBox.shrink(),
        ),
      );
      final wrappedIntrinsicCard = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(title: '', child: const SizedBox.shrink()),
      );

      expect(shouldExpandSidebarCassette(wrappedExpandingCard), isTrue);
      expect(shouldExpandSidebarCassette(wrappedIntrinsicCard), isFalse);
      expect(shouldExpandSidebarCassette(const SizedBox.shrink()), isFalse);
    });
  });

  group('reconcileSidebarPanels', () {
    testWidgets('preserves import panel when sidebar flow projects messages', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
        ],
      );
      final reconciliationSubscription = container.listen(
        reconcileSidebarPanelsProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      expect(container.read(sidebarFlowProvider).chosenContactId, isNull);

      reconciliationSubscription.close();
      await tester.idle();
      await tester.pump();
      container.dispose();
    });

    testWidgets(
      'center host removes rendered contact panel after choosing another contact',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            cassetteWidgetCoordinatorProvider(
              SidebarMode.messages,
            ).overrideWith(_DelayedCassetteWidgetCoordinator.new),
            messages_view_spec.viewSpecCoordinatorProvider.overrideWith(
              _FakeMessagesViewSpecCoordinator.new,
            ),
          ],
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.topChatMenu(),
              ),
            ]);

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
            .setRack([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.topChatMenu(),
              ),
              const CassetteSpec.contactsInfo(
                ContactsInfoCassetteSpec.infoCard(
                  key: ContactsInfoKey.pickerContentSources,
                ),
              ),
            ]);

        await tester.pump();

        expect(find.text('top-menu'), findsNothing);
        expect(find.text('picker'), findsNothing);

        await tester.pump(const Duration(milliseconds: 20));
        await tester.pump();

        expect(find.text('picker'), findsOneWidget);

        container.dispose();
      },
    );

    testWidgets(
      'does not reuse picker widgets during selected-contact transition',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            cassetteWidgetCoordinatorProvider(
              SidebarMode.messages,
            ).overrideWith(_PickerToHeroCassetteWidgetCoordinator.new),
          ],
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.topChatMenu(),
              ),
              const CassetteSpec.contactsInfo(
                ContactsInfoCassetteSpec.infoCard(
                  key: ContactsInfoKey.pickerContentSources,
                ),
              ),
            ]);

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
            .setRack([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.topChatMenu(),
              ),
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
              ),
            ]);

        await tester.pump();

        expect(find.text('picker'), findsNothing);
        expect(find.text('hero'), findsNothing);

        await tester.pump(const Duration(milliseconds: 20));
        await tester.pump();

        expect(find.text('hero'), findsOneWidget);

        container.dispose();
      },
    );
  });
}

class _DelayedCassetteWidgetCoordinator extends CassetteWidgetCoordinator {
  @override
  Future<List<ResolvedSidebarCassette>> build(SidebarMode mode) async {
    final rack = ref.watch(cassetteRackStateProvider(mode));

    if (rack.cassettes.length == 1) {
      return <ResolvedSidebarCassette>[
        ResolvedSidebarCassette(
          spec: rack.cassettes.first,
          cassetteIndex: 0,
          payload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'top-menu',
            role: SidebarCassetteRole.appControl,
          ),
        ),
      ];
    }

    await Future<void>.delayed(const Duration(milliseconds: 10));
    return <ResolvedSidebarCassette>[
      ResolvedSidebarCassette(
        spec: rack.cassettes.last,
        cassetteIndex: rack.cassettes.length - 1,
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'picker',
        ),
      ),
    ];
  }
}

class _PickerToHeroCassetteWidgetCoordinator extends CassetteWidgetCoordinator {
  @override
  Future<List<ResolvedSidebarCassette>> build(SidebarMode mode) async {
    final rack = ref.watch(cassetteRackStateProvider(mode));
    final trailingSpec = rack.cassettes.last;

    final isPicker = trailingSpec.maybeWhen(
      contactsInfo: (infoSpec) {
        return infoSpec.maybeWhen(
          infoCard: (key, _) {
            return key == ContactsInfoKey.pickerContentSources;
          },
          orElse: () {
            return false;
          },
        );
      },
      orElse: () {
        return false;
      },
    );

    if (isPicker) {
      return <ResolvedSidebarCassette>[
        ResolvedSidebarCassette(
          spec: trailingSpec,
          cassetteIndex: rack.cassettes.length - 1,
          payload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'picker',
          ),
        ),
      ];
    }

    final isHero = trailingSpec.maybeWhen(
      contacts: (contactsSpec) {
        return contactsSpec.maybeWhen(
          contactHeroSummary: (_) {
            return true;
          },
          orElse: () {
            return false;
          },
        );
      },
      orElse: () {
        return false;
      },
    );

    if (isHero) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return <ResolvedSidebarCassette>[
        ResolvedSidebarCassette(
          spec: trailingSpec,
          cassetteIndex: rack.cassettes.length - 1,
          payload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'hero',
          ),
        ),
      ];
    }

    return <ResolvedSidebarCassette>[
      ResolvedSidebarCassette(
        spec: trailingSpec,
        cassetteIndex: rack.cassettes.length - 1,
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'unexpected',
        ),
      ),
    ];
  }
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
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
