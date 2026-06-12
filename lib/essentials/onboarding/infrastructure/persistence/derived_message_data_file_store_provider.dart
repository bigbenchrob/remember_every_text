import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/derived_message_data_file_store.dart';
import 'filesystem_derived_message_data_file_store.dart';

part 'derived_message_data_file_store_provider.g.dart';

@riverpod
DerivedMessageDataFileStore derivedMessageDataFileStore(
  DerivedMessageDataFileStoreRef ref,
) {
  return const FilesystemDerivedMessageDataFileStore();
}
