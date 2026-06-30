import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../source_scoped_import/feature_level_providers.dart'
    show sourceScopedImportLedgerProvider;
import '../../infrastructure/repositories/source_scoped_import_ledger_probe_reader.dart';
import 'import_ledger_probe_reader.dart';

part 'import_ledger_probe_reader_provider.g.dart';

@riverpod
Future<ImportLedgerProbeReader> importLedgerProbeReader(Ref ref) async {
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  return SourceScopedImportLedgerProbeReader(importLedger: importLedger);
}
