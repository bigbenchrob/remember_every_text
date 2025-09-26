import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/address_book_folder_aggregate.dart';
import '../../domain/failures/more_failures/failures.dart';
import '../../feature_level_providers.dart';
import 'chosen_address_folder_repository.dart';

part 'folder_aggregate_repository.g.dart';

/// The non-asynchronous, non-Either provider of the [AddressBookFolderAggregate].
///
/// This value, obtained from the [getFolderAggregateEitherProvider], is cached
/// for the remainder of the app session. It can be modified, however, e.g. by
/// removing a folder from the list of folders.
///
/// We should never get a [Left(FolderRetrievalFailure)] from this provider, as
/// [getFolderAggregateEitherProvider] should have been checked before this
/// provider is called (but check just the same).
@riverpod
class FolderAggregateRepository extends _$FolderAggregateRepository {
  @override
  AddressBookFolderAggregate build() {
    final checkFolderAggregate = ref.watch(getFolderAggregateEitherProvider);
    return checkFolderAggregate.fold(
      (l) => throw const FolderRetrievalFailure(
        message: folderRetrieveFailureMessage,
      ),
      (AddressBookFolderAggregate r) => r,
    );
  }

  void filterOutBadFolders() {
    ///ToDo: check that removing a folder from the aggregate introduces inequlity
    final cachedState = state;
    state.filterOutBadFolders(ref.read(badAddressesProvider));

    if (cachedState != state) {
      /// update the folder aggregate provider to trigger a rebuild in
      /// listeners
      ref.invalidateSelf();
    }
  }
}
