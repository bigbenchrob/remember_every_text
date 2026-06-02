import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../domain/i_repositories/legacy_projection_status_repository.dart';

final class DriftLegacyProjectionStatusRepository
    implements LegacyProjectionStatusRepository {
  const DriftLegacyProjectionStatusRepository({
    required Future<WorkingDatabase> Function() openWorkingDatabase,
  }) : _openWorkingDatabase = openWorkingDatabase;

  final Future<WorkingDatabase> Function() _openWorkingDatabase;

  @override
  Future<bool> hasExistingMessages() async {
    final workingDb = await _openWorkingDatabase();
    final result = await workingDb
        .customSelect('SELECT COUNT(*) as count FROM messages')
        .getSingle();
    return result.read<int>('count') > 0;
  }
}
