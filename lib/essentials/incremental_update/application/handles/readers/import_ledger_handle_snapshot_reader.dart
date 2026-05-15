import '../../../domain/models/handle_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/import_ledger_handle_repository.dart';

class ImportLedgerHandleSnapshotReader implements Reader<HandleSnapshot> {
  const ImportLedgerHandleSnapshotReader({
    required ImportLedgerHandleRepository repository,
  }) : _repository = repository;

  final ImportLedgerHandleRepository _repository;

  @override
  Future<HandleSnapshot> read() async {
    return _repository.readHandleSnapshot();
  }
}
