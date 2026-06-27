import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../providers.dart';
import '../domain/entities/address_book_folder_aggregate.dart';
import '../domain/failures/folder_retrieval_failure.dart';
import '../infrastructure/data_sources/local/address_book_folder_path_finder.dart';
import '../infrastructure/repositories/address_book_folder_repository.dart';

part 'address_book_folder_providers.g.dart';

const folderRetrieveFailureMessage = '''
There was a problem locating the folder where your address book contacts are stored.

This folder is normally located at:

  (Library/Application Support/AddressBook/Sources/)

  ...and contains an AddressBook SQLite database file (AddressBook-v22.abcddb).

If you have moved your address book to a different location, 
please move it back to the default location and try again.

If you have not moved your address book, please contact the developer.

''';

/// A utility that scans a target directory for subfolders containing
///  an AddressBook SQLite database file ('AddressBook-v22.abcddb').
/// Used by [AddressBookFolderRepository] to retrieve a list of candidate
@riverpod
Future<AddressBookFolderPathsFinder> folderPathFinder(Ref ref) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  final logger = ref.read(appLoggerProvider.notifier);
  return AddressBookFolderPathsFinder(
    pathsHelper: pathsHelper,
    onDirectoryReadFailure: (dirPath, error, stackTrace) {
      logger.warn(
        'AddressBook folder scan: skipped unreadable candidate directory',
        source: 'AddressBookFolderPathsFinder',
        context: <String, Object?>{
          'dirPath': dirPath,
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
    },
  );
}

/// Responsible for querying the  [AddressBookFolderPathsFinder]
/// to retrieve an aggregate of AddressBookFolderModel objects corresponding to
/// the folders in the expected path:
///  (Library/Application Support/AddressBook/Sources/)
@riverpod
Future<AddressBookFolderRepository> addressBookFolderRepository(Ref ref) async {
  final folderPathFinder = await ref.watch(folderPathFinderProvider.future);
  return AddressBookFolderRepository(folderPathsFinder: folderPathFinder);
}

/// Resolve the most recent viable AddressBook folder aggregate.
/// Lazily loaded when needed instead of pre-initialized.
@riverpod
Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>
futureGetFolderAggregate(Ref ref) async {
  final repository = await ref.watch(
    addressBookFolderRepositoryProvider.future,
  );
  return repository.getFinalFolderAggregate();
}

/// Caches an aggregate containing a list of candidate
/// [AddressBookFolderEntity] objects.
///
/// The synchronous provider of the [AddressBookFolderAggregate],
/// This provider is the choke point where, if an address book folder cannot
/// be found and this provider returns a [Left(FolderRetrievalFailure)],
/// the user will be notified and the app will not proceed.
@riverpod
Either<FolderRetrievalFailure, AddressBookFolderAggregate>
getFolderAggregateEither(Ref ref) {
  final asyncAggregate = ref.watch(futureGetFolderAggregateProvider);
  return asyncAggregate.when(
    data: (aggregate) => aggregate,
    loading: () => const Left(
      FolderRetrievalFailure(message: 'Loading folder aggregate...'),
    ),
    error: (error, stack) => const Left(
      FolderRetrievalFailure(message: folderRetrieveFailureMessage),
    ),
  );
}
