import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/import_ledger_message_repository_provider.dart';
import './import_ledger_message_snapshot_reader.dart';

part 'import_ledger_message_snapshot_reader_provider.g.dart';

@riverpod
Future<ImportLedgerMessageSnapshotReader> importLedgerMessageSnapshotReader(
  Ref ref,
) async {
  final repository = await ref.watch(
    importLedgerMessageRepositoryProvider.future,
  );
  final reader = ImportLedgerMessageSnapshotReader(repository: repository);
  return reader;
}
