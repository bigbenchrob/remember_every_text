import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../handles/domain/entities/stray_handle_investigation_id.dart';
import '../../../handles/domain/spec_classes/handles_cassette_spec.dart';
import '../entities/attachment_info.dart';

part 'messages_view_spec.freezed.dart';

@freezed
abstract class MessagesSpec with _$MessagesSpec {
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

  /// Unknown-source investigation with either no target or one selected source.
  const factory MessagesSpec.handleInvestigation({
    required StrayHandleInvestigationId investigationId,
    required StrayHandleInvestigation investigation,
    required HandleInvestigationTarget target,
  }) = _MessagesHandleInvestigation;
}

/// Navigation-significant target within one unknown-source investigation.
@freezed
abstract class HandleInvestigationTarget with _$HandleInvestigationTarget {
  const factory HandleInvestigationTarget.idle() =
      _HandleInvestigationTargetIdle;

  const factory HandleInvestigationTarget.selectedSource({
    required int handleId,
  }) = _HandleInvestigationTargetSelectedSource;
}
