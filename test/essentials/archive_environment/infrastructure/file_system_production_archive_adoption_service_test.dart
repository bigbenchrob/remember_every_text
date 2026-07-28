import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/application/archive_admission_service.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory workRoot;
  late Directory sourceRoot;
  late FileSystemProductionArchiveAdoptionService adoptionService;
  const checkpointService = FileSystemArchiveCheckpointService();

  setUp(() async {
    workRoot = await Directory.systemTemp.createTemp(
      'production_adoption_work_',
    );
    sourceRoot = Directory(path.join(workRoot.path, 'unmarked-source'));
    await sourceRoot.create();
    final database = sqlite3.open(path.join(sourceRoot.path, 'working_ss.db'));
    try {
      database.execute(
        'CREATE TABLE evidence (id INTEGER PRIMARY KEY, body TEXT)',
      );
      database.execute("INSERT INTO evidence (body) VALUES ('preserved')");
    } finally {
      database.dispose();
    }
    final attachment = File(
      path.join(sourceRoot.path, 'attachment_archive', 'photo.bin'),
    );
    await attachment.create(recursive: true);
    await attachment.writeAsBytes(<int>[1, 2, 3, 4]);
    adoptionService = FileSystemProductionArchiveAdoptionService(
      checkpointService: checkpointService,
      currentTime: () => DateTime.utc(2026, 7, 27, 18),
    );
  });

  tearDown(() async {
    if (workRoot.existsSync()) {
      await workRoot.delete(recursive: true);
    }
  });

  test(
    'checkpoints, restores, adopts, admits, and rolls back a disposable clone',
    () async {
      final checkpointRoot = path.join(workRoot.path, 'checkpoint');
      final restoreRoot = path.join(workRoot.path, 'restore');

      final manifest = await adoptionService.prepareCheckpoint(
        sourceRootPath: sourceRoot.path,
        checkpointRootPath: checkpointRoot,
      );
      expect(manifest.archiveMarkerIncluded, isFalse);
      expect(await _markerAt(sourceRoot.path), isNull);
      expect(await _markerAt(checkpointRoot), isNull);

      await checkpointService.restoreAndVerify(
        checkpointRootPath: checkpointRoot,
        disposableRestoreRootPath: restoreRoot,
      );
      expect(await _markerAt(restoreRoot), isNull);

      final marker = await adoptionService.adopt(
        rootPath: restoreRoot,
        checkpointRootPath: checkpointRoot,
      );
      expect(marker.archiveInstanceId, manifest.sourceArchiveInstanceId);

      final authority = await _admitProduction(restoreRoot);
      expect(
        authority.identity.archiveInstanceId,
        manifest.sourceArchiveInstanceId,
      );

      await adoptionService.rollback(
        rootPath: restoreRoot,
        checkpointRootPath: checkpointRoot,
      );
      expect(await _markerAt(restoreRoot), isNull);
      expect(await _markerAt(sourceRoot.path), isNull);
    },
  );

  test('rollback refuses a payload changed after adoption', () async {
    final checkpointRoot = path.join(workRoot.path, 'checkpoint');
    final restoreRoot = path.join(workRoot.path, 'restore');
    await adoptionService.prepareCheckpoint(
      sourceRootPath: sourceRoot.path,
      checkpointRootPath: checkpointRoot,
    );
    await checkpointService.restoreAndVerify(
      checkpointRootPath: checkpointRoot,
      disposableRestoreRootPath: restoreRoot,
    );
    await adoptionService.adopt(
      rootPath: restoreRoot,
      checkpointRootPath: checkpointRoot,
    );
    await File(
      path.join(restoreRoot, 'attachment_archive', 'photo.bin'),
    ).writeAsBytes(<int>[9]);

    await expectLater(
      adoptionService.rollback(
        rootPath: restoreRoot,
        checkpointRootPath: checkpointRoot,
      ),
      throwsA(isA<ArchiveCheckpointException>()),
    );
    expect(await _markerAt(restoreRoot), isNotNull);
  });

  test(
    'inventory records source without copying payload and supports adoption',
    () async {
      final inventoryRoot = path.join(workRoot.path, 'adoption-inventory');
      final inventory = await adoptionService.prepareInventory(
        sourceRootPath: sourceRoot.path,
        inventoryRootPath: inventoryRoot,
      );

      expect(inventory.files, hasLength(2));
      expect(inventory.totalBytes, greaterThan(0));
      expect(await _markerAt(sourceRoot.path), isNull);
      expect(
        Directory(inventoryRoot)
            .listSync(recursive: true)
            .whereType<File>()
            .map((file) => path.basename(file.path))
            .toList(),
        <String>[
          FileSystemProductionArchiveAdoptionInventoryService.manifestFileName,
        ],
      );

      final marker = await adoptionService.adoptFromInventory(
        rootPath: sourceRoot.path,
        inventoryRootPath: inventoryRoot,
      );
      expect(marker.archiveInstanceId, inventory.plannedArchiveInstanceId);

      await adoptionService.rollbackFromInventory(
        rootPath: sourceRoot.path,
        inventoryRootPath: inventoryRoot,
      );
      expect(await _markerAt(sourceRoot.path), isNull);
      expect(
        File(
          path.join(sourceRoot.path, 'attachment_archive', 'photo.bin'),
        ).readAsBytesSync(),
        <int>[1, 2, 3, 4],
      );
    },
  );

  test(
    'inventory adoption refuses a source changed after inspection',
    () async {
      final inventoryRoot = path.join(workRoot.path, 'adoption-inventory');
      await adoptionService.prepareInventory(
        sourceRootPath: sourceRoot.path,
        inventoryRootPath: inventoryRoot,
      );
      await File(
        path.join(sourceRoot.path, 'attachment_archive', 'photo.bin'),
      ).writeAsBytes(<int>[9]);

      await expectLater(
        adoptionService.adoptFromInventory(
          rootPath: sourceRoot.path,
          inventoryRootPath: inventoryRoot,
        ),
        throwsA(isA<ArchiveCheckpointException>()),
      );
      expect(await _markerAt(sourceRoot.path), isNull);
    },
  );
}

Future<ArchiveMarker?> _markerAt(String rootPath) {
  return FileSystemArchiveMarkerStore(rootPath: rootPath).read();
}

Future<ArchiveAccessAuthority> _admitProduction(String rootPath) {
  final policy = ExactCanonicalArchiveRootPolicy(
    canonicalRoots: {ArchiveEnvironment.production: rootPath},
    platformApplicationSupportRoot: path.dirname(rootPath),
  );
  return ArchiveAdmissionService(
    validator: ArchiveIdentityValidator(rootPolicy: policy),
    markerStore: FileSystemArchiveMarkerStore(rootPath: rootPath),
  ).admit(
    NativeArchiveClaim(
      environment: ArchiveEnvironment.production,
      buildIdentity: ArchiveBuildIdentity.productionRelease,
      bundleIdentifier:
          ArchiveIdentityValidator.defaultProductionBundleIdentifier,
      productName: ArchiveIdentityValidator.defaultProductionProductName,
      canonicalRootPath: rootPath,
      productionSignatureIsValid: true,
    ),
  );
}
