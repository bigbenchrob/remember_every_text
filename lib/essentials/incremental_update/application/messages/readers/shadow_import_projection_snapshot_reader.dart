import '../../../domain/models/message_projection_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/shadow_import_message_projection_repository.dart';

class ShadowImportProjectionSnapshotReader
    implements Reader<MessageProjectionSnapshot> {
  const ShadowImportProjectionSnapshotReader({required this.repository});

  final ShadowImportMessageProjectionRepository repository;

  @override
  Future<MessageProjectionSnapshot> read() {
    return repository.readSnapshot();
  }
}
