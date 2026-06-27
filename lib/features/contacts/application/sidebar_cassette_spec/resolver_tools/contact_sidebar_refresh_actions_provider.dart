import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../read_models/contacts_list_repository_provider.dart';
import 'filtered_picker_sections_provider.dart';

part 'contact_sidebar_refresh_actions_provider.g.dart';

@riverpod
class ContactSidebarRefreshActions extends _$ContactSidebarRefreshActions {
  @override
  FutureOr<void> build() {}

  void refreshContactList() {
    ref.invalidate(contactsListRepositoryProvider);
  }

  void refreshFilteredPickerSections() {
    ref.invalidate(filteredPickerSectionsProvider);
  }
}
