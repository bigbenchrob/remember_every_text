import 'package:dartz/dartz.dart';

import '../../../domain/entities/address_book_folder_aggregate.dart';
import '../../../domain/entities/address_book_folder_entity.dart';
import '../../../domain/failures/more_failures/failures.dart';
import 'address_book_db_helper_multi_instance.dart';
import 'address_book_folder_path_finder.dart';

//  (1) This repository is responsible for querying the  ContactsDbFolderPathFinder
//  to retrieve an aggregate of AddressBookFolderModel objects corresponding to
//  the folders in the expected path:

//    (Library/Application Support/AddressBook/Sources/)

//  ...that contain an AddressBook SQLite database file (AddressBook-v22.abcddb).

//  If such a folder is found it returns the Aggregate wrapped in dartz Right()
//  to UseCaseGetFolders; otherwise returns a Left(FolderRetrievalFailure) error.

//  (2) The repository is also tasked with saving (and retrieving) the currently
//  chosen address book folder. For this it uses a local storage data source that
//  implements KeyValueDataSourceIF (assigned via InjectionContainer.init() ).

//  If there is no currently chosen folder after getFolders() completes,
//  FUNCTION assigns the default as the most recently modified folder. If there
//  is a currently stored path and it conflicts with the assigned default, it
//  notifies the user of this. The user can also at any point choose a
//  different folder to inspect. FUNCTION saves the user's choice.

class AddressBookFolderListDataSource {
  final AddressBookFolderPathsFinder addressBookFolderPathFinder;

  AddressBookFolderListDataSource({required this.addressBookFolderPathFinder});

  Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>
  getFinalFolderAggregate() async {
    try {
      final folderPathFinder = addressBookFolderPathFinder;

      final rawPathList = await folderPathFinder.getAddressBookPaths();
      if (rawPathList.isEmpty) {
        return const Left(
          FolderRetrievalFailure(message: 'No address book folders found'),
        );
      }

      final contactsDbPathList = rawPathList
          .where(addressBookDbExistsAtPath)
          .toList();
      if (contactsDbPathList.isEmpty) {
        return const Left(
          FolderRetrievalFailure(
            message: 'No viable address book folders found',
          ),
        );
      }

      final folderList = await Future.wait(
        contactsDbPathList.map((path) => processToFolderObject(path)),
        eagerError: true,
      );

      // The factory constructory for AddressBookFolderAggregateModel will
      // iterate through the supplied folder list and determine which
      // folder has been most recently modified.

      final folderAggregate = AddressBookFolderAggregate(folderList);

      return Right(folderAggregate);
    } catch (e) {
      return const Left(
        FolderRetrievalFailure(message: 'Folder retrieval failed'),
      );
    }
  }

  Future<AddressBookFolderEntity> processToFolderObject(String path) async {
    final helper = AddressBookDbHelperMultiInstance(path);
    final db = await helper.database;
    try {
      final result = await db.rawQuery(_qsAddressFolderInfo(path));
      final lineResult = result[0];

      return AddressBookFolderEntity.fromJson(lineResult);
    } catch (e) {
      throw const FolderRetrievalFailure(
        message: 'conversion of path to folder failed',
      );
    }
  }

  bool addressBookDbExistsAtPath(String path) {
    final helper = AddressBookDbHelperMultiInstance(path);

    /// db is lazy loaded, so we need to call the [database] getter
    /// to see if initializing it throws an error.
    try {
      helper.database;
    } catch (e) {
      return false;
    }
    return true;
  }

  String _qsAddressFolderInfo(String path) {
    return '''
      SELECT  '$path' AS path,
              MAX(Z_PK) maxId,
              COUNT(Z_PK) count,
              MAX(ZCREATIONDATE) creationDateMax,
              MAX(ZMODIFICATIONDATE) modificationDateMax

        FROM  ZABCDRECORD
''';
  }
}
