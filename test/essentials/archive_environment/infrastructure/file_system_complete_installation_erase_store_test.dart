import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure.dart';

void main() {
  late Directory sandbox;
  late Directory archiveRoot;
  late ArchiveAccessAuthority authority;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('complete-erase-test-');
    archiveRoot = Directory(path.join(sandbox.path, 'MessageLens'));
    await archiveRoot.create();
    authority = ArchiveAccessAuthority(
      identity: ResolvedArchiveIdentity(
        environment: ArchiveEnvironment.development,
        buildIdentity: ArchiveBuildIdentity.developmentDebug,
        archiveInstanceId: ArchiveInstanceId(
          '11111111-1111-4111-8111-111111111111',
        ),
        canonicalRootPath: archiveRoot.path,
        bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
        productName: 'MessageLens Development',
      ),
    );
    await FileSystemArchiveMarkerStore(
      rootPath: archiveRoot.path,
    ).createInitialMarker(
      ArchiveMarker(
        formatVersion: ArchiveMarker.currentFormatVersion,
        environment: authority.identity.environment,
        archiveInstanceId: authority.identity.archiveInstanceId,
        createdAtUtc: DateTime.utc(2026, 8, 1),
      ),
    );
  });

  tearDown(() async {
    if (sandbox.existsSync()) {
      await sandbox.delete(recursive: true);
    }
  });

  test(
    'erases every owned artifact and installs a new virgin identity',
    () async {
      final externalSource = File(path.join(sandbox.path, 'external-chat.db'));
      await externalSource.writeAsString('authoritative source bytes');
      final externalBefore = await externalSource.readAsBytes();

      for (final name in [
        'macos_import_ss.db',
        'working_ss.db',
        'user_overlays.db',
        'presence.db',
        'macos_import.db',
        'working.db',
        'import_log',
      ]) {
        await File(path.join(archiveRoot.path, name)).writeAsString(name);
      }
      await Directory(
        path.join(archiveRoot.path, 'attachment_archive', 'ab'),
      ).create(recursive: true);
      await File(
        path.join(archiveRoot.path, 'attachment_archive', 'ab', 'payload'),
      ).writeAsString('preservation payload');
      await File(
        path.join(archiveRoot.path, 'MessageLens.instance.lock'),
      ).writeAsString('live process lock');

      const store = FileSystemCompleteInstallationEraseStore();
      final transaction = CompleteInstallationEraseTransaction(
        formatVersion:
            CompleteInstallationEraseTransaction.currentFormatVersion,
        environment: ArchiveEnvironment.development,
        newArchiveInstanceId: ArchiveInstanceId(
          '22222222-2222-4222-8222-222222222222',
        ),
        createdAtUtc: DateTime.utc(2026, 8, 27),
      );
      await store.begin(authority: authority, transaction: transaction);
      await store.eraseOwnedState(authority: authority);
      await store.installVirginIdentity(
        authority: authority,
        transaction: transaction,
      );
      expect(
        File(
          path.join(
            archiveRoot.path,
            FileSystemCompleteInstallationEraseStore.transactionFileName,
          ),
        ).existsSync(),
        isTrue,
      );
      await store.complete(authority: authority);

      expect(await externalSource.readAsBytes(), externalBefore);
      expect(
        File(
          path.join(archiveRoot.path, 'MessageLens.instance.lock'),
        ).existsSync(),
        isTrue,
      );
      final marker = await FileSystemArchiveMarkerStore(
        rootPath: archiveRoot.path,
      ).read();
      expect(marker?.archiveInstanceId, transaction.newArchiveInstanceId);
      expect(
        File(
          path.join(
            archiveRoot.path,
            FileSystemCompleteInstallationEraseStore.transactionFileName,
          ),
        ).existsSync(),
        isFalse,
      );
      final names = await archiveRoot
          .list()
          .map((entity) => path.basename(entity.path))
          .toList();
      expect(names.toSet(), {
        'MessageLens.instance.lock',
        FileSystemArchiveMarkerStore.markerFileName,
      });
    },
  );

  test('refuses a symbolic link instead of following it', () async {
    final external = File(path.join(sandbox.path, 'external.txt'));
    await external.writeAsString('keep me');
    await Link(
      path.join(archiveRoot.path, 'unsafe-link'),
    ).create(external.path);
    const store = FileSystemCompleteInstallationEraseStore();

    await expectLater(
      store.eraseOwnedState(authority: authority),
      throwsA(isA<StateError>()),
    );
    expect(await external.readAsString(), 'keep me');
  });

  test('refuses an embedded Apple Messages source database', () async {
    final donor = Directory(path.join(archiveRoot.path, 'donor'));
    await donor.create();
    await File(path.join(donor.path, 'chat.db')).writeAsString('source');

    await expectLater(
      const FileSystemCompleteInstallationEraseStore().eraseOwnedState(
        authority: authority,
      ),
      throwsA(isA<StateError>()),
    );
    expect(File(path.join(donor.path, 'chat.db')).existsSync(), isTrue);
  });

  test('refuses dangerous filesystem roots before enumeration', () async {
    for (final dangerousRoot in <String>['/', '/Volumes']) {
      final unsafeAuthority = ArchiveAccessAuthority(
        identity: ResolvedArchiveIdentity(
          environment: ArchiveEnvironment.development,
          buildIdentity: ArchiveBuildIdentity.developmentDebug,
          archiveInstanceId: authority.identity.archiveInstanceId,
          canonicalRootPath: dangerousRoot,
          bundleIdentifier: authority.identity.bundleIdentifier,
          productName: authority.identity.productName,
        ),
      );
      await expectLater(
        const FileSystemCompleteInstallationEraseStore().eraseOwnedState(
          authority: unsafeAuthority,
        ),
        throwsA(isA<StateError>()),
      );
    }
  });

  test(
    'an interrupted erase converges using the durable transaction',
    () async {
      const store = FileSystemCompleteInstallationEraseStore();
      final transaction = CompleteInstallationEraseTransaction(
        formatVersion:
            CompleteInstallationEraseTransaction.currentFormatVersion,
        environment: ArchiveEnvironment.development,
        newArchiveInstanceId: ArchiveInstanceId(
          '33333333-3333-4333-8333-333333333333',
        ),
        createdAtUtc: DateTime.utc(2026, 8, 27),
      );
      await File(
        path.join(archiveRoot.path, 'legacy-cache'),
      ).writeAsString('obsolete');

      await store.begin(authority: authority, transaction: transaction);
      await store.eraseOwnedState(authority: authority);
      await store.installVirginIdentity(
        authority: authority,
        transaction: transaction,
      );

      final pending = await store.readPending(
        canonicalRootPath: archiveRoot.path,
      );
      expect(pending?.newArchiveInstanceId, transaction.newArchiveInstanceId);
      final recoveryAuthority = ArchiveAccessAuthority(
        identity: ResolvedArchiveIdentity(
          environment: authority.identity.environment,
          buildIdentity: authority.identity.buildIdentity,
          archiveInstanceId: transaction.newArchiveInstanceId,
          canonicalRootPath: authority.rootPath,
          bundleIdentifier: authority.identity.bundleIdentifier,
          productName: authority.identity.productName,
        ),
      );
      await store.eraseOwnedState(authority: recoveryAuthority);
      await store.installVirginIdentity(
        authority: recoveryAuthority,
        transaction: transaction,
      );
      await store.complete(authority: recoveryAuthority);

      expect(
        await FileSystemArchiveMarkerStore(rootPath: archiveRoot.path).read(),
        isNotNull,
      );
      expect(
        await store.readPending(canonicalRootPath: archiveRoot.path),
        isNull,
      );
    },
  );
}
