import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../contacts/feature_level_providers.dart';

part 'contact_evidence_header_context_provider.g.dart';

class ContactEvidenceHeaderContext {
  const ContactEvidenceHeaderContext({
    required this.contactId,
    required this.contactName,
    this.firstMessageAtUtc,
    this.lastMessageAtUtc,
    this.totalMessageCount,
    this.selectedHandleLabel,
  });

  final int contactId;
  final String contactName;
  final String? firstMessageAtUtc;
  final String? lastMessageAtUtc;
  final int? totalMessageCount;
  final String? selectedHandleLabel;
}

@riverpod
Future<ContactEvidenceHeaderContext> contactEvidenceHeaderContext(
  Ref ref, {
  required int contactId,
  int? filterHandleId,
}) async {
  final identityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  final snapshot = await ref.watch(
    contactPageGraphSnapshotProvider(contactId: contactId).future,
  );
  final selectedHandleLabel = filterHandleId == null
      ? null
      : await _selectedHandleLabel(
          ref,
          contactId: contactId,
          handleId: filterHandleId,
        );
  final activity = snapshot.messageActivity;

  return ContactEvidenceHeaderContext(
    contactId: contactId,
    contactName: identityResolver.resolveContact(contactId).primaryLabel,
    firstMessageAtUtc: activity?.firstMessageAtUtc,
    lastMessageAtUtc: activity?.lastMessageAtUtc,
    totalMessageCount: activity?.totalMessageCount,
    selectedHandleLabel: selectedHandleLabel,
  );
}

Future<String?> _selectedHandleLabel(
  Ref ref, {
  required int contactId,
  required int handleId,
}) async {
  final handles = await ref.watch(
    handlesForContactProvider(contactId: contactId).future,
  );
  for (final handle in handles) {
    if (handle.handleId == handleId) {
      return '${handle.displayValue} (${handle.service})';
    }
  }
  return null;
}
