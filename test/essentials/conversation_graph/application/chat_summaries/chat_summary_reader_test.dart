import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/legacy_overlay_graph_attachment_archive_lookup.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late ConversationGraphDatabase workingDatabase;
  late OverlayDatabase overlayDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_chat_summary_test_');
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    await archiveDir.create(recursive: true);
    workingDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await overlayDatabase.close();
    await workingDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('summarizes participant and message topology', () async {
    final chatSsId = _ss(7);
    final firstHandleSsId = _ss(101);
    final secondHandleSsId = _ss(102);
    final firstMessageSsId = _ss(201);
    final secondMessageSsId = _ss(202);

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertHandle(
      workingDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      workingDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: chatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: chatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertMessage(
      workingDatabase,
      ssId: firstMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'older',
    );
    await _insertMessage(
      workingDatabase,
      ssId: secondMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: firstMessageSsId,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: secondMessageSsId,
    );

    final summaries = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
    ).readSummaries();

    expect(summaries, hasLength(1));
    expect(summaries.single.chatSsId, chatSsId);
    expect(summaries.single.participantHandles, [
      '+15550000101',
      '+15550000102',
    ]);
    expect(summaries.single.participantCount, 2);
    expect(summaries.single.isGroup, isTrue);
    expect(summaries.single.messageCount, 2);
    expect(summaries.single.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    expect(summaries.single.lastMessageText, 'newer');
  });

  test('uses latest non-null message text', () async {
    final chatSsId = _ss(7);
    final olderMessageSsId = _ss(201);
    final newerMessageSsId = _ss(202);

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertMessage(
      workingDatabase,
      ssId: olderMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'visible',
    );
    await _insertMessage(
      workingDatabase,
      ssId: newerMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: null,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: olderMessageSsId,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: newerMessageSsId,
    );

    final summaries = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
    ).readSummaries();

    expect(summaries.single.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    expect(summaries.single.lastMessageText, 'visible');
  });

  test('handles chats with no text messages', () async {
    final chatSsId = _ss(7);
    final messageSsId = _ss(201);

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertMessage(
      workingDatabase,
      ssId: messageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: null,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: messageSsId,
    );

    final summaries = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
    ).readSummaries();

    expect(summaries.single.messageCount, 1);
    expect(summaries.single.lastMessageText, isNull);
  });

  test('deduplicates participant rows and reports sanity counts', () async {
    final groupChatSsId = _ss(7);
    final singleChatSsId = _ss(8);
    final firstHandleSsId = _ss(101);
    final secondHandleSsId = _ss(102);

    await _insertChat(workingDatabase, ssId: groupChatSsId);
    await _insertChat(workingDatabase, ssId: singleChatSsId);
    await _insertHandle(
      workingDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      workingDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: singleChatSsId,
      handleSsId: firstHandleSsId,
    );

    final reader = ChatSummaryReader(
      repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
    );
    final summaries = await reader.readSummaries();
    final sanityCounts = await reader.readSanityCounts();

    expect(
      summaries
          .singleWhere((summary) => summary.chatSsId == groupChatSsId)
          .participantCount,
      2,
    );
    expect(sanityCounts.groupChatCount, 1);
    expect(sanityCounts.singleParticipantChatCount, 1);
    expect(sanityCounts.orphanChatCount, 0);
    expect(sanityCounts.zeroHandleChatCount, 0);
    expect(sanityCounts.zeroMessageChatCount, 2);
    expect(sanityCounts.largestParticipantCount, 2);
  });

  test('filters and sorts summaries', () async {
    final groupChatSsId = _ss(7);
    final singleChatSsId = _ss(8);
    final firstHandleSsId = _ss(101);
    final secondHandleSsId = _ss(102);
    final groupMessageSsId = _ss(201);
    final singleMessageSsId = _ss(202);

    await _insertChat(workingDatabase, ssId: groupChatSsId);
    await _insertChat(workingDatabase, ssId: singleChatSsId);
    await _insertHandle(
      workingDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      workingDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: groupChatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertChatHandle(
      workingDatabase,
      chatSsId: singleChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertMessage(
      workingDatabase,
      ssId: groupMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'group',
    );
    await _insertMessage(
      workingDatabase,
      ssId: singleMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'single',
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: groupChatSsId,
      messageSsId: groupMessageSsId,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: singleChatSsId,
      messageSsId: singleMessageSsId,
    );

    final reader = ChatSummaryReader(
      repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
    );
    final groups = await reader.readSummaries(
      filter: ChatSummaryFilter.groupOnly,
    );
    final singles = await reader.readSummaries(
      filter: ChatSummaryFilter.singleParticipantOnly,
    );
    final byParticipantCount = await reader.readSummaries(
      sort: ChatSummarySort.largestParticipantCount,
    );

    expect(groups.map((summary) => summary.chatSsId), [groupChatSsId]);
    expect(singles.map((summary) => summary.chatSsId), [singleChatSsId]);
    expect(byParticipantCount.first.chatSsId, groupChatSsId);
  });

  test('reads recent messages newest first', () async {
    final chatSsId = _ss(7);
    final firstMessageSsId = _ss(201);
    final secondMessageSsId = _ss(202);

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertMessage(
      workingDatabase,
      ssId: firstMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'older',
      isFromMe: true,
    );
    await _insertMessage(
      workingDatabase,
      ssId: secondMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: firstMessageSsId,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: secondMessageSsId,
    );

    final messages = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(workingDatabase: workingDatabase),
    ).readRecentMessages(chatSsId: chatSsId);

    expect(messages.map((message) => message.messageSsId), [
      secondMessageSsId,
      firstMessageSsId,
    ]);
    expect(messages.last.isFromMe, isTrue);
  });

  test(
    'reads recent text-bearing messages separately from latest rows',
    () async {
      final chatSsId = _ss(7);
      final textMessageSsId = _ss(201);
      final noTextMessageSsId = _ss(202);

      await _insertChat(workingDatabase, ssId: chatSsId);
      await _insertMessage(
        workingDatabase,
        ssId: textMessageSsId,
        dateUtc: '2026-05-19T10:00:00.000Z',
        text: 'visible',
      );
      await _insertMessage(
        workingDatabase,
        ssId: noTextMessageSsId,
        dateUtc: '2026-05-20T10:00:00.000Z',
        text: null,
      );
      await _insertChatMessage(
        workingDatabase,
        chatSsId: chatSsId,
        messageSsId: textMessageSsId,
      );
      await _insertChatMessage(
        workingDatabase,
        chatSsId: chatSsId,
        messageSsId: noTextMessageSsId,
      );

      final reader = ChatSummaryReader(
        repository: SqliteChatSummaryRepository(
          workingDatabase: workingDatabase,
        ),
      );
      final latestRows = await reader.readRecentMessages(chatSsId: chatSsId);
      final textRows = await reader.readRecentTextMessages(chatSsId: chatSsId);
      final textStats = await reader.readMessageTextStats(chatSsId: chatSsId);

      expect(latestRows.map((message) => message.messageSsId), [
        noTextMessageSsId,
        textMessageSsId,
      ]);
      expect(textRows.map((message) => message.messageSsId), [textMessageSsId]);
      expect(textStats.totalMessageCount, 2);
      expect(textStats.textMessageCount, 1);
      expect(textStats.noTextMessageCount, 1);
    },
  );

  test('reads attachment stats and message attachment metadata', () async {
    final chatSsId = _ss(7);
    final firstMessageSsId = _ss(201);
    final secondMessageSsId = _ss(202);
    final imageAttachmentSsId = _ss(301);
    final documentAttachmentSsId = _ss(302);
    final existingImageFile = File('${tempDir.path}/photo.jpg');
    await existingImageFile.writeAsString('image bytes');
    final missingDocumentPath = '${tempDir.path}/brief.pdf';
    const archivedRelativePath = 'ab/archived-photo.jpg';
    final archivedFile = File(path.join(archiveDir.path, archivedRelativePath));
    await archivedFile.parent.create(recursive: true);
    await archivedFile.writeAsString('archived image bytes');

    await _insertChat(workingDatabase, ssId: chatSsId);
    await _insertMessage(
      workingDatabase,
      ssId: firstMessageSsId,
      guid: 'message-guid-1',
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'photo',
    );
    await _insertMessage(
      workingDatabase,
      ssId: secondMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'document',
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: firstMessageSsId,
    );
    await _insertChatMessage(
      workingDatabase,
      chatSsId: chatSsId,
      messageSsId: secondMessageSsId,
    );
    await _insertAttachment(
      workingDatabase,
      ssId: imageAttachmentSsId,
      transferName: 'photo.jpg',
      filename: existingImageFile.path,
      mimeType: 'image/jpeg',
      totalBytes: 1200,
    );
    await _insertAttachment(
      workingDatabase,
      ssId: documentAttachmentSsId,
      transferName: 'brief.pdf',
      filename: missingDocumentPath,
      mimeType: 'application/pdf',
      totalBytes: 2400,
    );
    await _insertMessageAttachment(
      workingDatabase,
      messageSsId: firstMessageSsId,
      attachmentSsId: imageAttachmentSsId,
    );
    await _insertMessageAttachment(
      workingDatabase,
      messageSsId: secondMessageSsId,
      attachmentSsId: documentAttachmentSsId,
    );
    await overlayDatabase.customStatement(
      '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        content_hash,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      <Object?>[
        'message-guid-1',
        SourceScopedRowKey.unpackSourceRowId(imageAttachmentSsId),
        archivedRelativePath,
        '2026-05-21T10:00:00.000Z',
        20,
        'hash',
        'archived',
      ],
    );

    final reader = ChatSummaryReader(
      repository: SqliteChatSummaryRepository(
        workingDatabase: workingDatabase,
        archiveLookup: LegacyOverlayGraphAttachmentArchiveLookup(
          graphDatabase: workingDatabase,
          overlayDatabase: overlayDatabase,
          archiveDirectory: archiveDir.path,
        ),
      ),
    );
    final stats = await reader.readAttachmentStats(chatSsId: chatSsId);
    final attachments = await reader.readMessageAttachments(
      messageSsId: firstMessageSsId,
    );
    final recentMessages = await reader.readRecentMessages(chatSsId: chatSsId);

    expect(stats.messageWithAttachmentCount, 2);
    expect(stats.attachmentCount, 2);
    expect(stats.imageAttachmentCount, 1);
    expect(stats.documentAttachmentCount, 1);
    expect(stats.sourcePathHintCount, 2);
    expect(stats.localFileAvailableCount, 1);
    expect(stats.localFileMissingCount, 1);
    expect(stats.archiveRecordCount, 1);
    expect(stats.archiveFileAvailableCount, 1);
    expect(stats.archiveFileMissingCount, 0);
    expect(attachments.single.attachmentSsId, imageAttachmentSsId);
    expect(attachments.single.transferName, 'photo.jpg');
    expect(attachments.single.filename, existingImageFile.path);
    expect(attachments.single.hasSourcePathHint, isTrue);
    expect(attachments.single.localFileExists, isTrue);
    expect(attachments.single.archiveRelativePath, archivedRelativePath);
    expect(attachments.single.archiveAbsolutePath, archivedFile.path);
    expect(attachments.single.hasArchiveRecord, isTrue);
    expect(attachments.single.archiveFileExists, isTrue);
    expect(
      recentMessages
          .singleWhere((message) => message.messageSsId == firstMessageSsId)
          .attachmentCount,
      1,
    );
  });
}

int _ss(int sourceRowId) {
  return SourceScopedRowKey.pack(sourceId: 1, sourceRowId: sourceRowId);
}

Future<void> _insertChat(
  ConversationGraphDatabase workingDatabase, {
  required int ssId,
}) async {
  await workingDatabase.database.insert('chats', <String, Object?>{
    'ss_id': ssId,
    'guid': 'chat-$ssId',
    'is_group': 0,
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase workingDatabase, {
  required int ssId,
  required String id,
}) async {
  await workingDatabase.database.insert('handles', <String, Object?>{
    'ss_id': ssId,
    'id': id,
  });
}

Future<void> _insertMessage(
  ConversationGraphDatabase workingDatabase, {
  required int ssId,
  required String dateUtc,
  required String? text,
  String? guid,
  bool isFromMe = false,
}) async {
  await workingDatabase.database.insert('messages', <String, Object?>{
    'ss_id': ssId,
    'guid': guid ?? 'message-$ssId',
    'is_from_me': isFromMe ? 1 : 0,
    'date_utc': dateUtc,
    'text': text,
  });
}

Future<void> _insertChatHandle(
  ConversationGraphDatabase workingDatabase, {
  required int chatSsId,
  required int handleSsId,
}) async {
  await workingDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatSsId,
    'handle_ss_id': handleSsId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertChatMessage(
  ConversationGraphDatabase workingDatabase, {
  required int chatSsId,
  required int messageSsId,
}) async {
  await workingDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatSsId,
    'message_ss_id': messageSsId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertAttachment(
  ConversationGraphDatabase workingDatabase, {
  required int ssId,
  required String transferName,
  required String filename,
  required String mimeType,
  required int totalBytes,
}) async {
  await workingDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': ssId,
    'guid': 'attachment-$ssId',
    'transfer_name': transferName,
    'filename': filename,
    'mime_type': mimeType,
    'total_bytes': totalBytes,
  });
}

Future<void> _insertMessageAttachment(
  ConversationGraphDatabase workingDatabase, {
  required int messageSsId,
  required int attachmentSsId,
}) async {
  await workingDatabase.database.insert(
    'message_to_attachment',
    <String, Object?>{
      'message_ss_id': messageSsId,
      'attachment_ss_id': attachmentSsId,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}
