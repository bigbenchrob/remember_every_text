import '../../../domain/models/legacy_incremental_update_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/legacy_incremental_update_state_repository.dart';

class LegacyIncrementalUpdateSnapshotReader
    implements Reader<LegacyIncrementalUpdateSnapshot> {
  const LegacyIncrementalUpdateSnapshotReader({required this.repository});

  final LegacyIncrementalUpdateStateRepository repository;

  @override
  Future<LegacyIncrementalUpdateSnapshot> read() {
    return repository.readSnapshot();
  }
}
