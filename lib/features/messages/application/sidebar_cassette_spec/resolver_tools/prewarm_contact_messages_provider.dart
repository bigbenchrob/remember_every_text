import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/message_evidence/message_evidence_scope.dart';
import '../../message_evidence/message_evidence_spine_provider.dart';
import 'contact_timeline_provider.dart';

part 'prewarm_contact_messages_provider.g.dart';

/// Warms the contact-scoped sidebar heatmap and center evidence skeleton
/// before the user-visible contact transition completes.
///
/// This exists to avoid the first contact selection on a cold launch showing
/// both a lower-sidebar loading gap and a center-panel spinner while those two
/// read-only data paths initialize for the first time.
@riverpod
Future<void> prewarmContactMessages(
  PrewarmContactMessagesRef ref, {
  required int contactId,
}) async {
  await Future.wait<void>([
    ref.watch(contactTimelineProvider(contactId: contactId).future),
    ref.watch(
      messageEvidenceTimelineSkeletonProvider(
        scope: ContactAllMessagesEvidenceScope(contactId: contactId),
      ).future,
    ),
  ]);
}
