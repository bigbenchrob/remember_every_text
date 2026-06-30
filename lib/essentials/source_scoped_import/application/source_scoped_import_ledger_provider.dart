import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart'
    show sourceScopedImportDatabaseProvider;
import '../domain/ports/import_ledger_port.dart';

part 'source_scoped_import_ledger_provider.g.dart';

/// Semantic access to the source-scoped import ledger.
///
/// Physical database construction stays in `essentials/db`; import/projection
/// code consumes this port-shaped provider instead of database file details.
@riverpod
Future<ImportLedger> sourceScopedImportLedger(Ref ref) async {
  return ref.watch(sourceScopedImportDatabaseProvider.future);
}
