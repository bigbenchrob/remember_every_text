import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/import_ledger_message_snapshot.dart';
import 'import_ledger_message_snapshot_reader_provider.dart';

part 'import_ledger_message_snapshot_provider.g.dart';

@riverpod
Future<ImportLedgerMessageSnapshot> importLedgerMessageSnapshot(Ref ref) async {
  final reader = await ref.watch(
    importLedgerMessageSnapshotReaderProvider.future,
  );
  return reader.read();
}
