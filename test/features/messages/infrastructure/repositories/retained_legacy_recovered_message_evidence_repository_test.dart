import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/retained_legacy_recovered_message_evidence_repository.dart';

void main() {
  group('RetainedLegacyRecoveredMessageEvidenceRepository', () {
    late WorkingDatabase workingDb;
    late OverlayDatabase overlayDb;
    late RetainedLegacyRecoveredMessageEvidenceRepository repository;

    setUp(() {
      workingDb = WorkingDatabase(NativeDatabase.memory());
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      repository = RetainedLegacyRecoveredMessageEvidenceRepository(
        db: workingDb,
        overlayDb: overlayDb,
      );
    });

    tearDown(() async {
      await workingDb.close();
      await overlayDb.close();
    });

    test(
      'preserves recovered rows, fallback text, and attachment dedupe',
      () async {
        await _insertRecoveredMessage(
          workingDb,
          id: 1,
          guid: 'recovered-1',
          text: '',
          semanticKind: 'attachment-only',
          hasAttachments: true,
        );
        await _insertRecoveredAttachment(
          workingDb,
          id: 10,
          messageGuid: 'recovered-1',
          importAttachmentId: 501,
          transferName: 'receipt.png',
        );
        await _insertRecoveredAttachment(
          workingDb,
          id: 11,
          messageGuid: 'recovered-1',
          importAttachmentId: 501,
          transferName: 'receipt-duplicate.png',
        );

        final messages = await repository.watchMessages().first;

        expect(messages, hasLength(1));
        expect(messages.single.text, '(No text content)');
        expect(messages.single.attachmentCount, 1);
        expect(messages.single.attachments.single.transferName, 'receipt.png');
      },
    );

    test(
      'scopes direct and inferred recovered messages to a contact',
      () async {
        await _insertHandle(workingDb, id: 11, rawIdentifier: '+16045550101');
        await _insertHandle(workingDb, id: 12, rawIdentifier: '+16045550202');

        await _insertRecoveredMessage(
          workingDb,
          id: 1,
          guid: 'direct',
          senderHandleId: 11,
          senderAddress: '+16045550101',
          text: 'direct match',
          sentAtUtc: '2026-05-20T10:00:00.000Z',
        );
        await _insertRecoveredMessage(
          workingDb,
          id: 2,
          guid: 'inferred',
          isFromMe: true,
          text: 'nearby no-handle outgoing',
          sentAtUtc: '2026-05-20T10:03:00.000Z',
        );
        await _insertRecoveredMessage(
          workingDb,
          id: 3,
          guid: 'too-late',
          isFromMe: true,
          text: 'outside inference window',
          sentAtUtc: '2026-05-20T10:30:00.000Z',
        );
        await _insertRecoveredMessage(
          workingDb,
          id: 4,
          guid: 'other-handle',
          senderHandleId: 12,
          senderAddress: '+16045550202',
          text: 'other contact',
          sentAtUtc: '2026-05-20T10:01:00.000Z',
        );

        final messages = await repository
            .watchMessages(contactId: 24, scopedHandleIds: const {11})
            .first;

        expect(messages.map((message) => message.guid), ['direct', 'inferred']);
        expect(messages.first.isInferred, isFalse);
        expect(messages.last.isInferred, isTrue);
      },
    );

    test(
      'resolves contact name through legacy handle participant links',
      () async {
        await _insertHandle(workingDb, id: 11, rawIdentifier: '+16045550101');
        await _insertParticipant(
          workingDb,
          id: 24,
          displayName: 'Cathie Campbell',
        );
        await workingDb
            .into(workingDb.handleToParticipant)
            .insert(
              HandleToParticipantCompanion.insert(
                handleId: 11,
                participantId: 24,
              ),
            );
        await _insertRecoveredMessage(
          workingDb,
          id: 1,
          guid: 'named',
          senderHandleId: 11,
          senderAddress: '+16045550101',
          text: 'direct match',
        );

        final messages = await repository.watchMessages().first;

        expect(messages.single.contactName, 'Cathie Campbell');
        expect(messages.single.senderLabel, '1 (604) 555-0101');
      },
    );
  });
}

Future<void> _insertRecoveredMessage(
  WorkingDatabase db, {
  required int id,
  required String guid,
  int? senderHandleId,
  String? senderAddress,
  bool isFromMe = false,
  String? text = 'hello',
  String sentAtUtc = '2026-05-20T10:00:00.000Z',
  String semanticKind = 'plain-text',
  bool hasAttachments = false,
}) async {
  await db
      .into(db.recoveredUnlinkedMessages)
      .insert(
        RecoveredUnlinkedMessagesCompanion.insert(
          id: drift.Value(id),
          guid: guid,
          senderHandleId: drift.Value(senderHandleId),
          senderAddress: drift.Value(senderAddress),
          isFromMe: drift.Value(isFromMe),
          sentAtUtc: drift.Value(sentAtUtc),
          textContent: drift.Value(text),
          semanticKind: drift.Value(semanticKind),
          hasAttachments: drift.Value(hasAttachments),
        ),
      );
}

Future<void> _insertRecoveredAttachment(
  WorkingDatabase db, {
  required int id,
  required String messageGuid,
  required int importAttachmentId,
  required String transferName,
}) async {
  await db
      .into(db.recoveredUnlinkedAttachments)
      .insert(
        RecoveredUnlinkedAttachmentsCompanion.insert(
          id: drift.Value(id),
          messageGuid: messageGuid,
          importAttachmentId: drift.Value(importAttachmentId),
          transferName: drift.Value(transferName),
        ),
      );
}

Future<void> _insertHandle(
  WorkingDatabase db, {
  required int id,
  required String rawIdentifier,
}) async {
  await db
      .into(db.handlesCanonical)
      .insert(
        HandlesCanonicalCompanion.insert(
          id: drift.Value(id),
          rawIdentifier: rawIdentifier,
          displayName: rawIdentifier,
          compoundIdentifier: '$rawIdentifier|iMessage',
        ),
      );
}

Future<void> _insertParticipant(
  WorkingDatabase db, {
  required int id,
  required String displayName,
}) async {
  await db
      .into(db.workingParticipants)
      .insert(
        WorkingParticipantsCompanion.insert(
          id: drift.Value(id),
          originalName: displayName,
          displayName: displayName,
          shortName: '',
        ),
      );
}
