import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import '../../../../core/util/date_converter.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../essentials/db/shared/handle_identifier_utils.dart';
import '../../../../essentials/logging/application/app_logger.dart';
import 'historical_archive_import_result.dart';
import 'historical_archive_preflight_summary.dart';

part 'historical_archive_merge_service_provider.g.dart';

@riverpod
HistoricalArchiveMergeService historicalArchiveMergeService(Ref ref) {
  return HistoricalArchiveMergeService(ref);
}

class HistoricalArchiveMergeService {
  HistoricalArchiveMergeService(this._ref);

  final Ref _ref;
  Future<HistoricalArchiveImportResult>? _activeImportFuture;

  Future<HistoricalArchivePreflightSummary?>
  pickArchiveFolderAndRunPreflight() async {
    final selectedPath = await FileSelectorPlatform.instance
        .getDirectoryPathWithOptions(
          const FileDialogOptions(confirmButtonText: 'Choose Archive Folder'),
        );
    if (selectedPath == null) {
      return null;
    }

    return runPreflightForFolder(selectedPath);
  }

  Future<HistoricalArchivePreflightSummary> runPreflightForFolder(
    String folderPath,
  ) async {
    final logger = _ref.read(appLoggerProvider.notifier);
    final archivePath = path.normalize(folderPath);
    final archiveLabel = path.basename(archivePath);
    final chatDbPath = path.join(archivePath, 'chat.db');
    final warnings = <String>[];

    if (Directory(path.join(archivePath, 'Attachments')).existsSync()) {
      warnings.add(
        'Attachments folder found. Attachment import is not part of this first version.',
      );
    } else {
      warnings.add(
        'No Attachments folder was found. Messages can still be imported, but older attachments may not be available.',
      );
    }

    if (!File(chatDbPath).existsSync()) {
      warnings.insert(0, 'The selected folder does not contain chat.db.');
      return HistoricalArchivePreflightSummary(
        archiveLabel: archiveLabel,
        archivePath: archivePath,
        totalMessages: 0,
        duplicateMessages: 0,
        newMessages: 0,
        earliestDate: null,
        latestDate: null,
        canImport: false,
        rowsWithoutGuidCount: 0,
        warnings: warnings,
      );
    }

    final workingDb = await _ref.read(driftWorkingDatabaseProvider.future);
    final summary = await _readArchiveSummary(
      chatDbPath: chatDbPath,
      archiveLabel: archiveLabel,
      archivePath: archivePath,
      workingDb: workingDb,
      warnings: warnings,
    );

    logger.info(
      'Historical archive preflight complete for ${summary.archivePath} '
      '(total=${summary.totalMessages}, duplicates=${summary.duplicateMessages}, '
      'new=${summary.newMessages}, missingGuid=${summary.rowsWithoutGuidCount})',
      source: 'HistoricalArchiveMerge',
    );

    return summary;
  }

  Future<HistoricalArchiveImportResult> importArchiveForFutureMerge({
    required String archivePath,
    required String archiveLabel,
  }) async {
    final activeImportFuture = _activeImportFuture;
    if (activeImportFuture != null) {
      _ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Historical archive import already in progress; reusing active run.',
            source: 'HistoricalArchiveMerge',
            context: {'archivePath': archivePath, 'archiveLabel': archiveLabel},
          );
      return activeImportFuture;
    }

    final importFuture = _runArchiveImport(
      archivePath: archivePath,
      archiveLabel: archiveLabel,
    );
    _activeImportFuture = importFuture;

    try {
      return await importFuture;
    } finally {
      if (identical(_activeImportFuture, importFuture)) {
        _activeImportFuture = null;
      }
    }
  }

  Future<HistoricalArchiveImportResult> _runArchiveImport({
    required String archivePath,
    required String archiveLabel,
  }) async {
    final logger = _ref.read(appLoggerProvider.notifier);
    final normalizedArchivePath = path.normalize(archivePath);
    final chatDbPath = path.join(normalizedArchivePath, 'chat.db');
    final warnings = _buildArchiveWarnings(normalizedArchivePath);

    if (!File(chatDbPath).existsSync()) {
      warnings.insert(0, 'The selected folder does not contain chat.db.');
      return HistoricalArchiveImportResult(
        archiveLabel: archiveLabel,
        archivePath: normalizedArchivePath,
        stagedMessages: 0,
        importedMessages: 0,
        skippedDuplicates: 0,
        failedRows: 0,
        rowsWithoutGuidCount: 0,
        batchId: null,
        warnings: warnings,
      );
    }

    final workingDb = await _ref.read(driftWorkingDatabaseProvider.future);
    final archiveImportDb = await _ref.read(
      historicalArchiveImportDatabaseProvider.future,
    );
    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    final batchId = await archiveImportDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: chatDbPath,
      notes: 'Historical archive import for $archiveLabel',
    );

    HistoricalArchiveImportResult stagedResult;
    try {
      stagedResult = await _stageArchiveRows(
        archiveImportDb: archiveImportDb,
        workingDb: workingDb,
        archiveLabel: archiveLabel,
        archivePath: normalizedArchivePath,
        chatDbPath: chatDbPath,
        batchId: batchId,
        warnings: warnings,
      );
    } catch (error, stackTrace) {
      warnings.insert(
        0,
        'MessageLens could not stage this archive into the dedicated archive database.',
      );
      logger.error(
        'Historical archive staging failed for $normalizedArchivePath',
        source: 'HistoricalArchiveMerge',
        context: {
          'archivePath': normalizedArchivePath,
          'batchId': batchId,
          'error': '$error',
          'stackTrace': '$stackTrace',
        },
      );
      await archiveImportDb.updateImportBatch(
        id: batchId,
        finishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        notes: 'Historical archive staging failed: error=$error',
      );
      return HistoricalArchiveImportResult(
        archiveLabel: archiveLabel,
        archivePath: normalizedArchivePath,
        stagedMessages: 0,
        importedMessages: 0,
        skippedDuplicates: 0,
        failedRows: 1,
        rowsWithoutGuidCount: 0,
        batchId: batchId,
        warnings: warnings,
      );
    }

    logger.info(
      'Historical archive staging stored ${stagedResult.importedMessages} rows for $normalizedArchivePath',
      source: 'HistoricalArchiveMerge',
      context: {
        'archivePath': normalizedArchivePath,
        'batchId': batchId,
        'stagedMessages': stagedResult.importedMessages,
        'skippedDuplicates': stagedResult.skippedDuplicates,
        'failedRows': stagedResult.failedRows,
        'rowsWithoutGuidCount': stagedResult.rowsWithoutGuidCount,
      },
    );

    try {
      final projectedMessages = await _projectArchiveBatchIntoWorking(
        archiveImportDb: archiveImportDb,
        workingDb: workingDb,
        archiveLabel: archiveLabel,
        archivePath: normalizedArchivePath,
        batchId: batchId,
      );
      final resultWarnings = [...stagedResult.warnings];
      if (projectedMessages != stagedResult.importedMessages) {
        resultWarnings.insert(
          0,
          'Some archive rows were stored durably but not projected into the live timeline.',
        );
      }
      final result = HistoricalArchiveImportResult(
        archiveLabel: stagedResult.archiveLabel,
        archivePath: stagedResult.archivePath,
        stagedMessages: stagedResult.importedMessages,
        importedMessages: projectedMessages,
        skippedDuplicates: stagedResult.skippedDuplicates,
        failedRows: stagedResult.failedRows,
        rowsWithoutGuidCount: stagedResult.rowsWithoutGuidCount,
        batchId: stagedResult.batchId,
        warnings: resultWarnings,
      );

      await archiveImportDb.updateImportBatch(
        id: batchId,
        finishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        notes:
            'Historical archive import complete: projected=${result.importedMessages}, '
            'staged=${stagedResult.importedMessages}, skipped=${result.skippedDuplicates}, failed=${result.failedRows}, '
            'missing_guid=${result.rowsWithoutGuidCount}',
      );

      logger.info(
        'Historical archive import complete for ${result.archivePath} '
        '(staged=${result.stagedMessages}, projected=${result.importedMessages}, skipped=${result.skippedDuplicates}, '
        'failed=${result.failedRows}, missingGuid=${result.rowsWithoutGuidCount}, '
        'batchId=${result.batchId})',
        source: 'HistoricalArchiveMerge',
      );

      return result;
    } catch (error, stackTrace) {
      final projectionWarnings = <String>[
        'Archive rows were staged in the dedicated archive database, but projection into working.db failed. They are not yet available in MessageLens.',
        ...stagedResult.warnings,
      ];
      logger.error(
        'Historical archive projection failed for $normalizedArchivePath',
        source: 'HistoricalArchiveMerge',
        context: {
          'archivePath': normalizedArchivePath,
          'batchId': batchId,
          'stagedMessages': stagedResult.importedMessages,
          'skippedDuplicates': stagedResult.skippedDuplicates,
          'failedRows': stagedResult.failedRows,
          'rowsWithoutGuidCount': stagedResult.rowsWithoutGuidCount,
          'error': '$error',
          'stackTrace': '$stackTrace',
        },
      );
      await archiveImportDb.updateImportBatch(
        id: batchId,
        finishedAtUtc: DateTime.now().toUtc().toIso8601String(),
        notes:
            'Historical archive projection failed: staged=${stagedResult.importedMessages}, '
            'skipped=${stagedResult.skippedDuplicates}, failed=${stagedResult.failedRows}, '
            'missing_guid=${stagedResult.rowsWithoutGuidCount}, error=$error',
      );
      return HistoricalArchiveImportResult(
        archiveLabel: stagedResult.archiveLabel,
        archivePath: normalizedArchivePath,
        stagedMessages: stagedResult.importedMessages,
        importedMessages: 0,
        skippedDuplicates: stagedResult.skippedDuplicates,
        failedRows: stagedResult.failedRows,
        rowsWithoutGuidCount: stagedResult.rowsWithoutGuidCount,
        batchId: batchId,
        warnings: projectionWarnings,
      );
    }
  }

  Future<void> clearArchiveImportDatabase() async {
    final logger = _ref.read(appLoggerProvider.notifier);
    final archiveImportDb = await _ref.read(
      historicalArchiveImportDatabaseProvider.future,
    );
    await archiveImportDb.deleteDatabaseFile();
    _ref.invalidate(historicalArchiveImportDatabaseProvider);
    await _ref.read(historicalArchiveImportDatabaseProvider.future);

    logger.info(
      'Historical archive import database cleared and recreated.',
      source: 'HistoricalArchiveMerge',
    );
  }

  Future<HistoricalArchivePreflightSummary> _readArchiveSummary({
    required String chatDbPath,
    required String archiveLabel,
    required String archivePath,
    required WorkingDatabase workingDb,
    required List<String> warnings,
  }) async {
    try {
      final database = sqlite3.sqlite3.open(
        chatDbPath,
        mode: sqlite3.OpenMode.readOnly,
      );
      try {
        database.execute('PRAGMA query_only = ON;');
        database.execute('PRAGMA busy_timeout = 3000;');

        final capabilityCheck = database.select(
          "SELECT 1 FROM pragma_table_info('message') WHERE name = 'guid' LIMIT 1",
        );
        if (capabilityCheck.isEmpty) {
          warnings.insert(
            0,
            'This archive uses a legacy schema without a guid column. Phase 1 cannot merge it safely.',
          );
          return HistoricalArchivePreflightSummary(
            archiveLabel: archiveLabel,
            archivePath: archivePath,
            totalMessages: 0,
            duplicateMessages: 0,
            newMessages: 0,
            earliestDate: null,
            latestDate: null,
            canImport: false,
            rowsWithoutGuidCount: 0,
            warnings: warnings,
          );
        }

        final rows = database.select('''
          SELECT guid, date
          FROM message
        ''');

        var totalMessages = 0;
        var duplicateMessages = 0;
        var newMessages = 0;
        var rowsWithoutGuidCount = 0;
        DateTime? earliestDate;
        DateTime? latestDate;

        for (final row in rows) {
          totalMessages++;
          final guid = _readTrimmedString(row['guid']);
          final messageDate = DateConverter.appleAnyToDateTime(row['date']);
          if (messageDate != null) {
            earliestDate =
                earliestDate == null || messageDate.isBefore(earliestDate)
                ? messageDate
                : earliestDate;
            latestDate = latestDate == null || messageDate.isAfter(latestDate)
                ? messageDate
                : latestDate;
          }

          if (guid == null) {
            rowsWithoutGuidCount++;
            continue;
          }

          if (await _guidExistsInWorkingDb(workingDb, guid)) {
            duplicateMessages++;
          } else {
            newMessages++;
          }
        }

        return HistoricalArchivePreflightSummary(
          archiveLabel: archiveLabel,
          archivePath: archivePath,
          totalMessages: totalMessages,
          duplicateMessages: duplicateMessages,
          newMessages: newMessages,
          earliestDate: earliestDate,
          latestDate: latestDate,
          canImport: newMessages > 0,
          rowsWithoutGuidCount: rowsWithoutGuidCount,
          warnings: warnings,
        );
      } finally {
        database.dispose();
      }
    } catch (_) {
      warnings.insert(
        0,
        'MessageLens could not open this archive chat.db read-only.',
      );
      return HistoricalArchivePreflightSummary(
        archiveLabel: archiveLabel,
        archivePath: archivePath,
        totalMessages: 0,
        duplicateMessages: 0,
        newMessages: 0,
        earliestDate: null,
        latestDate: null,
        canImport: false,
        rowsWithoutGuidCount: 0,
        warnings: warnings,
      );
    }
  }

  Future<HistoricalArchiveImportResult> _stageArchiveRows({
    required SqfliteImportDatabase archiveImportDb,
    required WorkingDatabase workingDb,
    required String archiveLabel,
    required String archivePath,
    required String chatDbPath,
    required int batchId,
    required List<String> warnings,
  }) async {
    final database = sqlite3.sqlite3.open(
      chatDbPath,
      mode: sqlite3.OpenMode.readOnly,
    );

    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');

      final columnNames = _readTableColumnNames(database, 'message');
      final chatColumnNames = _readTableColumnNames(database, 'chat');
      final handleColumnNames = _readTableColumnNames(database, 'handle');
      final chatJoinColumnNames = _readTableColumnNames(
        database,
        'chat_message_join',
      );
      final chatHandleJoinColumnNames = _readTableColumnNames(
        database,
        'chat_handle_join',
      );
      if (!columnNames.contains('guid')) {
        warnings.insert(
          0,
          'This archive uses a legacy schema without a guid column. Phase 1 cannot merge it safely.',
        );
        return HistoricalArchiveImportResult(
          archiveLabel: archiveLabel,
          archivePath: archivePath,
          stagedMessages: 0,
          importedMessages: 0,
          skippedDuplicates: 0,
          failedRows: 0,
          rowsWithoutGuidCount: 0,
          batchId: batchId,
          warnings: warnings,
        );
      }

      final linkedChatsById = _loadLinkedArchiveChats(
        database: database,
        chatColumnNames: chatColumnNames,
      );
      final archiveHandlesById = _loadArchiveHandles(
        database: database,
        handleColumnNames: handleColumnNames,
      );
      final chatIdByMessageId = _loadArchiveChatIdsByMessageId(
        database: database,
        chatJoinColumnNames: chatJoinColumnNames,
      );
      final handleIdsByChatId = _loadArchiveHandleIdsByChatId(
        database: database,
        chatHandleJoinColumnNames: chatHandleJoinColumnNames,
      );
      final insertedChatIds = <int>{};
      final insertedHandleIds = <int>{};
      final insertedParticipantKeys = <String>{};

      final rows = database.select('''
        SELECT
          rowid AS source_rowid,
          guid,
          ${_selectMessageColumn(columnNames, 'date', 'NULL')} AS archive_date,
          ${_selectMessageColumn(columnNames, 'handle_id', 'NULL')} AS archive_sender_handle_id,
          ${_selectMessageColumn(columnNames, 'service', "'Unknown'")} AS archive_service,
          ${_selectMessageColumn(columnNames, 'is_from_me', '0')} AS archive_is_from_me,
          ${_selectMessageColumn(columnNames, 'text', 'NULL')} AS archive_text
        FROM message
      ''');

      var importedMessages = 0;
      var skippedDuplicates = 0;
      var failedRows = 0;
      var rowsWithoutGuidCount = 0;

      for (final row in rows) {
        final guid = _readTrimmedString(row['guid']);
        if (guid == null) {
          failedRows++;
          rowsWithoutGuidCount++;
          continue;
        }

        final alreadyPresentInWorking = await _guidExistsInWorkingDb(
          workingDb,
          guid,
        );
        if (alreadyPresentInWorking) {
          skippedDuplicates++;
          continue;
        }

        final archiveDateUtc = DateConverter.appleAnyToIsoString(
          row['archive_date'],
        );
        final sourceMessageId = _coerceInt(row['source_rowid']);
        final sourceSenderHandleId = _coerceInt(
          row['archive_sender_handle_id'],
        );
        final linkedChat = sourceMessageId == null
            ? null
            : linkedChatsById[chatIdByMessageId[sourceMessageId]];
        final stagedSenderHandleId = await _stageArchiveHandleIfNeeded(
          archiveImportDb: archiveImportDb,
          archiveHandle: sourceSenderHandleId == null
              ? null
              : archiveHandlesById[sourceSenderHandleId],
          insertedHandleIds: insertedHandleIds,
          batchId: batchId,
        );

        if (linkedChat != null) {
          if (insertedChatIds.add(linkedChat.sourceChatId)) {
            await archiveImportDb.insertChat(
              id: linkedChat.sourceChatId,
              sourceRowid: linkedChat.sourceChatId,
              guid: linkedChat.guid,
              service: linkedChat.service,
              displayName: linkedChat.displayName,
              isGroup: linkedChat.isGroup,
              createdAtUtc: linkedChat.createdAtUtc,
              updatedAtUtc: linkedChat.updatedAtUtc,
              batchId: batchId,
            );
          }

          await _stageArchiveChatParticipants(
            archiveImportDb: archiveImportDb,
            linkedChat: linkedChat,
            archiveHandlesById: archiveHandlesById,
            sourceHandleIds:
                handleIdsByChatId[linkedChat.sourceChatId] ?? const <int>{},
            insertedHandleIds: insertedHandleIds,
            insertedParticipantKeys: insertedParticipantKeys,
            batchId: batchId,
          );

          await archiveImportDb.insertMessage(
            id: sourceMessageId,
            sourceRowid: sourceMessageId,
            guid: guid,
            chatId: linkedChat.sourceChatId,
            senderHandleId: stagedSenderHandleId,
            service: _readTrimmedString(row['archive_service']) ?? 'Unknown',
            isFromMe: _coerceBool(row['archive_is_from_me']),
            dateUtc: archiveDateUtc,
            text: _readTrimmedString(row['archive_text']),
            hasAttributedBodySource: false,
            hasMessageSummaryInfo: false,
            hasPayloadDataSource: false,
            itemType: _readTrimmedString(row['archive_text']) == null
                ? 'unknown'
                : 'text',
            isSystemMessage: false,
            batchId: batchId,
          );
        } else {
          await archiveImportDb.insertRecoveredUnlinkedMessage(
            sourceRowid: sourceMessageId,
            guid: guid,
            senderHandleId: stagedSenderHandleId,
            service: _readTrimmedString(row['archive_service']) ?? 'Unknown',
            isFromMe: _coerceBool(row['archive_is_from_me']),
            dateUtc: archiveDateUtc,
            text: _readTrimmedString(row['archive_text']),
            hasAttributedBodySource: false,
            hasMessageSummaryInfo: false,
            hasPayloadDataSource: false,
            itemType: _readTrimmedString(row['archive_text']) == null
                ? 'unknown'
                : 'text',
            isSystemMessage: false,
            batchId: batchId,
          );
        }
        importedMessages++;
      }

      return HistoricalArchiveImportResult(
        archiveLabel: archiveLabel,
        archivePath: archivePath,
        stagedMessages: importedMessages,
        importedMessages: importedMessages,
        skippedDuplicates: skippedDuplicates,
        failedRows: failedRows,
        rowsWithoutGuidCount: rowsWithoutGuidCount,
        batchId: batchId,
        warnings: warnings,
      );
    } finally {
      database.dispose();
    }
  }

  Future<int> _projectArchiveBatchIntoWorking({
    required SqfliteImportDatabase archiveImportDb,
    required WorkingDatabase workingDb,
    required String archiveLabel,
    required String archivePath,
    required int batchId,
  }) async {
    final logger = _ref.read(appLoggerProvider.notifier);
    final sourceProvenance = _archiveSourceProvenance(
      archiveLabel: archiveLabel,
      batchId: batchId,
    );
    final linkedRows = await archiveImportDb.rawQuery(
      '''
      SELECT
        m.guid,
        m.service,
        m.is_from_me,
        m.date_utc,
        m.text,
        m.sender_handle_id,
        c.guid AS chat_guid,
        c.service AS chat_service,
        c.display_name AS chat_display_name,
        c.is_group AS chat_is_group
      FROM messages m
      JOIN chats c ON c.id = m.chat_id
      WHERE m.batch_id = ?
      ORDER BY m.date_utc, m.id
      ''',
      <Object?>[batchId],
    );
    final recoveredRows = await archiveImportDb.rawQuery(
      '''
      SELECT guid, service, is_from_me, date_utc, text, sender_handle_id
      FROM recovered_unlinked_messages
      WHERE batch_id = ?
      ORDER BY date_utc, id
      ''',
      <Object?>[batchId],
    );
    final stagedHandlesById = await _loadStagedArchiveHandlesById(
      archiveImportDb: archiveImportDb,
      batchId: batchId,
    );
    final participantRowsByChatGuid =
        await _loadStagedArchiveParticipantsByChatGuid(
          archiveImportDb: archiveImportDb,
          batchId: batchId,
        );
    final knownWorkingGuids = await _loadExistingWorkingGuids(
      workingDb: workingDb,
      candidateGuids: {
        for (final row in linkedRows)
          if (_readTrimmedString(row['guid']) case final guid?) guid,
        for (final row in recoveredRows)
          if (_readTrimmedString(row['guid']) case final guid?) guid,
      },
    );
    final workingChatIdsByGuid = await _loadExistingWorkingChatIdsByGuid(
      workingDb: workingDb,
      chatGuids: {
        for (final row in linkedRows)
          if (_readTrimmedString(row['chat_guid']) case final chatGuid?)
            chatGuid,
      },
    );

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'staged-rows-selected',
      context: {
        'linkedRows': linkedRows.length,
        'recoveredRows': recoveredRows.length,
        'participantChats': participantRowsByChatGuid.length,
        'stagedHandles': stagedHandlesById.length,
        'knownWorkingGuids': knownWorkingGuids.length,
        'knownWorkingChats': workingChatIdsByGuid.length,
        'sourceProvenance': sourceProvenance,
      },
    );

    if (linkedRows.isEmpty && recoveredRows.isEmpty) {
      logger.warn(
        'Historical archive projection found no staged rows for batch $batchId',
        source: 'HistoricalArchiveMerge',
        context: {
          'archivePath': archivePath,
          'batchId': batchId,
          'sourceProvenance': sourceProvenance,
        },
      );
      return 0;
    }

    logger.info(
      'Historical archive projection starting for batch $batchId',
      source: 'HistoricalArchiveMerge',
      context: {
        'archivePath': archivePath,
        'batchId': batchId,
        'linkedRows': linkedRows.length,
        'recoveredRows': recoveredRows.length,
        'sourceProvenance': sourceProvenance,
      },
    );

    var insertedCount = 0;
    var linkedMessagesInserted = 0;
    var recoveredMessagesInserted = 0;
    var resolvedSenderHandles = 0;
    var transactionCommitted = false;
    final workingHandleIdsByArchiveHandleId = <int, int>{};
    final hydratedParticipantChatGuids = <String>{};
    var messageIndexTriggersSuspended = false;

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'projection-transaction-starting',
      context: {
        'linkedRows': linkedRows.length,
        'recoveredRows': recoveredRows.length,
        'sourceProvenance': sourceProvenance,
      },
    );

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-triggers-suspending',
      context: {'sourceProvenance': sourceProvenance},
    );
    await _dropMessageIndexTriggers(workingDb);
    messageIndexTriggersSuspended = true;
    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-triggers-suspended',
      context: {'sourceProvenance': sourceProvenance},
    );

    try {
      await workingDb.transaction(() async {
        for (final row in linkedRows) {
          final guid = _readTrimmedString(row['guid']);
          final chatGuid = _readTrimmedString(row['chat_guid']);
          if (guid == null || chatGuid == null) {
            continue;
          }

          if (knownWorkingGuids.contains(guid)) {
            continue;
          }

          final workingChatId = workingChatIdsByGuid.putIfAbsent(
            chatGuid,
            () => -1,
          );
          final resolvedWorkingChatId = workingChatId == -1
              ? null
              : workingChatId;
          final chatId =
              resolvedWorkingChatId ??
              await _ensureWorkingArchiveChat(
                workingDb: workingDb,
                chatGuid: chatGuid,
                chatService: _readTrimmedString(row['chat_service']),
                chatDisplayName: _readTrimmedString(row['chat_display_name']),
                isGroup: _coerceBool(row['chat_is_group']),
              );
          if (resolvedWorkingChatId == null) {
            workingChatIdsByGuid[chatGuid] = chatId;
          }
          if (hydratedParticipantChatGuids.add(chatGuid)) {
            await _projectArchiveChatParticipants(
              workingDb: workingDb,
              workingChatId: chatId,
              participantRows:
                  participantRowsByChatGuid[chatGuid] ??
                  const <_ArchiveChatParticipantRow>[],
              stagedHandlesById: stagedHandlesById,
              workingHandleIdsByArchiveHandleId:
                  workingHandleIdsByArchiveHandleId,
              batchId: batchId,
            );
          }
          final senderHandleId = await _resolveWorkingArchiveHandleId(
            workingDb: workingDb,
            archiveHandleId: _coerceInt(row['sender_handle_id']),
            stagedHandlesById: stagedHandlesById,
            workingHandleIdsByArchiveHandleId:
                workingHandleIdsByArchiveHandleId,
            batchId: batchId,
          );
          if (senderHandleId != null) {
            resolvedSenderHandles++;
          }
          await _insertWorkingArchiveMessage(
            workingDb: workingDb,
            guid: guid,
            chatId: chatId,
            senderHandleId: senderHandleId,
            sourceProvenance: sourceProvenance,
            importBatchId: batchId,
            isFromMe: _coerceBool(row['is_from_me']),
            dateUtc: _readTrimmedString(row['date_utc']),
            text: _readTrimmedString(row['text']),
            batchId: batchId,
          );
          knownWorkingGuids.add(guid);
          insertedCount++;
          linkedMessagesInserted++;
        }

        if (recoveredRows.isEmpty) {
          return;
        }

        final syntheticChatId = await _ensureSyntheticArchiveChat(
          workingDb: workingDb,
          archivePath: archivePath,
        );
        for (final row in recoveredRows) {
          final guid = _readTrimmedString(row['guid']);
          if (guid == null) {
            continue;
          }

          if (knownWorkingGuids.contains(guid)) {
            continue;
          }

          final senderHandleId = await _resolveWorkingArchiveHandleId(
            workingDb: workingDb,
            archiveHandleId: _coerceInt(row['sender_handle_id']),
            stagedHandlesById: stagedHandlesById,
            workingHandleIdsByArchiveHandleId:
                workingHandleIdsByArchiveHandleId,
            batchId: batchId,
          );
          if (senderHandleId != null) {
            resolvedSenderHandles++;
          }

          await _insertWorkingArchiveMessage(
            workingDb: workingDb,
            guid: guid,
            chatId: syntheticChatId,
            senderHandleId: senderHandleId,
            sourceProvenance: sourceProvenance,
            importBatchId: batchId,
            isFromMe: _coerceBool(row['is_from_me']),
            dateUtc: _readTrimmedString(row['date_utc']),
            text: _readTrimmedString(row['text']),
            batchId: batchId,
          );
          knownWorkingGuids.add(guid);
          insertedCount++;
          recoveredMessagesInserted++;
        }
      });
      transactionCommitted = true;
    } catch (error) {
      if (messageIndexTriggersSuspended) {
        await _restoreMessageIndexTriggersSafely(
          workingDb: workingDb,
          archiveImportDb: archiveImportDb,
          logger: logger,
          batchId: batchId,
          archivePath: archivePath,
          sourceProvenance: sourceProvenance,
          transactionCommitted: transactionCommitted,
          insertedCount: insertedCount,
        );
        messageIndexTriggersSuspended = false;
      }
      rethrow;
    }

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'projection-transaction-committed',
      context: {
        'insertedMessages': insertedCount,
        'linkedMessagesInserted': linkedMessagesInserted,
        'recoveredMessagesInserted': recoveredMessagesInserted,
        'resolvedSenderHandles': resolvedSenderHandles,
        'participantChatsHydrated': hydratedParticipantChatGuids.length,
        'knownWorkingGuids': knownWorkingGuids.length,
        'knownWorkingChats': workingChatIdsByGuid.length,
        'workingHandleCacheSize': workingHandleIdsByArchiveHandleId.length,
        'sourceProvenance': sourceProvenance,
      },
    );

    if (insertedCount == 0) {
      if (messageIndexTriggersSuspended) {
        await workingDb.createMessageIndexTriggers();
        messageIndexTriggersSuspended = false;
      }
      return 0;
    }

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'global-index-rebuild-starting',
      context: {
        'insertedMessages': insertedCount,
        'sourceProvenance': sourceProvenance,
      },
    );
    await workingDb.rebuildGlobalMessageIndex();
    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'global-index-rebuild-complete',
      context: {
        'insertedMessages': insertedCount,
        'sourceProvenance': sourceProvenance,
      },
    );

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-rebuild-starting',
      context: {
        'insertedMessages': insertedCount,
        'sourceProvenance': sourceProvenance,
      },
    );
    await workingDb.rebuildMessageIndex();
    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-rebuild-complete',
      context: {
        'insertedMessages': insertedCount,
        'sourceProvenance': sourceProvenance,
      },
    );

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'contact-index-rebuild-starting',
      context: {
        'insertedMessages': insertedCount,
        'participantChatsHydrated': hydratedParticipantChatGuids.length,
        'sourceProvenance': sourceProvenance,
      },
    );
    await workingDb.rebuildContactMessageIndex();
    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'contact-index-rebuild-complete',
      context: {
        'insertedMessages': insertedCount,
        'participantChatsHydrated': hydratedParticipantChatGuids.length,
        'sourceProvenance': sourceProvenance,
      },
    );

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-triggers-starting',
      context: {
        'insertedMessages': insertedCount,
        'sourceProvenance': sourceProvenance,
      },
    );
    await workingDb.createMessageIndexTriggers();
    messageIndexTriggersSuspended = false;
    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-triggers-complete',
      context: {
        'insertedMessages': insertedCount,
        'sourceProvenance': sourceProvenance,
      },
    );

    logger.info(
      'Historical archive projection completed for batch $batchId',
      source: 'HistoricalArchiveMerge',
      context: {
        'archivePath': archivePath,
        'batchId': batchId,
        'insertedMessages': insertedCount,
        'sourceProvenance': sourceProvenance,
      },
    );

    return insertedCount;
  }

  Future<void> _restoreMessageIndexTriggersSafely({
    required WorkingDatabase workingDb,
    required SqfliteImportDatabase archiveImportDb,
    required AppLogger logger,
    required int batchId,
    required String archivePath,
    required String sourceProvenance,
    required bool transactionCommitted,
    required int insertedCount,
  }) async {
    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-trigger-recovery-starting',
      context: {
        'sourceProvenance': sourceProvenance,
        'transactionCommitted': transactionCommitted,
        'insertedMessages': insertedCount,
      },
    );

    if (transactionCommitted && insertedCount > 0) {
      await workingDb.rebuildGlobalMessageIndex();
      await workingDb.rebuildMessageIndex();
      await workingDb.rebuildContactMessageIndex();
    }
    await workingDb.createMessageIndexTriggers();

    await _recordProjectionCheckpoint(
      archiveImportDb: archiveImportDb,
      logger: logger,
      batchId: batchId,
      archivePath: archivePath,
      phase: 'message-index-trigger-recovery-complete',
      context: {
        'sourceProvenance': sourceProvenance,
        'transactionCommitted': transactionCommitted,
        'insertedMessages': insertedCount,
      },
    );
  }

  Future<void> _dropMessageIndexTriggers(WorkingDatabase workingDb) async {
    for (final statement in const <String>[
      'DROP TRIGGER IF EXISTS trg_global_message_index_insert',
      'DROP TRIGGER IF EXISTS trg_global_message_index_update',
      'DROP TRIGGER IF EXISTS trg_global_message_index_delete',
      'DROP TRIGGER IF EXISTS trg_message_index_insert',
      'DROP TRIGGER IF EXISTS trg_message_index_update',
      'DROP TRIGGER IF EXISTS trg_message_index_delete',
      'DROP TRIGGER IF EXISTS trg_contact_message_index_insert',
      'DROP TRIGGER IF EXISTS trg_contact_message_index_update',
      'DROP TRIGGER IF EXISTS trg_contact_message_index_delete',
    ]) {
      await workingDb.customStatement(statement);
    }
  }

  Future<void> _recordProjectionCheckpoint({
    required SqfliteImportDatabase archiveImportDb,
    required AppLogger logger,
    required int batchId,
    required String archivePath,
    required String phase,
    required Map<String, Object?> context,
  }) async {
    logger.info(
      'Historical archive projection checkpoint: $phase',
      source: 'HistoricalArchiveMerge',
      context: {
        'archivePath': archivePath,
        'batchId': batchId,
        'phase': phase,
        ...context,
      },
    );

    final contextSummary = context.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(', ');
    await archiveImportDb.updateImportBatch(
      id: batchId,
      notes:
          'Historical archive projection checkpoint: phase=$phase${contextSummary.isEmpty ? '' : ', $contextSummary'}',
    );
  }

  Future<int> _ensureSyntheticArchiveChat({
    required WorkingDatabase workingDb,
    required String archivePath,
  }) async {
    final syntheticGuid = _syntheticArchiveChatGuid(archivePath);
    final existingChat = await (workingDb.select(
      workingDb.workingChats,
    )..where((chat) => chat.guid.equals(syntheticGuid))).getSingleOrNull();
    if (existingChat != null) {
      return existingChat.id;
    }

    return workingDb
        .into(workingDb.workingChats)
        .insert(
          WorkingChatsCompanion.insert(
            guid: syntheticGuid,
            service: const Value('Unknown'),
            isGroup: const Value(false),
          ),
        );
  }

  Future<int> _ensureWorkingArchiveChat({
    required WorkingDatabase workingDb,
    required String chatGuid,
    required String? chatService,
    required String? chatDisplayName,
    required bool isGroup,
  }) async {
    final existingChat = await (workingDb.select(
      workingDb.workingChats,
    )..where((chat) => chat.guid.equals(chatGuid))).getSingleOrNull();
    if (existingChat != null) {
      return existingChat.id;
    }

    return workingDb
        .into(workingDb.workingChats)
        .insert(
          WorkingChatsCompanion.insert(
            guid: chatGuid,
            service: Value(chatService ?? 'Unknown'),
            isGroup: Value(isGroup),
            lastMessagePreview: Value(chatDisplayName),
          ),
        );
  }

  Future<void> _insertWorkingArchiveMessage({
    required WorkingDatabase workingDb,
    required String guid,
    required int chatId,
    required int? senderHandleId,
    required String sourceProvenance,
    required int importBatchId,
    required bool isFromMe,
    required String? dateUtc,
    required String? text,
    required int batchId,
  }) {
    final itemType = text == null ? 'unknown' : 'text';
    final semanticKind = text == null ? 'unknown-variant' : 'plain-text';

    return workingDb
        .into(workingDb.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: guid,
            chatId: chatId,
            senderHandleId: senderHandleId == null
                ? const Value.absent()
                : Value(senderHandleId),
            sourceProvenance: Value(sourceProvenance),
            importBatchId: Value(importBatchId),
            isFromMe: Value(isFromMe),
            sentAtUtc: Value(dateUtc),
            textContent: Value(text),
            semanticKind: Value(semanticKind),
            hasAttributedBodySource: const Value(false),
            hasMessageSummaryInfo: const Value(false),
            hasPayloadDataSource: const Value(false),
            itemType: Value(itemType),
            isSystemMessage: const Value(false),
            hasAttachments: const Value(false),
            reactionCarrier: const Value(false),
            batchId: Value(batchId),
          ),
        );
  }

  Future<int?> _resolveWorkingArchiveHandleId({
    required WorkingDatabase workingDb,
    required int? archiveHandleId,
    required Map<int, _ArchiveHandleRow> stagedHandlesById,
    required Map<int, int> workingHandleIdsByArchiveHandleId,
    required int batchId,
  }) async {
    if (archiveHandleId == null) {
      return null;
    }

    final cachedHandleId = workingHandleIdsByArchiveHandleId[archiveHandleId];
    if (cachedHandleId != null) {
      return cachedHandleId;
    }

    final stagedHandle = stagedHandlesById[archiveHandleId];
    if (stagedHandle == null) {
      return null;
    }

    final workingHandleId = await _ensureWorkingArchiveHandle(
      workingDb: workingDb,
      archiveHandle: stagedHandle,
      batchId: batchId,
    );
    workingHandleIdsByArchiveHandleId[archiveHandleId] = workingHandleId;
    return workingHandleId;
  }

  Future<int> _ensureWorkingArchiveHandle({
    required WorkingDatabase workingDb,
    required _ArchiveHandleRow archiveHandle,
    required int batchId,
  }) async {
    final existingByCompound = await _firstWorkingHandleByCompoundIdentifier(
      workingDb: workingDb,
      compoundIdentifier: archiveHandle.compoundIdentifier,
    );
    if (existingByCompound != null) {
      return existingByCompound.id;
    }

    final existingByRawAndService = await _firstWorkingHandleByRawAndService(
      workingDb: workingDb,
      rawIdentifier: archiveHandle.rawIdentifier,
      service: archiveHandle.service,
    );
    if (existingByRawAndService != null) {
      return existingByRawAndService.id;
    }

    return workingDb
        .into(workingDb.handlesCanonical)
        .insert(
          HandlesCanonicalCompanion.insert(
            rawIdentifier: archiveHandle.rawIdentifier,
            displayName: archiveHandle.rawIdentifier,
            compoundIdentifier: archiveHandle.compoundIdentifier,
            service: Value(archiveHandle.service),
            country: Value(archiveHandle.country),
            lastSeenUtc: Value(archiveHandle.lastSeenUtc),
            batchId: Value(batchId),
          ),
        );
  }

  Future<void> _projectArchiveChatParticipants({
    required WorkingDatabase workingDb,
    required int workingChatId,
    required List<_ArchiveChatParticipantRow> participantRows,
    required Map<int, _ArchiveHandleRow> stagedHandlesById,
    required Map<int, int> workingHandleIdsByArchiveHandleId,
    required int batchId,
  }) async {
    for (final participantRow in participantRows) {
      final workingHandleId = await _resolveWorkingArchiveHandleId(
        workingDb: workingDb,
        archiveHandleId: participantRow.handleId,
        stagedHandlesById: stagedHandlesById,
        workingHandleIdsByArchiveHandleId: workingHandleIdsByArchiveHandleId,
        batchId: batchId,
      );
      if (workingHandleId == null) {
        continue;
      }

      await workingDb
          .into(workingDb.chatToHandle)
          .insert(
            ChatToHandleCompanion.insert(
              chatId: workingChatId,
              handleId: workingHandleId,
              role: Value(participantRow.role ?? 'member'),
              addedAtUtc: Value(participantRow.addedAtUtc),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<bool> _guidExistsInWorkingDb(
    WorkingDatabase workingDb,
    String guid,
  ) async {
    final rows = await workingDb
        .customSelect(
          '''
      SELECT 1 AS hit
      FROM messages
      WHERE guid = ?
      UNION ALL
      SELECT 1 AS hit
      FROM recovered_unlinked_messages
      WHERE guid = ?
      LIMIT 1
      ''',
          variables: [Variable<String>(guid), Variable<String>(guid)],
          readsFrom: {
            workingDb.workingMessages,
            workingDb.recoveredUnlinkedMessages,
          },
        )
        .get();

    return rows.isNotEmpty;
  }
}

Future<HandlesCanonicalData?> _firstWorkingHandleByCompoundIdentifier({
  required WorkingDatabase workingDb,
  required String compoundIdentifier,
}) async {
  final rows =
      await (workingDb.select(workingDb.handlesCanonical)
            ..where(
              (handle) => handle.compoundIdentifier.equals(compoundIdentifier),
            )
            ..orderBy([(handle) => OrderingTerm.asc(handle.id)])
            ..limit(1))
          .get();
  if (rows.isEmpty) {
    return null;
  }

  return rows.first;
}

Future<HandlesCanonicalData?> _firstWorkingHandleByRawAndService({
  required WorkingDatabase workingDb,
  required String rawIdentifier,
  required String service,
}) async {
  final rows =
      await (workingDb.select(workingDb.handlesCanonical)
            ..where(
              (handle) =>
                  handle.rawIdentifier.equals(rawIdentifier) &
                  handle.service.equals(service),
            )
            ..orderBy([(handle) => OrderingTerm.asc(handle.id)])
            ..limit(1))
          .get();
  if (rows.isEmpty) {
    return null;
  }

  return rows.first;
}

Future<Set<String>> _loadExistingWorkingGuids({
  required WorkingDatabase workingDb,
  required Set<String> candidateGuids,
}) async {
  if (candidateGuids.isEmpty) {
    return <String>{};
  }

  final knownGuids = <String>{};
  for (final chunk in _chunkList(candidateGuids.toList(growable: false), 400)) {
    final placeholders = List.filled(chunk.length, '?').join(', ');
    final variables = <Variable<Object>>[
      for (final guid in chunk) Variable<String>(guid),
      for (final guid in chunk) Variable<String>(guid),
    ];
    final rows = await workingDb
        .customSelect(
          '''
          SELECT guid
          FROM messages
          WHERE guid IN ($placeholders)
          UNION
          SELECT guid
          FROM recovered_unlinked_messages
          WHERE guid IN ($placeholders)
          ''',
          variables: variables,
          readsFrom: {
            workingDb.workingMessages,
            workingDb.recoveredUnlinkedMessages,
          },
        )
        .get();
    for (final row in rows) {
      final guid = _readTrimmedString(row.data['guid']);
      if (guid != null) {
        knownGuids.add(guid);
      }
    }
  }

  return knownGuids;
}

Future<Map<String, int>> _loadExistingWorkingChatIdsByGuid({
  required WorkingDatabase workingDb,
  required Set<String> chatGuids,
}) async {
  if (chatGuids.isEmpty) {
    return <String, int>{};
  }

  final chatIdsByGuid = <String, int>{};
  for (final chunk in _chunkList(chatGuids.toList(growable: false), 400)) {
    final placeholders = List.filled(chunk.length, '?').join(', ');
    final rows = await workingDb
        .customSelect(
          'SELECT id, guid FROM chats WHERE guid IN ($placeholders)',
          variables: [for (final guid in chunk) Variable<String>(guid)],
          readsFrom: {workingDb.workingChats},
        )
        .get();
    for (final row in rows) {
      final guid = _readTrimmedString(row.data['guid']);
      final chatId = _coerceInt(row.data['id']);
      if (guid != null && chatId != null) {
        chatIdsByGuid[guid] = chatId;
      }
    }
  }

  return chatIdsByGuid;
}

Iterable<List<T>> _chunkList<T>(List<T> items, int chunkSize) sync* {
  for (var index = 0; index < items.length; index += chunkSize) {
    final end = (index + chunkSize < items.length)
        ? index + chunkSize
        : items.length;
    yield items.sublist(index, end);
  }
}

Future<int?> _stageArchiveHandleIfNeeded({
  required SqfliteImportDatabase archiveImportDb,
  required _ArchiveHandleRow? archiveHandle,
  required Set<int> insertedHandleIds,
  required int batchId,
}) async {
  if (archiveHandle == null) {
    return null;
  }

  if (insertedHandleIds.add(archiveHandle.sourceHandleId)) {
    await archiveImportDb.insertHandle(
      id: archiveHandle.sourceHandleId,
      sourceRowid: archiveHandle.sourceHandleId,
      service: archiveHandle.service,
      rawIdentifier: archiveHandle.rawIdentifier,
      normalizedIdentifier: archiveHandle.normalizedIdentifier,
      compoundIdentifier: archiveHandle.compoundIdentifier,
      country: archiveHandle.country,
      lastSeenUtc: archiveHandle.lastSeenUtc,
      batchId: batchId,
    );
  }

  return archiveHandle.sourceHandleId;
}

Future<void> _stageArchiveChatParticipants({
  required SqfliteImportDatabase archiveImportDb,
  required _ArchiveChatRow linkedChat,
  required Map<int, _ArchiveHandleRow> archiveHandlesById,
  required Set<int> sourceHandleIds,
  required Set<int> insertedHandleIds,
  required Set<String> insertedParticipantKeys,
  required int batchId,
}) async {
  for (final sourceHandleId in sourceHandleIds) {
    final archiveHandle = archiveHandlesById[sourceHandleId];
    if (archiveHandle == null) {
      continue;
    }

    await _stageArchiveHandleIfNeeded(
      archiveImportDb: archiveImportDb,
      archiveHandle: archiveHandle,
      insertedHandleIds: insertedHandleIds,
      batchId: batchId,
    );

    final participantKey = '${linkedChat.sourceChatId}:$sourceHandleId';
    if (!insertedParticipantKeys.add(participantKey)) {
      continue;
    }

    await archiveImportDb.insertChatParticipant(
      chatId: linkedChat.sourceChatId,
      handleId: sourceHandleId,
    );
  }
}

Map<int, _ArchiveChatRow> _loadLinkedArchiveChats({
  required sqlite3.Database database,
  required Set<String> chatColumnNames,
}) {
  if (!chatColumnNames.contains('guid')) {
    return const <int, _ArchiveChatRow>{};
  }

  final rows = database.select('''
    SELECT
      rowid AS source_rowid,
      guid,
      ${_selectMessageColumn(chatColumnNames, 'service_name', 'service')} AS service_name,
      ${_selectMessageColumn(chatColumnNames, 'display_name', 'NULL')} AS display_name,
      ${_selectMessageColumn(chatColumnNames, 'is_group', '0')} AS is_group,
      ${_selectMessageColumn(chatColumnNames, 'creation_date', 'NULL')} AS creation_date,
      ${_selectMessageColumn(chatColumnNames, 'last_read_message_timestamp', 'NULL')} AS last_read_message_timestamp
    FROM chat
    WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0
  ''');

  final chatsById = <int, _ArchiveChatRow>{};
  for (final row in rows) {
    final sourceChatId = _coerceInt(row['source_rowid']);
    final guid = _readTrimmedString(row['guid']);
    if (sourceChatId == null || guid == null) {
      continue;
    }

    chatsById[sourceChatId] = _ArchiveChatRow(
      sourceChatId: sourceChatId,
      guid: guid,
      service: _readTrimmedString(row['service_name']) ?? 'Unknown',
      displayName: _readTrimmedString(row['display_name']),
      isGroup: _coerceBool(row['is_group']),
      createdAtUtc: DateConverter.appleAnyToIsoString(row['creation_date']),
      updatedAtUtc: DateConverter.appleAnyToIsoString(
        row['last_read_message_timestamp'],
      ),
    );
  }

  return chatsById;
}

Map<int, _ArchiveHandleRow> _loadArchiveHandles({
  required sqlite3.Database database,
  required Set<String> handleColumnNames,
}) {
  if (!handleColumnNames.contains('id')) {
    return const <int, _ArchiveHandleRow>{};
  }

  final rows = database.select('''
    SELECT
      rowid AS source_rowid,
      id AS raw_identifier,
      ${_selectMessageColumn(handleColumnNames, 'service', "'Unknown'")} AS service,
      ${_selectMessageColumn(handleColumnNames, 'country', 'NULL')} AS country,
      ${_selectMessageColumn(handleColumnNames, 'last_read_date', _selectMessageColumn(handleColumnNames, 'last_use', 'NULL'))} AS last_seen
    FROM handle
    WHERE id IS NOT NULL AND LENGTH(TRIM(id)) > 0
  ''');

  final handlesById = <int, _ArchiveHandleRow>{};
  for (final row in rows) {
    final sourceHandleId = _coerceInt(row['source_rowid']);
    final rawIdentifier = stripMeaninglessHandlePrefix(
      _readTrimmedString(row['raw_identifier']),
    );
    if (sourceHandleId == null ||
        rawIdentifier == null ||
        rawIdentifier.isEmpty) {
      continue;
    }

    final service = sanitizeHandleService(_readTrimmedString(row['service']));
    final normalizedIdentifier = normalizeHandleIdentifier(rawIdentifier);
    handlesById[sourceHandleId] = _ArchiveHandleRow(
      sourceHandleId: sourceHandleId,
      rawIdentifier: rawIdentifier,
      normalizedIdentifier: normalizedIdentifier,
      compoundIdentifier: buildCompoundIdentifier(
        normalizedIdentifier: normalizedIdentifier,
        rawIdentifier: rawIdentifier,
        service: service,
      ),
      service: service,
      country: _readTrimmedString(row['country']),
      lastSeenUtc: DateConverter.appleAnyToIsoString(row['last_seen']),
    );
  }

  return handlesById;
}

Map<int, int> _loadArchiveChatIdsByMessageId({
  required sqlite3.Database database,
  required Set<String> chatJoinColumnNames,
}) {
  if (!chatJoinColumnNames.contains('message_id') ||
      !chatJoinColumnNames.contains('chat_id')) {
    return const <int, int>{};
  }

  final rows = database.select(
    'SELECT message_id, chat_id FROM chat_message_join',
  );
  final chatIdByMessageId = <int, int>{};
  for (final row in rows) {
    final messageId = _coerceInt(row['message_id']);
    final chatId = _coerceInt(row['chat_id']);
    if (messageId == null || chatId == null) {
      continue;
    }
    chatIdByMessageId[messageId] = chatId;
  }

  return chatIdByMessageId;
}

Map<int, Set<int>> _loadArchiveHandleIdsByChatId({
  required sqlite3.Database database,
  required Set<String> chatHandleJoinColumnNames,
}) {
  if (!chatHandleJoinColumnNames.contains('chat_id') ||
      !chatHandleJoinColumnNames.contains('handle_id')) {
    return const <int, Set<int>>{};
  }

  final rows = database.select(
    'SELECT chat_id, handle_id FROM chat_handle_join',
  );
  final handleIdsByChatId = <int, Set<int>>{};
  for (final row in rows) {
    final chatId = _coerceInt(row['chat_id']);
    final handleId = _coerceInt(row['handle_id']);
    if (chatId == null || handleId == null) {
      continue;
    }
    handleIdsByChatId.putIfAbsent(chatId, () => <int>{}).add(handleId);
  }

  return handleIdsByChatId;
}

Future<Map<int, _ArchiveHandleRow>> _loadStagedArchiveHandlesById({
  required SqfliteImportDatabase archiveImportDb,
  required int batchId,
}) async {
  final rows = await archiveImportDb.rawQuery(
    '''
    SELECT id, raw_identifier, normalized_identifier, compound_identifier, service, country, last_seen_utc
    FROM handles
    WHERE batch_id = ?
    ''',
    <Object?>[batchId],
  );

  final handlesById = <int, _ArchiveHandleRow>{};
  for (final row in rows) {
    final sourceHandleId = _coerceInt(row['id']);
    final rawIdentifier = _readTrimmedString(row['raw_identifier']);
    final compoundIdentifier = _readTrimmedString(row['compound_identifier']);
    if (sourceHandleId == null ||
        rawIdentifier == null ||
        compoundIdentifier == null) {
      continue;
    }

    handlesById[sourceHandleId] = _ArchiveHandleRow(
      sourceHandleId: sourceHandleId,
      rawIdentifier: rawIdentifier,
      normalizedIdentifier: _readTrimmedString(row['normalized_identifier']),
      compoundIdentifier: compoundIdentifier,
      service: sanitizeHandleService(_readTrimmedString(row['service'])),
      country: _readTrimmedString(row['country']),
      lastSeenUtc: _readTrimmedString(row['last_seen_utc']),
    );
  }

  return handlesById;
}

Future<Map<String, List<_ArchiveChatParticipantRow>>>
_loadStagedArchiveParticipantsByChatGuid({
  required SqfliteImportDatabase archiveImportDb,
  required int batchId,
}) async {
  final rows = await archiveImportDb.rawQuery(
    '''
    SELECT c.guid AS chat_guid, cth.handle_id, cth.role, cth.added_at_utc
    FROM chat_to_handle cth
    JOIN chats c ON c.id = cth.chat_id
    WHERE c.batch_id = ?
    ORDER BY c.guid, cth.handle_id
    ''',
    <Object?>[batchId],
  );

  final rowsByChatGuid = <String, List<_ArchiveChatParticipantRow>>{};
  for (final row in rows) {
    final chatGuid = _readTrimmedString(row['chat_guid']);
    final handleId = _coerceInt(row['handle_id']);
    if (chatGuid == null || handleId == null) {
      continue;
    }

    rowsByChatGuid
        .putIfAbsent(chatGuid, () => <_ArchiveChatParticipantRow>[])
        .add(
          _ArchiveChatParticipantRow(
            handleId: handleId,
            role: _readTrimmedString(row['role']),
            addedAtUtc: _readTrimmedString(row['added_at_utc']),
          ),
        );
  }

  return rowsByChatGuid;
}

List<String> _buildArchiveWarnings(String archivePath) {
  if (Directory(path.join(archivePath, 'Attachments')).existsSync()) {
    return <String>[
      'Attachments folder found. Attachment import is not part of this first version.',
    ];
  }

  return <String>[
    'No Attachments folder was found. Messages can still be imported, but older attachments may not be available.',
  ];
}

Set<String> _readTableColumnNames(sqlite3.Database database, String tableName) {
  final rows = database.select(
    "SELECT name FROM pragma_table_info('$tableName')",
  );
  return rows
      .map((row) => _readTrimmedString(row['name']))
      .whereType<String>()
      .toSet();
}

String _selectMessageColumn(
  Set<String> columnNames,
  String columnName,
  String fallbackExpression,
) {
  return columnNames.contains(columnName) ? columnName : fallbackExpression;
}

int? _coerceInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value');
}

bool _coerceBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  return '$value' == '1' || '$value'.toLowerCase() == 'true';
}

String _syntheticArchiveChatGuid(String archivePath) {
  return 'historical-archive::$archivePath';
}

String _archiveSourceProvenance({
  required String archiveLabel,
  required int batchId,
}) {
  final sanitizedLabel = archiveLabel
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '')
      .toLowerCase();
  if (sanitizedLabel.isEmpty) {
    return 'archive_batch_$batchId';
  }
  return 'archive_$sanitizedLabel';
}

final class _ArchiveChatRow {
  const _ArchiveChatRow({
    required this.sourceChatId,
    required this.guid,
    required this.service,
    required this.displayName,
    required this.isGroup,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final int sourceChatId;
  final String guid;
  final String service;
  final String? displayName;
  final bool isGroup;
  final String? createdAtUtc;
  final String? updatedAtUtc;
}

final class _ArchiveHandleRow {
  const _ArchiveHandleRow({
    required this.sourceHandleId,
    required this.rawIdentifier,
    required this.normalizedIdentifier,
    required this.compoundIdentifier,
    required this.service,
    required this.country,
    required this.lastSeenUtc,
  });

  final int sourceHandleId;
  final String rawIdentifier;
  final String? normalizedIdentifier;
  final String compoundIdentifier;
  final String service;
  final String? country;
  final String? lastSeenUtc;
}

final class _ArchiveChatParticipantRow {
  const _ArchiveChatParticipantRow({
    required this.handleId,
    required this.role,
    required this.addedAtUtc,
  });

  final int handleId;
  final String? role;
  final String? addedAtUtc;
}

String? _readTrimmedString(Object? value) {
  if (value == null) {
    return null;
  }

  final text = '$value'.trim();
  if (text.isEmpty) {
    return null;
  }

  return text;
}
