import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_provenance.dart';
import 'package:remember_this_text/features/attachments/domain/constants/resolved_attachment_availability.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/graph_attachment_evidence.dart';

void main() {
  test(
    'maps archived graph image attachment to display-ready evidence',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'graph-attachment-evidence-test-',
      );
      addTearDown(() async {
        await tempDir.delete(recursive: true);
      });
      final archivedFile = File('${tempDir.path}/photo.jpg');
      await archivedFile.writeAsBytes(const <int>[1, 2, 3]);

      final evidence = graphAttachmentEvidenceFromMessageAttachment(
        MessageAttachment(
          attachmentSsId: 1,
          guid: 'guid',
          filename: '/source/photo.jpg',
          transferName: 'photo.jpg',
          uti: 'public.jpeg',
          mimeType: 'image/jpeg',
          totalBytes: 100,
          createdAtUtc: '2026-05-20T10:00:00.000Z',
          localFileExists: false,
          archiveRelativePath: 'aa/photo.jpg',
          archiveAbsolutePath: archivedFile.path,
          archiveFileExists: true,
        ),
      );

      expect(evidence.isImage, isTrue);
      expect(evidence.isDisplayable, isTrue);
      expect(evidence.displayPath, archivedFile.path);
      expect(evidence.provenance, AttachmentProvenance.archived);
      expect(evidence.availability, ResolvedAttachmentAvailability.available);
    },
  );

  test('maps missing graph attachment to visible unavailable evidence', () {
    final evidence = graphAttachmentEvidenceFromMessageAttachment(
      const MessageAttachment(
        attachmentSsId: 2,
        guid: 'guid',
        filename: '/missing/photo.jpg',
        transferName: 'photo.jpg',
        uti: 'public.jpeg',
        mimeType: 'image/jpeg',
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: 'aa/photo.jpg',
        archiveAbsolutePath: '/missing/archive/photo.jpg',
        archiveFileExists: false,
      ),
    );

    expect(evidence.isImage, isTrue);
    expect(evidence.isDisplayable, isFalse);
    expect(
      evidence.availability,
      ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
    );
    expect(evidence.provenance, isNull);
  });

  test(
    'maps archived graph video attachment to display-ready evidence',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'graph-video-evidence-test-',
      );
      addTearDown(() async {
        await tempDir.delete(recursive: true);
      });
      final archivedFile = File('${tempDir.path}/clip.mov');
      await archivedFile.writeAsBytes(const <int>[1, 2, 3]);

      final evidence = graphAttachmentEvidenceFromMessageAttachment(
        MessageAttachment(
          attachmentSsId: 3,
          guid: 'guid',
          filename: '/source/clip.mov',
          transferName: 'clip.mov',
          uti: 'public.movie',
          mimeType: 'video/quicktime',
          totalBytes: 100,
          createdAtUtc: '2026-05-20T10:00:00.000Z',
          localFileExists: false,
          archiveRelativePath: 'aa/clip.mov',
          archiveAbsolutePath: archivedFile.path,
          archiveFileExists: true,
        ),
      );

      expect(evidence.isVideo, isTrue);
      expect(evidence.isDisplayable, isTrue);
      expect(evidence.displayPath, archivedFile.path);
      expect(evidence.provenance, AttachmentProvenance.archived);
      expect(evidence.availability, ResolvedAttachmentAvailability.available);
    },
  );

  test('classifies plugin payload attachments as URL preview evidence', () {
    final evidence = graphAttachmentEvidenceFromMessageAttachment(
      const MessageAttachment(
        attachmentSsId: 4,
        guid: 'guid',
        filename: '/source/GUID.pluginPayloadAttachment',
        transferName: 'GUID.pluginPayloadAttachment',
        uti: null,
        mimeType: null,
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: 'aa/GUID.pluginPayloadAttachment',
        archiveAbsolutePath: '/archive/GUID.pluginPayloadAttachment',
        archiveFileExists: false,
      ),
    );

    expect(evidence.isUrlPreview, isTrue);
    expect(evidence.isImage, isFalse);
    expect(evidence.isVideo, isFalse);
  });

  test('extracts first URL from graph message text', () {
    expect(
      firstUrlInGraphMessageText('see https://example.com/story now'),
      'https://example.com/story',
    );
    expect(firstUrlInGraphMessageText('no URL here'), isNull);
  });

  test('collapses multiple URL preview resources into one evidence item', () {
    final evidence = graphAttachmentEvidenceFromMessageAttachments(const [
      MessageAttachment(
        attachmentSsId: 10,
        guid: 'preview-1',
        filename: '/source/ONE.pluginPayloadAttachment',
        transferName: 'ONE.pluginPayloadAttachment',
        uti: null,
        mimeType: null,
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: null,
        archiveAbsolutePath: null,
        archiveFileExists: false,
      ),
      MessageAttachment(
        attachmentSsId: 11,
        guid: 'preview-2',
        filename: '/source/TWO.pluginPayloadAttachment',
        transferName: 'TWO.pluginPayloadAttachment',
        uti: null,
        mimeType: null,
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: null,
        archiveAbsolutePath: null,
        archiveFileExists: false,
      ),
      MessageAttachment(
        attachmentSsId: 12,
        guid: 'image',
        filename: '/source/photo.jpg',
        transferName: 'photo.jpg',
        uti: 'public.jpeg',
        mimeType: 'image/jpeg',
        totalBytes: 100,
        createdAtUtc: '2026-05-20T10:00:00.000Z',
        localFileExists: false,
        archiveRelativePath: null,
        archiveAbsolutePath: null,
        archiveFileExists: false,
      ),
    ]);

    expect(evidence, hasLength(2));
    expect(evidence.first.isUrlPreview, isTrue);
    expect(evidence.first.attachmentSsId, 10);
    expect(evidence.first.sourceRecordCount, 2);
    expect(evidence.last.isImage, isTrue);
  });
}
