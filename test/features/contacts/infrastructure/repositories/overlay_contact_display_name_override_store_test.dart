import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/overlay_contact_display_name_override_store.dart';

void main() {
  group('OverlayContactDisplayNameOverrideStore', () {
    late OverlayDatabase overlayDb;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await overlayDb.close();
    });

    test('rewrites retained display override to graph contact key', () async {
      const retainedContactId = 24;
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: retainedContactId,
      );
      await overlayDb.setParticipantDisplayNameOverride(
        retainedContactId,
        'Old Claire',
      );

      final store = OverlayContactDisplayNameOverrideStore(
        overlayDatabase: overlayDb,
      );

      await store.setDisplayNameOverride(
        contactId: graphContactId,
        displayName: 'Claire',
      );

      final rows = await overlayDb.getAllParticipantOverrides();

      expect(rows.map((row) => row.participantId), [graphContactId]);
      expect(rows.single.displayNameOverride, 'Claire');
    });

    test('clears retained and graph display override variants', () async {
      const retainedContactId = 24;
      final graphContactId = SourceScopedRowKey.pack(
        sourceId: liveAddressBookSourceId,
        sourceRowId: retainedContactId,
      );
      await overlayDb.setParticipantDisplayNameOverride(
        retainedContactId,
        'Retained Claire',
      );
      await overlayDb.setParticipantDisplayNameOverride(
        graphContactId,
        'Graph Claire',
      );

      final store = OverlayContactDisplayNameOverrideStore(
        overlayDatabase: overlayDb,
      );

      await store.setDisplayNameOverride(
        contactId: graphContactId,
        displayName: null,
      );

      final rows = await overlayDb.getAllParticipantOverrides();

      expect(rows, isEmpty);
    });
  });
}
