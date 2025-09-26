// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_aggregate_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$folderAggregateRepositoryHash() =>
    r'ab7ad0c1ebdbc33a6f4f984f39e0f7cd626aa2f2';

/// The non-asynchronous, non-Either provider of the [AddressBookFolderAggregate].
///
/// This value, obtained from the [getFolderAggregateEitherProvider], is cached
/// for the remainder of the app session. It can be modified, however, e.g. by
/// removing a folder from the list of folders.
///
/// We should never get a [Left(FolderRetrievalFailure)] from this provider, as
/// [getFolderAggregateEitherProvider] should have been checked before this
/// provider is called (but check just the same).
///
/// Copied from [FolderAggregateRepository].
@ProviderFor(FolderAggregateRepository)
final folderAggregateRepositoryProvider =
    AutoDisposeNotifierProvider<
      FolderAggregateRepository,
      AddressBookFolderAggregate
    >.internal(
      FolderAggregateRepository.new,
      name: r'folderAggregateRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$folderAggregateRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FolderAggregateRepository =
    AutoDisposeNotifier<AddressBookFolderAggregate>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
