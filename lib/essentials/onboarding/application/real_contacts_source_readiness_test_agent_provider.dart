import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/address_book_folders/application/address_book_folder_providers.dart'
    show addressBookFolderRepositoryProvider;
import 'contacts_source_readiness_test_agent.dart';

part 'real_contacts_source_readiness_test_agent_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ContactsSourceReadinessTestAgent> realContactsSourceReadinessTestAgent(
  Ref ref,
) async {
  final repository = await ref.watch(
    addressBookFolderRepositoryProvider.future,
  );
  return ContactsSourceReadinessTestAgent(repository: repository);
}
