import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../../attachments/application/attachment_resolver_provider.dart';
import '../../../../domain/entities/attachment_info.dart' as message_domain;
import '../../../debug/contact_timeline_scroll_probe.dart';
import 'attachment_info.dart';

Future<List<AttachmentInfo>> loadAttachmentsForMessage(
  WorkingDatabase db,
  String messageGuid,
) async {
  ContactTimelineScrollProbe.count('attachments.load.calls');
  final attachmentRows = await ContactTimelineScrollProbe.traceAsync(
    'attachments.load.query',
    () => (db.select(
      db.workingAttachments,
    )..where((attachment) => attachment.messageGuid.equals(messageGuid))).get(),
  );
  ContactTimelineScrollProbe.count(
    'attachments.load.rows',
    by: attachmentRows.length,
  );

  final results = <AttachmentInfo>[];
  for (final attachment in attachmentRows) {
    ContactTimelineScrollProbe.count('attachments.load.items');
    results.add(await loadAttachment(attachment));
  }
  return results;
}

Future<AttachmentInfo> loadAttachment(WorkingAttachment attachment) async {
  return AttachmentInfo(
    id: attachment.id,
    localPath: attachment.localPath,
    mimeType: attachment.mimeType,
    transferName: attachment.transferName,
    importAttachmentId: attachment.importAttachmentId,
    messageGuid: attachment.messageGuid,
  );
}

Future<List<AttachmentInfo>> resolveAttachmentsForDisplay({
  required Ref ref,
  required List<AttachmentInfo> attachments,
}) async {
  if (attachments.isEmpty) {
    return const [];
  }

  ContactTimelineScrollProbe.count('attachments.resolve.calls');
  ContactTimelineScrollProbe.count(
    'attachments.resolve.items',
    by: attachments.length,
  );

  return ContactTimelineScrollProbe.traceAsync(
    'attachments.resolve.batch',
    () => Future.wait(
      attachments.map((attachment) async {
        final messageGuid = attachment.messageGuid;
        if (messageGuid == null || messageGuid.isEmpty) {
          return attachment;
        }

        ContactTimelineScrollProbe.count('attachments.resolve.item');
        final resolved = await ContactTimelineScrollProbe.traceAsync(
          'attachments.resolve.provider_read',
          () => ref.read(
            attachmentResolverProvider(
              message_domain.AttachmentInfo(
                id: attachment.id,
                localPath: attachment.localPath,
                mimeType: attachment.mimeType,
                transferName: attachment.transferName,
                mediaWidth: attachment.mediaWidth,
                mediaHeight: attachment.mediaHeight,
              ),
              messageGuid: messageGuid,
              importAttachmentId: attachment.importAttachmentId,
            ).future,
          ),
        );

        return attachment.copyWith(
          resolvedDisplayPath: resolved.resolvedFile?.path,
          availability: resolved.availability,
          provenance: resolved.provenance,
          recoveryMetadata: resolved.recoveryMetadata,
        );
      }),
    ),
  );
}
