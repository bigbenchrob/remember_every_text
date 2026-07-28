import '../domain/archive_checkpoint_manifest.dart';
import '../domain/archive_checkpoint_receipt.dart';

abstract interface class ArchiveCheckpointService {
  Future<ArchiveCheckpointManifest> createOfflineCheckpoint({
    required String sourceRootPath,
    required String checkpointRootPath,
  });

  Future<ArchiveCheckpointReceipt> restoreAndVerify({
    required String checkpointRootPath,
    required String disposableRestoreRootPath,
  });

  Future<bool> checkpointStillMatchesSource(ArchiveCheckpointReceipt receipt);
}
