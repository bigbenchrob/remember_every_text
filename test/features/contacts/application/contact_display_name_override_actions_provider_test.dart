import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_display_name_override_actions_provider.dart';

void main() {
  group('ContactDisplayNameOverrideActions', () {
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
    });

    test(
      'sets user display-name override through the action boundary',
      () async {
        final graphContactId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: 24,
        );

        await container
            .read(contactDisplayNameOverrideActionsProvider.notifier)
            .setDisplayNameOverride(
              contactId: graphContactId,
              displayName: ' Claire ',
            );

        final rows = await overlayDb.getAllParticipantOverrides();

        expect(rows.map((row) => row.participantId), [graphContactId]);
        expect(rows.single.displayNameOverride, 'Claire');
      },
    );

    test(
      'clears user display-name override variants through action boundary',
      () async {
        const rowidKeyedContactId = 24;
        final graphContactId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: rowidKeyedContactId,
        );
        await overlayDb.setParticipantDisplayNameOverride(
          rowidKeyedContactId,
          'Rowid-keyed Claire',
        );
        await overlayDb.setParticipantDisplayNameOverride(
          graphContactId,
          'Graph Claire',
        );

        await container
            .read(contactDisplayNameOverrideActionsProvider.notifier)
            .setDisplayNameOverride(
              contactId: graphContactId,
              displayName: null,
            );

        final rows = await overlayDb.getAllParticipantOverrides();

        expect(rows, isEmpty);
      },
    );
  });
}
