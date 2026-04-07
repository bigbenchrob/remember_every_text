import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/contacts_info_cassette_spec.dart';
import '../resolvers/info_content_resolver.dart';

part 'info_cassette_coordinator.g.dart';

/// Contacts Info Cassette Coordinator
///
/// Routes [ContactsInfoCassetteSpec] variants to info resolvers.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// The coordinator:
/// - Pattern-matches on the spec
/// - Extracts the info key
/// - Calls the info content resolver
/// - Returns `Future<SidebarCassettePayload>`
@riverpod
class ContactsInfoCassetteCoordinator
    extends _$ContactsInfoCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a sidebar cassette payload for a Contacts info cassette request.
  Future<SidebarCassettePayload> buildViewModel(
    ContactsInfoCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    switch (spec) {
      case ContactsInfoCassetteSpecInfoCard(:final key):
        final content = await ref
            .read(contactsInfoContentResolverProvider.notifier)
            .resolve(key);

        return StaticFeatureInfoSidebarCassettePayload(
          role: SidebarCassetteRole.contextSecondary,
          title: content.title,
          bodyText: content.body,
        );
    }

    throw StateError(
      'Unhandled ContactsInfoCassetteSpec variant: ${spec.runtimeType}',
    );
  }
}
