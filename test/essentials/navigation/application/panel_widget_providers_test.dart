import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_cassette_card.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('isPinnedAppControlCassette', () {
    test('returns true only for app control cassette cards', () {
      const appControlCard = SidebarCassetteCard(
        title: '',
        role: SidebarCassetteRole.appControl,
        isNaked: true,
        child: SizedBox.shrink(),
      );
      const contextCard = SidebarCassetteCard(
        title: '',
        role: SidebarCassetteRole.contextPrimary,
        isNaked: true,
        child: SizedBox.shrink(),
      );

      expect(isPinnedAppControlCassette(appControlCard), isTrue);
      expect(isPinnedAppControlCassette(contextCard), isFalse);
      expect(isPinnedAppControlCassette(const SizedBox.shrink()), isFalse);
    });

    test('unwraps padded cassette cards before checking pinned role', () {
      const wrappedAppControlCard = Padding(
        padding: EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(
          title: '',
          role: SidebarCassetteRole.appControl,
          isNaked: true,
          child: SizedBox.shrink(),
        ),
      );

      expect(isPinnedAppControlCassette(wrappedAppControlCard), isTrue);
    });
  });

  group('shouldExpandSidebarCassette', () {
    test('unwraps padded cassette cards before checking expansion', () {
      const wrappedExpandingCard = Padding(
        padding: EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(
          title: '',
          shouldExpand: true,
          child: SizedBox.shrink(),
        ),
      );
      const wrappedIntrinsicCard = Padding(
        padding: EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(title: '', child: SizedBox.shrink()),
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
      final container = ProviderContainer();
      final reconciliationSubscription = container.listen(
        reconcileSidebarPanelsProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      await tester.idle();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.center,
            spec: const ViewSpec.import(ImportSpec.forImport()),
          );

      await tester.pump();
      await tester.pump();

      expect(
        container
            .read(
              panelsViewStateProvider(SidebarMode.messages),
            )[WindowPanel.center]
            ?.activePage
            ?.spec,
        const ViewSpec.import(ImportSpec.forImport()),
      );
      expect(
        container.read(sidebarFlowProvider).projectedCenterSpec,
        const ViewSpec.messages(MessagesSpec.globalTimeline()),
      );

      reconciliationSubscription.close();
      await tester.idle();
      await tester.pump();
      container.dispose();
    });
  });

  group('LeftPanelHost', () {
    testWidgets(
      'does not reuse stale cassette widgets across rack-shape changes',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            cassetteWidgetCoordinatorProvider(
              SidebarMode.messages,
            ).overrideWith(_DelayedCassetteWidgetCoordinator.new),
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
  Future<List<Widget>> build(SidebarMode mode) async {
    final rack = ref.watch(cassetteRackStateProvider(mode));

    if (rack.cassettes.length == 1) {
      return const [Text('top-menu')];
    }

    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const [Text('picker')];
  }
}

class _PickerToHeroCassetteWidgetCoordinator extends CassetteWidgetCoordinator {
  @override
  Future<List<Widget>> build(SidebarMode mode) async {
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
      return const [Text('picker')];
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
      return const [Text('hero')];
    }

    return const [Text('unexpected')];
  }
}
