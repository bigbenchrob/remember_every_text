import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/import_ledger_handle_repository_provider.dart';
import 'import_ledger_handle_snapshot_reader.dart';

part 'import_ledger_handle_snapshot_reader_provider.g.dart';

@riverpod
Future<ImportLedgerHandleSnapshotReader> importLedgerHandleSnapshotReader(
  Ref ref,
) async {
  final repository = await ref.watch(
    importLedgerHandleRepositoryProvider.future,
  );
  return ImportLedgerHandleSnapshotReader(repository: repository);
}
