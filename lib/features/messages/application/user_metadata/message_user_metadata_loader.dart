import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../domain/entities/message_user_metadata.dart';

Future<Map<String, MessageUserMetadata>> loadMessageUserMetadataByGuids({
  required OverlayDatabase overlayDb,
  required Iterable<String> messageGuids,
}) async {
  final guidList = messageGuids
      .where((guid) => guid.isNotEmpty)
      .toSet()
      .toList();
  if (guidList.isEmpty) {
    return const <String, MessageUserMetadata>{};
  }

  final savedByGuid = await overlayDb.getSavedFlagsByGuids(guidList);
  final tagsByGuid = await overlayDb.getTagsByGuids(guidList);

  return {
    for (final guid in guidList)
      guid: MessageUserMetadata(
        messageGuid: guid,
        isSaved: savedByGuid[guid] ?? false,
        tags: (tagsByGuid[guid] ?? const <MessageUserTag>[])
            .map((tag) => tag.tagDisplay)
            .toList(growable: false),
      ),
  };
}

Future<MessageUserMetadata> loadMessageUserMetadataByGuid({
  required OverlayDatabase overlayDb,
  required String messageGuid,
}) async {
  final metadataByGuid = await loadMessageUserMetadataByGuids(
    overlayDb: overlayDb,
    messageGuids: <String>[messageGuid],
  );

  return metadataByGuid[messageGuid] ??
      MessageUserMetadata.empty(messageGuid: messageGuid);
}
