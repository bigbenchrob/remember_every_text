import '../../../../core/util/date_converter.dart';
import 'address_book_folder_entity.dart';

/// This is the aggregate root for the list of address book folders
/// returned by [AddressFolderListDataSource] after a scan of the expected
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

  /// make a getter to retrieve a list of all the folder paths
  ///
  /// - used potentially for an simple UI element to choose a folder,
  /// with not additional information about the folder displayed.
  /// - also used to disqualify a folder found not to contain a working
  ///
  /// use List.fold() because the product (<String>[]) is of a different type
  /// than the input (List<AddressBookFolderEntity>).

  List<String> get folderPaths {
    return folders.fold<List<String>>([], (list, folder) {
      list.add(folder.path.getOrCrash());
      return list;
    });
  }

  String get mostRecentFolderPath {
    return folders.first.path.getOrCrash();
  }

  void filterOutBadFolders(List<String> badFolders) {
    folders.removeWhere(
      (folder) => badFolders.contains(folder.path.getOrCrash()),
    );
  }

  void removeFolder(String folderPath) {
    folders.removeWhere((folder) => folder.path.getOrCrash() == folderPath);
  }
}
