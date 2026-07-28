import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/archive_checkpoint_receipt.dart';
import '../infrastructure/file_system_archive_checkpoint_receipt_validator.dart';
import 'archive_checkpoint_receipt_validator.dart';

part 'verified_archive_checkpoint_provider.g.dart';

@Riverpod(keepAlive: true)
class VerifiedArchiveCheckpoint extends _$VerifiedArchiveCheckpoint {
  @override
  ArchiveCheckpointReceipt? build() => null;

  void record(ArchiveCheckpointReceipt receipt) {
    state = receipt;
  }

  void clear() {
    state = null;
  }
}

@riverpod
ArchiveCheckpointReceiptValidator archiveCheckpointReceiptValidator(Ref ref) {
  return const FileSystemArchiveCheckpointReceiptValidator();
}
