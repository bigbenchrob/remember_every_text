import '../../domain/participant_origin.dart';

class ContactProfileSummary {
  const ContactProfileSummary({
    required this.contactId,
    required this.displayName,
    required this.origin,
  });

  final int contactId;
  final String displayName;
  final ParticipantOrigin origin;
}
