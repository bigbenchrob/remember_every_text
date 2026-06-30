import 'package:dartz/dartz.dart';

import '../../domain/entities/address_book_folder_aggregate.dart';
import '../../domain/entities/address_book_folder_entity.dart';
import '../../domain/failures/folder_retrieval_failure.dart';
import '../data_sources/local/address_book_db_helper_multi_instance.dart';
import '../data_sources/local/address_book_folder_path_finder.dart';

class AddressBookFolderRepository {
  final AddressBookFolderPathsFinder folderPathsFinder;

  AddressBookFolderRepository({required this.folderPathsFinder});

  Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>
  getFinalFolderAggregate() async {
    try {
      final candidatePaths = await folderPathsFinder.getAddressBookPaths();
      if (candidatePaths.isEmpty) {
        return const Left(
          FolderRetrievalFailure(message: 'No address book folders found'),
        );
      }

      final viablePathScan = await _filterViablePaths(candidatePaths);
      if (viablePathScan.viablePaths.isEmpty) {
        return Left(
          FolderRetrievalFailure(
            message:
                'No viable address book folders found'
                '${viablePathScan.rejectionSummary}',
          ),
        );
      }

      final folders = await Future.wait(
        viablePathScan.viablePaths.map((path) => _processToFolderEntity(path)),
        eagerError: true,
      );

      final aggregate = AddressBookFolderAggregate(folders);
      return Right(aggregate);
    } catch (error) {
      return Left(
        FolderRetrievalFailure(message: 'Folder retrieval failed: $error'),
      );
    }
  }

  Future<_ViableAddressBookPathScan> _filterViablePaths(
    List<String> paths,
  ) async {
    final viablePaths = <String>[];
    final rejectedReasons = <String>[];
    for (final path in paths) {
      final rejectionReason = await _addressBookDbRejectionReason(path);
      if (rejectionReason == null) {
        viablePaths.add(path);
      } else {
        rejectedReasons.add('$path: $rejectionReason');
      }
    }
    return _ViableAddressBookPathScan(
      viablePaths: viablePaths,
      rejectedReasons: rejectedReasons,
    );
  }

  Future<String?> _addressBookDbRejectionReason(String path) async {
    final helper = AddressBookDbHelperMultiInstance(path);
    try {
      await helper.verifyReadable();
      return null;
    } catch (error) {
      return '$error';
    } finally {
      await helper.close();
    }
  }

  Future<AddressBookFolderEntity> _processToFolderEntity(String path) async {
    final helper = AddressBookDbHelperMultiInstance(path);
    try {
      final result = await helper.readRows(_qsAddressFolderInfo(path));
      final jsonResult = result.first;
      return AddressBookFolderEntity.fromJson(jsonResult);
    } catch (error) {
      throw FolderRetrievalFailure(
        message:
            'Conversion of AddressBook path to folder entity failed for '
            '$path: $error',
      );
    } finally {
      await helper.close();
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

class _ViableAddressBookPathScan {
  const _ViableAddressBookPathScan({
    required this.viablePaths,
    required this.rejectedReasons,
  });

  final List<String> viablePaths;
  final List<String> rejectedReasons;

  String get rejectionSummary {
    if (rejectedReasons.isEmpty) {
      return '';
    }

    return ': ${rejectedReasons.join('; ')}';
  }
}
