import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_recovery_hint_storage.dart';

void main() {
  group('AttachmentArchiveService.prioritizeRecovery', () {
    late OverlayDatabase overlayDb;
    late Directory tempDir;
    late ProviderContainer container;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp(
        'attachment-priority-test-',
      );
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: 'true',
      );

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          attachmentArchiveDirectoryProvider.overrideWith(
            (ref) => tempDir.path,
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'stores a recovery hint and archives immediately when source exists',
      () async {
        final sourceFile = File('${tempDir.path}/messages/recover-now.jpg');
        await sourceFile.parent.create(recursive: true);
        await sourceFile.writeAsString('recover-now');

        await container
            .read(attachmentArchiveServiceProvider.notifier)
            .prioritizeRecovery(
              messageGuid: 'm-recover-now',
              importAttachmentId: 99,
              resolvedLocalPath: sourceFile.path,
              mimeType: 'image/jpeg',
            );

        var archivedRow =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (t) =>
                      t.messageGuid.equals('m-recover-now') &
                      t.importAttachmentId.equals(99),
                ))
                .getSingleOrNull();

        for (var attempt = 0; attempt < 20 && archivedRow == null; attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          archivedRow =
              await (overlayDb.select(overlayDb.archivedAttachments)..where(
                    (t) =>
                        t.messageGuid.equals('m-recover-now') &
                        t.importAttachmentId.equals(99),
                  ))
                  .getSingleOrNull();
        }

        expect(archivedRow, isNotNull);
        expect(
          await overlayDb.readOverlaySetting(
            attachmentRecoveryHintSettingKey(
              messageGuid: 'm-recover-now',
              importAttachmentId: 99,
            ),
          ),
          isNull,
        );
      },
    );
  });
}
