import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../source_scoped_import/feature_level_providers.dart';
import '../../application/monitor/import_ledger_probe_reader.dart';
import 'source_scoped_import_ledger_probe_reader.dart';

part 'import_ledger_probe_reader_provider.g.dart';

@riverpod
Future<ImportLedgerProbeReader> importLedgerProbeReader(
  ImportLedgerProbeReaderRef ref,
) async {
  final importDb = await ref.watch(sourceScopedImportDatabaseProvider.future);
  return SourceScopedImportLedgerProbeReader(importDb: importDb);
}
