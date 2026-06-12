import '../../domain/entities/message_overlay_state.dart';
import 'message_overlay_repository.dart';

/// Graph-keyed controller for message user intent.
///
/// This is the graph-era application boundary. It accepts canonical
/// `message_ss_id` values and delegates retained overlay-key compatibility to
/// the injected repository implementation.
class MessageOverlayController {
  const MessageOverlayController({
    required MessageOverlayRepository repository,
    required int messageSsId,
  }) : _repository = repository,
       _messageSsId = messageSsId;

  final MessageOverlayRepository _repository;
  final int _messageSsId;

  Future<MessageOverlayState> read() {
    return _repository.readForMessage(_messageSsId);
  }

  Future<void> setSaved({required bool isSaved}) {
    return _repository.setSaved(messageSsId: _messageSsId, isSaved: isSaved);
  }

  Future<bool> toggleSaved() {
    return _repository.toggleSaved(_messageSsId);
  }

  Future<void> setStarred({required bool isStarred}) {
    return _repository.setStarred(
      messageSsId: _messageSsId,
      isStarred: isStarred,
    );
  }

  Future<void> setArchived({required bool isArchived}) {
    return _repository.setArchived(
      messageSsId: _messageSsId,
      isArchived: isArchived,
    );
  }

  Future<void> addTags(Iterable<String> tags) {
    return _repository.addTags(messageSsId: _messageSsId, tags: tags);
  }

  Future<void> removeTag(String tag) {
    return _repository.removeTag(messageSsId: _messageSsId, tag: tag);
  }
}
