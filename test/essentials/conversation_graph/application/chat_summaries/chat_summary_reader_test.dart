import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../conversation_graph_test_database.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late ConversationGraphDatabase graphDatabase;
  late OverlayDatabase overlayDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_chat_summary_test_');
    archiveDir = Directory(path.join(tempDir.path, 'attachment_archive'));
    await archiveDir.create(recursive: true);
    graphDatabase = await openConversationGraphTestDatabase();
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await overlayDatabase.close();
    await graphDatabase.close();
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

    await _insertChat(graphDatabase, ssId: chatSsId);
    await _insertHandle(
      graphDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      graphDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: chatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: chatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertMessage(
      graphDatabase,
      ssId: firstMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'older',
    );
    await _insertMessage(
      graphDatabase,
      ssId: secondMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: firstMessageSsId,
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: secondMessageSsId,
    );

    final summaries = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(graphDatabase: graphDatabase),
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

    await _insertChat(graphDatabase, ssId: chatSsId);
    await _insertMessage(
      graphDatabase,
      ssId: olderMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'visible',
    );
    await _insertMessage(
      graphDatabase,
      ssId: newerMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: null,
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: olderMessageSsId,
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: newerMessageSsId,
    );

    final summaries = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(graphDatabase: graphDatabase),
    ).readSummaries();

    expect(summaries.single.lastMessageAtUtc, '2026-05-20T10:00:00.000Z');
    expect(summaries.single.lastMessageText, 'visible');
  });

  test('handles chats with no text messages', () async {
    final chatSsId = _ss(7);
    final messageSsId = _ss(201);

    await _insertChat(graphDatabase, ssId: chatSsId);
    await _insertMessage(
      graphDatabase,
      ssId: messageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: null,
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: messageSsId,
    );

    final summaries = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(graphDatabase: graphDatabase),
    ).readSummaries();

    expect(summaries.single.messageCount, 1);
    expect(summaries.single.lastMessageText, isNull);
  });

  test('deduplicates participant rows and reports sanity counts', () async {
    final groupChatSsId = _ss(7);
    final singleChatSsId = _ss(8);
    final firstHandleSsId = _ss(101);
    final secondHandleSsId = _ss(102);

    await _insertChat(graphDatabase, ssId: groupChatSsId);
    await _insertChat(graphDatabase, ssId: singleChatSsId);
    await _insertHandle(
      graphDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      graphDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: groupChatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: singleChatSsId,
      handleSsId: firstHandleSsId,
    );

    final reader = ChatSummaryReader(
      repository: SqliteChatSummaryRepository(graphDatabase: graphDatabase),
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

    await _insertChat(graphDatabase, ssId: groupChatSsId);
    await _insertChat(graphDatabase, ssId: singleChatSsId);
    await _insertHandle(
      graphDatabase,
      ssId: firstHandleSsId,
      id: '+15550000101',
    );
    await _insertHandle(
      graphDatabase,
      ssId: secondHandleSsId,
      id: '+15550000102',
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: groupChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: groupChatSsId,
      handleSsId: secondHandleSsId,
    );
    await _insertChatHandle(
      graphDatabase,
      chatSsId: singleChatSsId,
      handleSsId: firstHandleSsId,
    );
    await _insertMessage(
      graphDatabase,
      ssId: groupMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'group',
    );
    await _insertMessage(
      graphDatabase,
      ssId: singleMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'single',
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: groupChatSsId,
      messageSsId: groupMessageSsId,
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: singleChatSsId,
      messageSsId: singleMessageSsId,
    );

    final reader = ChatSummaryReader(
      repository: SqliteChatSummaryRepository(graphDatabase: graphDatabase),
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

    await _insertChat(graphDatabase, ssId: chatSsId);
    await _insertMessage(
      graphDatabase,
      ssId: firstMessageSsId,
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'older',
      isFromMe: true,
    );
    await _insertMessage(
      graphDatabase,
      ssId: secondMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'newer',
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: firstMessageSsId,
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: secondMessageSsId,
    );

    final messages = await ChatSummaryReader(
      repository: SqliteChatSummaryRepository(graphDatabase: graphDatabase),
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

      await _insertChat(graphDatabase, ssId: chatSsId);
      await _insertMessage(
        graphDatabase,
        ssId: textMessageSsId,
        dateUtc: '2026-05-19T10:00:00.000Z',
        text: 'visible',
      );
      await _insertMessage(
        graphDatabase,
        ssId: noTextMessageSsId,
        dateUtc: '2026-05-20T10:00:00.000Z',
        text: null,
      );
      await _insertChatMessage(
        graphDatabase,
        chatSsId: chatSsId,
        messageSsId: textMessageSsId,
      );
      await _insertChatMessage(
        graphDatabase,
        chatSsId: chatSsId,
        messageSsId: noTextMessageSsId,
      );

      final reader = ChatSummaryReader(
        repository: SqliteChatSummaryRepository(graphDatabase: graphDatabase),
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

    await _insertChat(graphDatabase, ssId: chatSsId);
    await _insertMessage(
      graphDatabase,
      ssId: firstMessageSsId,
      guid: 'message-guid-1',
      dateUtc: '2026-05-19T10:00:00.000Z',
      text: 'photo',
    );
    await _insertMessage(
      graphDatabase,
      ssId: secondMessageSsId,
      dateUtc: '2026-05-20T10:00:00.000Z',
      text: 'document',
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: firstMessageSsId,
    );
    await _insertChatMessage(
      graphDatabase,
      chatSsId: chatSsId,
      messageSsId: secondMessageSsId,
    );
    await _insertAttachment(
      graphDatabase,
      ssId: imageAttachmentSsId,
      transferName: 'photo.jpg',
      filename: existingImageFile.path,
      mimeType: 'image/jpeg',
      totalBytes: 1200,
    );
    await _insertAttachment(
      graphDatabase,
      ssId: documentAttachmentSsId,
      transferName: 'brief.pdf',
      filename: missingDocumentPath,
      mimeType: 'application/pdf',
      totalBytes: 2400,
    );
    await _insertMessageAttachment(
      graphDatabase,
      messageSsId: firstMessageSsId,
      attachmentSsId: imageAttachmentSsId,
    );
    await _insertMessageAttachment(
      graphDatabase,
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
        graphDatabase: graphDatabase,
        archiveLookup: OverlayArchiveCompatibilityLookup(
          graphDatabase: graphDatabase,
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
  ConversationGraphDatabase graphDatabase, {
  required int ssId,
}) async {
  await graphDatabase.database.insert('chats', <String, Object?>{
    'ss_id': ssId,
    'guid': 'chat-$ssId',
    'is_group': 0,
  });
}

Future<void> _insertHandle(
  ConversationGraphDatabase graphDatabase, {
  required int ssId,
  required String id,
}) async {
  await graphDatabase.database.insert('handles', <String, Object?>{
    'ss_id': ssId,
    'id': id,
  });
}

Future<void> _insertMessage(
  ConversationGraphDatabase graphDatabase, {
  required int ssId,
  required String dateUtc,
  required String? text,
  String? guid,
  bool isFromMe = false,
}) async {
  await graphDatabase.database.insert('messages', <String, Object?>{
    'ss_id': ssId,
    'guid': guid ?? 'message-$ssId',
    'is_from_me': isFromMe ? 1 : 0,
    'date_utc': dateUtc,
    'text': text,
  });
}

Future<void> _insertChatHandle(
  ConversationGraphDatabase graphDatabase, {
  required int chatSsId,
  required int handleSsId,
}) async {
  await graphDatabase.database.insert('chat_to_handle', <String, Object?>{
    'chat_ss_id': chatSsId,
    'handle_ss_id': handleSsId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertChatMessage(
  ConversationGraphDatabase graphDatabase, {
  required int chatSsId,
  required int messageSsId,
}) async {
  await graphDatabase.database.insert('chat_to_message', <String, Object?>{
    'chat_ss_id': chatSsId,
    'message_ss_id': messageSsId,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);
}

Future<void> _insertAttachment(
  ConversationGraphDatabase graphDatabase, {
  required int ssId,
  required String transferName,
  required String filename,
  required String mimeType,
  required int totalBytes,
}) async {
  await graphDatabase.database.insert('attachments', <String, Object?>{
    'ss_id': ssId,
    'guid': 'attachment-$ssId',
    'transfer_name': transferName,
    'filename': filename,
    'mime_type': mimeType,
    'total_bytes': totalBytes,
  });
}

Future<void> _insertMessageAttachment(
  ConversationGraphDatabase graphDatabase, {
  required int messageSsId,
  required int attachmentSsId,
}) async {
  await graphDatabase.database.insert(
    'message_to_attachment',
    <String, Object?>{
      'message_ss_id': messageSsId,
      'attachment_ss_id': attachmentSsId,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}
