import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_projection_snapshot.freezed.dart';

@freezed
abstract class MessageProjectionSnapshot with _$MessageProjectionSnapshot {
  const factory MessageProjectionSnapshot({
    required int maxMessageId,
    required int totalMessageCount,
  }) = _MessageProjectionSnapshot;
}
