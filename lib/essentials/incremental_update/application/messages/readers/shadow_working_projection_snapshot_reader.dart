import '../../../domain/models/message_projection_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/shadow_working_message_projection_repository.dart';

class ShadowWorkingProjectionSnapshotReader
    implements Reader<MessageProjectionSnapshot> {
  const ShadowWorkingProjectionSnapshotReader({required this.repository});

  final ShadowWorkingMessageProjectionRepository repository;

  @override
  Future<MessageProjectionSnapshot> read() {
    return repository.readSnapshot();
  }
}
