import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/send_logs_info_cassette_payload.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/messages_heatmap_cassette_payload.dart';

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
        const SendLogsInfoCassettePayload().renderKind,
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
  });
}
