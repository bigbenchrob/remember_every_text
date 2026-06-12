import '../../domain/entities/message_overlay_state.dart';

/// Application boundary for graph-keyed message user intent.
///
/// Callers speak in canonical `message_ss_id` values. Any retained overlay key
/// compatibility remains an infrastructure concern behind this contract.
abstract class MessageOverlayRepository {
  Future<MessageOverlayState> readForMessage(int messageSsId);

  Future<void> setSaved({required int messageSsId, required bool isSaved});

  Future<bool> toggleSaved(int messageSsId);

  Future<void> setStarred({required int messageSsId, required bool isStarred});

  Future<void> setArchived({
    required int messageSsId,
    required bool isArchived,
  });

  Future<void> addTags({
    required int messageSsId,
    required Iterable<String> tags,
  });

  Future<void> removeTag({required int messageSsId, required String tag});
}
