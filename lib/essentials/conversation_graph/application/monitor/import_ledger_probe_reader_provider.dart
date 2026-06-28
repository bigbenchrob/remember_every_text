import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers/persistent_database_providers.dart'
    show sourceScopedImportDatabaseProvider;
import '../../infrastructure/repositories/source_scoped_import_ledger_probe_reader.dart';
import 'import_ledger_probe_reader.dart';

part 'import_ledger_probe_reader_provider.g.dart';

@riverpod
Future<ImportLedgerProbeReader> importLedgerProbeReader(Ref ref) async {
  final importLedgerDb = await ref.watch(
    sourceScopedImportDatabaseProvider.future,
  );
  return SourceScopedImportLedgerProbeReader(importLedgerDb: importLedgerDb);
}
