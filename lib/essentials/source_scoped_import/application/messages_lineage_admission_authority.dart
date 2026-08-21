import '../domain/messages_lineage_admission.dart';

abstract interface class MessagesLineageAdmissionAuthority {
  Future<MessagesLineageAdmission> verifyMacMessagesCandidate({
    required String candidateChatDatabasePath,
  });

  Future<MessagesLineageAdmission> verifyMessageLensCandidate({
    required String candidateImportLedgerPath,
  });
}
