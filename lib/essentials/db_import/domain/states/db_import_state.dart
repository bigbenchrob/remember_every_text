import '../entities/db_import_result.dart';
import 'db_import_progress.dart';

enum DbImportStatus { idle, running, succeeded, failed }

class DbImportState {
  const DbImportState({required this.status, this.progress, this.result});

  const DbImportState.idle()
    : status = DbImportStatus.idle,
      progress = null,
      result = null;

  final DbImportStatus status;
  final DbImportProgress? progress;
  final DbImportResult? result;

  bool get isRunning => status == DbImportStatus.running;

  DbImportState copyWith({
    DbImportStatus? status,
    DbImportProgress? progress,
    bool clearProgress = false,
    DbImportResult? result,
    bool clearResult = false,
  }) {
    return DbImportState(
      status: status ?? this.status,
      progress: clearProgress ? null : progress ?? this.progress,
      result: clearResult ? null : result ?? this.result,
    );
  }
}
