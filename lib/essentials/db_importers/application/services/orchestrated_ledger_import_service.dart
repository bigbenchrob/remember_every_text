import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../../features/address_book_folders/feature_level_providers.dart';
import '../../../../providers.dart';
import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../logging/application/import_audit_writer.dart';
import '../../../logging/application/pipeline_incident_tracker_provider.dart';
import '../../domain/entities/db_import_result.dart';
import '../../domain/i_importers.dart/table_importer.dart';
import '../../domain/ports/message_extractor_port.dart';
import '../../domain/states/table_import_progress.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import '../debug_settings_provider.dart';
import '../import_execution_gate_provider.dart';
import '../importers/attachments_importer.dart';
import '../importers/chat_to_handle_importer.dart';
import '../importers/chat_to_message_importer.dart';
import '../importers/chats_importer.dart';
import '../importers/clear_ledger_importer.dart';
import '../importers/contact_channels_importer.dart';
import '../importers/contact_to_chat_handle_importer.dart';
import '../importers/contacts_importer.dart';
import '../importers/handles_importer.dart';
import '../importers/message_attachments_importer.dart';
import '../importers/message_rich_text_importer.dart';
import '../importers/messages_importer.dart';
import '../importers/prepare_sources_importer.dart';
import '../orchestrator/import_orchestrator.dart';
import '../pipeline_cancellation.dart';
import 'incremental_ledger_integrity_check.dart';

typedef ExecutionPlanCallback = void Function(List<ImporterStep> steps);

class OrchestratedLedgerImportService {
  OrchestratedLedgerImportService({
    required this.ref,
    required MessageExtractorPort extractor,
    this.rustExtractionLimit = 200000,
  }) : _extractor = extractor;

  final Ref ref;
  // ignore: unused_field
  final MessageExtractorPort _extractor;
  final int rustExtractionLimit;

  static const String _logContext = 'OrchestratedLedgerImportService';

  Future<DbImportResult> runImport({
    required String executionOwner,
    String? sourceChatDbOverride,
    String chatSourceKind = 'current_mac',
    String? sourceLabelOverride,
    bool includeContactImport = true,
    bool includeAttachmentImport = true,
    ExecutionPlanCallback? onExecutionPlan,
    TableImportProgressCallback? onTableProgress,
  }) async {
    final executionGate = ref.read(importExecutionGateProvider.notifier);
    if (!executionGate.tryAcquire(executionOwner)) {
      final gateState = ref.read(importExecutionGateProvider);
      final activeOwner = gateState.owner ?? 'unknown';
      return DbImportResult(
        batchId: -1,
        success: false,
        error: 'Import is already running for $activeOwner.',
      );
    }

    final debugSettings = ref.read(importDebugSettingsProvider);
    final ledgerDb = await ref.read(sqfliteImportDatabaseProvider.future);
    final pathsHelper = await ref.read(pathsHelperProvider.future);
    final isHistoricalArchive = chatSourceKind == 'historical_archive';
    final messagesDbPath = sourceChatDbOverride ?? pathsHelper.chatDBPath;
    final normalizedMessagesDbPath = p.normalize(messagesDbPath);
    final sourceLabel =
        sourceLabelOverride ??
        (isHistoricalArchive
            ? p.basename(p.dirname(normalizedMessagesDbPath))
            : 'Current Mac Messages');
    final startedAtUtc = DateTime.now().toUtc().toIso8601String();
    final startedAt =
        DateTime.parse(startedAtUtc).millisecondsSinceEpoch ~/ 1000;
    final currentSourceId = await ledgerDb.upsertLedgerSource(
      sourceKind: chatSourceKind,
      stableKey: normalizedMessagesDbPath,
      sourceLabel: sourceLabel,
      chatDbPath: normalizedMessagesDbPath,
      attachmentsPath: p.join(
        p.dirname(normalizedMessagesDbPath),
        'Attachments',
      ),
      seenAt: startedAt,
      importedAt: startedAt,
      notes: isHistoricalArchive
          ? 'Historical archive canonical ledger import.'
          : null,
    );

    final hasAnyLedgerData =
        await ledgerDb.maxHandleSourceRowId() != null ||
        await ledgerDb.maxChatSourceRowId() != null ||
        await ledgerDb.maxMessageSourceRowId() != null ||
        await ledgerDb.maxAttachmentSourceRowId() != null ||
        await ledgerDb.maxMessageAttachmentSourceRowId() != null;

    var previousMaxHandleRowId = isHistoricalArchive
        ? await ledgerDb.maxHandleSourceRowIdForSource(currentSourceId)
        : await ledgerDb.maxHandleSourceRowId();
    var previousMaxChatRowId = isHistoricalArchive
        ? await ledgerDb.maxChatSourceRowIdForSource(currentSourceId)
        : await ledgerDb.maxChatSourceRowId();
    var previousMaxMessageRowId = isHistoricalArchive
        ? await ledgerDb.maxMessageSourceRowIdForSource(currentSourceId)
        : await ledgerDb.maxMessageSourceRowId();
    var previousMaxAttachmentRowId = includeAttachmentImport
        ? await ledgerDb.maxAttachmentSourceRowId()
        : null;
    var previousMaxMessageAttachmentRowId = includeAttachmentImport
        ? await ledgerDb.maxMessageAttachmentSourceRowId()
        : null;

    var hasExistingSourceLedgerData =
        previousMaxHandleRowId != null ||
        previousMaxChatRowId != null ||
        previousMaxMessageRowId != null ||
        previousMaxAttachmentRowId != null ||
        previousMaxMessageAttachmentRowId != null;
    var hasExistingLedgerData = hasAnyLedgerData;

    if (!isHistoricalArchive &&
        hasExistingSourceLedgerData &&
        previousMaxMessageRowId != null) {
      const messageCountFloor = 50;
      const rowIdGapThreshold = 500;
      final existingMessageCount = await ledgerDb.countRows('messages');
      final detectedTruncatedMessages =
          existingMessageCount > 0 &&
          existingMessageCount < messageCountFloor &&
          previousMaxMessageRowId - existingMessageCount > rowIdGapThreshold;

      if (detectedTruncatedMessages) {
        debugSettings.logProgress(
          '$_logContext: Detected truncated message set, forcing full reimport.',
        );
        previousMaxHandleRowId = null;
        previousMaxChatRowId = null;
        previousMaxMessageRowId = null;
        previousMaxAttachmentRowId = null;
        previousMaxMessageAttachmentRowId = null;
        hasExistingSourceLedgerData = false;
        hasExistingLedgerData = false;
      }
    }

    String? addressBookPath;
    if (includeContactImport) {
      final addressBookEither = await ref.read(
        futureGetFolderAggregateProvider.future,
      );
      addressBookEither.fold(
        (_) {},
        (aggregate) => addressBookPath = aggregate.mostRecentFolderPath,
      );
      if (addressBookPath == null) {
        const failureMessage =
            'AddressBook path could not be resolved via getFolderAggregateEitherProvider';
        debugSettings.logError('$_logContext: $failureMessage');
        return const DbImportResult(
          batchId: -1,
          success: false,
          error: 'AddressBook path resolution failed',
        );
      }
    }

    final messagesFile = File(messagesDbPath);
    final addressBookFile = addressBookPath == null
        ? null
        : File(addressBookPath!);
    if (!messagesFile.existsSync()) {
      final message = 'Messages database not found at $messagesDbPath';
      debugSettings.logError('$_logContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }
    if (includeContactImport &&
        (addressBookFile == null || !addressBookFile.existsSync())) {
      final message =
          'AddressBook database not found at ${addressBookFile?.path}';
      debugSettings.logError('$_logContext: $message');
      return DbImportResult(batchId: -1, success: false, error: message);
    }

    if (!isHistoricalArchive && hasExistingSourceLedgerData) {
      final hasMissingMembershipParents = await hasMissingChatMembershipParents(
        ledgerDb: ledgerDb,
        messagesDbPath: messagesFile.path,
      );
      if (hasMissingMembershipParents) {
        debugSettings.logProgress(
          '$_logContext: Detected incomplete handles/chats baseline for chat memberships, forcing full reimport.',
        );
        previousMaxHandleRowId = null;
        previousMaxChatRowId = null;
        previousMaxMessageRowId = null;
        previousMaxAttachmentRowId = null;
        previousMaxMessageAttachmentRowId = null;
        hasExistingSourceLedgerData = false;
        hasExistingLedgerData = false;
      }
    }

    final batchId = await ledgerDb.insertImportBatch(
      startedAtUtc: startedAtUtc,
      sourceChatDb: normalizedMessagesDbPath,
      sourceAddressbook: addressBookFile?.path,
      hostInfoJson: await _buildHostInfoJson(),
      notes: 'Orchestrated import ${DateTime.now().toIso8601String()}',
      chatSourceId: currentSourceId,
      chatSourceKind: chatSourceKind,
      status: 'running',
      startedAt: startedAt,
      sourceLabelSnapshot: sourceLabel,
    );
    if (hasExistingSourceLedgerData) {
      await ledgerDb.assignExistingRecordsToBatch(
        batchId: batchId,
        sourceId: currentSourceId,
        updateContacts: includeContactImport,
      );
    }

    await _recordSourceFile(
      ledgerDb: ledgerDb,
      batchId: batchId,
      file: messagesFile,
    );
    if (addressBookFile != null) {
      await _recordSourceFile(
        ledgerDb: ledgerDb,
        batchId: batchId,
        file: addressBookFile,
      );
    }

    Database? messagesDb;
    Database? addressBookDb;
    final scratchpad = <String, Object?>{};

    try {
      messagesDb = await openDatabase(messagesFile.path, readOnly: true);
      addressBookDb = includeContactImport
          ? await openDatabase(addressBookFile!.path, readOnly: true)
          : await openDatabase(inMemoryDatabasePath);

      final sourceMaxHandleRowIdAtBatchStart = await _readMaxSourceRowId(
        messagesDb,
        'handle',
      );
      final sourceMaxChatRowIdAtBatchStart = await _readMaxSourceRowId(
        messagesDb,
        'chat',
      );
      final sourceMaxMessageRowIdAtBatchStart = await _readMaxSourceRowId(
        messagesDb,
        'message',
      );
      final sourceMaxAttachmentRowIdAtBatchStart = await _readMaxSourceRowId(
        messagesDb,
        'attachment',
      );

      final context = ImportContextSqlite(
        importDb: ledgerDb,
        messagesDb: messagesDb,
        messagesDbPath: messagesFile.path,
        addressBookDb: addressBookDb,
        batchId: batchId,
        chatSourceId: currentSourceId,
        log: debugSettings.logProgress,
        extractor: _extractor,
        rustExtractionLimit: rustExtractionLimit,
        previousMaxHandleRowId: previousMaxHandleRowId,
        previousMaxChatRowId: previousMaxChatRowId,
        previousMaxMessageRowId: previousMaxMessageRowId,
        previousMaxAttachmentRowId: previousMaxAttachmentRowId,
        previousMaxMessageAttachmentRowId: previousMaxMessageAttachmentRowId,
        sourceMaxHandleRowIdAtBatchStart: sourceMaxHandleRowIdAtBatchStart,
        sourceMaxChatRowIdAtBatchStart: sourceMaxChatRowIdAtBatchStart,
        sourceMaxMessageRowIdAtBatchStart: sourceMaxMessageRowIdAtBatchStart,
        sourceMaxAttachmentRowIdAtBatchStart:
            sourceMaxAttachmentRowIdAtBatchStart,
        hasExistingLedgerData: hasExistingLedgerData,
        scratchpad: scratchpad,
      );

      final importers = <TableImporter>[
        const PrepareSourcesImporter(),
        const ClearLedgerImporter(),
        HandlesImporter(),
        ChatsImporter(),
        ChatToHandleImporter(),
        if (includeContactImport) ContactsImporter(),
        if (includeContactImport) ContactChannelsImporter(),
        if (includeContactImport) ContactToChatHandleImporter(),
        MessagesImporter(),
        MessageRichTextImporter(),
        ChatToMessageImporter(),
        if (includeAttachmentImport) AttachmentsImporter(),
        if (includeAttachmentImport) MessageAttachmentsImporter(),
      ];

      final orchestrator = ImportOrchestrator(importers);
      onExecutionPlan?.call(orchestrator.executionOrder());
      await orchestrator.run(context, onTableProgress: onTableProgress);

      debugSettings.logProgress(
        '$_logContext: Ledger import completed successfully',
      );

      final finishedAtUtc = DateTime.now().toUtc().toIso8601String();
      final finishedAt =
          DateTime.parse(finishedAtUtc).millisecondsSinceEpoch ~/ 1000;
      final handlesImported = context.readScratch<int>('handles.inserted') ?? 0;
      final chatsImported = context.readScratch<int>('chats.inserted') ?? 0;
      final chatsUpdated = context.readScratch<int>('chats.updated') ?? 0;
      final chatsDeduplicated =
          context.readScratch<int>('chats.deduplicated') ?? 0;
      final chatMembershipsImported =
          context.readScratch<int>('chatMemberships.inserted') ?? 0;
      final contactsImported =
          context.readScratch<int>('contacts.inserted') ?? 0;
      final contactChannelsImported =
          context.readScratch<int>('contactChannels.inserted') ?? 0;
      final contactLinksImported =
          context.readScratch<int>('contactHandleLinks.inserted') ?? 0;
      final messagesImported =
          context.readScratch<int>('messages.inserted') ?? 0;
      final messagesUpdated = context.readScratch<int>('messages.updated') ?? 0;
      final messagesDeduplicated =
          context.readScratch<int>('messages.deduplicated') ?? 0;
      final messagesMissingGuids =
          context.readScratch<int>('messages.missingGuids') ?? 0;
      final recoveredMessagesUpdated =
          context.readScratch<int>('recoveredUnlinkedMessages.updated') ?? 0;
      final recoveredMessagesDeduplicated =
          context.readScratch<int>('recoveredUnlinkedMessages.deduplicated') ??
          0;
      final richTextApplied =
          context.readScratch<int>('messages.richTextApplied') ?? 0;
      final chatMessageLinks =
          context.readScratch<int>('chatToMessage.inserted') ?? 0;
      final attachmentsImported =
          context.readScratch<int>('attachments.inserted') ?? 0;
      final messageAttachmentLinks =
          context.readScratch<int>('messageAttachments.inserted') ?? 0;

      final totalRowsInserted =
          handlesImported +
          chatsImported +
          chatMembershipsImported +
          contactsImported +
          contactChannelsImported +
          contactLinksImported +
          messagesImported +
          chatMessageLinks +
          attachmentsImported +
          messageAttachmentLinks;
      final totalRowsUpdated =
          chatsUpdated + messagesUpdated + recoveredMessagesUpdated;
      final totalRowsDeduplicated =
          chatsDeduplicated +
          messagesDeduplicated +
          recoveredMessagesDeduplicated;

      await ledgerDb.updateImportBatch(
        id: batchId,
        finishedAtUtc: finishedAtUtc,
        notes: 'Completed orchestrated import',
        status: 'succeeded',
        finishedAt: finishedAt,
        rowsInserted: totalRowsInserted,
        rowsUpdated: totalRowsUpdated,
        rowsDeduplicated: totalRowsDeduplicated,
        rowsFailed: messagesMissingGuids,
      );

      try {
        await const ImportAuditWriter().writeReport(
          messagesDb: messagesDb,
          addressBookDb: addressBookDb,
          importDb: ledgerDb,
          scratchpad: scratchpad,
          batchId: batchId,
          startedAt: startedAtUtc,
          success: true,
          hasExistingLedgerData: hasExistingLedgerData,
          previousMaxMessageRowId: previousMaxMessageRowId,
        );
      } catch (auditError) {
        debugSettings.logProgress(
          '$_logContext: audit log write failed (non-fatal): $auditError',
        );
      }

      final handlesCount = await ledgerDb.countRows('handles');
      final chatsCount = await ledgerDb.countRows('chats');
      final membershipsCount = await ledgerDb.countRows('chat_to_handle');
      final messagesCount = await ledgerDb.countRows('messages');
      final chatMessageJoinCount = await ledgerDb.countRows('chat_to_message');
      final attachmentsCount = await ledgerDb.countRows('attachments');
      final messageAttachmentsCount = await ledgerDb.countRows(
        'message_attachments',
      );
      final contactsCount = await ledgerDb.countRows('contacts');
      final contactChannelsCount = await ledgerDb.countRows(
        'contact_phone_email',
      );
      final contactLinksCount = await ledgerDb.countRows(
        'contact_to_chat_handle',
      );

      final result = DbImportResult(
        batchId: batchId,
        success: true,
        handlesImported: handlesImported,
        chatsImported: chatsImported,
        participantsImported: chatMembershipsImported,
        messagesImported: messagesImported,
        attachmentsImported: attachmentsImported,
        messageAttachmentsImported: messageAttachmentLinks,
        contactsImported: contactsImported,
        contactChannelsImported: contactChannelsImported,
        warnings: <String>[
          'Handles table row count: $handlesCount',
          'Chats table row count: $chatsCount',
          'Chat memberships row count: $membershipsCount',
          'Messages table row count: $messagesCount',
          'Chat/message links row count: $chatMessageJoinCount',
          'Attachments table row count: $attachmentsCount',
          'Message/attachment links row count: $messageAttachmentsCount',
          'Contacts table row count: $contactsCount',
          'Contact channels row count: $contactChannelsCount',
          'Contact-to-handle links row count: $contactLinksCount',
          'Messages inserted this run: $messagesImported (rich text applied: $richTextApplied)',
          'Chat/message links inserted this run: $chatMessageLinks',
          'Attachments inserted this run: $attachmentsImported',
          'Message/attachment links inserted this run: $messageAttachmentLinks',
          'Contact links inserted this run: $contactLinksImported',
        ],
      );
      await ref
          .read(pipelineIncidentTrackerProvider.notifier)
          .recordImportResult(result: result, executionOwner: executionOwner);
      return result;
    } catch (error, stackTrace) {
      debugSettings.logError('$_logContext: import failed: $error');
      debugSettings.logProgress(stackTrace.toString());
      final isCancelled = error is DbPipelineCancelledException;

      final failedAtUtc = DateTime.now().toUtc().toIso8601String();
      final failedAt =
          DateTime.parse(failedAtUtc).millisecondsSinceEpoch ~/ 1000;
      try {
        await ledgerDb.updateImportBatch(
          id: batchId,
          finishedAtUtc: failedAtUtc,
          notes: isCancelled
              ? 'Canceled orchestrated import'
              : 'Failed orchestrated import',
          status: isCancelled ? 'cancelled' : 'failed',
          finishedAt: failedAt,
          errorSummary: isCancelled ? dbPipelineCancelledMessage : '$error',
        );
      } catch (_) {
        // Batch-finalization is best-effort on failure.
      }

      if (messagesDb != null && addressBookDb != null) {
        try {
          await const ImportAuditWriter().writeReport(
            messagesDb: messagesDb,
            addressBookDb: addressBookDb,
            importDb: ledgerDb,
            scratchpad: scratchpad,
            batchId: batchId,
            startedAt: startedAtUtc,
            success: false,
            errorMessage: '$error',
            hasExistingLedgerData: hasExistingLedgerData,
            previousMaxMessageRowId: previousMaxMessageRowId,
          );
        } catch (_) {
          // Audit logging is best-effort; don't mask the real error.
        }
      }

      final result = DbImportResult(
        batchId: batchId,
        success: false,
        error: isCancelled ? dbPipelineCancelledMessage : '$error',
      );
      await ref
          .read(pipelineIncidentTrackerProvider.notifier)
          .recordImportResult(result: result, executionOwner: executionOwner);
      return result;
    } finally {
      await messagesDb?.close();
      await addressBookDb?.close();
      executionGate.release(executionOwner);
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
    } catch (_) {}
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
}

Future<int?> _readMaxSourceRowId(Database db, String tableName) async {
  final rows = await db.rawQuery(
    'SELECT MAX(ROWID) AS max_rowid FROM $tableName',
  );
  if (rows.isEmpty) {
    return null;
  }

  final value = rows.first['max_rowid'];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}
