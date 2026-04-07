import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/reimport_data_info_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/send_logs_info_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/actions_info_resolver.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolvers/reimport_data_info_resolver.dart';

void main() {
  group('Contacts settings info payload resolvers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('send logs resolver returns inert feature-info payload', () {
      final payload = container
          .read(actionsInfoResolverProvider.notifier)
          .resolve(cassetteIndex: 0);

      expect(payload, isA<SendLogsInfoCassettePayload>());
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      expect(payload.role, SidebarCassetteRole.action);
    });

    test('reimport data resolver returns inert feature-info payload', () {
      final payload = container
          .read(reimportDataInfoResolverProvider.notifier)
          .resolve(cassetteIndex: 0);

      expect(payload, isA<ReimportDataInfoCassettePayload>());
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      expect(payload.role, SidebarCassetteRole.action);
    });

    test('attachment archive resolver returns inert feature-info payload', () {
      final payload = container
          .read(attachmentArchiveSettingsResolverProvider.notifier)
          .resolve(cassetteIndex: 0);

      expect(payload, isA<AttachmentArchiveSettingsCassettePayload>());
      expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      expect(payload.role, SidebarCassetteRole.action);
    });
  });
}
