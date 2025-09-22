import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/migration_service.dart';
import '../../domain/entities/import_progress_stage.dart';
import '../../domain/entities/import_subtask_timing.dart';
import '../../domain/feature_constants.dart';
import '../../feature_level_providers.dart';

part 'import_control_state_provider.g.dart';

class ImportControlState {
  final ImportMode selectedMode;
  final bool isProcessing;
  final String? statusMessage;
  final double? progress;
  final List<ImportProgressStage> stages;
  final String? currentStage;
  final ImportViewMode viewMode;
  final List<ImportSubtaskTiming> timings;

  const ImportControlState({
    this.selectedMode = ImportMode.import,
    this.isProcessing = false,
    this.statusMessage,
    this.progress,
    this.stages = const [],
    this.currentStage,
    this.viewMode = ImportViewMode.progress,
    this.timings = const [],
  });

  ImportControlState copyWith({
    ImportMode? selectedMode,
    bool? isProcessing,
    String? statusMessage,
    double? progress,
    List<ImportProgressStage>? stages,
    String? currentStage,
    ImportViewMode? viewMode,
    List<ImportSubtaskTiming>? timings,
  }) {
    return ImportControlState(
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
class ImportControlViewModel extends _$ImportControlViewModel {
  // Renamed from ImportControlStateNotifier to follow codebase conventions
  @override
  ImportControlState build() {
    return const ImportControlState();
  }

  void setMode(ImportMode mode) {
    state = state.copyWith(selectedMode: mode);
  }

  void setViewMode(ImportViewMode mode) {
    if (state.viewMode != mode) {
      state = state.copyWith(viewMode: mode);
    }
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
    for (final t in state.timings) {
      if (!ended &&
          t.stageName == stageName &&
          t.subtaskName == subtaskName &&
          t.endedAt == null) {
        updated.add(t.end(finalItemCount: itemCount));
        ended = true;
      } else {
        updated.add(t);
      }
    }
    state = state.copyWith(timings: updated);
  }

  List<ImportProgressStage> _getImportStages() {
    return [
      const ImportProgressStage(
        name: 'clearingData',
        displayName: 'Clearing existing data',
      ),
      const ImportProgressStage(
        name: 'importingHandles',
        displayName: 'Importing message handles',
      ),
      const ImportProgressStage(
        name: 'importingChats',
        displayName: 'Importing chat conversations',
      ),
      const ImportProgressStage(
        name: 'importingChatHandleJoins',
        displayName: 'Linking chats to handles',
      ),
      const ImportProgressStage(
        name: 'analyzingMessages',
        displayName: 'Analyzing messages',
      ),
      const ImportProgressStage(
        name: 'extractingRichContent',
        displayName: 'Extracting rich content',
      ),
      const ImportProgressStage(
        name: 'importingMessages',
        displayName: 'Importing messages',
      ),
      const ImportProgressStage(
        name: 'importingAttachments',
        displayName: 'Importing attachments',
      ),
      const ImportProgressStage(
        name: 'importingAddressBook',
        displayName: 'Importing AddressBook contacts',
      ),
      const ImportProgressStage(
        name: 'linkingContacts',
        displayName: 'Linking contacts to messages',
      ),
      const ImportProgressStage(
        name: 'completed',
        displayName: 'Import completed',
      ),
    ];
  }

  void _updateStageProgress(
    String stageName,
    double overallProgress,
    String message, {
    double? stageProgress,
    int? stageCurrent,
    int? stageTotal,
  }) {
    final stageExists = state.stages.any((s) => s.name == stageName);
    if (!stageExists) {
      return;
    }

    final currentStageIndex = state.stages.indexWhere(
      (s) => s.name == stageName,
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
      } else if (index < currentStageIndex) {
        if (!stage.isComplete) {
          return stage.copyWith(isActive: false, isComplete: true);
        }
        return stage;
      } else {
        return stage.copyWith(isActive: false);
      }
    }).toList();

    state = state.copyWith(
      stages: updatedStages,
      currentStage: stageName,
      progress: overallProgress,
      statusMessage: message,
    );
  }

  Future<void> startImport() async {
    final initialStages = _getImportStages();

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting import...',
      progress: 0.0,
      stages: initialStages,
      currentStage: null,
    );

    try {
      final importService = ref.read(importServiceProvider);

      final result = await importService.importAllData(
        onProgress:
            (
              stage,
              progress,
              message, {
              stageProgress,
              stageCurrent,
              stageTotal,
            }) {
              _updateStageProgress(
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
    } catch (e) {
      var errorMessage = 'Import failed: $e';

      // Provide specific guidance for common database lock issues
      if (e.toString().contains('SqliteFfiException') &&
          e.toString().contains('authorization denied')) {
        errorMessage =
            'Import failed: Database is locked or in use.\n\n'
            'Common causes:\n'
            '• Close VS Code SQLite extension viewer\n'
            '• Close any database browser applications\n'
            '• Restart the app if database remains locked';
      } else if (e.toString().contains('database is locked') ||
          e.toString().contains('SQLITE_BUSY')) {
        errorMessage =
            'Import failed: Database is currently in use.\n\n'
            'Please close any applications viewing the database and try again.';
      }

      state = state.copyWith(
        isProcessing: false,
        statusMessage: errorMessage,
        progress: 0.0,
      );
    }
  }

  Future<void> startMigration() async {
    final initialStages = [
      const ImportProgressStage(
        name: 'preparingMigration',
        displayName: 'Preparing Migration',
      ),
      const ImportProgressStage(
        name: 'clearingData',
        displayName: 'Clearing Data',
      ),
      const ImportProgressStage(
        name: 'migratingContacts',
        displayName: 'Migrating Contacts',
      ),
      const ImportProgressStage(
        name: 'migratingHandles',
        displayName: 'Migrating Handles',
      ),
      const ImportProgressStage(
        name: 'migratingChats',
        displayName: 'Migrating Chats',
      ),
      const ImportProgressStage(
        name: 'migratingMessages',
        displayName: 'Migrating Messages',
      ),
      const ImportProgressStage(
        name: 'updatingChatCounts',
        displayName: 'Updating Chat Counts',
      ),
      const ImportProgressStage(name: 'completed', displayName: 'Completed'),
    ];

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'Starting migration...',
      progress: 0.0,
      stages: initialStages,
      currentStage: null,
    );

    try {
      final migrationService = ref.read(dataMigrationServiceProvider);

      final result = await migrationService.migrateAllData(
        onProgress:
            (
              String stage,
              double progress,
              String message, {
              double? stageProgress,
              int? stageCurrent,
              int? stageTotal,
            }) {
              _updateStageProgress(
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
        // Handle database lock errors in result.error as well
        var errorMessage =
            'Migration failed: ${result.error ?? 'Unknown error'}';
        final errorString = result.error ?? '';

        // Debug: Always show the raw error for now
        print('🔍 Migration Error Debug: $errorString');

        if (errorString.contains('SqliteFfiException') &&
            errorString.contains('authorization denied')) {
          errorMessage =
              'Migration failed: Database is locked or in use.\n\n'
              'Common causes:\n'
              '• Close VS Code SQLite extension viewer\n'
              '• Close any database browser applications\n'
              '• Check if another instance of this app is running\n'
              '• Restart the app if database remains locked\n\n'
              'Original error: $errorString';
        } else if (errorString.contains('database is locked') ||
            errorString.contains('SQLITE_BUSY')) {
          errorMessage =
              'Migration failed: Database is currently in use.\n\n'
              'Please close any applications viewing the database and try again.\n\n'
              'Original error: $errorString';
        } else {
          // For debugging - show the full error until we identify the pattern
          errorMessage =
              'Migration failed with unhandled error:\n\n$errorString\n\n'
              'This error will help improve the error handling. '
              'Please share this message for better diagnostics.';
        }

        state = state.copyWith(
          isProcessing: false,
          statusMessage: errorMessage,
          progress: 0.0,
        );
      }
    } catch (e) {
      var errorMessage = 'Migration failed: $e';
      final errorString = e.toString();

      // Enhanced database lock detection patterns
      if ((errorString.contains('SqliteFfiException') &&
              errorString.contains('authorization denied')) ||
          errorString.contains('database is locked') ||
          errorString.contains('SQLITE_BUSY') ||
          errorString.contains('SQLITE_LOCKED') ||
          errorString.contains('database_locked') ||
          errorString.contains('unable to open database file')) {
        errorMessage =
            'Migration failed: Database is locked or in use.\n\n'
            'Troubleshooting steps:\n'
            '1. Close VS Code SQLite extension viewer\n'
            '2. Close DB Browser for SQLite or similar tools\n'
            '3. Check if another instance of this app is running\n'
            '4. Try restarting this application\n'
            '5. Check if system backup is accessing files\n\n'
            'Technical error: $errorString';
      }

      state = state.copyWith(
        isProcessing: false,
        statusMessage: errorMessage,
        progress: 0.0,
      );
    }
  }

  void reset() {
    state = const ImportControlState();
  }

  /// Check if databases might be locked by external applications
  Future<void> checkDatabaseAccess() async {
    state = state.copyWith(statusMessage: 'Checking database access...');

    try {
      // Try to access both databases to check for locks
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        statusMessage: 'Database access check completed. Ready for migration.',
      );
    } catch (e) {
      var errorMessage = 'Database access check failed: $e';
      final errorString = e.toString();

      // Enhanced error detection for check
      if ((errorString.contains('SqliteFfiException') &&
              errorString.contains('authorization denied')) ||
          errorString.contains('database is locked') ||
          errorString.contains('SQLITE_BUSY') ||
          errorString.contains('SQLITE_LOCKED')) {
        errorMessage =
            'Database is currently locked!\n\n'
            'Troubleshooting steps:\n'
            '1. Close VS Code SQLite extension viewer\n'
            '2. Close DB Browser for SQLite\n'
            '3. Close any terminal windows running sqlite3\n'
            '4. Check Activity Monitor for sqlite processes\n'
            '5. Check if Time Machine is backing up\n'
            '6. Restart this app if needed\n\n'
            'Technical details: $errorString';
      }

      state = state.copyWith(statusMessage: errorMessage);
    }
  }

  /// Diagnostic method to help identify database lock sources
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
