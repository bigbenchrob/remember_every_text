import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../import/application/debug_settings_provider.dart';
import '../../domain/entities/db_migration_result.dart';
import '../../domain/states/db_migration_progress.dart';
import '../../domain/value_objects/db_migration_stage.dart';
import '../application_providers/supabase_mirror_sync_service_provider.dart';

typedef DbMigrationProgressCallback =
    void Function(DbMigrationProgress progress);

/// Orchestrates the projection of data from the Sqflite ledger database into
/// the Drift-powered working database used by the UI layer.
class LedgerToWorkingMigrationService {
  LedgerToWorkingMigrationService({required this.ref});

  final Ref ref;

  static const String _logContext = 'LedgerToWorkingMigrationService';

  Future<DbMigrationResult> runMigration({
    DbMigrationProgressCallback? onProgress,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final ledger = await ref.watch(sqfliteImportDatabaseProvider.future);
    final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

    final importDb = await ledger.database;
    var activeBatchId = -1;
    final resultBuilder = _DbMigrationResultBuilder(batchId: activeBatchId);

    void emit(
      DbMigrationStage stage,
      double progress,
      String message, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    }) {
      onProgress?.call(
        DbMigrationProgress(
          stage: stage,
          overallProgress: progress,
          message: message,
          stageProgress: stageProgress,
          stageCurrent: stageCurrent,
          stageTotal: stageTotal,
        ),
      );
      debugSettings.logProgress('$_logContext: $message');
    }

    try {
      emit(
        DbMigrationStage.preparingSources,
        0.02,
        'Locating latest import batch',
      );

      final batchId = await _fetchLatestBatchId(importDb);
      if (batchId == null) {
        const message = 'Ledger contains no import batches to project';
        debugSettings.logError('$_logContext: $message');
        return resultBuilder
            .copyWith(batchId: -1, error: message)
            .build(success: false);
      }

      activeBatchId = batchId;
      resultBuilder.batchId = batchId;

      emit(
        DbMigrationStage.clearingWorking,
        0.08,
        'Clearing existing working projections',
      );
      await _clearWorkingDatabase(workingDb: workingDb);

      emit(
        DbMigrationStage.loadingContacts,
        0.12,
        'Loading contact metadata from ledger batch $batchId',
      );
      final contactIndex = await _loadContacts(
        importDb: importDb,
        batchId: batchId,
      );

      emit(
        DbMigrationStage.migratingIdentities,
        0.25,
        'Projecting identities and handle links',
      );
      final identityProjection = await _projectIdentities(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        contactIndex: contactIndex,
      );
      resultBuilder.identitiesProjected = identityProjection.identityCount;
      resultBuilder.identityHandleLinksProjected =
          identityProjection.handleLinkCount;

      emit(
        DbMigrationStage.migratingChats,
        0.45,
        'Projecting chats and participants',
      );
      final chatProjection = await _projectChats(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        handleToIdentity: identityProjection.handleToIdentityId,
        handleToContact: identityProjection.handleToContactId,
        identityDisplayNames: identityProjection.identityDisplayNames,
        contactIndex: contactIndex,
      );
      resultBuilder.chatsProjected = chatProjection.chatCount;
      resultBuilder.participantsProjected = chatProjection.participantCount;

      emit(DbMigrationStage.migratingMessages, 0.68, 'Projecting messages');
      final attachmentsIndex = await _loadAttachments(
        importDb: importDb,
        batchId: batchId,
      );
      final messageProjection = await _projectMessages(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        chatIdMap: chatProjection.chatIdMap,
        handleToIdentity: identityProjection.handleToIdentityId,
        attachmentsIndex: attachmentsIndex,
      );
      resultBuilder.messagesProjected = messageProjection.messageCount;

      emit(
        DbMigrationStage.migratingAttachments,
        0.82,
        'Projecting attachments',
      );
      final attachmentsInserted = await _projectAttachments(
        workingDb: workingDb,
        attachmentsIndex: attachmentsIndex,
        messageGuidByImportId: messageProjection.messageGuidByImportId,
      );
      resultBuilder.attachmentsProjected = attachmentsInserted;

      emit(DbMigrationStage.migratingReactions, 0.9, 'Projecting reactions');
      final reactionsInserted = await _projectReactions(
        importDb: importDb,
        workingDb: workingDb,
        batchId: batchId,
        handleToIdentity: identityProjection.handleToIdentityId,
        migratedMessageGuids: messageProjection.migratedMessageGuids,
      );
      resultBuilder.reactionsProjected = reactionsInserted;

      emit(
        DbMigrationStage.updatingProjectionState,
        0.96,
        'Updating projection state metadata',
      );
      await _updateProjectionState(workingDb: workingDb, batchId: batchId);

      emit(
        DbMigrationStage.mirroringSupabase,
        0.98,
        'Mirroring working projection to Supabase',
      );
      final mirrorService = await ref.watch(
        supabaseMirrorSyncServiceProvider.future,
      );
      await mirrorService.syncAllPendingBatches();

      emit(
        DbMigrationStage.completed,
        1.0,
        'Projection completed for ledger batch $batchId',
      );

      return resultBuilder.build(success: true);
    } catch (error, stackTrace) {
      debugSettings.logError('$_logContext: migration failed: $error');
      debugSettings.logError('$stackTrace');
      final message = 'Projection failed: $error';
      onProgress?.call(
        DbMigrationProgress(
          stage: DbMigrationStage.completed,
          overallProgress: 1.0,
          message: message,
        ),
      );
      return resultBuilder
          .copyWith(batchId: activeBatchId, error: message)
          .build(success: false);
    }
  }

  Future<int?> _fetchLatestBatchId(Database importDb) async {
    final rows = await importDb.rawQuery(
      'SELECT id FROM import_batches ORDER BY id DESC LIMIT 1',
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['id'];
    return value is int ? value : int.tryParse('$value');
  }

  Future<void> _clearWorkingDatabase({
    required WorkingDatabase workingDb,
  }) async {
    await workingDb.transaction(() async {
      const tablesInDeleteOrder = <String>[
        'message_read_marks',
        'read_state',
        'reaction_counts',
        'reactions',
        'attachments',
        'messages',
        'chat_participants_proj',
        'chats',
        'identity_handle_links',
        'identities',
      ];

      for (final table in tablesInDeleteOrder) {
        await workingDb.customStatement('DELETE FROM $table');
      }
    });
  }

  Future<_ContactIndex> _loadContacts({
    required Database importDb,
    required int batchId,
  }) async {
    final contactRows = await importDb.query(
      'contacts',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final contactsById = <int, _LedgerContact>{};
    for (final row in contactRows) {
      final id = row['id'] as int?;
      if (id == null) {
        continue;
      }
      contactsById[id] = _LedgerContact(
        id: id,
        displayName:
            (row['display_name'] as String?) ??
            _composeDisplayName(
              first: row['given_name'] as String?,
              last: row['family_name'] as String?,
              company: row['organization'] as String?,
            ),
      );
    }

    final channelRows = await importDb.query(
      'contact_channels',
      columns: <String>['contact_id', 'kind', 'value'],
    );

    final normalizedChannelToContactId = <String, int>{};

    for (final row in channelRows) {
      final contactId = row['contact_id'] as int?;
      final kind = row['kind'] as String?;
      final value = row['value'] as String?;
      if (contactId == null || kind == null || value == null) {
        continue;
      }
      if (!contactsById.containsKey(contactId)) {
        continue;
      }
      final keys = _normalizedChannelKeys(kind: kind, value: value);
      for (final key in keys) {
        normalizedChannelToContactId.putIfAbsent(key, () => contactId);
      }
      contactsById[contactId]!.channels.add(
        _ContactChannel(kind: kind, value: value),
      );
    }

    return _ContactIndex(
      contactsById: contactsById,
      normalizedChannelToContactId: normalizedChannelToContactId,
    );
  }

  Future<_IdentityProjection> _projectIdentities({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required _ContactIndex contactIndex,
  }) async {
    final rows = await importDb.query(
      'handles',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final handleToIdentity = <int, int>{};
    final handleToContactId = <int, int>{};
    final identityDisplayNames = <int, String>{};
    final identityLookup = <_IdentityKey, int>{};

    var identitiesInserted = 0;
    var linksInserted = 0;

    for (final row in rows) {
      final handleId = row['id'] as int?;
      if (handleId == null) {
        continue;
      }

      final service = (row['service'] as String?) ?? 'Unknown';
      final rawIdentifier = row['raw_identifier'] as String?;
      final normalizedAddressRaw = row['normalized_address'] as String?;

      final normalized = _normalizeHandleIdentifier(
        rawIdentifier: rawIdentifier,
        normalizedAddress: normalizedAddressRaw,
      );

      int? matchedContactId;
      for (final key in normalized.matchingKeys) {
        final contactId = contactIndex.normalizedChannelToContactId[key];
        if (contactId != null) {
          matchedContactId = contactId;
          break;
        }
      }

      final displayName = matchedContactId != null
          ? contactIndex.contactsById[matchedContactId]?.displayName ??
                (rawIdentifier ?? 'Unknown contact')
          : (rawIdentifier ?? 'Unknown contact');

      if (matchedContactId != null) {
        handleToContactId[handleId] = matchedContactId;
      }

      final key = _IdentityKey(
        service: service,
        normalizedAddress: normalized.canonical ?? rawIdentifier,
      );

      final identityId = await _upsertIdentity(
        workingDb: workingDb,
        identityLookup: identityLookup,
        key: key,
        displayName: displayName,
        contactId: matchedContactId,
        isSystem: false,
        identitiesInserted: () {
          identitiesInserted++;
        },
      );

      identityDisplayNames.putIfAbsent(identityId, () => displayName);

      await workingDb
          .into(workingDb.identityHandleLinks)
          .insert(
            IdentityHandleLinksCompanion.insert(
              identityId: identityId,
              importHandleId: handleId,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      linksInserted++;
      handleToIdentity[handleId] = identityId;
    }

    return _IdentityProjection(
      handleToIdentityId: handleToIdentity,
      handleToContactId: handleToContactId,
      identityDisplayNames: identityDisplayNames,
      identityCount: identitiesInserted,
      handleLinkCount: linksInserted,
    );
  }

  Future<_ChatProjection> _projectChats({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, int> handleToIdentity,
    required Map<int, int> handleToContact,
    required Map<int, String> identityDisplayNames,
    required _ContactIndex contactIndex,
  }) async {
    final chatRows = await importDb.query(
      'chats',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final participantsByChat = await _loadChatParticipants(
      importDb: importDb,
      chatIds: chatRows
          .map((Map<String, Object?> e) => e['id'])
          .whereType<int>()
          .toList(growable: false),
    );

    final chatIdMap = <int, int>{};
    var chatsInserted = 0;
    var participantsInserted = 0;

    for (final row in chatRows) {
      final importChatId = row['id'] as int?;
      if (importChatId == null) {
        continue;
      }
      final guid = (row['guid'] as String?) ?? 'chat-$importChatId';
      final ledgerDisplayName = row['display_name'] as String?;
      final isGroup = ((row['is_group'] as int?) ?? 0) == 1;
      final createdAtUtc = row['created_at_utc'] as String?;
      final updatedAtUtc = row['updated_at_utc'] as String?;
      final service = row['service'] as String?;

      final participants =
          participantsByChat[importChatId] ?? const <_LedgerChatParticipant>[];

      final computedName = _deriveChatDisplayName(
        explicitName: ledgerDisplayName,
        participants: participants,
        handleToIdentity: handleToIdentity,
        handleToContact: handleToContact,
        identityDisplayNames: identityDisplayNames,
        contactIndex: contactIndex,
        isGroup: isGroup,
      );

      final newChatId = await workingDb
          .into(workingDb.workingChats)
          .insert(
            WorkingChatsCompanion.insert(
              guid: guid,
              service: Value(service ?? 'Unknown'),
              isGroup: Value(isGroup),
              computedName: Value(computedName),
              displayName: Value(computedName),
              createdAtUtc: Value(createdAtUtc),
              updatedAtUtc: Value(updatedAtUtc),
            ),
          );
      chatsInserted++;
      chatIdMap[importChatId] = newChatId;

      var sortIndex = 0;
      for (final participant in participants) {
        final handleId = participant.handleId;
        if (handleId == null) {
          continue;
        }
        final identityId = handleToIdentity[handleId];
        if (identityId == null) {
          continue;
        }
        await workingDb
            .into(workingDb.chatParticipantsProj)
            .insert(
              ChatParticipantsProjCompanion.insert(
                chatId: newChatId,
                identityId: identityId,
                role: Value(participant.role ?? 'member'),
                sortKey: Value(sortIndex),
              ),
              mode: InsertMode.insertOrReplace,
            );
        participantsInserted++;
        sortIndex++;
      }
    }

    return _ChatProjection(
      chatIdMap: chatIdMap,
      chatCount: chatsInserted,
      participantCount: participantsInserted,
    );
  }

  Future<_MessageProjection> _projectMessages({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, int> chatIdMap,
    required Map<int, int> handleToIdentity,
    required _AttachmentsIndex attachmentsIndex,
  }) async {
    final messageRows = await importDb.query(
      'messages',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
      orderBy: 'date_utc ASC, id ASC',
    );

    final messageGuidById = <int, String>{};
    final migratedGuids = <String>{};
    var messagesInserted = 0;

    for (final row in messageRows) {
      final messageId = row['id'] as int?;
      final chatId = row['chat_id'] as int?;
      final guid = row['guid'] as String?;
      if (messageId == null || chatId == null || guid == null) {
        continue;
      }
      final workingChatId = chatIdMap[chatId];
      if (workingChatId == null) {
        continue;
      }

      final senderHandleId = row['sender_handle_id'] as int?;
      final senderIdentityId = senderHandleId == null
          ? null
          : handleToIdentity[senderHandleId];
      final isFromMe = ((row['is_from_me'] as int?) ?? 0) == 1;
      final sentAtUtc = row['date_utc'] as String?;
      final deliveredAtUtc = row['date_delivered_utc'] as String?;
      final readAtUtc = row['date_read_utc'] as String?;
      final text = row['text'] as String?;
      final threadOriginatorGuid = row['thread_originator_guid'] as String?;
      final associatedMessageGuid = row['associated_message_guid'] as String?;
      final balloonBundleId = row['balloon_bundle_id'] as String?;
      final isSystemMessage = ((row['is_system_message'] as int?) ?? 0) == 1;
      final itemType = row['item_type'] as String?;
      final errorCode = row['error_code'] as int?;
      final attachmentsForMessage =
          attachmentsIndex.byMessage[messageId] ?? const <_LedgerAttachment>[];

      final status = _deriveMessageStatus(
        isFromMe: isFromMe,
        deliveredAtUtc: deliveredAtUtc,
        readAtUtc: readAtUtc,
        errorCode: errorCode,
      );

      await workingDb
          .into(workingDb.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: guid,
              chatId: workingChatId,
              senderIdentityId: Value(senderIdentityId),
              isFromMe: Value(isFromMe),
              sentAtUtc: Value(sentAtUtc),
              deliveredAtUtc: Value(deliveredAtUtc),
              readAtUtc: Value(readAtUtc),
              status: Value(status),
              textContent: Value(text),
              hasAttachments: Value(attachmentsForMessage.isNotEmpty),
              replyToGuid: Value(threadOriginatorGuid ?? associatedMessageGuid),
              systemType: Value(isSystemMessage ? 'system' : null),
              reactionCarrier: Value(itemType == 'reaction-carrier'),
              balloonBundleId: Value(balloonBundleId),
              updatedAtUtc: Value(sentAtUtc ?? deliveredAtUtc ?? readAtUtc),
            ),
            mode: InsertMode.insertOrReplace,
          );

      messageGuidById[messageId] = guid;
      migratedGuids.add(guid);
      messagesInserted++;
    }

    return _MessageProjection(
      messageGuidByImportId: messageGuidById,
      migratedMessageGuids: migratedGuids,
      messageCount: messagesInserted,
    );
  }

  Future<int> _projectAttachments({
    required WorkingDatabase workingDb,
    required _AttachmentsIndex attachmentsIndex,
    required Map<int, String> messageGuidByImportId,
  }) async {
    var attachmentsInserted = 0;
    for (final attachment in attachmentsIndex.byId.values) {
      final messageId = attachment.messageId;
      if (messageId == null) {
        continue;
      }
      final messageGuid = messageGuidByImportId[messageId];
      if (messageGuid == null) {
        continue;
      }
      await workingDb
          .into(workingDb.workingAttachments)
          .insert(
            WorkingAttachmentsCompanion.insert(
              messageGuid: messageGuid,
              importAttachmentId: Value(attachment.id),
              localPath: Value(attachment.localPath),
              mimeType: Value(attachment.mimeType),
              uti: Value(attachment.uti),
              transferName: Value(attachment.transferName),
              sizeBytes: Value(attachment.totalBytes),
              isSticker: Value(attachment.isSticker),
              createdAtUtc: Value(attachment.createdAtUtc),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      attachmentsInserted++;
    }
    return attachmentsInserted;
  }

  Future<int> _projectReactions({
    required Database importDb,
    required WorkingDatabase workingDb,
    required int batchId,
    required Map<int, int> handleToIdentity,
    required Set<String> migratedMessageGuids,
  }) async {
    final rows = await importDb.query('reactions');
    var reactionsInserted = 0;
    for (final row in rows) {
      final carrierMessageId = row['carrier_message_id'] as int?;
      final targetMessageGuid = row['target_message_guid'] as String?;
      if (carrierMessageId == null || targetMessageGuid == null) {
        continue;
      }
      if (!migratedMessageGuids.contains(targetMessageGuid)) {
        continue;
      }

      final reactorHandleId = row['reactor_handle_id'] as int?;
      final reactorIdentityId = reactorHandleId == null
          ? null
          : handleToIdentity[reactorHandleId];
      final action = row['action'] as String?;
      final kind = (row['kind'] as String?) ?? 'unknown';
      final reactedAtUtc = row['reacted_at_utc'] as String?;

      await workingDb
          .into(workingDb.workingReactions)
          .insert(
            WorkingReactionsCompanion.insert(
              messageGuid: targetMessageGuid,
              kind: kind,
              action: action ?? 'add',
              reactorIdentityId: Value(reactorIdentityId),
              reactedAtUtc: Value(reactedAtUtc),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      reactionsInserted++;
    }
    return reactionsInserted;
  }

  Future<void> _updateProjectionState({
    required WorkingDatabase workingDb,
    required int batchId,
  }) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    await workingDb
        .into(workingDb.projectionState)
        .insertOnConflictUpdate(
          ProjectionStateCompanion(
            id: const Value(1),
            lastImportBatchId: Value(batchId),
            lastProjectedAtUtc: Value(timestamp),
          ),
        );
  }

  Future<Map<int, List<_LedgerChatParticipant>>> _loadChatParticipants({
    required Database importDb,
    required List<int> chatIds,
  }) async {
    if (chatIds.isEmpty) {
      return <int, List<_LedgerChatParticipant>>{};
    }
    final placeholders = List<String>.filled(chatIds.length, '?').join(',');
    final rows = await importDb.rawQuery(
      'SELECT chat_id, handle_id, role FROM chat_participants '
      'WHERE chat_id IN ($placeholders)',
      chatIds,
    );

    final byChat = <int, List<_LedgerChatParticipant>>{};
    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      if (chatId == null) {
        continue;
      }
      byChat
          .putIfAbsent(chatId, () => <_LedgerChatParticipant>[])
          .add(
            _LedgerChatParticipant(
              chatId: chatId,
              handleId: row['handle_id'] as int?,
              role: row['role'] as String?,
            ),
          );
    }
    return byChat;
  }

  Future<_AttachmentsIndex> _loadAttachments({
    required Database importDb,
    required int batchId,
  }) async {
    final attachmentRows = await importDb.query(
      'attachments',
      where: 'batch_id = ?',
      whereArgs: <Object>[batchId],
    );

    final attachmentsById = <int, _LedgerAttachment>{};
    for (final row in attachmentRows) {
      final id = row['id'] as int?;
      if (id == null) {
        continue;
      }
      attachmentsById[id] = _LedgerAttachment(
        id: id,
        messageId: null,
        guid: row['guid'] as String?,
        transferName: row['transfer_name'] as String?,
        uti: row['uti'] as String?,
        mimeType: row['mime_type'] as String?,
        totalBytes: row['total_bytes'] as int?,
        isSticker: ((row['is_sticker'] as int?) ?? 0) == 1,
        createdAtUtc: row['created_at_utc'] as String?,
        localPath: row['local_path'] as String?,
      );
    }

    final joinRows = await importDb.query(
      'message_attachments',
      columns: <String>['message_id', 'attachment_id'],
    );

    final attachmentsByMessage = <int, List<_LedgerAttachment>>{};
    for (final row in joinRows) {
      final messageId = row['message_id'] as int?;
      final attachmentId = row['attachment_id'] as int?;
      if (messageId == null || attachmentId == null) {
        continue;
      }
      final attachment = attachmentsById[attachmentId];
      if (attachment == null) {
        continue;
      }
      final updated = attachment.copyWith(messageId: messageId);
      attachmentsById[attachmentId] = updated;
      attachmentsByMessage
          .putIfAbsent(messageId, () => <_LedgerAttachment>[])
          .add(updated);
    }

    return _AttachmentsIndex(
      byId: attachmentsById,
      byMessage: attachmentsByMessage,
    );
  }

  String _deriveChatDisplayName({
    required String? explicitName,
    required List<_LedgerChatParticipant> participants,
    required Map<int, int> handleToIdentity,
    required Map<int, int> handleToContact,
    required Map<int, String> identityDisplayNames,
    required _ContactIndex contactIndex,
    required bool isGroup,
  }) {
    if (explicitName != null && explicitName.trim().isNotEmpty) {
      return explicitName.trim();
    }

    final participantNames = <String>[];
    for (final participant in participants) {
      final handleId = participant.handleId;
      if (handleId == null) {
        continue;
      }
      final identityId = handleToIdentity[handleId];
      if (identityId == null) {
        continue;
      }
      final contactId = handleToContact[handleId];
      if (contactId != null) {
        final name = contactIndex.contactsById[contactId]?.displayName;
        if (name != null && name.trim().isNotEmpty) {
          participantNames.add(name.trim());
          continue;
        }
      }
      final identityName = identityDisplayNames[identityId];
      if (identityName != null && identityName.trim().isNotEmpty) {
        participantNames.add(identityName.trim());
        continue;
      }
      participantNames.add('Participant');
    }

    if (participantNames.isEmpty) {
      return isGroup ? 'Group chat' : 'Conversation';
    }

    if (isGroup) {
      return participantNames.take(3).join(', ');
    }

    return participantNames.first;
  }

  String _deriveMessageStatus({
    required bool isFromMe,
    required String? deliveredAtUtc,
    required String? readAtUtc,
    required int? errorCode,
  }) {
    if (errorCode != null && errorCode != 0) {
      return 'failed';
    }
    if (readAtUtc != null) {
      return 'read';
    }
    if (deliveredAtUtc != null) {
      return 'delivered';
    }
    if (isFromMe) {
      return 'sent';
    }
    return 'unknown';
  }

  String _composeDisplayName({
    required String? first,
    required String? last,
    required String? company,
  }) {
    if (first != null && first.isNotEmpty || last != null && last.isNotEmpty) {
      final firstPart = first?.trim() ?? '';
      final lastPart = last?.trim() ?? '';
      return '$firstPart $lastPart'.trim().isNotEmpty
          ? '$firstPart $lastPart'.trim()
          : (company ?? '').trim();
    }
    if (company != null && company.trim().isNotEmpty) {
      return company.trim();
    }
    return 'Unknown contact';
  }

  Iterable<String> _normalizedChannelKeys({
    required String kind,
    required String value,
  }) {
    final keys = <String>{};
    if (kind == 'phone') {
      final digitsOnly = value.replaceAll(RegExp(r'[^0-9+]'), '');
      final trimmed = digitsOnly.trim();
      if (trimmed.isEmpty) {
        return <String>{value.trim()};
      }
      final canonical = _normalizePhoneNumber(trimmed);
      keys.add(canonical);
      keys.add(trimmed);
      if (!trimmed.startsWith('+')) {
        keys.add('+$trimmed');
      }
    } else if (kind == 'email') {
      keys.add(value.trim().toLowerCase());
    } else {
      keys.add(value.trim());
    }
    return keys.where((String element) => element.isNotEmpty);
  }

  _NormalizedIdentifier _normalizeHandleIdentifier({
    required String? rawIdentifier,
    required String? normalizedAddress,
  }) {
    final canonical = normalizedAddress?.trim().isNotEmpty == true
        ? normalizedAddress!.trim()
        : rawIdentifier?.trim();
    final keys = <String>{};
    if (canonical != null && canonical.isNotEmpty) {
      keys.add(canonical);
    }
    if (canonical != null && RegExp(r'[0-9]').hasMatch(canonical)) {
      keys.add(_normalizePhoneNumber(canonical));
    }
    if (rawIdentifier != null) {
      keys.add(rawIdentifier.trim());
    }
    return _NormalizedIdentifier(
      canonical: canonical,
      matchingKeys: keys.where((String element) => element.isNotEmpty).toSet(),
    );
  }

  String _normalizePhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return input;
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return digits.substring(1);
    }
    return digits;
  }

  Future<int> _upsertIdentity({
    required WorkingDatabase workingDb,
    required Map<_IdentityKey, int> identityLookup,
    required _IdentityKey key,
    required String displayName,
    required int? contactId,
    required bool isSystem,
    required void Function() identitiesInserted,
  }) async {
    final existingId = identityLookup[key];
    if (existingId != null) {
      return existingId;
    }
    final newId = await workingDb
        .into(workingDb.workingIdentities)
        .insert(
          WorkingIdentitiesCompanion.insert(
            normalizedAddress: Value(key.normalizedAddress),
            service: Value(key.service),
            displayName: Value(displayName),
            contactRef: contactId == null
                ? const Value.absent()
                : Value('contact:$contactId'),
            isSystem: Value(isSystem),
          ),
        );
    identityLookup[key] = newId;
    identitiesInserted();
    return newId;
  }
}

class _ContactIndex {
  _ContactIndex({
    required this.contactsById,
    required this.normalizedChannelToContactId,
  });

  final Map<int, _LedgerContact> contactsById;
  final Map<String, int> normalizedChannelToContactId;
}

class _LedgerContact {
  _LedgerContact({required this.id, required this.displayName});

  final int id;
  final String displayName;
  final List<_ContactChannel> channels = <_ContactChannel>[];
}

class _ContactChannel {
  _ContactChannel({required this.kind, required this.value});

  final String kind;
  final String value;

  Iterable<String> get normalizedKeys => kind == 'email'
      ? <String>[value.trim().toLowerCase()]
      : <String>[_normalize(value)];

  String _normalize(String input) {
    if (kind == 'phone') {
      final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length == 11 && digits.startsWith('1')) {
        return digits.substring(1);
      }
      return digits;
    }
    return input.trim();
  }
}

class _LedgerChatParticipant {
  const _LedgerChatParticipant({
    required this.chatId,
    required this.handleId,
    required this.role,
  });

  final int chatId;
  final int? handleId;
  final String? role;
}

class _LedgerAttachment {
  _LedgerAttachment({
    required this.id,
    required this.messageId,
    required this.guid,
    required this.transferName,
    required this.uti,
    required this.mimeType,
    required this.totalBytes,
    required this.isSticker,
    required this.createdAtUtc,
    required this.localPath,
  });

  final int id;
  final int? messageId;
  final String? guid;
  final String? transferName;
  final String? uti;
  final String? mimeType;
  final int? totalBytes;
  final bool isSticker;
  final String? createdAtUtc;
  final String? localPath;

  _LedgerAttachment copyWith({int? messageId}) {
    return _LedgerAttachment(
      id: id,
      messageId: messageId ?? this.messageId,
      guid: guid,
      transferName: transferName,
      uti: uti,
      mimeType: mimeType,
      totalBytes: totalBytes,
      isSticker: isSticker,
      createdAtUtc: createdAtUtc,
      localPath: localPath,
    );
  }
}

class _AttachmentsIndex {
  _AttachmentsIndex({required this.byId, required this.byMessage});

  final Map<int, _LedgerAttachment> byId;
  final Map<int, List<_LedgerAttachment>> byMessage;
}

@immutable
class _IdentityKey {
  const _IdentityKey({required this.service, required this.normalizedAddress});

  final String service;
  final String? normalizedAddress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! _IdentityKey) {
      return false;
    }
    return other.service == service &&
        other.normalizedAddress == normalizedAddress;
  }

  @override
  int get hashCode => Object.hash(service, normalizedAddress);
}

class _NormalizedIdentifier {
  const _NormalizedIdentifier({
    required this.canonical,
    required this.matchingKeys,
  });

  final String? canonical;
  final Set<String> matchingKeys;
}

class _IdentityProjection {
  const _IdentityProjection({
    required this.handleToIdentityId,
    required this.handleToContactId,
    required this.identityDisplayNames,
    required this.identityCount,
    required this.handleLinkCount,
  });

  final Map<int, int> handleToIdentityId;
  final Map<int, int> handleToContactId;
  final Map<int, String> identityDisplayNames;
  final int identityCount;
  final int handleLinkCount;
}

class _ChatProjection {
  const _ChatProjection({
    required this.chatIdMap,
    required this.chatCount,
    required this.participantCount,
  });

  final Map<int, int> chatIdMap;
  final int chatCount;
  final int participantCount;
}

class _MessageProjection {
  const _MessageProjection({
    required this.messageGuidByImportId,
    required this.migratedMessageGuids,
    required this.messageCount,
  });

  final Map<int, String> messageGuidByImportId;
  final Set<String> migratedMessageGuids;
  final int messageCount;
}

class _DbMigrationResultBuilder {
  _DbMigrationResultBuilder({required this.batchId});

  int batchId;
  String? error;
  int identitiesProjected = 0;
  int identityHandleLinksProjected = 0;
  int chatsProjected = 0;
  int participantsProjected = 0;
  int messagesProjected = 0;
  int attachmentsProjected = 0;
  int reactionsProjected = 0;
  final List<String> warnings = <String>[];

  _DbMigrationResultBuilder copyWith({int? batchId, String? error}) {
    this.batchId = batchId ?? this.batchId;
    this.error = error ?? this.error;
    return this;
  }

  DbMigrationResult build({required bool success}) {
    return DbMigrationResult(
      batchId: batchId,
      success: success,
      error: error,
      identitiesProjected: identitiesProjected,
      identityHandleLinksProjected: identityHandleLinksProjected,
      chatsProjected: chatsProjected,
      participantsProjected: participantsProjected,
      messagesProjected: messagesProjected,
      attachmentsProjected: attachmentsProjected,
      reactionsProjected: reactionsProjected,
      warnings: warnings,
    );
  }
}
