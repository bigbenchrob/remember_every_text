import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/address_book_folders/application/address_book_folder_providers.dart';
import 'package:remember_this_text/features/address_book_folders/infrastructure/data_sources/local/address_book_folder_path_finder.dart';

void main() {
  test(
    'production repository remains composed from folderPathFinder',
    () async {
      final finder = AddressBookFolderPathsFinder.atSourcesRoot(
        sourcesRootPath: '/deliberately/not/read',
      );
      final container = ProviderContainer(
        overrides: <Override>[
          folderPathFinderProvider.overrideWith((ref) async => finder),
        ],
      );
      addTearDown(container.dispose);

      final repository = await container.read(
        addressBookFolderRepositoryProvider.future,
      );

      expect(repository.folderPathsFinder, same(finder));
    },
  );
}
