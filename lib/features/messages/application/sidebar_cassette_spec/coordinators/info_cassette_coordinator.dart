import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/messages_info_cassette_spec.dart';
import '../payloads/recovered_no_handle_from_me_navigator_cassette_payload.dart';
import '../payloads/recovered_unlinked_navigator_cassette_payload.dart';
import '../resolvers/info_content_resolver.dart';

part 'info_cassette_coordinator.g.dart';

/// Messages Info Cassette Coordinator
///
/// Routes [MessagesInfoCassetteSpec] variants to info resolvers.
@riverpod
class MessagesInfoCassetteCoordinator
    extends _$MessagesInfoCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  Future<SidebarCassettePayload> buildViewModel(
    MessagesInfoCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    switch (spec) {
      case MessagesInfoCassetteSpecInfoCard(:final key):
        final content = await ref
            .read(messagesInfoContentResolverProvider.notifier)
            .resolve(key, cassetteIndex: cassetteIndex);
        final body = content.body;

        if (body != null) {
          return StaticFeatureInfoSidebarCassettePayload(
            role: SidebarCassetteRole.contextSecondary,
            semanticStyle: SidebarCassetteSemanticStyle.supportingContext,
            topSpacing: content.topSpacing,
            title: content.title,
            bodyText: body,
          );
        }

        return switch (content.navigatorKind!) {
          MessagesInfoNavigatorKind.recoveredDeletedMessages =>
            RecoveredUnlinkedNavigatorCassettePayload(
              cassetteIndex: cassetteIndex,
              topSpacing: content.topSpacing,
            ),
          MessagesInfoNavigatorKind.recoveredNoHandleMessages =>
            RecoveredNoHandleFromMeNavigatorCassettePayload(
              cassetteIndex: cassetteIndex,
              topSpacing: content.topSpacing,
            ),
        };
    }

    throw StateError(
      'Unhandled MessagesInfoCassetteSpec variant: ${spec.runtimeType}',
    );
  }
}
