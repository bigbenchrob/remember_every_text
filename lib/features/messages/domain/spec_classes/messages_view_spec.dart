import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/attachment_info.dart';

part 'messages_view_spec.freezed.dart';

@freezed
abstract class MessagesSpec with _$MessagesSpec {
  const factory MessagesSpec.forConversation({
    required int conversationId,
    int? anchorMessageId,
    String? searchQuery,
  }) = _MessagesForConversation;

  const factory MessagesSpec.forContact({
    required int contactId,
    DateTime? scrollToDate,
    int? filterHandleId,
  }) = _MessagesForContact;

  /// Show every message across all chats as a graph evidence timeline.
  const factory MessagesSpec.globalTimeline({DateTime? scrollToDate}) =
      _MessagesGlobalTimeline;

  /// Show ALL messages from a handle across all chats chronologically
  const factory MessagesSpec.forHandle({required int handleId}) =
      _MessagesForHandle;

  /// Dedicated surface for recovered deleted-message candidates that remain
  /// outside the normal chat linkage model.
  const factory MessagesSpec.recoveredUnlinkedMessages({
    int? contactId,
    DateTime? scrollToDate,
  }) = _RecoveredUnlinkedMessages;

  /// Experimental surface for recovered orphaned records with no surviving
  /// handle linkage that still appear to be outgoing messages.
  const factory MessagesSpec.recoveredNoHandleFromMeMessages({
    DateTime? scrollToDate,
  }) = _RecoveredNoHandleFromMeMessages;

  /// End-sidebar viewer for a single recovered attachment.
  const factory MessagesSpec.recoveredAttachmentViewer({
    required int messageId,
    required AttachmentInfo attachment,
  }) = _RecoveredAttachmentViewer;

  /// End-sidebar context viewer for a selected search result.
  const factory MessagesSpec.searchResultContext({
    required int messageId,
    required int chatId,
    @Default(10) int beforeCount,
    @Default(10) int afterCount,
  }) = _MessagesSearchResultContext;

  /// Triage view for a stray handle: header + action bar + message list.
  const factory MessagesSpec.handleLens({required int handleId}) =
      _MessagesHandleLens;
}
