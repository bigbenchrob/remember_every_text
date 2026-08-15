import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/stray_handle_summary.dart';
import 'package:remember_this_text/features/handles/application/read_models/stray_handles_provider.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/widget_builders/stray_handles_review_cassette.dart';
import 'package:remember_this_text/features/handles/domain/entities/stray_handle_endpoint_kind.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  group('StrayHandlesReviewCassette', () {
    testWidgets(
      'uses sidebar flow selection instead of conflicting stored center stack',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            sidebarFlowPreferenceStoreProvider.overrideWith((ref) async {
              return _InMemorySidebarFlowPreferenceStore();
            }),
            unknownSourceIdentificationHandlesProvider.overrideWith((ref) {
              return AsyncData(<StrayHandleSummary>[
                StrayHandleSummary(
                  handleId: 7,
                  handleValue: '+15551234567',
                  serviceType: 'iMessage',
                  totalMessages: 3,
                  endpointKind: StrayHandleEndpointKind.phoneNumber,
                  lastMessageDate: DateTime(2024, 7, 6),
                ),
              ]);
            }),
          ],
        );
        final panelsSubscription = container.listen(
          panelsViewStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final preferenceSubscription = container.listen(
          sidebarFlowPreferenceStoreProvider,
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
                  width: 340,
                  height: 240,
                  child: StrayHandlesReviewCassette(
                    investigation: StrayHandleInvestigation.identifySources,
                    filter: StrayHandleFilter.phones,
                    mode: StrayHandleReviewMode.active,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('+15551234567'), findsOneWidget);
        expect(find.text('SPAM'), findsNothing);
        expect(find.byIcon(CupertinoIcons.xmark), findsNothing);
        expect(tester.takeException(), isNull);

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
