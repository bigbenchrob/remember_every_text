import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/util/message_tag_normalizer.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../domain/entities/message_user_metadata.dart';

part 'message_user_metadata_controller.g.dart';

@riverpod
class MessageUserMetadataController extends _$MessageUserMetadataController {
  @override
  Future<MessageUserMetadata> build({required String messageGuid}) async {
    return _loadMetadata();
  }

  Future<void> toggleSaved() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.toggleMessageSaved(messageGuid);
    await _refresh();
  }

  Future<void> setSaved({required bool isSaved}) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.setMessageSaved(messageGuid: messageGuid, isSaved: isSaved);
    await _refresh();
  }

  Future<void> addTags(Iterable<String> tags) async {
    final parsedTags = <String>[];
    for (final tag in tags) {
      parsedTags.addAll(parseMessageTagInput(tag));
    }
    if (parsedTags.isEmpty) {
      return;
    }

    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.addMessageUserTags(
      messageGuid: messageGuid,
      tags: parsedTags,
    );
    await _refresh();
  }

  Future<void> removeTag(String tag) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    await overlayDb.removeMessageUserTag(
      messageGuid: messageGuid,
      normalizedTag: tag,
    );
    await _refresh();
  }

  Future<void> replaceTags(Iterable<String> tags) async {
    final currentMetadata = await future;
    final desiredDisplays = <String>[];
    for (final tag in tags) {
      desiredDisplays.addAll(parseMessageTagInput(tag));
    }

    final normalizedDesired = desiredDisplays
        .map(normalizeMessageTagValue)
        .where((tag) => tag.isNotEmpty)
        .toSet();
    final normalizedCurrent = currentMetadata.tags
        .map(normalizeMessageTagValue)
        .where((tag) => tag.isNotEmpty)
        .toSet();

    final tagsToRemove = normalizedCurrent.difference(normalizedDesired);
    final tagsToAdd = desiredDisplays
        .where((tag) {
          return !normalizedCurrent.contains(normalizeMessageTagValue(tag));
        })
        .toList(growable: false);

    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    if (tagsToRemove.isNotEmpty) {
      await overlayDb.removeMessageUserTags(
        messageGuid: messageGuid,
        tags: tagsToRemove,
      );
    }
    if (tagsToAdd.isNotEmpty) {
      await overlayDb.addMessageUserTags(
        messageGuid: messageGuid,
        tags: tagsToAdd,
      );
    }

    await _refresh();
  }

  Future<MessageUserMetadata> _loadMetadata() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final savedFlag = await overlayDb.getMessageUserFlag(messageGuid);
    final tags = await overlayDb.getMessageUserTags(messageGuid);

    return MessageUserMetadata(
      messageGuid: messageGuid,
      isSaved: savedFlag?.isSaved ?? false,
      tags: tags.map((tag) => tag.tagDisplay).toList(growable: false),
    );
  }

  Future<void> _refresh() async {
    state = const AsyncLoading<MessageUserMetadata>().copyWithPrevious(state);
    state = AsyncData(await _loadMetadata());
  }
}

@riverpod
Future<List<String>> messageTagSuggestions(Ref ref, {String query = ''}) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return overlayDb.getMessageTagSuggestions(query: query);
}
