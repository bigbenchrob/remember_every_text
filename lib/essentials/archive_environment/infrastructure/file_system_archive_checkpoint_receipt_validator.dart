import '../application/archive_checkpoint_receipt_validator.dart';
import '../domain/archive_access_authority.dart';
import '../domain/archive_checkpoint_receipt.dart';
import 'file_system_archive_checkpoint_service.dart';

final class FileSystemArchiveCheckpointReceiptValidator
    implements ArchiveCheckpointReceiptValidator {
  const FileSystemArchiveCheckpointReceiptValidator({
    this.checkpointService = const FileSystemArchiveCheckpointService(),
  });

  final FileSystemArchiveCheckpointService checkpointService;

  @override
  Future<bool> validates({
    required ArchiveCheckpointReceipt receipt,
    required ArchiveAccessAuthority authority,
  }) async {
    return receipt.matches(authority) &&
        await checkpointService.checkpointStillMatchesSource(receipt);
  }
}
