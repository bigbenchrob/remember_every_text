import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../constants/domain/contact_constants.dart';
import '../../../feature_level_providers.dart';
import '../payloads/contact_chooser_cassette_payload.dart';
import 'filtered_picker_sections_provider.dart';
import 'picker_filter_mode_provider.dart';
import 'picker_mode_decision.dart';
import 'unified_picker_sections_provider.dart';

part 'contact_chooser_snapshot_provider.g.dart';

final class ContactChooserSnapshot {
  const ContactChooserSnapshot._({
    required this.loadState,
    this.pickerMode,
    this.pickerFilterMode,
    this.filteredSections,
  });

  const ContactChooserSnapshot.loading()
    : this._(loadState: ContactChooserLoadState.loading);

  const ContactChooserSnapshot.error()
    : this._(loadState: ContactChooserLoadState.error);

  const ContactChooserSnapshot.ready({
    required ContactPickerMode pickerMode,
    required PickerFilterMode pickerFilterMode,
    required UnifiedPickerSections filteredSections,
  }) : this._(
         loadState: ContactChooserLoadState.ready,
         pickerMode: pickerMode,
         pickerFilterMode: pickerFilterMode,
         filteredSections: filteredSections,
       );

  final ContactChooserLoadState loadState;
  final ContactPickerMode? pickerMode;
  final PickerFilterMode? pickerFilterMode;
  final UnifiedPickerSections? filteredSections;
}

@riverpod
ContactChooserSnapshot contactChooserSnapshot(Ref ref) {
  final contactsAsync = ref.watch(contactsListRepositoryProvider);
  final filteredSectionsAsync = ref.watch(filteredPickerSectionsProvider);
  final pickerFilterMode = ref.watch(pickerFilterProvider);

  if (contactsAsync.isLoading || filteredSectionsAsync.isLoading) {
    return const ContactChooserSnapshot.loading();
  }

  if (contactsAsync.hasError || filteredSectionsAsync.hasError) {
    return const ContactChooserSnapshot.error();
  }

  final contacts = contactsAsync.requireValue;
  final filteredSections = filteredSectionsAsync.requireValue;

  return ContactChooserSnapshot.ready(
    pickerMode: determinePickerMode(contacts.length),
    pickerFilterMode: pickerFilterMode,
    filteredSections: filteredSections,
  );
}
