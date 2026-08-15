import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/contacts_source_readiness_test_agent.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import 'package:remember_this_text/features/address_book_folders/infrastructure/data_sources/local/address_book_folder_path_finder.dart';
import 'package:remember_this_text/features/address_book_folders/infrastructure/repositories/address_book_folder_repository.dart';

void main() {
  test('delegates every evaluation to a fresh repository read', () async {
    final repository = _RecordingAddressBookFolderRepository(
      results: <Either<FolderRetrievalFailure, AddressBookFolderAggregate>>[
        const Left(FolderRetrievalFailure(message: 'Unavailable')),
        Right(AddressBookFolderAggregate(<Never>[])),
      ],
    );
    final agent = ContactsSourceReadinessTestAgent(repository: repository);

    expect(await agent.evaluate(), isFalse);
    expect(await agent.evaluate(), isTrue);
    expect(repository.invocationCount, 2);
  });
}

final class _RecordingAddressBookFolderRepository
    implements AddressBookFolderRepository {
  _RecordingAddressBookFolderRepository({required this.results});

  final List<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>
  results;
  int invocationCount = 0;

  @override
  AddressBookFolderPathsFinder get folderPathsFinder =>
      throw UnsupportedError('The Agent delegates only the repository read.');

  @override
  Future<Either<FolderRetrievalFailure, AddressBookFolderAggregate>>
  getFinalFolderAggregate() async {
    final result = results[invocationCount];
    invocationCount += 1;
    return result;
  }
}
