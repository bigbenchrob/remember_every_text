import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/message_overlay_state.dart';
import '../../infrastructure/repositories/message_overlay_identity_bridge_repository.dart';

part 'message_overlay_controller.g.dart';

/// Graph-keyed controller for message user intent.
///
/// This is the graph-era application boundary. It accepts canonical
/// `message_ss_id` values and delegates legacy compatibility to the
/// infrastructure bridge.
@riverpod
class MessageOverlay extends _$MessageOverlay {
  @override
  Future<MessageOverlayState> build(int messageSsId) async {
    return _load();
  }

  Future<void> setSaved({required bool isSaved}) async {
    final repository = await ref.watch(
      messageOverlayIdentityBridgeRepositoryProvider.future,
    );
    await repository.setSaved(messageSsId: messageSsId, isSaved: isSaved);
    await _refresh();
  }

  Future<void> toggleSaved() async {
    final repository = await ref.watch(
      messageOverlayIdentityBridgeRepositoryProvider.future,
    );
    await repository.toggleSaved(messageSsId);
    await _refresh();
  }

  Future<void> setStarred({required bool isStarred}) async {
    final repository = await ref.watch(
      messageOverlayIdentityBridgeRepositoryProvider.future,
    );
    await repository.setStarred(messageSsId: messageSsId, isStarred: isStarred);
    await _refresh();
  }

  Future<void> setArchived({required bool isArchived}) async {
    final repository = await ref.watch(
      messageOverlayIdentityBridgeRepositoryProvider.future,
    );
    await repository.setArchived(
      messageSsId: messageSsId,
      isArchived: isArchived,
    );
    await _refresh();
  }

  Future<void> addTags(Iterable<String> tags) async {
    final repository = await ref.watch(
      messageOverlayIdentityBridgeRepositoryProvider.future,
    );
    await repository.addTags(messageSsId: messageSsId, tags: tags);
    await _refresh();
  }

  Future<void> removeTag(String tag) async {
    final repository = await ref.watch(
      messageOverlayIdentityBridgeRepositoryProvider.future,
    );
    await repository.removeTag(messageSsId: messageSsId, tag: tag);
    await _refresh();
  }

  Future<MessageOverlayState> _load() async {
    final repository = await ref.watch(
      messageOverlayIdentityBridgeRepositoryProvider.future,
    );
    return repository.readForMessage(messageSsId);
  }

  Future<void> _refresh() async {
    state = const AsyncLoading<MessageOverlayState>().copyWithPrevious(state);
    state = AsyncData(await _load());
  }
}
