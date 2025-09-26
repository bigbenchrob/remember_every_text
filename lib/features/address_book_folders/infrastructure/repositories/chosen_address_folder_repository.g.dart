// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chosen_address_folder_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$badAddressesHash() => r'd0cea98b2c842362bd8f33c979b27c04ff3e0779';

/// A single purpose provider to store a list of bad folder paths.
///
/// Originally used to store folder paths not containing a functioning
/// contacts db when this was being checked by the
/// [ChosenAddressFolderPathRepository] provider. Not necessary now
/// that this check is done by the [AddressFolderListDataSource] provider,
/// but leave it in in case it becomes useful for something else.
///
/// Copied from [BadAddresses].
@ProviderFor(BadAddresses)
final badAddressesProvider =
    AutoDisposeNotifierProvider<BadAddresses, List<String>>.internal(
      BadAddresses.new,
      name: r'badAddressesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$badAddressesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BadAddresses = AutoDisposeNotifier<List<String>>;
String _$chosenAddressFolderPathRepositoryHash() =>
    r'87a80a00ff331ea7373958fcc62ddad225c6ea3c';

/// A repository that serves as the top level source for the path of the
/// address book folder that will be used to retrieve contact data.
///
/// The [AddressBookFolderAggregate] holds a list of candidate contact.db
/// folders as well as some logic to determine the most recently modified
/// one and to remove undesired ones. It is initially obtained by querying the
/// feature-level provider [getFolderAggregateEitherProvider]. The state of
/// that provider must be checked before this provider is read: if it returns
/// a Left(FolderRetrievalFailure), the application should not proceed and
/// this provider should never be read.
///
/// The AddressBookFolderAggregate used here is obtained from the feature-level
/// provider [folderAggregateEntityProvider]. Any modifications to the
/// aggregate, such as removing a folder, should be done via that provider,
/// which will trigger a rebuild in this and other listeners by invoking
/// [ref.invalidateSelf()].
///
/// build() method logic:
/// If a folder path has been stored in local storage, it will be used.
/// Otherwise, the most recently modified folder from the aggregate will
/// be used. This will be stored in local storage, as will any subsequent
/// choices made by the user. Local storage is also handled by this
/// repository.
///
/// Copied from [ChosenAddressFolderPathRepository].
@ProviderFor(ChosenAddressFolderPathRepository)
final chosenAddressFolderPathRepositoryProvider =
    NotifierProvider<ChosenAddressFolderPathRepository, String>.internal(
      ChosenAddressFolderPathRepository.new,
      name: r'chosenAddressFolderPathRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chosenAddressFolderPathRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChosenAddressFolderPathRepository = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
