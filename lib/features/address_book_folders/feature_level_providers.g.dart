// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$folderPathFinderHash() => r'4ba472b7817abc99b8db4113dedc89263e804e81';

///* The next two providers are the low level utilities that do the work of
///* finding the address book folder and the address book database files.
///
/// A utility that scans a target directory for subfolders containing
///  an AddressBook SQLite database file ('AddressBook-v22.abcddb').
/// Used by [AddressBookFolderListDataSource] to retrieve a list of candidate
///
/// Copied from [folderPathFinder].
@ProviderFor(folderPathFinder)
final folderPathFinderProvider =
    AutoDisposeFutureProvider<AddressBookFolderPathsFinder>.internal(
      folderPathFinder,
      name: r'folderPathFinderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$folderPathFinderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FolderPathFinderRef =
    AutoDisposeFutureProviderRef<AddressBookFolderPathsFinder>;
String _$addressFolderListDataSourceHash() =>
    r'69150041a3f512178bd545eb7e062036502c99cc';

/// Responsible for querying the  [AddressBookFolderPathsFinder]
/// to retrieve an aggregate of AddressBookFolderModel objects corresponding to
/// the folders in the expected path:
///  (Library/Application Support/AddressBook/Sources/)
///
/// Copied from [addressFolderListDataSource].
@ProviderFor(addressFolderListDataSource)
final addressFolderListDataSourceProvider =
    AutoDisposeFutureProvider<AddressBookFolderRepository>.internal(
      addressFolderListDataSource,
      name: r'addressFolderListDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressFolderListDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddressFolderListDataSourceRef =
    AutoDisposeFutureProviderRef<AddressBookFolderRepository>;
String _$futureGetFolderAggregateHash() =>
    r'ffe278749d499993e7f9e1b8ede9482327c6be86';

/// Resolve the Future [AddressFolderListRepository.getFolders()]
/// Lazily loaded when needed instead of pre-initialized.
///
/// Copied from [futureGetFolderAggregate].
@ProviderFor(futureGetFolderAggregate)
final futureGetFolderAggregateProvider =
    AutoDisposeFutureProvider<
      Either<FolderRetrievalFailure, AddressBookFolderAggregate>
    >.internal(
      futureGetFolderAggregate,
      name: r'futureGetFolderAggregateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$futureGetFolderAggregateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FutureGetFolderAggregateRef =
    AutoDisposeFutureProviderRef<
      Either<FolderRetrievalFailure, AddressBookFolderAggregate>
    >;
String _$getFolderAggregateEitherHash() =>
    r'503cd3e14436e5ef1234a77ee2a3cb1ec2833702';

/// Caches an aggregate containing a list of candidate
/// [AddressBookFolderEntity] objects.
///
/// The synchronous provider of the [AddressBookFolderAggregate],
/// This provider is the choke point where, if an address book folder cannot
/// be found and this provider returns a [Left(FolderRetrievalFailure)],
/// the user will be notified and the app will not proceed.
///
/// Copied from [getFolderAggregateEither].
@ProviderFor(getFolderAggregateEither)
final getFolderAggregateEitherProvider =
    AutoDisposeProvider<
      Either<FolderRetrievalFailure, AddressBookFolderAggregate>
    >.internal(
      getFolderAggregateEither,
      name: r'getFolderAggregateEitherProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getFolderAggregateEitherHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetFolderAggregateEitherRef =
    AutoDisposeProviderRef<
      Either<FolderRetrievalFailure, AddressBookFolderAggregate>
    >;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
