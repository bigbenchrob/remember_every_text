import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers/persistent_database_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import '../../domain/entities/message_overlay_state.dart';
import '../../infrastructure/repositories/graph_message_overlay_repository.dart';
import '../message_evidence/message_evidence_identity.dart';
import 'message_overlay_controller.dart';
import 'message_overlay_repository.dart';

part 'message_overlay_provider.g.dart';

@riverpod
Future<MessageOverlayRepository> messageOverlayRepository(Ref ref) async {
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return GraphMessageOverlayRepository(
    graphDatabase: graphDatabase,
    overlayDatabase: overlayDatabase,
  );
}

@riverpod
class MessageOverlay extends _$MessageOverlay {
  @override
  Future<MessageOverlayState> build(int messageSsId) async {
    return _load();
  }

  Future<void> setSaved({required bool isSaved}) async {
    final controller = await _controller();
    await controller.setSaved(isSaved: isSaved);
    await _refresh();
  }

  Future<void> toggleSaved() async {
    final controller = await _controller();
    await controller.toggleSaved();
    await _refresh();
  }

  Future<void> setStarred({required bool isStarred}) async {
    final controller = await _controller();
    await controller.setStarred(isStarred: isStarred);
    await _refresh();
  }

  Future<void> setArchived({required bool isArchived}) async {
    final controller = await _controller();
    await controller.setArchived(isArchived: isArchived);
    await _refresh();
  }

  Future<void> addTags(Iterable<String> tags) async {
    final controller = await _controller();
    await controller.addTags(tags);
    await _refresh();
  }

  Future<void> removeTag(String tag) async {
    final controller = await _controller();
    await controller.removeTag(tag);
    await _refresh();
  }

  Future<MessageOverlayState> _load() async {
    final controller = await _controller();
    return controller.read();
  }

  Future<void> _refresh() async {
    state = const AsyncLoading<MessageOverlayState>().copyWithPrevious(state);
    state = AsyncData(await _load());
  }

  Future<MessageOverlayController> _controller() async {
    final repository = await ref.watch(messageOverlayRepositoryProvider.future);
    return MessageOverlayController(
      repository: repository,
      messageSsId: canonicalMessageEvidenceId(messageSsId),
    );
  }
}
