import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../providers.dart';
import '../../feature_level_providers.dart';
import 'folder_aggregate_repository.dart';

part 'chosen_address_folder_repository.g.dart';

const FOLDER_PATH_FAVOURITE_KEY = 'folderPathFavourite';

/// A single purpose provider to store a list of bad folder paths.
///
/// Originally used to store folder paths not containing a functioning
/// contacts db when this was being checked by the
/// [ChosenAddressFolderPathRepository] provider. Not necessary now
/// that this check is done by the [AddressFolderListDataSource] provider,
/// but leave it in in case it becomes useful for something else.
@riverpod
class BadAddresses extends _$BadAddresses {
  @override
  List<String> build() {
    return [];
  }

  void addBadAddress(String address) {
    state = [...state, address];

    /// update the folder aggregate provider
    ref.read(folderAggregateRepositoryProvider.notifier).filterOutBadFolders();
  }
}

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

@Riverpod(keepAlive: true)
class ChosenAddressFolderPathRepository
    extends _$ChosenAddressFolderPathRepository {
  static const key = FOLDER_PATH_FAVOURITE_KEY;

  @override
  String build() {
    final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
    if (sharedPreferences.containsKey(key)) {
      return sharedPreferences.getString(key)!;
    } else {
      final folderAggregate = ref.watch(folderAggregateRepositoryProvider);
      return folderAggregate.mostRecentFolderPath;
    }
  }

  void chooseFolderPath(String path) {
    state = path;
    storePath(path);
    ref.invalidateSelf();
  }

  void storePath(String path) {
    final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
    sharedPreferences.setString(FOLDER_PATH_FAVOURITE_KEY, path);
  }
}
