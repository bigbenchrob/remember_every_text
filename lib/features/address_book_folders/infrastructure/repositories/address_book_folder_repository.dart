import 'package:dartz/dartz.dart';

import '../../domain/entities/address_book_folder_aggregate.dart';
import '../../domain/entities/address_book_folder_entity.dart';
import '../../domain/failures/more_failures/failures.dart';
import '../data_sources/local/address_book_db_helper_multi_instance.dart';
import '../data_sources/local/address_book_folder_path_finder.dart';

class AddressBookFolderRepository {
  final AddressBookFolderPathsFinder folderPathsFinder;

  AddressBookFolderRepository({required this.folderPathsFinder});

  Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>
  getFinalFolderAggregate() async {
    try {
      // (1) Retrieve candidate paths.
      final candidatePaths = await folderPathsFinder.getAddressBookPaths();
      if (candidatePaths.isEmpty) {
        return const Left(
          FolderRetrievalFailure(message: 'No address book folders found'),
        );
      }

      // (2) Filter paths having a viable database.
      final viablePaths = await _filterViablePaths(candidatePaths);
      if (viablePaths.isEmpty) {
        return const Left(
          FolderRetrievalFailure(
            message: 'No viable address book folders found',
          ),
        );
      }

      // (3) Convert each viable path to a folder entity.
      final folders = await Future.wait(
        viablePaths.map((path) => _processToFolderEntity(path)),
        eagerError: true,
      );

      // (4) Build the aggregate (the factory constructor decides the most recent folder).
      final aggregate = AddressBookFolderAggregate(folders);
      return Right(aggregate);
    } catch (e) {
      return const Left(
        FolderRetrievalFailure(message: 'Folder retrieval failed'),
      );
    }
  }

  Future<List<String>> _filterViablePaths(List<String> paths) async {
    final viablePaths = <String>[];
    for (final path in paths) {
      if (await _addressBookDbExistsAtPath(path)) {
        viablePaths.add(path);
      }
    }
    return viablePaths;
  }

  Future<bool> _addressBookDbExistsAtPath(String path) async {
    try {
      // This awaits for database access to confirm viability.
      final helper = AddressBookDbHelperMultiInstance(path);
      await helper.database;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<AddressBookFolderEntity> _processToFolderEntity(String path) async {
    final helper = AddressBookDbHelperMultiInstance(path);
    final db = await helper.database;
    try {
      final result = await db.rawQuery(_qsAddressFolderInfo(path));
      final jsonResult = result.first;
      return AddressBookFolderEntity.fromJson(jsonResult);
    } catch (e) {
      throw const FolderRetrievalFailure(
        message: 'Conversion of path to folder failed',
      );
    }
  }

  String _qsAddressFolderInfo(String path) {
    return '''
      SELECT  '$path' AS path,
              MAX(Z_PK) AS maxId,
              COUNT(Z_PK) AS count,
              MAX(ZCREATIONDATE) AS creationDateMax,
              MAX(ZMODIFICATIONDATE) AS modificationDateMax
        FROM  ZABCDRECORD
    ''';
  }
}
