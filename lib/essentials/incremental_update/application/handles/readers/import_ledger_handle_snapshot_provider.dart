import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/handle_snapshot.dart';
import 'import_ledger_handle_snapshot_reader_provider.dart';

part 'import_ledger_handle_snapshot_provider.g.dart';

@riverpod
Future<HandleSnapshot> importLedgerHandleSnapshot(Ref ref) async {
  final reader = await ref.watch(
    importLedgerHandleSnapshotReaderProvider.future,
  );
  return reader.read();
}
