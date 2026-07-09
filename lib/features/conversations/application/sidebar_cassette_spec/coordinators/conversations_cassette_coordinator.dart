import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/conversations_cassette_spec.dart';
import '../resolvers/conversation_signatures_resolver.dart';

part 'conversations_cassette_coordinator.g.dart';

@riverpod
class ConversationsCassetteCoordinator
    extends _$ConversationsCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator.
  }

  Future<SidebarCassettePayload> buildViewModel(
    ConversationsCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    return spec.when(
      conversationSignatures: () => ref
          .read(conversationSignaturesResolverProvider.notifier)
          .resolve(cassetteIndex: cassetteIndex),
    );
  }
}
