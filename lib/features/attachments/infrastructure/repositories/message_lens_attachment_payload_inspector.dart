import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import '../../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
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

  /// Inspects all preflight claims in one read-only directory traversal.
  ///
  /// Directory entries establish regular-file and symlink truth. Each claimed
  /// regular file is statted once for its size; payload bytes are never read.
  Future<Map<ArchiveCompatibilityKey, AttachmentPayloadInspection>>
  inspectClaims({
    required String archiveDirectoryPath,
    required List<MessageLensArchivedPayloadClaim> claims,
    void Function(int completed, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    final normalizedRoot = path.normalize(path.absolute(archiveDirectoryPath));
    final inspections =
        <ArchiveCompatibilityKey, AttachmentPayloadInspection>{};
    var lastPublishedCompleted = 0;
    void publishProgress(int completed, {bool force = false}) {
      const batchSize = 250;
      if (completed == lastPublishedCompleted) {
        return;
      }
      if (force ||
          completed == claims.length ||
          completed - lastPublishedCompleted >= batchSize) {
        lastPublishedCompleted = completed;
        onProgress?.call(completed, claims.length);
      }
    }

    if (_isLink(normalizedRoot) ||
        FileSystemEntity.typeSync(normalizedRoot, followLinks: false) !=
            FileSystemEntityType.directory) {
      return <ArchiveCompatibilityKey, AttachmentPayloadInspection>{
        for (final claim in claims)
          claim.archiveCompatibilityKey:
              const AttachmentPayloadInspection.unsafePath(),
      };
    }

    final claimsByPath = <String, List<MessageLensArchivedPayloadClaim>>{};
    var completed = 0;
    for (final claim in claims) {
      final relativePath = claim.payload.archiveRelativePath;
      if (!_lexicalPayloadPathIsSafe(relativePath)) {
        inspections[claim.archiveCompatibilityKey] =
            const AttachmentPayloadInspection.unsafePath();
        completed += 1;
      } else {
        claimsByPath.putIfAbsent(relativePath, () => []).add(claim);
      }
    }
    publishProgress(completed);

    final linkPaths = <String>[];
    try {
      await for (final entity in Directory(
        normalizedRoot,
      ).list(recursive: true, followLinks: false)) {
        if (isCancelled?.call() ?? false) {
          throw const MessageLensAttachmentInspectionCancelled();
        }
        final relativePath = path.normalize(
          path.relative(entity.path, from: normalizedRoot),
        );
        if (entity is Link) {
          linkPaths.add(relativePath);
          final linkedClaims = claimsByPath.remove(relativePath);
          if (linkedClaims != null) {
            for (final claim in linkedClaims) {
              inspections[claim.archiveCompatibilityKey] =
                  const AttachmentPayloadInspection.unsafePath();
            }
            completed += linkedClaims.length;
            publishProgress(completed);
          }
          continue;
        }
        final matchingClaims = claimsByPath.remove(relativePath);
        if (matchingClaims == null) {
          continue;
        }
        final stat = await entity.stat();
        for (final claim in matchingClaims) {
          inspections[claim.archiveCompatibilityKey] =
              stat.type == FileSystemEntityType.file &&
                  stat.size == claim.payload.recordedSizeBytes
              ? AttachmentPayloadInspection(
                  status: AttachmentPayloadInspectionStatus.valid,
                  actualSizeBytes: stat.size,
                  actualSha256: claim.payload.recordedSha256
                      ?.trim()
                      .toLowerCase(),
                )
              : AttachmentPayloadInspection(
                  status: AttachmentPayloadInspectionStatus.invalid,
                  actualSizeBytes: stat.size,
                  actualSha256: null,
                );
        }
        completed += matchingClaims.length;
        publishProgress(completed);
      }
    } on MessageLensAttachmentInspectionCancelled {
      rethrow;
    } on FileSystemException {
      for (final unresolved in claimsByPath.values.expand((items) => items)) {
        inspections[unresolved.archiveCompatibilityKey] =
            const AttachmentPayloadInspection(
              status: AttachmentPayloadInspectionStatus.invalid,
              actualSizeBytes: null,
              actualSha256: null,
            );
      }
      publishProgress(claims.length, force: true);
      return inspections;
    }

    for (final entry in claimsByPath.entries) {
      final crossesLink = linkPaths.any(
        (linkPath) =>
            path.equals(entry.key, linkPath) ||
            path.isWithin(linkPath, entry.key),
      );
      for (final claim in entry.value) {
        inspections[claim.archiveCompatibilityKey] = crossesLink
            ? const AttachmentPayloadInspection.unsafePath()
            : const AttachmentPayloadInspection.missing();
      }
      completed += entry.value.length;
      publishProgress(completed);
    }
    publishProgress(claims.length, force: true);
    return inspections;
  }

  /// Performs the read-only proof required to classify a preflight candidate.
  ///
  /// This deliberately validates path containment, regular-file presence, and
  /// recorded size without reading payload bytes. [inspectVerified] repeats
  /// these checks and verifies SHA-256 immediately before installation.
  Future<AttachmentPayloadInspection> inspect({
    required String donorArchiveRoot,
    required MessageLensArchivedPayloadEvidence payload,
  }) async {
    if (!_lexicalPathIsSafe(
      donorArchiveRoot: donorArchiveRoot,
      relativePath: payload.archiveRelativePath,
    )) {
      return const AttachmentPayloadInspection.unsafePath();
    }
    final absoluteDonorRoot = path.normalize(path.absolute(donorArchiveRoot));
    final payloadRoot = path.normalize(
      path.join(absoluteDonorRoot, 'attachment_archive'),
    );
    if (_isLink(absoluteDonorRoot) || _isLink(payloadRoot)) {
      return const AttachmentPayloadInspection.unsafePath();
    }
    final candidatePath = path.normalize(
      path.join(payloadRoot, payload.archiveRelativePath),
    );
    var cursor = payloadRoot;
    for (final component in path.split(payload.archiveRelativePath)) {
      cursor = path.join(cursor, component);
      if (_isLink(cursor)) {
        return const AttachmentPayloadInspection.unsafePath();
      }
    }
    if (FileSystemEntity.typeSync(candidatePath, followLinks: false) !=
        FileSystemEntityType.file) {
      return const AttachmentPayloadInspection.missing();
    }
    try {
      final actualSize = await File(candidatePath).length();
      return AttachmentPayloadInspection(
        status: actualSize == payload.recordedSizeBytes
            ? AttachmentPayloadInspectionStatus.valid
            : AttachmentPayloadInspectionStatus.invalid,
        actualSizeBytes: actualSize,
        // The trusted donor record is sufficient for preflight identity and
        // duplicate-claim comparison. Execution recomputes this hash.
        actualSha256: payload.recordedSha256?.trim().toLowerCase(),
      );
    } on FileSystemException {
      return const AttachmentPayloadInspection(
        status: AttachmentPayloadInspectionStatus.invalid,
        actualSizeBytes: null,
        actualSha256: null,
      );
    }
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

  static bool _lexicalPayloadPathIsSafe(String relativePath) {
    if (relativePath.trim().isEmpty || path.isAbsolute(relativePath)) {
      return false;
    }
    final normalized = path.normalize(relativePath);
    return normalized != '..' && !normalized.startsWith('../');
  }

  static bool _isLink(String candidatePath) {
    return FileSystemEntity.typeSync(candidatePath, followLinks: false) ==
        FileSystemEntityType.link;
  }
}

final class MessageLensAttachmentInspectionCancelled implements Exception {
  const MessageLensAttachmentInspectionCancelled();
}
