import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/address_book_folders/feature_level_providers.dart'
    show addressBookFolderRepositoryProvider;
import '../source_database_opener_provider.dart';
import '../source_scoped_import_ledger_provider.dart';
import 'contact_importer.dart';

part 'contact_importer_provider.g.dart';

@riverpod
Future<ContactImporter> contactImporter(Ref ref) async {
  final addressBookDbPath = await _mostRecentAddressBookPath(ref);
  final importLedger = await ref.watch(sourceScopedImportLedgerProvider.future);
  final sourceDatabaseOpener = ref.watch(sourceDatabaseOpenerProvider);

  return ContactImporter(
    addressBookDbPath: addressBookDbPath,
    importLedger: importLedger,
    sourceDatabaseOpener: sourceDatabaseOpener,
  );
}

Future<String> _mostRecentAddressBookPath(Ref ref) async {
  final repository = await ref.watch(
    addressBookFolderRepositoryProvider.future,
  );
  final aggregateEither = await repository.getFinalFolderAggregate();
  return aggregateEither.fold(
    (failure) => throw StateError(failure.error),
    (aggregate) => aggregate.mostRecentFolderPath,
  );
}
