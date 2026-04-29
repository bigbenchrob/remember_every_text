import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../db/feature_level_providers.dart';
import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../db_importers/application/debug_settings_provider.dart';
import '../../../logging/application/migration_audit_writer.dart';
import '../../../logging/application/pipeline_incident_tracker_provider.dart';
import '../../../search/feature_level_providers.dart';
import '../../domain/base_table_migrator.dart';
import '../../domain/entities/db_migration_result.dart';
import '../../domain/states/table_migration_progress.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';
import '../diagnostics/migration_diagnostics.dart';
import '../migrators/attachments_migrator.dart';
import '../migrators/chat_to_handle_migrator.dart';
import '../migrators/chats_migrator.dart';
import '../migrators/handle_to_participant_migrator.dart';
import '../migrators/handles_migrator.dart';
import '../migrators/message_read_marks_migrator.dart';
import '../migrators/messages_migrator.dart';
import '../migrators/participants_migrator.dart';
import '../migrators/reaction_counts_migrator.dart';
import '../migrators/reactions_migrator.dart';
import '../migrators/read_state_migrator.dart';
import '../migrators/recovered_unlinked_attachments_migrator.dart';
import '../migrators/recovered_unlinked_messages_migrator.dart';
import './migration_orchestrator.dart';

typedef MigrationExecutionPlanCallback =
    void Function(List<MigratorStep> steps);

class HandlesMigrationService {
  HandlesMigrationService({required this.ref});

  final Ref ref;

  static const String _logContext = 'HandlesMigrationService';
  static final HandlesMigrator _handlesMigrator = HandlesMigrator();
  static const ChatsMigrator _chatsMigrator = ChatsMigrator();
  static const ChatToHandleMigrator _chatToHandleMigrator =
      ChatToHandleMigrator();
  static const ParticipantsMigrator _participantsMigrator =
      ParticipantsMigrator();
  static const HandleToParticipantMigrator _handleToParticipantMigrator =
      HandleToParticipantMigrator();
  static const MessagesMigrator _messagesMigrator = MessagesMigrator();
  static const RecoveredUnlinkedMessagesMigrator
  _recoveredUnlinkedMessagesMigrator = RecoveredUnlinkedMessagesMigrator();
  static const AttachmentsMigrator _attachmentsMigrator = AttachmentsMigrator();
  static const RecoveredUnlinkedAttachmentsMigrator
  _recoveredUnlinkedAttachmentsMigrator =
      RecoveredUnlinkedAttachmentsMigrator();
  static const ReactionsMigrator _reactionsMigrator = ReactionsMigrator();
  static const ReactionCountsMigrator _reactionCountsMigrator =
      ReactionCountsMigrator();
  static const MessageReadMarksMigrator _messageReadMarksMigrator =
      MessageReadMarksMigrator();
  static const ReadStateMigrator _readStateMigrator = ReadStateMigrator();

  /// Names of synthetic (non-orchestrated) post-migration steps.
  static const String _rebuildIndexesStep = 'rebuild_indexes';
  static const String _rebuildSearchStep = 'rebuild_search';

  Future<bool> relationshipProjectionRepairRequired() async {
    final importDatabase = await ref.read(sqfliteImportDatabaseProvider.future);
    final workingDatabase = await ref.read(driftWorkingDatabaseProvider.future);

    final projectedChatMemberships = await _chatToHandleMigrator.count(
      workingDatabase,
      'chat_to_handle',
    );
    final projectedParticipantLinks = await _handleToParticipantMigrator.count(
      workingDatabase,
      'handle_to_participant',
    );

    if (projectedChatMemberships > 0 && projectedParticipantLinks > 0) {
      return false;
    }

    return _withAttachedImport(
      workingDatabase: workingDatabase,
      importDatabase: importDatabase,
      run: () async {
        final joinableChatMemberships = projectedChatMemberships == 0
            ? await _countJoinableChatMemberships(workingDatabase)
            : 0;
        final joinableParticipantLinks = projectedParticipantLinks == 0
            ? await _countJoinableParticipantLinks(workingDatabase)
            : 0;

        return (projectedChatMemberships == 0 && joinableChatMemberships > 0) ||
            (projectedParticipantLinks == 0 && joinableParticipantLinks > 0);
      },
    );
  }

  Future<DbMigrationResult> run({
    MigrationExecutionPlanCallback? onExecutionPlan,
    TableMigrationProgressCallback? onTableProgress,
    bool incrementalMode = false,
  }) async {
    final debugSettings = ref.watch(importDebugSettingsProvider);
    final importDatabase = await ref.watch(
      sqfliteImportDatabaseProvider.future,
    );
    final workingDatabase = await ref.watch(
      driftWorkingDatabaseProvider.future,
    );

    final context = MigrationContextSqlite(
      importDb: importDatabase,
      workingDb: workingDatabase,
      log: debugSettings.logProgress,
      incrementalMode: incrementalMode,
    );

    final migrators = <BaseTableMigrator>[
      _handlesMigrator,
      _chatsMigrator,
      _chatToHandleMigrator,
      _participantsMigrator,
      _handleToParticipantMigrator,
      _messagesMigrator,
      _recoveredUnlinkedMessagesMigrator,
      _attachmentsMigrator,
      _recoveredUnlinkedAttachmentsMigrator,
      _reactionsMigrator,
      _reactionCountsMigrator,
      _messageReadMarksMigrator,
      _readStateMigrator,
    ];

    final orchestrator = MigrationOrchestrator(migrators);

    // Communicate the execution plan to the UI before running.
    // The plan includes orchestrated migrators plus post-migration steps.
    final orchestratorSteps = orchestrator.executionOrder();
    final postStepBase = orchestratorSteps.length;
    final allSteps = <MigratorStep>[
      ...orchestratorSteps,
      MigratorStep(
        index: postStepBase,
        name: _rebuildIndexesStep,
        displayName: 'Rebuild Indexes',
      ),
      MigratorStep(
        index: postStepBase + 1,
        name: _rebuildSearchStep,
        displayName: 'Rebuild Search',
      ),
    ];
    onExecutionPlan?.call(allSteps);

    try {
      // Run diagnostics before migration to help troubleshoot issues
      if (debugSettings.logProgress == print) {
        const diagnostics = MigrationDiagnostics();
        final report = await diagnostics.diagnose(
          importDb: importDatabase,
          workingDb: workingDatabase,
        );
        final formatted = diagnostics.formatReport(report);
        debugSettings.logProgress('\n$formatted');
      }

      await orchestrator.run(context, onTableProgress: onTableProgress);

      // --- Post-orchestrator synthetic steps ---

      // Rebuild indexes
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.validatePrereqs,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.copy,
        TableMigrationStatus.started,
      );
      await Future<void>.delayed(Duration.zero);

      await workingDatabase.rebuildGlobalMessageIndex();
      await workingDatabase.rebuildMessageIndex();
      await workingDatabase.rebuildContactMessageIndex();
      await workingDatabase.createMessageIndexTriggers();

      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.copy,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildIndexesStep,
        'Rebuild Indexes',
        TableMigrationPhase.postValidate,
        TableMigrationStatus.succeeded,
      );

      // Rebuild search indexes
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.validatePrereqs,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.copy,
        TableMigrationStatus.started,
      );
      await Future<void>.delayed(Duration.zero);

      final searchIndexOrchestrator = ref.read(searchIndexOrchestratorProvider);
      await searchIndexOrchestrator.rebuildAll();

      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.copy,
        TableMigrationStatus.succeeded,
      );
      _emitSyntheticEvent(
        onTableProgress,
        _rebuildSearchStep,
        'Rebuild Search',
        TableMigrationPhase.postValidate,
        TableMigrationStatus.succeeded,
      );

      // Gather final counts for the result
      final handlesCount = await _handlesMigrator.count(
        context.workingDb,
        'handles_canonical',
      );
      final chatsCount = await _chatsMigrator.count(context.workingDb, 'chats');
      final chatMembershipCount = await _chatToHandleMigrator.count(
        context.workingDb,
        'chat_to_handle',
      );
      final participantsCount = await _participantsMigrator.count(
        context.workingDb,
        'participants',
      );
      final participantLinksCount = await _handleToParticipantMigrator.count(
        context.workingDb,
        'handle_to_participant',
      );
      final messagesCount = await _messagesMigrator.count(
        context.workingDb,
        'messages',
      );
      final attachmentsCount = await _attachmentsMigrator.count(
        context.workingDb,
        'attachments',
      );
      final reactionsCount = await _reactionsMigrator.count(
        context.workingDb,
        'reactions',
      );
      final latestBatch = await _latestBatchId(await importDatabase.database);

      debugSettings.logProgress(
        '$_logContext: projected chat memberships=$chatMembershipCount '
        'participant links=$participantLinksCount',
      );

      // Write detailed audit log
      try {
        await const MigrationAuditWriter().writeReport(
          importDb: importDatabase,
          workingDb: workingDatabase,
          incrementalMode: incrementalMode,
          success: true,
        );
      } catch (auditError) {
        debugSettings.logProgress(
          '$_logContext: audit log write failed (non-fatal): $auditError',
        );
      }

      final result = DbMigrationResult(
        batchId: latestBatch ?? 0,
        success: true,
        identitiesProjected: handlesCount,
        identityHandleLinksProjected: participantLinksCount,
        chatsProjected: chatsCount,
        participantsProjected: participantsCount,
        messagesProjected: messagesCount,
        attachmentsProjected: attachmentsCount,
        reactionsProjected: reactionsCount,
      );
      await ref
          .read(pipelineIncidentTrackerProvider.notifier)
          .recordMigrationResult(
            result: result,
            incrementalMode: incrementalMode,
          );
      return result;
    } catch (error, stackTrace) {
      debugSettings.logError('$_logContext: migration failed: $error');
      debugSettings.logProgress(stackTrace.toString());

      // Write audit log even on failure
      try {
        await const MigrationAuditWriter().writeReport(
          importDb: importDatabase,
          workingDb: workingDatabase,
          incrementalMode: incrementalMode,
          success: false,
          errorMessage: '$error',
        );
      } catch (_) {
        // Audit logging is best-effort; don't mask the real error.
      }

      final result = DbMigrationResult(
        batchId: 0,
        success: false,
        error: 'Identity + message migration failed: $error',
      );
      await ref
          .read(pipelineIncidentTrackerProvider.notifier)
          .recordMigrationResult(
            result: result,
            incrementalMode: incrementalMode,
          );
      return result;
    }
  }

  void _emitSyntheticEvent(
    TableMigrationProgressCallback? onTableProgress,
    String name,
    String displayName,
    TableMigrationPhase phase,
    TableMigrationStatus status,
  ) {
    onTableProgress?.call(
      TableMigrationProgressEvent(
        tableName: name,
        displayName: displayName,
        phase: phase,
        status: status,
      ),
    );
  }

  Future<int?> _latestBatchId(Database db) async {
    final rows = await db.query(
      'import_batches',
      columns: <String>['id'],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['id'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  Future<T> _withAttachedImport<T>({
    required WorkingDatabase workingDatabase,
    required SqfliteImportDatabase importDatabase,
    required Future<T> Function() run,
  }) async {
    final importSqlite = await importDatabase.database;
    final escapedPath = importSqlite.path.replaceAll("'", "''");
    await workingDatabase.customStatement(
      "ATTACH DATABASE '$escapedPath' AS repair_import",
    );
    try {
      return await run();
    } finally {
      await workingDatabase.customStatement('DETACH DATABASE repair_import');
    }
  }

  Future<int> _countJoinableChatMemberships(
    WorkingDatabase workingDatabase,
  ) async {
    final rows = await workingDatabase.customSelect('''
      SELECT COUNT(*) AS c
      FROM repair_import.chat_to_handle cth
      JOIN handles_canonical_to_alias map
        ON map.source_handle_id = cth.handle_id
      JOIN handles_canonical h ON h.id = map.canonical_handle_id
      JOIN chats c ON c.id = cth.chat_id
    ''').get();
    return _extractCount(rows, 'c');
  }

  Future<int> _countJoinableParticipantLinks(
    WorkingDatabase workingDatabase,
  ) async {
    final rows = await workingDatabase.customSelect('''
      SELECT COUNT(*) AS c
      FROM repair_import.contact_to_chat_handle cth
      JOIN repair_import.contacts c
        ON c.Z_PK = cth.contact_Z_PK AND c.is_ignored = 0
      JOIN repair_import.handles h
        ON h.id = cth.chat_handle_id AND h.is_ignored = 0
      JOIN handles_canonical_to_alias map
        ON map.source_handle_id = cth.chat_handle_id
      JOIN handles_canonical wh ON wh.id = map.canonical_handle_id
      JOIN participants p ON p.id = c.Z_PK
    ''').get();
    return _extractCount(rows, 'c');
  }

  int _extractCount(List<dynamic> rows, String key) {
    if (rows.isEmpty) {
      return 0;
    }
    final first = rows.first;
    final data = (first as dynamic).data as Map<String, Object?>;
    final value = data[key];
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }
}
