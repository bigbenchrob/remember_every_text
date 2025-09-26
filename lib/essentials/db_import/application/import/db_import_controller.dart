import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/db_import_result.dart';
import '../../domain/states/db_import_progress.dart';
import '../../domain/states/db_import_state.dart';
import '../../domain/value_objects/db_import_stage.dart';
import '../../feature_level_providers.dart';

part 'db_import_controller.g.dart';

@riverpod
class DbImportController extends _$DbImportController {
  @override
  DbImportState build() => const DbImportState.idle();

  Future<DbImportResult> runImport() async {
    if (state.isRunning) {
      return state.result ??
          const DbImportResult(
            batchId: -1,
            success: false,
            error: 'Import already running',
          );
    }

    state = state.copyWith(
      status: DbImportStatus.running,
      progress: const DbImportProgress(
        stage: DbImportStage.preparingSources,
        overallProgress: 0.0,
        message: 'Preparing import pipeline',
      ),
      clearResult: true,
    );

    final service = ref.read(ledgerImportServiceProvider);

    try {
      final result = await service.runImport(
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
      );

      final status = result.success
          ? DbImportStatus.succeeded
          : DbImportStatus.failed;

      state = state.copyWith(
        status: status,
        progress: result.success
            ? const DbImportProgress(
                stage: DbImportStage.completed,
                overallProgress: 1.0,
                message: 'Import completed successfully',
                stageProgress: 1.0,
              )
            : state.progress,
        result: result,
      );

      return result;
    } catch (error, stackTrace) {
      final failureResult = DbImportResult(
        batchId: -1,
        success: false,
        error: 'Unexpected import failure: $error',
        warnings: <String>['Stack trace: $stackTrace'],
      );

      state = state.copyWith(
        status: DbImportStatus.failed,
        result: failureResult,
      );

      return failureResult;
    }
  }
}
