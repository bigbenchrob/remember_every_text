import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_recovery_hint_storage.dart';
import 'package:remember_this_text/features/attachments/application/attachment_resolver_provider.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_provenance.dart';
import 'package:remember_this_text/features/attachments/domain/constants/resolved_attachment_availability.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_recovery_metadata.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';

void main() {
  group('attachmentResolverProvider', () {
    late OverlayDatabase overlayDb;
    late Directory tempDir;
    ProviderContainer? container;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp(
        'attachment-resolver-test-',
      );
    });

    tearDown(() async {
      container?.dispose();
      await overlayDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<ProviderContainer> createContainer({
      required bool archiveEnabled,
    }) async {
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: archiveEnabled.toString(),
      );

      return ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          attachmentArchiveDirectoryProvider.overrideWith(
            (ref) => tempDir.path,
          ),
        ],
      );
    }

    test('archive disabled resolves live file directly', () async {
      final liveFile = File('${tempDir.path}/messages/photo.jpg');
      await liveFile.parent.create(recursive: true);
      await liveFile.writeAsString('live');

      container = await createContainer(archiveEnabled: false);

      final result = await container!.read(
        attachmentResolverProvider(
          AttachmentInfo(
            id: 1,
            localPath: liveFile.path,
            mimeType: 'image/jpeg',
            transferName: 'photo.jpg',
          ),
          messageGuid: 'm1',
          importAttachmentId: 11,
        ).future,
      );

      expect(result.availability, ResolvedAttachmentAvailability.available);
      expect(result.provenance, AttachmentProvenance.messagesLive);
      expect(result.resolvedFile?.path, liveFile.path);
    });

    test('archive enabled resolves archived file first', () async {
      final archiveFile = File('${tempDir.path}/ab/hash.jpg');
      await archiveFile.parent.create(recursive: true);
      await archiveFile.writeAsString('archived');

      await overlayDb
          .into(overlayDb.archivedAttachments)
          .insert(
            ArchivedAttachmentsCompanion.insert(
              messageGuid: 'm2',
              importAttachmentId: 22,
              archiveRelativePath: 'ab/hash.jpg',
              archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
              fileSizeBytes: await archiveFile.length(),
              contentHash: const drift.Value('hash'),
              originalLocalPath: const drift.Value('/tmp/missing.jpg'),
            ),
          );

      container = await createContainer(archiveEnabled: true);

      final result = await container!.read(
        attachmentResolverProvider(
          const AttachmentInfo(
            id: 2,
            localPath: '/tmp/does-not-exist.jpg',
            mimeType: 'image/jpeg',
            transferName: 'archived.jpg',
          ),
          messageGuid: 'm2',
          importAttachmentId: 22,
        ).future,
      );

      expect(result.availability, ResolvedAttachmentAvailability.available);
      expect(result.provenance, AttachmentProvenance.archived);
      expect(result.resolvedFile?.path, archiveFile.path);
    });

    test(
      'archive enabled reports pending when live file exists but archive does not',
      () async {
        final liveFile = File('${tempDir.path}/messages/pending.png');
        await liveFile.parent.create(recursive: true);
        await liveFile.writeAsString('pending');

        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            AttachmentInfo(
              id: 3,
              localPath: liveFile.path,
              mimeType: 'image/png',
              transferName: 'pending.png',
            ),
            messageGuid: 'm3',
            importAttachmentId: 33,
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.pendingArchive,
        );
        expect(result.resolvedFile, isNull);
        expect(result.recoveryMetadata?.recoveryPriority, 1);

        var archiveCreated = false;
        for (var attempt = 0; attempt < 20; attempt++) {
          final archivedRow =
              await (overlayDb.select(overlayDb.archivedAttachments)..where(
                    (t) =>
                        t.messageGuid.equals('m3') &
                        t.importAttachmentId.equals(33),
                  ))
                  .getSingleOrNull();
          if (archivedRow != null) {
            archiveCreated = true;
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }

        expect(archiveCreated, isTrue);
      },
    );

    test(
      'archive enabled reports unavailable awaiting recovery when no file is available',
      () async {
        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            const AttachmentInfo(
              id: 4,
              localPath: '/tmp/evicted.mov',
              mimeType: 'video/quicktime',
              transferName: 'evicted.mov',
            ),
            messageGuid: 'm4',
            importAttachmentId: 44,
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
        );
        expect(result.recoveryMetadata?.isNonRecoverable, isFalse);
        expect(result.resolvedFile, isNull);
      },
    );

    test(
      'archive enabled merges stored user-interest recovery hint into unresolved metadata',
      () async {
        const userInterestRaisedAt = '2026-04-05T12:34:56.000Z';
        final expectedUserInterestRaisedAt = DateTime.parse(
          userInterestRaisedAt,
        ).toUtc();

        await overlayDb.writeOverlaySetting(
          settingKey: attachmentRecoveryHintSettingKey(
            messageGuid: 'm-priority',
            importAttachmentId: 55,
          ),
          settingValue: encodeAttachmentRecoveryHint(
            AttachmentRecoveryMetadata(
              recoveryPriority: 10,
              userInterestRaisedAt: expectedUserInterestRaisedAt,
            ),
          ),
        );

        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            const AttachmentInfo(
              id: 6,
              localPath: '/tmp/missing-priority.jpg',
              mimeType: 'image/jpeg',
              transferName: 'missing-priority.jpg',
            ),
            messageGuid: 'm-priority',
            importAttachmentId: 55,
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
        );
        expect(result.recoveryMetadata?.recoveryPriority, 10);
        expect(
          result.recoveryMetadata?.userInterestRaisedAt,
          expectedUserInterestRaisedAt,
        );
      },
    );

    test(
      'archive enabled reports non-recoverable when no live path or archive key exists',
      () async {
        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            const AttachmentInfo(
              id: 5,
              localPath: null,
              mimeType: 'application/octet-stream',
              transferName: 'unknown.bin',
            ),
            messageGuid: 'm5',
            importAttachmentId: null,
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.nonRecoverable,
        );
        expect(result.recoveryMetadata?.isNonRecoverable, isTrue);
      },
    );
  });
}
