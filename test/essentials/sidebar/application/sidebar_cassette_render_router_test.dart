import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_render_router.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/messages_heatmap_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/settings_info_actions_cassette_payload.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/settings_top_menu_row.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('sidebar cassette render contract', () {
    test('placement-governed feature payloads expose feature render kind', () {
      expect(
        const MessagesHeatmapCassettePayload(contactId: 42).renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
    });

    test('feature info payloads expose info render kind', () {
      expect(
        const AttachmentArchiveSettingsCassettePayload().renderKind,
        SidebarCassetteRenderKind.featureInfo,
      );

      expect(
        const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'info',
        ).renderKind,
        SidebarCassetteRenderKind.featureInfo,
      );
    });

    test('shared body-model payloads expose body-model render kind', () {
      expect(
        const SharedBodyModelSidebarCassettePayload(
          bodyModel: SidebarInfoBodyModel(bodyText: 'info'),
        ).renderKind,
        SidebarCassetteRenderKind.sharedBodyModel,
      );
    });

    testWidgets('builds a flat mixed-row settings top menu widget', (
      tester,
    ) async {
      final widget = buildSidebarCassettePayloadWidget(
        mode: SidebarMode.settings,
        resolvedCassette: const ResolvedSidebarCassette(
          spec: CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          cassetteIndex: 0,
          payload: SettingsTopMenuCassettePayload(
            cassetteIndex: 0,
            promptLabel: 'Choose setting or action',
            rows: <SettingsTopMenuRow>[
              SettingsTopMenuGroupHeaderRow(label: 'Troubleshooting'),
              SettingsTopMenuActionRow.transientAction(
                label: 'Send logs…',
                actionId: SettingsMenuActionId.sendLogs,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      );

      expect(find.text('Choose setting or action'), findsOneWidget);

      await tester.tap(find.text('Choose setting or action'));
      await tester.pump();

      expect(find.text('Troubleshooting'), findsOneWidget);
      expect(find.text('Send logs…'), findsOneWidget);
    });

    testWidgets('builds a unified send logs cassette with inline action', (
      tester,
    ) async {
      final widget = buildSidebarCassettePayloadWidget(
        mode: SidebarMode.settings,
        resolvedCassette: const ResolvedSidebarCassette(
          spec: CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
          cassetteIndex: 1,
          payload: SettingsInfoActionsCassettePayload(
            cassetteIndex: 1,
            bodyText:
                'Send log data to help diagnose problems with MessageLens. The exported report includes application logs and database health diagnostics. It does not modify your imported data.',
            actions: [
              SidebarActionDescriptor(
                label: 'Send log data…',
                intent: SendLogsRequested(),
                tone: SidebarActionTone.primary,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      );

      expect(
        find.textContaining('database health diagnostics'),
        findsOneWidget,
      );
      expect(find.text('Send log data…'), findsOneWidget);
      expect(find.text('Send Logs'), findsNothing);
    });

    testWidgets('builds a sidebar-local reset message data confirm cassette', (
      tester,
    ) async {
      final widget = buildSidebarCassettePayloadWidget(
        mode: SidebarMode.settings,
        resolvedCassette: const ResolvedSidebarCassette(
          spec: CassetteSpec.settings(
            SettingsCassetteSpec.resetMessageDataPanel(),
          ),
          cassetteIndex: 1,
          payload: SettingsInfoActionsCassettePayload(
            cassetteIndex: 1,
            title: 'Reset Message Data',
            bodyText:
                'Use this if the messages or contacts shown in MessageLens do not match what you see in Messages or Contacts on your Mac. Resetting deletes imported message and contact data, keeps your preferences, and re-imports from your Mac the next time you open the app.',
            actions: [
              SidebarActionDescriptor(
                label: 'Cancel',
                intent: SettingsTransientActionCancelled(),
              ),
              SidebarActionDescriptor(
                label: 'Reset message data…',
                intent: ResetMessageDataRequested(),
                tone: SidebarActionTone.destructive,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      );

      expect(find.textContaining('keeps your preferences'), findsOneWidget);
      expect(find.text('Reset Message Data'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset message data…'), findsOneWidget);
    });
  });
}
