import '../../../handles/domain/spec_classes/handles_cassette_spec.dart';

/// Messages-owned presentation copy for one Unknown Sources investigation.
///
/// The center-panel identity is derived from [investigation] every time. It is
/// never cached or independently maintained as mutable UI state.
final class HandleInvestigationPresentation {
  const HandleInvestigationPresentation({
    required this.panelTitle,
    required this.idleExplanation,
    required this.idleGuidance,
  });

  final String panelTitle;
  final String idleExplanation;
  final String idleGuidance;
}

HandleInvestigationPresentation handleInvestigationPresentation(
  StrayHandleInvestigation investigation,
) {
  return switch (investigation) {
    StrayHandleInvestigation.identifySources =>
      const HandleInvestigationPresentation(
        panelTitle: 'Messages not linked to a contact',
        idleExplanation:
            'These phone numbers, email addresses, and business identities '
            "could not be matched to a contact in your Mac's Contacts data.",
        idleGuidance:
            'Select one to review its messages. When you recognize it, create '
            'a Contact or link it to an existing one. Dismissed sources remain '
            'available from Show.',
      ),
    StrayHandleInvestigation.numericSenderIds =>
      const HandleInvestigationPresentation(
        panelTitle: 'Messages from numeric IDs',
        idleExplanation:
            'Numeric IDs are commonly used for authentication codes, delivery '
            'updates, appointment reminders, alerts, and other automated '
            'messages.',
        idleGuidance:
            'Select one to review its messages. Nothing here requires action. '
            'Dismissed IDs remain available from Show.',
      ),
  };
}
