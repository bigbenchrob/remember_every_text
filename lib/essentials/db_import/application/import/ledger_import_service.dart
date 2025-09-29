import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../features/address_book_folders/feature_level_providers.dart';
import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../domain/entities/db_import_result.dart';
import '../../domain/ports/message_extractor_port.dart';
import '../../domain/states/db_import_progress.dart';
import '../../domain/value_objects/db_import_stage.dart';
import '../debug_settings_provider.dart';

typedef DbImportProgressCallback = void Function(DbImportProgress progress);

/// Coordinates a full ingest from macOS `chat.db` and AddressBook into the
/// Sqflite ledger database (`macos_import.db`).
class LedgerImportService {
  LedgerImportService({
    required this.ref,
    required this.extractor,
    this.rustExtractionLimit = 200000,
  });

  final Ref ref;
  final MessageExtractorPort extractor;
  final int rustExtractionLimit;

  static const String _importLogContext = 'LedgerImportService';

  Future<DbImportResult> runImport({
    DbImportProgressCallback? onProgress,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final ledgerDb = await ref.watch(sqfliteImportDatabaseProvider.future);
    final pathsHelper = await ref.watch(pathsHelperProvider.future);

    final messagesDbPath = pathsHelper.chatDBPath;
    final addressBookEither = await ref.watch(
      futureGetFolderAggregateProvider.future,
    );
    String? addressBookPath;
    String? addressBookFailure;
    addressBookEither.fold(
      (failure) => addressBookFailure = failure.message,
      (aggregate) => addressBookPath = aggregate.mostRecentFolderPath,
    );

    if (addressBookPath == null) {
      final failureMessage =
          addressBookFailure ??
          'AddressBook path could not be resolved via getFolderAggregateEitherProvider';
      debugSettings.logError('$_importLogContext: $failureMessage');
      return DbImportResult(batchId: -1, success: false, error: failureMessage);
    }

    final resolvedAddressBookPath = addressBookPath!;

    final messagesFile = File(messagesDbPath);
    final addressBookFile = File(resolvedAddressBookPath);

    if (!messagesFile.existsSync()) {
      final message = 'Messages database not found at $messagesDbPath';
      debugSettings.logError('$_importLogContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }

    if (!addressBookFile.existsSync()) {
      final message =
          'AddressBook database not found at $resolvedAddressBookPath';
      debugSettings.logError('$_importLogContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }

    final now = DateTime.now().toUtc();
    final startedAtUtc = now.toIso8601String();

    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: messagesDbPath,
      sourceAddressbook: resolvedAddressBookPath,
      hostInfoJson: await _buildHostInfoJson(),
      notes: 'Automated import run ${now.toIso8601String()}',
    );

    debugSettings.logDatabase(
      '$_importLogContext: created import batch $batchId',
    );

    final resultBuilder = _DbImportResultBuilder(batchId: batchId);

    void emit(
      DbImportStage stage,
      double progress,
      String message, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    }) {
      onProgress?.call(
        DbImportProgress(
          stage: stage,
          overallProgress: progress,
          message: message,
          stageProgress: stageProgress,
          stageCurrent: stageCurrent,
          stageTotal: stageTotal,
        ),
      );
      if (stage == DbImportStage.completed) {
        debugSettings.logProgress('$_importLogContext: $message');
      }
    }

    emit(DbImportStage.preparingSources, 0.02, 'Preparing source metadata');

    await _recordSourceFile(
      ledgerDb: ledgerDb,
      batchId: batchId,
      file: messagesFile,
    );
    await _recordSourceFile(
      ledgerDb: ledgerDb,
      batchId: batchId,
      file: addressBookFile,
    );

    emit(DbImportStage.clearingLedger, 0.05, 'Clearing previous ledger data');
    await ledgerDb.clearAllData();

    Database? messagesDb;
    Database? addressBookDb;

    try {
      messagesDb = await openDatabase(messagesDbPath, readOnly: true);
      addressBookDb = await openDatabase(
        resolvedAddressBookPath,
        readOnly: true,
      );

      resultBuilder.handlesImported = await _importHandles(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
      );

      resultBuilder.chatsImported = await _importChats(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
      );

      resultBuilder.participantsImported = await _importChatParticipants(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
      );

      final chatJoinCache = await _buildChatMessageJoinCache(
        messagesDb: messagesDb,
        cachingEnabled: debugSettings.ledgerRowCachingEnabled,
        debugSettings: debugSettings,
      );

      final extraction = await _extractRichText(
        extractor: extractor,
        messagesDbPath: messagesDbPath,
        messagesDb: messagesDb,
      );

      resultBuilder.messagesImported = await _importMessages(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        chatJoinCache: chatJoinCache,
        extraction: extraction,
        emit: emit,
      );

      final attachmentsCounts = await _importAttachments(
        ledgerDb: ledgerDb,
        batchId: batchId,
        messagesDb: messagesDb,
        emit: emit,
      );
      resultBuilder.attachmentsImported = attachmentsCounts.attachments;
      resultBuilder.messageAttachmentsImported =
          attachmentsCounts.messageAttachments;

      resultBuilder.contactsImported = await _importContacts(
        ledgerDb: ledgerDb,
        batchId: batchId,
        addressBookDb: addressBookDb,
        emit: emit,
      );
      resultBuilder.contactChannelsImported = await _importContactChannels(
        ledgerDb: ledgerDb,
        batchId: batchId,
        addressBookDb: addressBookDb,
        emit: emit,
      );

      emit(DbImportStage.completed, 1.0, 'Import completed successfully');

      await ledgerDb.insertImportBatch(
        id: batchId,
        startedAtUtc: startedAtUtc,
        finishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        sourceChatDb: messagesDbPath,
        sourceAddressbook: resolvedAddressBookPath,
        hostInfoJson: await _buildHostInfoJson(),
        notes: 'Completed import run',
      );

      return resultBuilder.build(success: true);
    } catch (error, stackTrace) {
      debugSettings.logError(
        '$_importLogContext: import failed with $error\n$stackTrace',
      );
      resultBuilder.error = error.toString();
      return resultBuilder.build(success: false);
    } finally {
      await messagesDb?.close();
      await addressBookDb?.close();
    }
  }

  Future<void> _recordSourceFile({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required File file,
  }) async {
    try {
      final stat = file.statSync();
      await ledgerDb.insertSourceFile(
        batchId: batchId,
        path: p.normalize(file.path),
        sizeBytes: stat.size,
        mtimeUtc: stat.modified.toUtc().toIso8601String(),
      );
    } catch (_) {
      // Ignore failures here; they are not fatal to the import.
    }
  }

  Future<int> _importHandles({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingHandles,
      0.1,
      'Importing message handles',
      stageProgress: 0,
    );

    final rows = await messagesDb.query('handle');
    var processed = 0;
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final rawIdentifier = (row['id'] as String?)?.trim();
      final normalizedAddress = _normalizeIdentifier(rawIdentifier);
      final service = (row['service'] as String?)?.trim();
      final country = (row['country'] as String?)?.trim();
      final lastSeen = row['last_read_date'] as int? ?? row['last_use'] as int?;
      final lastSeenUtc = _appleEpochToIsoString(lastSeen);

      await ledgerDb.insertHandle(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        service: service ?? 'Unknown',
        rawIdentifier: rawIdentifier ?? 'unknown',
        normalizedAddress: normalizedAddress,
        country: country,
        lastSeenUtc: lastSeenUtc,
        batchId: batchId,
      );

      processed++;
      if (processed % 200 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingHandles,
          0.12,
          'Imported $processed/${rows.length} handles',
          stageProgress: processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }

    return rows.length;
  }

  Future<int> _importChats({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingChats,
      0.18,
      'Importing chats',
      stageProgress: 0,
    );
    final rows = await messagesDb.query('chat');
    var processed = 0;
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = (row['guid'] as String?)?.trim();
      if (guid == null || guid.isEmpty) {
        continue;
      }
      final isGroup = (row['is_group'] as int? ?? 0) == 1;
      final created = row['creation_date'] as int?;
      final updated = row['last_read_message_timestamp'] as int?;

      await ledgerDb.insertChat(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: guid,
        service: (row['service_name'] as String?)?.trim() ?? 'Unknown',
        displayName: (row['display_name'] as String?)?.trim(),
        isGroup: isGroup,
        createdAtUtc: _appleEpochToIsoString(created),
        updatedAtUtc: _appleEpochToIsoString(updated),
        batchId: batchId,
      );

      processed++;
      if (processed % 100 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingChats,
          0.24,
          'Imported $processed/${rows.length} chats',
          stageProgress: processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }
    return rows.length;
  }

  Future<int> _importChatParticipants({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingParticipants,
      0.28,
      'Importing chat participants',
      stageProgress: 0,
    );
    final rows = await messagesDb.query('chat_handle_join');
    var processed = 0;
    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      final handleId = row['handle_id'] as int?;
      if (chatId == null || handleId == null) {
        continue;
      }
      await ledgerDb.insertChatParticipant(chatId: chatId, handleId: handleId);
      processed++;
      if (processed % 500 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingParticipants,
          0.32,
          'Linked $processed/${rows.length} participants',
          stageProgress: processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }
    return rows.length;
  }

  Future<_ChatMessageJoinCache> _buildChatMessageJoinCache({
    required Database messagesDb,
    required bool cachingEnabled,
    required ImportDebugSettingsState debugSettings,
  }) async {
    if (!cachingEnabled) {
      debugSettings.logProgress(
        'LedgerImportService: ledger row caching disabled; using per-message lookups',
      );
      return _ChatMessageJoinCache.disabled();
    }

    final rows = await messagesDb.query('chat_message_join');
    final messageToChat = <int, int>{};
    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      final messageId = row['message_id'] as int?;
      if (chatId == null || messageId == null) {
        continue;
      }
      messageToChat.putIfAbsent(messageId, () => chatId);
    }

    debugSettings.logProgress(
      'LedgerImportService: cached ${messageToChat.length} chat-message joins',
    );
    return _ChatMessageJoinCache.enabled(messageToChat);
  }

  Future<_RichTextExtraction> _extractRichText({
    required MessageExtractorPort extractor,
    required String messagesDbPath,
    required Database messagesDb,
  }) async {
    final rows = await messagesDb.query('message');
    final blobMessageIds = <int>[];
    for (final row in rows) {
      final rowId = row['ROWID'] as int?;
      if (rowId == null) {
        continue;
      }
      final text = row['text'] as String?;
      final attributed = row['attributedBody'] as Uint8List?;
      if ((text == null || text.isEmpty) && attributed != null) {
        blobMessageIds.add(rowId);
      }
    }

    if (blobMessageIds.isEmpty) {
      return const _RichTextExtraction(messages: <int, String>{});
    }

    final extracted = await extractor.extractAllMessageTexts(
      limit: rustExtractionLimit,
      dbPath: messagesDbPath,
    );
    return _RichTextExtraction(messages: extracted);
  }

  Future<int> _importMessages({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required _ChatMessageJoinCache chatJoinCache,
    required _RichTextExtraction extraction,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(DbImportStage.importingMessages, 0.36, 'Importing messages');
    final rows = await messagesDb.query('message');
    var processed = 0;

    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = row['guid'] as String?;
      if (sourceRowId == null || guid == null || guid.isEmpty) {
        continue;
      }

      final chatId = await chatJoinCache.resolveChatId(
        messagesDb: messagesDb,
        messageId: sourceRowId,
      );
      if (chatId == null) {
        continue;
      }

      final text = row['text'] as String?;
      final attributed = row['attributedBody'] as Uint8List?;
      final extractedText = extraction.messages[sourceRowId];
      final resolvedText = (text == null || text.isEmpty)
          ? extractedText
          : text;

      final messageInserted = await ledgerDb.insertMessage(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: guid,
        chatId: chatId,
        senderHandleId: row['handle_id'] as int?,
        service: (row['service'] as String?)?.trim() ?? 'Unknown',
        isFromMe: (row['is_from_me'] as int? ?? 0) == 1,
        dateUtc: _appleEpochToIsoString(row['date'] as int?),
        dateReadUtc: _appleEpochToIsoString(row['date_read'] as int?),
        dateDeliveredUtc: _appleEpochToIsoString(row['date_delivered'] as int?),
        subject: (row['subject'] as String?)?.trim(),
        text: resolvedText,
        attributedBodyBlob: attributed,
        itemType: _inferItemType(row),
        errorCode: row['error'] as int?,
        isSystemMessage: (row['is_system_message'] as int? ?? 0) == 1,
        threadOriginatorGuid: row['thread_originator_guid'] as String?,
        associatedMessageGuid: row['associated_message_guid'] as String?,
        balloonBundleId: row['balloon_bundle_id'] as String?,
        payloadJson: _decodeOptionalBlob(row['payload_data']),
        batchId: batchId,
      );

      if (messageInserted > 0) {
        await ledgerDb.insertChatMessageJoinSource(
          chatId: chatId,
          messageId: sourceRowId,
          sourceRowid: sourceRowId,
        );
      }

      processed++;
      if (processed % 500 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingMessages,
          0.52,
          'Imported $processed/${rows.length} messages',
          stageProgress: processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }

    return rows.length;
  }

  Future<_AttachmentCounts> _importAttachments({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database messagesDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(DbImportStage.importingAttachments, 0.6, 'Importing attachments');
    final attachments = await messagesDb.query('attachment');
    var processed = 0;
    for (final row in attachments) {
      final sourceRowId = row['ROWID'] as int?;
      await ledgerDb.insertAttachment(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: row['guid'] as String?,
        transferName: row['transfer_name'] as String?,
        uti: row['uti'] as String?,
        mimeType: row['mime_type'] as String?,
        totalBytes: row['total_bytes'] as int?,
        isSticker: (row['is_sticker'] as int? ?? 0) == 1,
        isOutgoing: _nullableBool(row['is_outgoing'] as int?),
        createdAtUtc: _appleEpochToIsoString(row['created_date'] as int?),
        localPath: row['filename'] as String?,
        batchId: batchId,
      );
      processed++;
      if (processed % 200 == 0 || processed == attachments.length) {
        emit(
          DbImportStage.importingAttachments,
          0.66,
          'Imported $processed/${attachments.length} attachments',
          stageProgress: processed / attachments.length,
          stageCurrent: processed,
          stageTotal: attachments.length,
        );
      }
    }

    final joins = await messagesDb.query('message_attachment_join');
    processed = 0;
    for (final row in joins) {
      final messageId = row['message_id'] as int?;
      final attachmentId = row['attachment_id'] as int?;
      if (messageId == null || attachmentId == null) {
        continue;
      }
      await ledgerDb.insertMessageAttachment(
        messageId: messageId,
        attachmentId: attachmentId,
        sourceRowid: row['ROWID'] as int?,
      );
      processed++;
      if (processed % 500 == 0 || processed == joins.length) {
        emit(
          DbImportStage.linkingMessageArtifacts,
          0.7,
          'Linked $processed/${joins.length} message attachments',
          stageProgress: processed / joins.length,
          stageCurrent: processed,
          stageTotal: joins.length,
        );
      }
    }

    return _AttachmentCounts(
      attachments: attachments.length,
      messageAttachments: joins.length,
    );
  }

  Future<int> _importContacts({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database addressBookDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(DbImportStage.importingAddressBook, 0.78, 'Importing contacts');
    final rows = await addressBookDb.query('ZABCDRECORD');
    var processed = 0;
    for (final row in rows) {
      final recordId = row['Z_PK'] as int?;
      if (recordId == null) {
        continue;
      }
      final first = row['ZFIRSTNAME'] as String?;
      final last = row['ZLASTNAME'] as String?;
      final company = row['ZORGANIZATION'] as String?;
      final isCompany = (row['ZISCOMPANY'] as int? ?? 0) == 1;

      await ledgerDb.insertContact(
        id: recordId,
        sourceRecordId: recordId,
        displayName: _buildDisplayName(first, last, company, isCompany),
        givenName: first,
        familyName: last,
        organization: company,
        isOrganization: isCompany,
        createdAtUtc: _appleEpochToIsoString(row['ZCREATIONDATE'] as int?),
        updatedAtUtc: _appleEpochToIsoString(row['ZMODIFICATIONDATE'] as int?),
        batchId: batchId,
      );
      processed++;
      if (processed % 200 == 0 || processed == rows.length) {
        emit(
          DbImportStage.importingAddressBook,
          0.82,
          'Imported $processed/${rows.length} contacts',
          stageProgress: processed / rows.length,
          stageCurrent: processed,
          stageTotal: rows.length,
        );
      }
    }
    return rows.length;
  }

  Future<int> _importContactChannels({
    required SqfliteImportDatabase ledgerDb,
    required int batchId,
    required Database addressBookDb,
    required void Function(
      DbImportStage,
      double,
      String, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    })
    emit,
  }) async {
    emit(
      DbImportStage.importingAddressBook,
      0.86,
      'Importing contact channels',
    );
    var totalChannels = 0;

    final emailRows = await addressBookDb.query('ZABCDEMAILADDRESS');
    for (final row in emailRows) {
      final recordId = row['ZOWNER'] as int?;
      if (recordId == null) {
        continue;
      }
      final value = (row['ZADDRESS'] as String?)?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      await ledgerDb.insertContactChannel(
        contactId: recordId,
        kind: 'email',
        value: value.toLowerCase(),
        label: row['ZLABEL'] as String?,
      );
      totalChannels++;
    }

    final phoneRows = await addressBookDb.query('ZABCDPHONENUMBER');
    for (final row in phoneRows) {
      final recordId = row['ZOWNER'] as int?;
      if (recordId == null) {
        continue;
      }
      final value = (row['ZFULLNUMBER'] as String?)?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      await ledgerDb.insertContactChannel(
        contactId: recordId,
        kind: 'phone',
        value: _normalizeIdentifier(value) ?? value,
        label: row['ZLABEL'] as String?,
      );
      totalChannels++;
    }

    emit(
      DbImportStage.importingAddressBook,
      0.9,
      'Imported $totalChannels contact channels',
      stageProgress: 1,
    );

    return totalChannels;
  }

  Future<String?> _buildHostInfoJson() async {
    try {
      final info = <String, Object?>{
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
      };
      return jsonEncode(info);
    } catch (_) {
      return null;
    }
  }

  String? _normalizeIdentifier(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.contains('@')) {
      return trimmed.toLowerCase();
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) {
      return null;
    }
    final normalized = digits.startsWith('+') ? digits.substring(1) : digits;
    if (normalized.length == 11 && normalized.startsWith('1')) {
      return normalized.substring(1);
    }
    return normalized;
  }

  bool? _nullableBool(int? value) {
    if (value == null) {
      return null;
    }
    if (value == 1) {
      return true;
    }
    if (value == 0) {
      return false;
    }
    return null;
  }

  String? _decodeOptionalBlob(Object? blob) {
    if (blob is Uint8List) {
      try {
        return utf8.decode(blob, allowMalformed: true);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String? _appleEpochToIsoString(int? raw) {
    if (raw == null || raw == 0) {
      return null;
    }
    final dateTime = _appleEpochToDate(raw).toUtc();
    return dateTime.toIso8601String();
  }

  DateTime _appleEpochToDate(int raw) {
    const appleEpochSecondsOffset = 978307200; // 2001-01-01 to 1970-01-01
    final absRaw = raw.abs();
    final microseconds = absRaw > 1000000000000
        ? raw ~/ 1000
        : absRaw > 1000000000
        ? raw
        : raw * 1000000;
    final epochMicros = (appleEpochSecondsOffset * 1000000) + microseconds;
    return DateTime.fromMicrosecondsSinceEpoch(epochMicros, isUtc: true);
  }

  String? _buildDisplayName(
    String? first,
    String? last,
    String? company,
    bool isCompany,
  ) {
    if (isCompany) {
      return company ?? 'Unknown';
    }
    if (first != null && last != null) {
      return '$first $last'.trim();
    }
    return first ?? last ?? company ?? 'Unknown';
  }

  String _inferItemType(Map<String, Object?> row) {
    final text = row['text'] as String?;
    final associated = row['associated_message_guid'] as String?;
    final balloonId = row['balloon_bundle_id'] as String?;
    if (associated != null && associated.isNotEmpty) {
      return 'reaction-carrier';
    }
    if (balloonId != null && balloonId.isNotEmpty) {
      return 'sticker';
    }
    if (text == null || text.isEmpty) {
      return 'attachment-only';
    }
    return 'text';
  }
}

class _DbImportResultBuilder {
  _DbImportResultBuilder({required this.batchId});

  final int batchId;
  int handlesImported = 0;
  int chatsImported = 0;
  int participantsImported = 0;
  int messagesImported = 0;
  int attachmentsImported = 0;
  int messageAttachmentsImported = 0;
  int reactionsImported = 0;
  int contactChannelsImported = 0;
  int contactsImported = 0;
  String? error;
  final List<String> warnings = <String>[];

  DbImportResult build({required bool success}) {
    return DbImportResult(
      batchId: batchId,
      success: success,
      error: error,
      handlesImported: handlesImported,
      chatsImported: chatsImported,
      participantsImported: participantsImported,
      messagesImported: messagesImported,
      attachmentsImported: attachmentsImported,
      messageAttachmentsImported: messageAttachmentsImported,
      reactionsImported: reactionsImported,
      contactChannelsImported: contactChannelsImported,
      contactsImported: contactsImported,
      warnings: warnings,
    );
  }
}

class _ChatMessageJoinCache {
  _ChatMessageJoinCache.enabled(Map<int, int> cache) : _messageToChat = cache;

  _ChatMessageJoinCache.disabled() : _messageToChat = <int, int>{};

  final Map<int, int> _messageToChat;

  bool get isEnabled => _messageToChat.isNotEmpty;

  Future<int?> resolveChatId({
    required Database messagesDb,
    required int messageId,
  }) async {
    final cached = _messageToChat[messageId];
    if (cached != null) {
      return cached;
    }

    if (isEnabled) {
      return null;
    }

    final rows = await messagesDb.query(
      'chat_message_join',
      columns: <String>['chat_id'],
      where: 'message_id = ?',
      whereArgs: <Object>[messageId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final value = rows.first['chat_id'];
    final chatId = value is int
        ? value
        : value is num
        ? value.toInt()
        : int.tryParse('$value');
    if (chatId != null) {
      _messageToChat[messageId] = chatId;
    }
    return chatId;
  }
}

class _RichTextExtraction {
  const _RichTextExtraction({required this.messages});

  final Map<int, String> messages;
}

class _AttachmentCounts {
  const _AttachmentCounts({
    required this.attachments,
    required this.messageAttachments,
  });

  final int attachments;
  final int messageAttachments;
}
