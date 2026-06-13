import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/widget_builders/stray_handles_review_cassette.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/handles/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  group('StrayHandlesReviewCassette', () {
    testWidgets(
      'uses effective center spec instead of conflicting stored center stack',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
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
            effectiveCenterPanelSpecProvider(SidebarMode.messages).overrideWith(
              (ref) {
                return const ViewSpec.messages(
                  MessagesSpec.handleLens(handleId: 7),
                );
              },
            ),
          ],
        );
        final panelsSubscription = container.listen(
          panelsViewStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(panelsSubscription.close);
        addTearDown(container.dispose);

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
        await tester.pump();
      },
    );
  });
}
