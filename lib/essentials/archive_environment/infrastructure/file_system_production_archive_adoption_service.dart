import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../domain/archive_checkpoint_exception.dart';
import '../domain/archive_checkpoint_manifest.dart';
import '../domain/archive_environment.dart';
import '../domain/archive_instance_id.dart';
import '../domain/archive_marker.dart';
import '../domain/production_archive_adoption_inventory.dart';
import 'file_system_archive_checkpoint_service.dart';
import 'file_system_archive_marker_store.dart';
import 'file_system_production_archive_adoption_inventory_service.dart';

/// Explicit filesystem workflow for adopting an existing unmarked production
/// archive. Ordinary application startup never invokes this service.
final class FileSystemProductionArchiveAdoptionService {
  FileSystemProductionArchiveAdoptionService({
    FileSystemArchiveCheckpointService checkpointService =
        const FileSystemArchiveCheckpointService(),
    FileSystemProductionArchiveAdoptionInventoryService inventoryService =
        const FileSystemProductionArchiveAdoptionInventoryService(),
    Uuid uuid = const Uuid(),
    DateTime Function()? currentTime,
  }) : _checkpointService = checkpointService,
       _inventoryService = inventoryService,
       _uuid = uuid,
       _currentTime = currentTime ?? DateTime.now;

  final FileSystemArchiveCheckpointService _checkpointService;
  final FileSystemProductionArchiveAdoptionInventoryService _inventoryService;
  final Uuid _uuid;
  final DateTime Function() _currentTime;

  Future<ArchiveCheckpointManifest> prepareCheckpoint({
    required String sourceRootPath,
    required String checkpointRootPath,
  }) {
    final plannedMarker = ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: ArchiveEnvironment.production,
      archiveInstanceId: ArchiveInstanceId(_uuid.v4()),
      createdAtUtc: _currentTime().toUtc(),
    );
    return _checkpointService.createProductionAdoptionCheckpoint(
      sourceRootPath: sourceRootPath,
      checkpointRootPath: checkpointRootPath,
      plannedMarker: plannedMarker,
    );
  }

  /// Records the unchanged source archive and planned production identity
  /// without copying archive payload.
  Future<ProductionArchiveAdoptionInventory> prepareInventory({
    required String sourceRootPath,
    required String inventoryRootPath,
  }) {
    final plannedMarker = ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: ArchiveEnvironment.production,
      archiveInstanceId: ArchiveInstanceId(_uuid.v4()),
      createdAtUtc: _currentTime().toUtc(),
    );
    return _inventoryService.create(
      sourceRootPath: sourceRootPath,
      inventoryRootPath: inventoryRootPath,
      plannedMarker: plannedMarker,
    );
  }

  Future<ArchiveMarker> adoptFromInventory({
    required String rootPath,
    required String inventoryRootPath,
  }) async {
    final inventory = await _requireAdoptionInventory(inventoryRootPath);
    final markerStore = FileSystemArchiveMarkerStore(rootPath: rootPath);
    if (await markerStore.read() != null) {
      throw const ArchiveCheckpointException(
        'Production adoption refuses an archive that is already marked.',
      );
    }
    if (!await _inventoryService.inventoryMatchesTarget(
      inventoryRootPath: inventoryRootPath,
      targetRootPath: rootPath,
      allowPlannedMarker: false,
    )) {
      throw const ArchiveCheckpointException(
        'Production adoption target no longer matches its verified inventory.',
      );
    }

    final marker = _markerForInventory(inventory);
    await markerStore.createInitialMarker(marker);
    return marker;
  }

  Future<void> rollbackFromInventory({
    required String rootPath,
    required String inventoryRootPath,
  }) async {
    final inventory = await _requireAdoptionInventory(inventoryRootPath);
    final markerStore = FileSystemArchiveMarkerStore(rootPath: rootPath);
    final marker = await markerStore.read();
    final expectedMarker = _markerForInventory(inventory);
    if (!_sameMarker(marker, expectedMarker)) {
      throw const ArchiveCheckpointException(
        'Rollback refuses a missing or unexpected production marker.',
      );
    }
    if (!await _inventoryService.inventoryMatchesTarget(
      inventoryRootPath: inventoryRootPath,
      targetRootPath: rootPath,
      allowPlannedMarker: true,
    )) {
      throw const ArchiveCheckpointException(
        'Rollback refuses an archive whose payload changed after adoption.',
      );
    }

    await File(
      path.join(rootPath, FileSystemArchiveMarkerStore.markerFileName),
    ).delete();
  }

  Future<ArchiveMarker> adopt({
    required String rootPath,
    required String checkpointRootPath,
  }) async {
    final manifest = await _requireAdoptionManifest(checkpointRootPath);
    final markerStore = FileSystemArchiveMarkerStore(rootPath: rootPath);
    if (await markerStore.read() != null) {
      throw const ArchiveCheckpointException(
        'Production adoption refuses an archive that is already marked.',
      );
    }
    if (!await _checkpointService.adoptionCheckpointMatchesTarget(
      checkpointRootPath: checkpointRootPath,
      targetRootPath: rootPath,
      allowPlannedMarker: false,
    )) {
      throw const ArchiveCheckpointException(
        'Production adoption target no longer matches its verified checkpoint.',
      );
    }

    final marker = _markerFor(manifest);
    await markerStore.createInitialMarker(marker);
    return marker;
  }

  Future<void> rollback({
    required String rootPath,
    required String checkpointRootPath,
  }) async {
    final manifest = await _requireAdoptionManifest(checkpointRootPath);
    final markerStore = FileSystemArchiveMarkerStore(rootPath: rootPath);
    final marker = await markerStore.read();
    final expectedMarker = _markerFor(manifest);
    if (!_sameMarker(marker, expectedMarker)) {
      throw const ArchiveCheckpointException(
        'Rollback refuses a missing or unexpected production marker.',
      );
    }
    if (!await _checkpointService.adoptionCheckpointMatchesTarget(
      checkpointRootPath: checkpointRootPath,
      targetRootPath: rootPath,
      allowPlannedMarker: true,
    )) {
      throw const ArchiveCheckpointException(
        'Rollback refuses an archive whose payload changed after adoption.',
      );
    }

    final markerFile = File(
      path.join(rootPath, FileSystemArchiveMarkerStore.markerFileName),
    );
    await markerFile.delete();
  }

  Future<ArchiveCheckpointManifest> _requireAdoptionManifest(
    String checkpointRootPath,
  ) async {
    final manifest = await _checkpointService.readAndVerifyCheckpoint(
      checkpointRootPath,
    );
    if (manifest.sourceEnvironment != ArchiveEnvironment.production ||
        manifest.archiveMarkerIncluded) {
      throw const ArchiveCheckpointException(
        'Checkpoint is not an unmarked production-adoption checkpoint.',
      );
    }
    return manifest;
  }

  Future<ProductionArchiveAdoptionInventory> _requireAdoptionInventory(
    String inventoryRootPath,
  ) async {
    final inventory = await _inventoryService.read(inventoryRootPath);
    if (inventory.sourceEnvironment != ArchiveEnvironment.production) {
      throw const ArchiveCheckpointException(
        'Inventory is not a production archive adoption inventory.',
      );
    }
    return inventory;
  }

  ArchiveMarker _markerFor(ArchiveCheckpointManifest manifest) {
    return ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: ArchiveEnvironment.production,
      archiveInstanceId: manifest.sourceArchiveInstanceId,
      createdAtUtc: manifest.createdAtUtc,
    );
  }

  ArchiveMarker _markerForInventory(
    ProductionArchiveAdoptionInventory inventory,
  ) {
    return ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: ArchiveEnvironment.production,
      archiveInstanceId: inventory.plannedArchiveInstanceId,
      createdAtUtc: inventory.createdAtUtc,
    );
  }

  bool _sameMarker(ArchiveMarker? actual, ArchiveMarker expected) {
    return actual != null &&
        actual.formatVersion == expected.formatVersion &&
        actual.environment == expected.environment &&
        actual.archiveInstanceId == expected.archiveInstanceId &&
        actual.createdAtUtc == expected.createdAtUtc;
  }
}
