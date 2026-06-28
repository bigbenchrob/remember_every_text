import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers/persistent_database_providers.dart'
    show sourceScopedImportDatabaseProvider;
import '../domain/ports/import_ledger_port.dart';

part 'source_scoped_import_ledger_provider.g.dart';

@riverpod
Future<ImportLedger> sourceScopedImportLedger(Ref ref) async {
  return ref.watch(sourceScopedImportDatabaseProvider.future);
}
