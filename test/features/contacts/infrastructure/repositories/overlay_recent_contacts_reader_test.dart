import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/overlay_recent_contacts_reader.dart';

import '../../../../test_utils/contact_summary_fixture.dart';

void main() {
  group('OverlayRecentContactsReader', () {
    late OverlayDatabase overlayDb;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await overlayDb.close();
    });

    test(
      'deduplicates rowid-keyed and graph recents before limiting',
      () async {
        const rowidKeyedClaireId = 24;
        final graphClaireId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: rowidKeyedClaireId,
        );
        final graphBobId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: 25,
        );
        final graphAdaId = SourceScopedRowKey.pack(
          sourceId: liveAddressBookSourceId,
          sourceRowId: 26,
        );

        await overlayDb.addFavorite(
          rowidKeyedClaireId,
          DateTime.utc(2024, 12, 5),
        );
        await overlayDb.addFavorite(graphClaireId, DateTime.utc(2024, 12, 4));
        await overlayDb.addFavorite(graphBobId, DateTime.utc(2024, 12, 3));
        await overlayDb.addFavorite(graphAdaId, DateTime.utc(2024, 12, 2));

        final reader = OverlayRecentContactsReader(overlayDb: overlayDb);

        final recents = await reader.readRecentContacts(
          contacts: [
            buildContactSummary(
              participantId: graphClaireId,
              displayName: 'Claire',
            ),
            buildContactSummary(participantId: graphBobId, displayName: 'Bob'),
            buildContactSummary(participantId: graphAdaId, displayName: 'Ada'),
          ],
        );

        expect(recents.map((entry) => entry.participantId), [
          graphClaireId,
          graphBobId,
          graphAdaId,
        ]);
      },
    );
  });
}
