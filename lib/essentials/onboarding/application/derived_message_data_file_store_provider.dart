import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../infrastructure/persistence/filesystem_derived_message_data_file_store.dart';
import 'derived_message_data_file_store.dart';

part 'derived_message_data_file_store_provider.g.dart';

@riverpod
DerivedMessageDataFileStore derivedMessageDataFileStore(Ref ref) {
  return FilesystemDerivedMessageDataFileStore(
    databaseDirectory: ref.watch(archiveAccessAuthorityProvider).rootPath,
  );
}
