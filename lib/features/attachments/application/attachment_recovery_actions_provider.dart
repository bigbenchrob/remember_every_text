import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'archive_compatibility_key.dart';
import 'attachment_archive_service_provider.dart';

part 'attachment_recovery_actions_provider.g.dart';

@riverpod
class AttachmentRecoveryActions extends _$AttachmentRecoveryActions {
  @override
  FutureOr<void> build() {}

  Future<void> prioritizeRecovery({
    required ArchiveCompatibilityKey archiveKey,
    required String? resolvedLocalPath,
    required String? mimeType,
  }) async {
    await ref
        .read(attachmentArchiveServiceProvider.notifier)
        .prioritizeRecovery(
          archiveKey: archiveKey,
          resolvedLocalPath: resolvedLocalPath,
          mimeType: mimeType,
        );
  }
}
