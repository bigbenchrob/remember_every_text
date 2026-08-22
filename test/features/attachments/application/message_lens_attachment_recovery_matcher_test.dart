import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_matcher.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/message_lens_attachment_identity_evidence_factory.dart';

void main() {
  const matcher = MessageLensAttachmentRecoveryMatcher();

  test('matched relationship and valid missing payload is recoverable', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [_input()],
    );

    expect(result.recoverableCount, 1);
    expect(result.recoverableBytes, 3);
    expect(result.funnel.messageMatchedCount, 1);
    expect(result.funnel.attachmentMatchedCount, 1);
    expect(result.funnel.donorPayloadPresentCount, 1);
    expect(result.funnel.currentPayloadPresentCount, 0);
    expect(result.classificationCountsReconcile, isTrue);
    expect(
      result.candidates.single.classification,
      MessageLensAttachmentRecoveryClassification.recoverable,
    );
  });

  test('current valid payload is already present and rerun is idempotent', () {
    final first = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [_input()],
    );
    final rerun = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(
          currentPayloadStatus: CurrentAttachmentPayloadStatus.presentValid,
        ),
      ],
    );

    expect(first.recoverableCount, 1);
    expect(rerun.recoverableCount, 0);
    expect(rerun.alreadyPresentCount, 1);
  });

  test('same message ROWID with different GUID rejects relationship', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(currentRelationships: [_relationship(messageGuid: 'other')]),
      ],
    );

    expect(result.messageMismatchCount, 1);
  });

  test('attachment ROWID or GUID mismatch rejects attachment', () {
    final rowIdMismatch = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(
          currentRelationships: [
            _relationship(attachmentRowId: 99, filename: 'same-name.jpg'),
          ],
        ),
      ],
    );
    final guidMismatch = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(currentRelationships: [_relationship(attachmentGuid: 'other')]),
      ],
    );

    expect(rowIdMismatch.attachmentMismatchCount, 1);
    expect(guidMismatch.attachmentMismatchCount, 1);
  });

  test('exact attachment is selected from a multi-attachment message', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(
          currentRelationships: [
            _relationship(attachmentRowId: 99, attachmentGuid: 'other'),
            _relationship(),
          ],
        ),
      ],
    );

    expect(result.recoverableCount, 1);
    expect(result.ambiguousCount, 0);
  });

  test('filename and path similarity have no identity authority', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(
          currentRelationships: [
            _relationship(
              attachmentRowId: 99,
              attachmentGuid: null,
              filename: 'same-name.jpg',
            ),
          ],
          donorPayload: const MessageLensArchivedPayloadEvidence(
            archiveRelativePath: 'same-name.jpg',
            recordedSizeBytes: 3,
            recordedSha256: 'hash',
          ),
        ),
      ],
    );

    expect(result.attachmentMismatchCount, 1);
  });

  test('ambiguous relationship or duplicate destination fails closed', () {
    final ambiguousRelationship = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(
          currentRelationships: [
            _relationship(),
            _relationship(attachmentGuid: 'second'),
          ],
        ),
      ],
    );
    final duplicateDestination = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(),
        _input(
          donorPayloadInspection: const AttachmentPayloadInspection(
            status: AttachmentPayloadInspectionStatus.valid,
            actualSizeBytes: 4,
            actualSha256: 'different-hash',
          ),
        ),
      ],
    );

    expect(ambiguousRelationship.ambiguousCount, 1);
    expect(duplicateDestination.candidates, hasLength(1));
    expect(duplicateDestination.ambiguousCount, 1);
  });

  test('byte-identical duplicate donor evidence produces one candidate', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [_input(), _input()],
    );

    expect(result.candidates, hasLength(1));
    expect(result.examinedCount, 2);
    expect(result.funnel.duplicateClaimsCollapsedCount, 1);
    expect(result.classificationCountsReconcile, isTrue);
    expect(result.recoverableCount, 1);
    expect(result.recoverableBytes, 3);
  });

  test('payload states remain separately countable', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(attachmentRowId: 42),
        _input(
          attachmentRowId: 43,
          donorPayloadInspection: const AttachmentPayloadInspection.missing(),
        ),
        _input(
          attachmentRowId: 44,
          currentPayloadStatus: CurrentAttachmentPayloadStatus.presentConflict,
        ),
        _input(
          attachmentRowId: 45,
          donorPayloadInspection:
              const AttachmentPayloadInspection.unsafePath(),
        ),
      ],
    );

    expect(result.examinedCount, 4);
    expect(result.recoverableCount, 1);
    expect(result.donorMissingCount, 1);
    expect(result.conflictCount, 1);
    expect(result.unsafeDonorPathCount, 1);
    expect(result.recoverableBytes, 3);
    expect(result.terminalClassificationCount, 4);
    expect(result.classificationCountsReconcile, isTrue);
  });

  test('source-scoped identities decode before cross-scope matching', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(
          donorRelationship: _relationship(sourceId: 7),
          currentRelationships: [_relationship(sourceId: 1)],
        ),
      ],
    );

    expect(result.recoverableCount, 1);
    expect(result.messageMismatchCount, 0);
    expect(result.attachmentMismatchCount, 0);
    expect(result.funnel.messageMatchedCount, 1);
    expect(result.funnel.attachmentMatchedCount, 1);
  });

  test('all physically present matched payloads produce truthful zero', () {
    final result = matcher.inspect(
      lineageAdmission: _sameLineageAdmission(),
      inputs: [
        _input(
          attachmentRowId: 42,
          currentPayloadStatus: CurrentAttachmentPayloadStatus.presentValid,
        ),
        _input(
          attachmentRowId: 43,
          currentPayloadStatus: CurrentAttachmentPayloadStatus.presentValid,
        ),
      ],
    );

    expect(result.recoverableCount, 0);
    expect(result.alreadyPresentCount, 2);
    expect(result.funnel.currentPayloadPresentCount, 2);
    expect(result.classificationCountsReconcile, isTrue);
  });
}

MessageLensAttachmentRecoveryInput _input({
  int attachmentRowId = 42,
  MessageLensAttachmentRelationshipEvidence? donorRelationship,
  List<MessageLensAttachmentRelationshipEvidence>? currentRelationships,
  MessageLensArchivedPayloadEvidence donorPayload =
      const MessageLensArchivedPayloadEvidence(
        archiveRelativePath: 'ab/hash.jpg',
        recordedSizeBytes: 3,
        recordedSha256: 'hash',
      ),
  AttachmentPayloadInspection donorPayloadInspection =
      const AttachmentPayloadInspection(
        status: AttachmentPayloadInspectionStatus.valid,
        actualSizeBytes: 3,
        actualSha256: 'hash',
      ),
  CurrentAttachmentPayloadStatus currentPayloadStatus =
      CurrentAttachmentPayloadStatus.missing,
}) {
  return MessageLensAttachmentRecoveryInput(
    donorRelationship:
        donorRelationship ?? _relationship(attachmentRowId: attachmentRowId),
    currentRelationshipCandidates:
        currentRelationships ??
        [_relationship(attachmentRowId: attachmentRowId)],
    donorPayload: donorPayload,
    donorPayloadInspection: donorPayloadInspection,
    currentPayloadStatus: currentPayloadStatus,
  );
}

MessageLensAttachmentRelationshipEvidence _relationship({
  int sourceId = 1,
  int messageRowId = 41,
  String messageGuid = 'message-guid',
  int attachmentRowId = 42,
  String? attachmentGuid = 'attachment-guid',
  String? filename = 'photo.jpg',
}) {
  return const MessageLensAttachmentIdentityEvidenceFactory().create(
    messageSsId: SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: messageRowId,
    ),
    messageSourceId: sourceId,
    originalMessageRowId: messageRowId,
    messageGuid: messageGuid,
    attachmentSsId: SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: attachmentRowId,
    ),
    attachmentSourceId: sourceId,
    originalAttachmentRowId: attachmentRowId,
    attachmentGuid: attachmentGuid,
    relationshipOccurrenceCount: 1,
    filename: filename,
    transferName: filename,
    mimeType: 'image/jpeg',
    uti: 'public.jpeg',
    totalBytes: 3,
  );
}

SameMessagesLineageAdmission _sameLineageAdmission() {
  final admission = MessagesLineageAdmission.fromEvidence(
    const MessagesLineageEvidence(
      candidateRecordCount: 64,
      usableCandidateIdentityCount: 64,
      blankCandidateGuidCount: 0,
      inconsistentCandidateIdentityCount: 0,
      duplicateCandidateRowIdCount: 0,
      currentRowsInCandidateRangeCount: 64,
      comparableCount: 64,
      matchingCount: 64,
      contradictionCount: 0,
      missingCurrentRowCount: 0,
      unusableCurrentGuidCount: 0,
      matchingRowIdBandCount: 4,
      candidateSourceShapeIsCoherent: true,
      currentSourceShapeIsCoherent: true,
    ),
  );
  return admission as SameMessagesLineageAdmission;
}
