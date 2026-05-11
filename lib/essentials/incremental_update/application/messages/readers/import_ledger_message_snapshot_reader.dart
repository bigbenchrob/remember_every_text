import '../../../domain/models/import_ledger_message_snapshot.dart';
import '../../../domain/responsibiliity_role_interfaces.dart';
import '../../../infrastructure/import_ledger_message_repository.dart';

class ImportLedgerMessageSnapshotReader
    implements Reader<ImportLedgerMessageSnapshot> {
  const ImportLedgerMessageSnapshotReader({
    required ImportLedgerMessageRepository repository,
  }) : _repository = repository;

  final ImportLedgerMessageRepository _repository;

  @override
  Future<ImportLedgerMessageSnapshot> read() async {
    return _repository.readMessageSnapshot();
  }
}
