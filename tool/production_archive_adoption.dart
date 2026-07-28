import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/application/archive_admission_service.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_access_authority.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_identity_validator.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/native_archive_claim.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/exact_canonical_archive_root_policy.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_checkpoint_service.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_marker_store.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_production_archive_adoption_service.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.contains('--help')) {
    _usage();
    return;
  }

  final command = arguments.first;
  final options = _parseOptions(arguments.skip(1).toList());
  const checkpointService = FileSystemArchiveCheckpointService();
  final adoptionService = FileSystemProductionArchiveAdoptionService(
    checkpointService: checkpointService,
  );

  switch (command) {
    case 'prepare':
      final manifest = await adoptionService.prepareCheckpoint(
        sourceRootPath: _required(options, 'source'),
        checkpointRootPath: _required(options, 'checkpoint'),
      );
      stdout.writeln(
        'Prepared ${manifest.checkpointId} for production archive '
        '${manifest.sourceArchiveInstanceId.value}.',
      );
      return;
    case 'inventory':
      final inventory = await adoptionService.prepareInventory(
        sourceRootPath: _required(options, 'source'),
        inventoryRootPath: _required(options, 'inventory'),
      );
      stdout.writeln(
        'Recorded ${inventory.inventoryId} for production archive '
        '${inventory.plannedArchiveInstanceId.value} without copying payload.',
      );
      return;
    case 'restore':
      final receipt = await checkpointService.restoreAndVerify(
        checkpointRootPath: _required(options, 'checkpoint'),
        disposableRestoreRootPath: _required(options, 'restore'),
      );
      stdout.writeln(
        'Restored and verified ${receipt.checkpointId} without adopting it.',
      );
      return;
    case 'adopt':
      final inventoryRoot = options['inventory'];
      final marker = inventoryRoot == null
          ? await adoptionService.adopt(
              rootPath: _required(options, 'root'),
              checkpointRootPath: _required(options, 'checkpoint'),
            )
          : await adoptionService.adoptFromInventory(
              rootPath: _required(options, 'root'),
              inventoryRootPath: inventoryRoot,
            );
      stdout.writeln(
        'Adopted production archive ${marker.archiveInstanceId.value}.',
      );
      return;
    case 'verify-admission':
      final authority = await _verifyProductionAdmission(
        _required(options, 'root'),
      );
      stdout.writeln(
        'Production admission verified for '
        '${authority.identity.archiveInstanceId.value}.',
      );
      return;
    case 'rollback':
      final inventoryRoot = options['inventory'];
      if (inventoryRoot == null) {
        await adoptionService.rollback(
          rootPath: _required(options, 'root'),
          checkpointRootPath: _required(options, 'checkpoint'),
        );
      } else {
        await adoptionService.rollbackFromInventory(
          rootPath: _required(options, 'root'),
          inventoryRootPath: inventoryRoot,
        );
      }
      stdout.writeln('Rolled back the unchanged production marker adoption.');
      return;
    case 'rehearse':
      await _rehearse(
        sourceRootPath: _required(options, 'source'),
        workRootPath: _required(options, 'work-root'),
        checkpointService: checkpointService,
        adoptionService: adoptionService,
      );
      return;
    default:
      _usage();
      stderr.writeln('Unknown adoption command: $command');
      exitCode = 64;
  }
}

Future<void> _rehearse({
  required String sourceRootPath,
  required String workRootPath,
  required FileSystemArchiveCheckpointService checkpointService,
  required FileSystemProductionArchiveAdoptionService adoptionService,
}) async {
  final workRoot = Directory(path.normalize(path.absolute(workRootPath)));
  if (workRoot.existsSync()) {
    throw StateError('Rehearsal work root already exists: ${workRoot.path}');
  }
  await workRoot.create(recursive: true);

  final checkpointPath = path.join(workRoot.path, 'checkpoint');
  final restorePath = path.join(workRoot.path, 'restore');
  final manifest = await adoptionService.prepareCheckpoint(
    sourceRootPath: sourceRootPath,
    checkpointRootPath: checkpointPath,
  );
  await checkpointService.restoreAndVerify(
    checkpointRootPath: checkpointPath,
    disposableRestoreRootPath: restorePath,
  );

  final sourceMarker = await FileSystemArchiveMarkerStore(
    rootPath: sourceRootPath,
  ).read();
  if (sourceMarker != null) {
    throw StateError('Rehearsal modified the unmarked source archive.');
  }

  await adoptionService.adopt(
    rootPath: restorePath,
    checkpointRootPath: checkpointPath,
  );
  final authority = await _verifyProductionAdmission(restorePath);
  if (authority.identity.archiveInstanceId !=
      manifest.sourceArchiveInstanceId) {
    throw StateError('Admitted identity does not match the adoption plan.');
  }

  await adoptionService.rollback(
    rootPath: restorePath,
    checkpointRootPath: checkpointPath,
  );
  final restoredMarker = await FileSystemArchiveMarkerStore(
    rootPath: restorePath,
  ).read();
  if (restoredMarker != null) {
    throw StateError('Rehearsal rollback left the archive marked.');
  }

  stdout.writeln(
    'Rehearsal passed for ${manifest.checkpointId}: checkpoint, restore, '
    'adoption, production admission, and unchanged-payload rollback.',
  );
  stdout.writeln('Disposable evidence retained at ${workRoot.path}.');
}

Future<ArchiveAccessAuthority> _verifyProductionAdmission(
  String rootPath,
) async {
  final canonicalRoot = Directory(
    path.normalize(path.absolute(rootPath)),
  ).resolveSymbolicLinksSync();
  final policy = ExactCanonicalArchiveRootPolicy(
    canonicalRoots: {ArchiveEnvironment.production: canonicalRoot},
    platformApplicationSupportRoot: path.dirname(canonicalRoot),
  );
  final service = ArchiveAdmissionService(
    validator: ArchiveIdentityValidator(rootPolicy: policy),
    markerStore: FileSystemArchiveMarkerStore(rootPath: canonicalRoot),
  );
  return service.admit(
    NativeArchiveClaim(
      environment: ArchiveEnvironment.production,
      buildIdentity: ArchiveBuildIdentity.productionRelease,
      bundleIdentifier:
          ArchiveIdentityValidator.defaultProductionBundleIdentifier,
      productName: ArchiveIdentityValidator.defaultProductionProductName,
      canonicalRootPath: canonicalRoot,
      productionSignatureIsValid: true,
    ),
  );
}

Map<String, String> _parseOptions(List<String> arguments) {
  final result = <String, String>{};
  for (var index = 0; index < arguments.length; index += 2) {
    final key = arguments[index];
    if (!key.startsWith('--') || index + 1 >= arguments.length) {
      throw const FormatException(
        'Adoption options must use --name value pairs.',
      );
    }
    result[key.substring(2)] = arguments[index + 1];
  }
  return result;
}

String _required(Map<String, String> options, String name) {
  final value = options[name];
  if (value == null || value.isEmpty) {
    throw FormatException('Missing required option --$name.');
  }
  return value;
}

void _usage() {
  stdout.writeln(r'''
Explicit production archive adoption tool

Record a read-only in-place adoption inventory:
  dart run tool/production_archive_adoption.dart inventory \
    --source <unmarked-archive-root> \
    --inventory <new-inventory-root>

Prepare an offline unmarked archive checkpoint:
  dart run tool/production_archive_adoption.dart prepare \
    --source <unmarked-archive-root> \
    --checkpoint <new-checkpoint-root>

Restore without adopting:
  dart run tool/production_archive_adoption.dart restore \
    --checkpoint <checkpoint-root> \
    --restore <new-disposable-root>

Adopt a matching offline root:
  dart run tool/production_archive_adoption.dart adopt \
    --root <archive-root> \
    --inventory <inventory-root>

Verify production admission:
  dart run tool/production_archive_adoption.dart verify-admission \
    --root <adopted-archive-root>

Rollback only when the payload has not changed:
  dart run tool/production_archive_adoption.dart rollback \
    --root <adopted-archive-root> \
    --inventory <inventory-root>

Run the full disposable marker lifecycle:
  dart run tool/production_archive_adoption.dart rehearse \
    --source <unmarked-representative-root> \
    --work-root <new-work-root>

The tool never launches MessageLens. Ordinary application startup cannot adopt
an unmarked production archive. The checkpoint commands remain available for
disposable recovery rehearsals; inventory records in-place adoption evidence
and does not copy archive payload.
''');
}
