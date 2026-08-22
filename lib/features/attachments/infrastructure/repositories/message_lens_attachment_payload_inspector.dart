import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../../application/verified_donor_attachment_payload.dart';
import '../../domain/entities/message_lens_attachment_recovery.dart';

class _FilesystemVerifiedDonorAttachmentPayload
    implements VerifiedDonorAttachmentPayload {
  const _FilesystemVerifiedDonorAttachmentPayload({
    required this.archiveRelativePath,
    required this.sourceExtension,
    required this.expectedSizeBytes,
    required this.expectedSha256,
    required String absolutePath,
  }) : _absolutePath = absolutePath;

  @override
  final String archiveRelativePath;

  @override
  final String sourceExtension;

  @override
  final int expectedSizeBytes;

  @override
  final String expectedSha256;

  final String _absolutePath;

  @override
  Stream<List<int>> openRead() => File(_absolutePath).openRead();
}

class VerifiedDonorAttachmentPayloadResult {
  const VerifiedDonorAttachmentPayloadResult({
    required this.inspection,
    required this.payload,
  });

  final AttachmentPayloadInspection inspection;
  final VerifiedDonorAttachmentPayload? payload;
}

/// Read-only validation of a payload recorded inside a donor MessageLens
/// archive. It does not create directories, normalize the donor, or copy data.
class MessageLensAttachmentPayloadInspector {
  const MessageLensAttachmentPayloadInspector();

  Future<AttachmentPayloadInspection> inspect({
    required String donorArchiveRoot,
    required MessageLensArchivedPayloadEvidence payload,
  }) async {
    return (await inspectVerified(
      donorArchiveRoot: donorArchiveRoot,
      payload: payload,
    )).inspection;
  }

  Future<VerifiedDonorAttachmentPayloadResult> inspectVerified({
    required String donorArchiveRoot,
    required MessageLensArchivedPayloadEvidence payload,
  }) async {
    if (!_lexicalPathIsSafe(
      donorArchiveRoot: donorArchiveRoot,
      relativePath: payload.archiveRelativePath,
    )) {
      return const VerifiedDonorAttachmentPayloadResult(
        inspection: AttachmentPayloadInspection.unsafePath(),
        payload: null,
      );
    }

    final absoluteDonorRoot = path.normalize(path.absolute(donorArchiveRoot));
    final payloadRoot = path.normalize(
      path.join(absoluteDonorRoot, 'attachment_archive'),
    );
    if (_isLink(absoluteDonorRoot) || _isLink(payloadRoot)) {
      return const VerifiedDonorAttachmentPayloadResult(
        inspection: AttachmentPayloadInspection.unsafePath(),
        payload: null,
      );
    }

    final candidatePath = path.normalize(
      path.join(payloadRoot, payload.archiveRelativePath),
    );
    var cursor = payloadRoot;
    for (final component in path.split(payload.archiveRelativePath)) {
      cursor = path.join(cursor, component);
      if (_isLink(cursor)) {
        return const VerifiedDonorAttachmentPayloadResult(
          inspection: AttachmentPayloadInspection.unsafePath(),
          payload: null,
        );
      }
    }

    if (FileSystemEntity.typeSync(candidatePath, followLinks: false) !=
        FileSystemEntityType.file) {
      return const VerifiedDonorAttachmentPayloadResult(
        inspection: AttachmentPayloadInspection.missing(),
        payload: null,
      );
    }

    try {
      final resolvedRoot = await Directory(payloadRoot).resolveSymbolicLinks();
      final resolvedFile = await File(candidatePath).resolveSymbolicLinks();
      if (!path.isWithin(resolvedRoot, resolvedFile)) {
        return const VerifiedDonorAttachmentPayloadResult(
          inspection: AttachmentPayloadInspection.unsafePath(),
          payload: null,
        );
      }
    } on FileSystemException {
      return const VerifiedDonorAttachmentPayloadResult(
        inspection: AttachmentPayloadInspection(
          status: AttachmentPayloadInspectionStatus.invalid,
          actualSizeBytes: null,
          actualSha256: null,
        ),
        payload: null,
      );
    }

    final file = File(candidatePath);
    try {
      final actualSize = await file.length();
      final actualHash = (await sha256.bind(file.openRead()).first).toString();
      final expectedHash = payload.recordedSha256?.trim().toLowerCase();
      final sizeMatches = actualSize == payload.recordedSizeBytes;
      final hashMatches =
          expectedHash == null ||
          expectedHash.isEmpty ||
          actualHash == expectedHash;
      final inspection = AttachmentPayloadInspection(
        status: sizeMatches && hashMatches
            ? AttachmentPayloadInspectionStatus.valid
            : AttachmentPayloadInspectionStatus.invalid,
        actualSizeBytes: actualSize,
        actualSha256: actualHash,
      );
      return VerifiedDonorAttachmentPayloadResult(
        inspection: inspection,
        payload: inspection.status == AttachmentPayloadInspectionStatus.valid
            ? _FilesystemVerifiedDonorAttachmentPayload(
                archiveRelativePath: payload.archiveRelativePath,
                sourceExtension: path.extension(candidatePath),
                expectedSizeBytes: actualSize,
                expectedSha256: actualHash,
                absolutePath: candidatePath,
              )
            : null,
      );
    } on FileSystemException {
      return const VerifiedDonorAttachmentPayloadResult(
        inspection: AttachmentPayloadInspection(
          status: AttachmentPayloadInspectionStatus.invalid,
          actualSizeBytes: null,
          actualSha256: null,
        ),
        payload: null,
      );
    }
  }

  static bool _lexicalPathIsSafe({
    required String donorArchiveRoot,
    required String relativePath,
  }) {
    if (donorArchiveRoot.trim().isEmpty ||
        relativePath.trim().isEmpty ||
        path.isAbsolute(relativePath)) {
      return false;
    }
    final payloadRoot = path.normalize(
      path.absolute(path.join(donorArchiveRoot, 'attachment_archive')),
    );
    final candidatePath = path.normalize(path.join(payloadRoot, relativePath));
    return path.isWithin(payloadRoot, candidatePath);
  }

  static bool _isLink(String candidatePath) {
    return FileSystemEntity.typeSync(candidatePath, followLinks: false) ==
        FileSystemEntityType.link;
  }
}
