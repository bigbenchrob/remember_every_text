import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/message_lens_attachment_payload_inspector.dart';

void main() {
  const inspector = MessageLensAttachmentPayloadInspector();
  late Directory temporaryRoot;

  setUp(() {
    temporaryRoot = Directory.systemTemp.createTempSync(
      'message_lens_attachment_payload_inspector_',
    );
  });

  tearDown(() {
    if (temporaryRoot.existsSync()) {
      temporaryRoot.deleteSync(recursive: true);
    }
  });

  test('validates contained regular file by exact size and SHA-256', () async {
    final bytes = <int>[1, 2, 3];
    final file = File(
      path.join(temporaryRoot.path, 'attachment_archive', 'ab', 'payload.bin'),
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);

    final result = await inspector.inspect(
      donorArchiveRoot: temporaryRoot.path,
      payload: MessageLensArchivedPayloadEvidence(
        archiveRelativePath: 'ab/payload.bin',
        recordedSizeBytes: bytes.length,
        recordedSha256: sha256.convert(bytes).toString(),
      ),
    );

    expect(result.status, AttachmentPayloadInspectionStatus.valid);
    expect(result.actualSizeBytes, 3);
    expect(result.actualSha256, sha256.convert(bytes).toString());
  });

  test('produces a read-only capability only for validated payload', () async {
    final bytes = <int>[4, 5, 6];
    final file = File(
      path.join(temporaryRoot.path, 'attachment_archive', 'cd', 'payload.pdf'),
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);

    final result = await inspector.inspectVerified(
      donorArchiveRoot: temporaryRoot.path,
      payload: MessageLensArchivedPayloadEvidence(
        archiveRelativePath: 'cd/payload.pdf',
        recordedSizeBytes: bytes.length,
        recordedSha256: sha256.convert(bytes).toString(),
      ),
    );

    expect(result.inspection.status, AttachmentPayloadInspectionStatus.valid);
    expect(result.payload, isNotNull);
    expect(result.payload!.sourceExtension, '.pdf');
    expect(result.payload!.expectedSizeBytes, bytes.length);
    expect(
      await result.payload!.openRead().expand((chunk) => chunk).toList(),
      bytes,
    );
  });

  test(
    'reports missing contained payload separately from unsafe path',
    () async {
      final result = await inspector.inspect(
        donorArchiveRoot: temporaryRoot.path,
        payload: const MessageLensArchivedPayloadEvidence(
          archiveRelativePath: 'ab/missing.bin',
          recordedSizeBytes: 3,
          recordedSha256: null,
        ),
      );

      expect(result.status, AttachmentPayloadInspectionStatus.missing);
    },
  );

  test('rejects traversal and absolute donor paths', () async {
    final traversal = await inspector.inspect(
      donorArchiveRoot: temporaryRoot.path,
      payload: const MessageLensArchivedPayloadEvidence(
        archiveRelativePath: '../outside.bin',
        recordedSizeBytes: 1,
        recordedSha256: null,
      ),
    );
    final absolute = await inspector.inspect(
      donorArchiveRoot: temporaryRoot.path,
      payload: const MessageLensArchivedPayloadEvidence(
        archiveRelativePath: '/tmp/outside.bin',
        recordedSizeBytes: 1,
        recordedSha256: null,
      ),
    );

    expect(traversal.status, AttachmentPayloadInspectionStatus.unsafePath);
    expect(absolute.status, AttachmentPayloadInspectionStatus.unsafePath);
  });

  test('rejects symlink escape without reading target', () async {
    final outside = File(path.join(temporaryRoot.parent.path, 'outside.bin'));
    await outside.writeAsBytes([1, 2, 3]);
    final payloadRoot = Directory(
      path.join(temporaryRoot.path, 'attachment_archive'),
    );
    await payloadRoot.create(recursive: true);
    final link = Link(path.join(payloadRoot.path, 'linked.bin'));
    await link.create(outside.path);

    try {
      final result = await inspector.inspect(
        donorArchiveRoot: temporaryRoot.path,
        payload: const MessageLensArchivedPayloadEvidence(
          archiveRelativePath: 'linked.bin',
          recordedSizeBytes: 3,
          recordedSha256: null,
        ),
      );

      expect(result.status, AttachmentPayloadInspectionStatus.unsafePath);
    } finally {
      if (outside.existsSync()) {
        outside.deleteSync();
      }
    }
  });

  test(
    'size or hash mismatch is invalid, never recoverable evidence',
    () async {
      final file = File(
        path.join(temporaryRoot.path, 'attachment_archive', 'payload.bin'),
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes([1, 2, 3]);

      final result = await inspector.inspect(
        donorArchiveRoot: temporaryRoot.path,
        payload: const MessageLensArchivedPayloadEvidence(
          archiveRelativePath: 'payload.bin',
          recordedSizeBytes: 4,
          recordedSha256: 'not-the-hash',
        ),
      );

      expect(result.status, AttachmentPayloadInspectionStatus.invalid);
    },
  );
}
