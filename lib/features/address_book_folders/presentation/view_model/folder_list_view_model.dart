import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/address_book_folder_entity.dart';
import '../../infrastructure/repositories/chosen_address_folder_repository.dart';
import '../../infrastructure/repositories/folder_aggregate_repository.dart';

part 'folder_list_view_model.g.dart';

@riverpod
class FolderListViewModel extends _$FolderListViewModel {
  @override
  List<AddressBookFolderEntity> build() {
    final foldersAggregate = ref.watch(folderAggregateRepositoryProvider);
    final folders = foldersAggregate.folders;

    return folders;
  }

  void onFolderSelected(AddressBookFolderEntity folder) {
    Clipboard.setData(ClipboardData(text: folder.path.getOrCrash()));
    ref
        // ignore: avoid_manual_providers_as_generated_provider_dependency
        .read(chosenAddressFolderPathRepositoryProvider.notifier)
        .chooseFolderPath(folder.path.getOrCrash());
  }
}
