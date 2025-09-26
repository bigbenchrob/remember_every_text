import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
/// Represents all app failures
class AddressBookFolderFailure
    with _$AddressBookFolderFailure
    implements Exception {
  const AddressBookFolderFailure._();

  /// Expected value is null or empty
  const factory AddressBookFolderFailure.folderFavouriteNotStored() =
      FolderFailureNotStored;
}
