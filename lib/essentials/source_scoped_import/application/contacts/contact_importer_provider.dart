import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/address_book_folders/feature_level_providers.dart';
import '../../../../features/address_book_folders/infrastructure/repositories/address_book_folder_preference_key.dart';
import '../../../../providers.dart';
import '../../infrastructure/import_database_provider.dart';
import 'contact_importer.dart';

part 'contact_importer_provider.g.dart';

@riverpod
Future<ContactImporter> contactImporter(Ref ref) async {
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);
  final storedAddressBookPath = sharedPreferences.getString(
    FOLDER_PATH_FAVOURITE_KEY,
  );
  final addressBookDbPath =
      storedAddressBookPath == null || storedAddressBookPath.isEmpty
      ? await _mostRecentAddressBookPath(ref)
      : storedAddressBookPath;
  final importDatabase = await ref.watch(importDatabaseProvider.future);

  return ContactImporter(
    addressBookDbPath: addressBookDbPath,
    importDatabase: importDatabase,
  );
}

Future<String> _mostRecentAddressBookPath(Ref ref) async {
  final repository = await ref.watch(addressBookFolderRepositoryProvider.future);
  final aggregateEither = await repository.getFinalFolderAggregate();
  return aggregateEither.fold(
    (failure) => throw StateError(failure.error),
    (aggregate) => aggregate.mostRecentFolderPath,
  );
}
