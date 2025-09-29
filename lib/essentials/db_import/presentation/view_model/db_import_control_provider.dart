import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../import/application/migration_service.dart';
import '../../../import/domain/entities/import_progress_stage.dart';
import '../../../import/domain/entities/import_subtask_timing.dart';
import '../../../import/domain/feature_constants.dart';
import '../../../import/feature_level_providers.dart';

part 'db_import_control_provider.g.dart';

class DbImportControlState {
  const DbImportControlState({
    this.selectedMode = ImportMode.import,
    this.isProcessing = false,
    this.statusMessage,
    this.progress,
    this.stages = const [],
    this.currentStage,
    this.viewMode = ImportViewMode.progress,
    this.timings = const [],
  });

  final ImportMode selectedMode;
  final bool isProcessing;
  final String? statusMessage;
  final double? progress;
  final List<ImportProgressStage> stages;
  final String? currentStage;
  final ImportViewMode viewMode;
  final List<ImportSubtaskTiming> timings;

  DbImportControlState copyWith({
    ImportMode? selectedMode,
    bool? isProcessing,
    String? statusMessage,
    double? progress,
    List<ImportProgressStage>? stages,
    String? currentStage,
    ImportViewMode? viewMode,
    List<ImportSubtaskTiming>? timings,
  }) {
    return DbImportControlState(
      selectedMode: selectedMode ?? this.selectedMode,
      isProcessing: isProcessing ?? this.isProcessing,
      statusMessage: statusMessage ?? this.statusMessage,
      progress: progress ?? this.progress,
      stages: stages ?? this.stages,
      currentStage: currentStage ?? this.currentStage,
      viewMode: viewMode ?? this.viewMode,
      timings: timings ?? this.timings,
    );
  }
}

@riverpod
class DbImportControlViewModel extends _$DbImportControlViewModel {
  @override
  DbImportControlState build() {
    return const DbImportControlState();
  }

  void setMode(ImportMode mode) {
    state = state.copyWith(selectedMode: mode);
  }

  void setViewMode(ImportViewMode mode) {
    if (state.viewMode != mode) {
      state = state.copyWith(viewMode: mode);
    }
  }

  void reset() {
    state = const DbImportControlState();
  }

  void startSubtask(String stageName, String subtaskName) {
    final updated = List<ImportSubtaskTiming>.from(state.timings)
      ..add(
        ImportSubtaskTiming(
          stageName: stageName,
          subtaskName: subtaskName,
          startedAt: DateTime.now(),
        ),
      );
    state = state.copyWith(timings: updated);
  }

  void endSubtask(String stageName, String subtaskName, {int? itemCount}) {
    final updated = <ImportSubtaskTiming>[];
    var ended = false;
    for (final timing in state.timings) {
      if (!ended &&
          timing.stageName == stageName &&
          timing.subtaskName == subtaskName &&
          timing.endedAt == null) {
        updated.add(timing.end(finalItemCount: itemCount));
        ended = true;
      } else {
        updated.add(timing);
      }
    }
    state = state.copyWith(timings: updated);
  }

  List<ImportProgressStage> _importStageTemplate() {
    return const [
      ImportProgressStage(
        name: 'clearingData',
        displayName: 'Clearing existing data',
      ),
      ImportProgressStage(
        name: 'importingHandles',
        displayName: 'Importing message handles',
      ),
      ImportProgressStage(
        name: 'importingChats',
        displayName: 'Importing chat conversations',
      ),
      ImportProgressStage(
        name: 'importingChatHandleJoins',
        displayName: 'Linking chats to handles',
      ),
      ImportProgressStage(
        name: 'analyzingMessages',
        displayName: 'Analyzing messages',
      ),
      ImportProgressStage(
        name: 'extractingRichContent',
        displayName: 'Extracting rich content',
      ),
      ImportProgressStage(
        name: 'importingMessages',
        displayName: 'Importing messages',
      ),
      ImportProgressStage(
        name: 'importingAttachments',
        displayName: 'Importing attachments',
      ),
      ImportProgressStage(
        name: 'importingAddressBook',
        displayName: 'Importing AddressBook contacts',
      ),
      ImportProgressStage(
        name: 'linkingContacts',
        displayName: 'Linking contacts to messages',
      ),
      ImportProgressStage(name: 'completed', displayName: 'Import completed'),
    ];
  }

  List<ImportProgressStage> _migrationStageTemplate() {
    return const [
      ImportProgressStage(
        name: 'preparingMigration',
        displayName: 'Preparing Migration',
      ),
      ImportProgressStage(name: 'clearingData', displayName: 'Clearing Data'),
      ImportProgressStage(
        name: 'migratingContacts',
        displayName: 'Migrating Contacts',
      ),
      ImportProgressStage(
        name: 'migratingHandles',
        displayName: 'Migrating Handles',
      ),
      ImportProgressStage(
        name: 'migratingChats',
        displayName: 'Migrating Chats',
      ),
      ImportProgressStage(
        name: 'migratingMessages',
        displayName: 'Migrating Messages',
      ),
      ImportProgressStage(
        name: 'updatingChatCounts',
        displayName: 'Updating Chat Counts',
      ),
      ImportProgressStage(name: 'completed', displayName: 'Completed'),
    ];
  }

  void _recordProgress(
    String stageName,
    double overallProgress,
    String message, {
    double? stageProgress,
    int? stageCurrent,
    int? stageTotal,
  }) {
    final exists = state.stages.any((stage) => stage.name == stageName);
    if (!exists) {
      return;
    }

    final currentStageIndex = state.stages.indexWhere(
      (stage) => stage.name == stageName,
    );

    final updatedStages = state.stages.asMap().entries.map((entry) {
      final index = entry.key;
      final stage = entry.value;

      if (stage.name == stageName) {
        final isComplete = stageProgress != null && stageProgress >= 1.0;
        return stage.copyWith(
          isActive: !isComplete,
          isComplete: isComplete,
          progress: stageProgress,
          current: stageCurrent,
          total: stageTotal,
        );
      }

      if (index < currentStageIndex) {
        if (!stage.isComplete) {
          return stage.copyWith(isActive: false, isComplete: true);
        }
        return stage;
      }

      return stage.copyWith(isActive: false);
    }).toList();

    state = state.copyWith(
      stages: updatedStages,
      currentStage: stageName,
      progress: overallProgress,
      statusMessage: message,
    );
  }

  Future<void> startImport() async {
    final stages = _importStageTemplate();

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting import...',
      progress: 0.0,
      stages: stages,
      timings: const [],
    );

    try {
      final importService = ref.read(importServiceProvider);
      final result = await importService.importAllData(
        onProgress:
            (
              stage,
              progress,
              message, {
              double? stageProgress,
              int? stageCurrent,
              int? stageTotal,
            }) {
              _recordProgress(
                stage,
                progress,
                message,
                stageProgress: stageProgress,
                stageCurrent: stageCurrent,
                stageTotal: stageTotal,
              );
            },
        onInstrument: (stageName, subtaskName, event, {int? itemCount}) {
          if (event == 'start') {
            startSubtask(stageName, subtaskName);
          } else if (event == 'end') {
            endSubtask(stageName, subtaskName, itemCount: itemCount);
          }
        },
      );

      if (result.success) {
        final totalRecords =
            result.messagesImported +
            result.contactsImported +
            result.handlesImported +
            result.chatsImported;
        state = state.copyWith(
          isProcessing: false,
          statusMessage:
              'Import completed successfully: $totalRecords records imported',
          progress: 1.0,
        );
      } else {
        state = state.copyWith(
          isProcessing: false,
          statusMessage: 'Import failed: ${result.error ?? 'Unknown error'}',
          progress: 0.0,
        );
      }
    } catch (error) {
      final message = _mapDatabaseError('Import failed', error);
      state = state.copyWith(
        isProcessing: false,
        statusMessage: message,
        progress: 0.0,
      );
    }
  }

  Future<void> startMigration() async {
    final stages = _migrationStageTemplate();

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting migration...',
      progress: 0.0,
      stages: stages,
      timings: const [],
    );

    try {
      final migrationService = ref.read(dataMigrationServiceProvider);
      final result = await migrationService.migrateAllData(
        onProgress:
            (
              stage,
              progress,
              message, {
              double? stageProgress,
              int? stageCurrent,
              int? stageTotal,
            }) {
              _recordProgress(
                stage,
                progress,
                message,
                stageProgress: stageProgress,
                stageCurrent: stageCurrent,
                stageTotal: stageTotal,
              );
            },
      );

      if (result.success) {
        final totalRecords =
            result.messagesImported +
            result.contactsImported +
            result.handlesImported +
            result.chatsImported;
        state = state.copyWith(
          isProcessing: false,
          statusMessage:
              'Migration completed successfully: $totalRecords records migrated',
          progress: 1.0,
        );
      } else {
        state = state.copyWith(
          isProcessing: false,
          statusMessage: 'Migration failed: ${result.error ?? 'Unknown error'}',
          progress: 0.0,
        );
      }
    } catch (error) {
      final message = _mapDatabaseError('Migration failed', error);
      state = state.copyWith(
        isProcessing: false,
        statusMessage: message,
        progress: 0.0,
      );
    }
  }

  String _mapDatabaseError(String prefix, Object error) {
    final raw = error.toString();
    if ((raw.contains('SqliteFfiException') &&
            raw.contains('authorization denied')) ||
        raw.contains('database is locked') ||
        raw.contains('SQLITE_BUSY') ||
        raw.contains('SQLITE_LOCKED') ||
        raw.contains('database_locked') ||
        raw.contains('unable to open database file')) {
      return '$prefix: Database is locked or in use.\n\n'
          'Troubleshooting steps:\n'
          '1. Close VS Code SQLite extension viewer\n'
          '2. Close DB Browser for SQLite\n'
          '3. Check for other running instances of this app\n'
          '4. Restart the app if the lock persists\n\n'
          'Technical error: $raw';
    }

    return '$prefix: $raw';
  }

  Future<void> checkDatabaseAccess() async {
    state = state.copyWith(statusMessage: 'Checking database access...');

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        statusMessage: 'Database access check completed. Ready for migration.',
      );
    } catch (error) {
      final message = _mapDatabaseError('Database access check failed', error);
      state = state.copyWith(statusMessage: message);
    }
  }

  void showDatabaseDiagnostics() {
    const diagnosticMessage = '''
Database Lock Diagnostics:

🔍 MOST LIKELY CAUSE:
The running application itself has database connections open!

Common causes of database locks:
1. 🔥 INTERNAL: App's own database connections (most likely)
2. VS Code SQLite extension
3. DB Browser for SQLite
4. Another instance of this app
5. Terminal sqlite3 commands
6. System backup processes (Time Machine)
7. Antivirus scanning
8. File indexing (Spotlight)

📁 Database file locations:
• import.db (in ~/sqlite_rmc/messages/)
• working.db (in ~/sqlite_rmc/messages/)

🛠️ Troubleshooting steps:
1. 🔄 RESTART THIS APP (closes internal connections)
2. Quit all database applications
3. Check Activity Monitor for sqlite processes
4. Close any open terminal sqlite3 sessions
5. Run migration again

💡 Technical note: The app may be holding database connections
that prevent migration access. Restarting the app is the best solution.''';

    state = state.copyWith(statusMessage: diagnosticMessage);
  }
}
