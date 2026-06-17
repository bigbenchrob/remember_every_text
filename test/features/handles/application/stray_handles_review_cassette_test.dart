import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/feature_level_providers.dart'
    as sidebar;
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/widget_builders/stray_handles_review_cassette.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/handles/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  group('StrayHandlesReviewCassette', () {
    testWidgets(
      'uses sidebar flow selection instead of conflicting stored center stack',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            sidebar.sidebarFlowPreferenceStoreProvider.overrideWith((
              ref,
            ) async {
              return _InMemorySidebarFlowPreferenceStore();
            }),
            strayHandlesProvider.overrideWith((ref) async {
              return <StrayHandleSummary>[
                const StrayHandleSummary(
                  handleId: 7,
                  handleValue: '+15551234567',
                  serviceType: 'iMessage',
                  totalMessages: 3,
                ),
              ];
            }),
          ],
        );
        final panelsSubscription = container.listen(
          panelsViewStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final preferenceSubscription = container.listen(
          sidebar.sidebarFlowPreferenceStoreProvider,
          (_, __) {},
          fireImmediately: true,
        );
        final flowSubscription = container.listen(
          sidebarFlowProvider,
          (_, __) {},
          fireImmediately: true,
        );

        container
            .read(sidebarFlowProvider.notifier)
            .openStrayHandleLens(handleId: 7);
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.center,
              spec: const ViewSpec.messages(
                MessagesSpec.forContact(contactId: 42),
              ),
            );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MacosApp(
              home: MacosWindow(
                child: SizedBox(
                  width: 420,
                  height: 240,
                  child: StrayHandlesReviewCassette(
                    filter: StrayHandleFilter.phones,
                    mode: StrayHandleMode.allStrays,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('+15551234567'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(StrayHandlesReviewCassette),
            matching: find.byType(Positioned),
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        panelsSubscription.close();
        preferenceSubscription.close();
        flowSubscription.close();
        container.dispose();
        await tester.pump();
      },
    );
  });
}

class _InMemorySidebarFlowPreferenceStore
    implements SidebarFlowPreferenceStore {
  String? _contactContextPreference;
  String? _navigationPreference;

  @override
  Future<String?> readContactContextPreference() async {
    return _contactContextPreference;
  }

  @override
  Future<String?> readNavigationPreference() async {
    return _navigationPreference;
  }

  @override
  Future<void> writeContactContextPreference(String value) async {
    _contactContextPreference = value;
  }

  @override
  Future<void> writeNavigationPreference(String value) async {
    _navigationPreference = value;
  }
}
