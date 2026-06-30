import '../../../../core/util/date_converter.dart';
import 'address_book_folder_entity.dart';

/// This is the aggregate root for the list of address book folders
/// returned by [AddressBookFolderRepository] after a scan of the expected
/// parent directory.
///
/// Its only job is to determine which folder is the most recently modified
/// and store that as the [mostRecentFolderPath].

class AddressBookFolderAggregate {
  List<AddressBookFolderEntity> folders;

  static List<AddressBookFolderEntity> sortFoldersByDate(
    List<AddressBookFolderEntity> folders,
  ) {
    folders.sort(
      (a, b) =>
          DateConverter.dartDateTime2timeStamp(
            b.lastModificationDate.getOrCrash(),
          ) -
          DateConverter.dartDateTime2timeStamp(
            a.lastModificationDate.getOrCrash(),
          ),
    );
    return folders;
  }

  AddressBookFolderAggregate(List<AddressBookFolderEntity> folders)
    : folders = sortFoldersByDate(folders);

  String get mostRecentFolderPath {
    return folders.first.path.getOrCrash();
  }
}
