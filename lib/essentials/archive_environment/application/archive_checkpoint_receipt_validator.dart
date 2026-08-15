import '../domain/archive_access_authority.dart';
import '../domain/archive_checkpoint_receipt.dart';

abstract interface class ArchiveCheckpointReceiptValidator {
  Future<bool> validates({
    required ArchiveCheckpointReceipt receipt,
    required ArchiveAccessAuthority authority,
  });
}
