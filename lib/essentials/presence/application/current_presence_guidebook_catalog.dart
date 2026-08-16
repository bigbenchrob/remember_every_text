import '../domain/entities/choice_option.dart';
import '../domain/entities/choice_value.dart';
import '../domain/entities/presence_guidebook_catalog.dart';
import '../domain/entities/test_agent_id.dart';
import '../domain/entities/trip_definition_id.dart';
import '../domain/services/presence_guidebook_catalog_validator.dart';

const int requiredSourcesReadinessScheduleId = 6;
const TripDefinitionId introduceMessageLensTripId = TripDefinitionId(301);
const TripDefinitionId determineInitialMessagesSourceReadinessTripId =
    TripDefinitionId(302);
const TripDefinitionId guideUnreadableMessagesSourceTripId = TripDefinitionId(
  303,
);
const TripDefinitionId verifyMessagesSourceReadinessTripId = TripDefinitionId(
  304,
);
const TripDefinitionId determineContactsSourceReadinessTripId =
    TripDefinitionId(305);
const TripDefinitionId guideUnavailableContactsSourceTripId = TripDefinitionId(
  306,
);
const TripDefinitionId confirmRequiredSourcesReadableTripId = TripDefinitionId(
  307,
);
const TripDefinitionId determineMessagesSourceHistorySufficiencyTripId =
    TripDefinitionId(308);
const TripDefinitionId guideSparseMessagesSourceHistoryTripId =
    TripDefinitionId(309);
const TripDefinitionId classifyMessagesSourceFailureTripId = TripDefinitionId(
  310,
);
const TripDefinitionId guideUnavailableMessagesSourceTripId = TripDefinitionId(
  311,
);

final TestAgentId messagesSourceReadableTestAgentId = TestAgentId(
  'onboarding.messages-source-readable',
);
final TestAgentId messagesSourceAccessDeniedTestAgentId = TestAgentId(
  'onboarding.messages-source-access-denied',
);
final TestAgentId contactsSourceReadableTestAgentId = TestAgentId(
  'onboarding.contacts-source-readable',
);
final TestAgentId messagesSourceHistorySufficientTestAgentId = TestAgentId(
  'onboarding.messages-source-history-sufficient',
);

/// The complete guidebook content shipped by this MessageLens build.
///
/// Construction is deterministic and has no runtime or persistence dependency.
PresenceGuidebookCatalog currentPresenceGuidebookCatalog() {
  final catalog = PresenceGuidebookCatalog(
    schedules: <PresenceGuidebookSchedule>[
      PresenceGuidebookSchedule(
        id: requiredSourcesReadinessScheduleId,
        name: 'required_sources_readiness_onboarding_experiment',
        trips: <PresenceGuidebookTripOccurrence>[
          _occurrence(
            occurrenceId: 6101,
            position: 0,
            id: introduceMessageLensTripId,
            name: 'required_sources_introduction',
            steps: const <PresenceGuidebookStep>[
              PresenceGuidebookTellStep(
                id: 6101,
                name: 'required_sources_welcome',
                text: 'Welcome to MessageLens.',
              ),
              PresenceGuidebookTellStep(
                id: 6102,
                name: 'explain_required_sources_check',
                text:
                    'I’ll make sure I can read the local Messages and Contacts '
                    'information I need.',
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6102,
            position: 1,
            id: determineInitialMessagesSourceReadinessTripId,
            name: 'required_sources_initial_messages_readiness',
            steps: <PresenceGuidebookStep>[
              PresenceGuidebookTestStep(
                id: 6201,
                name: 'test_required_sources_initial_messages_readiness',
                testAgentId: messagesSourceReadableTestAgentId,
                trueDestinationTripDefinitionId:
                    determineContactsSourceReadinessTripId,
                falseDestinationTripDefinitionId:
                    classifyMessagesSourceFailureTripId,
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6103,
            position: 2,
            id: guideUnreadableMessagesSourceTripId,
            name: 'required_sources_messages_remediation',
            steps: const <PresenceGuidebookStep>[
              PresenceGuidebookTellStep(
                id: 6301,
                name: 'explain_required_sources_messages_permission',
                text:
                    'MessageLens needs permission to read your Messages and '
                    'Contacts data. On macOS, Apple calls this Full Disk Access.',
              ),
              PresenceGuidebookTellStep(
                id: 6302,
                name: 'explain_required_sources_full_disk_access_action',
                text:
                    'In Full Disk Access, add or enable MessageLens Development. '
                    'macOS may ask you to quit and reopen the app after you make '
                    'the change.',
              ),
              PresenceGuidebookOpenFdaSettingsStep(
                id: 6303,
                name: 'open_full_disk_access_for_required_sources',
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6104,
            position: 3,
            id: verifyMessagesSourceReadinessTripId,
            name: 'required_sources_messages_verification',
            steps: <PresenceGuidebookStep>[
              const PresenceGuidebookTellStep(
                id: 6401,
                name: 'orient_required_sources_messages_verification',
                text:
                    'Welcome back. I’ll check whether MessageLens can now read '
                    'the protected Messages database.',
              ),
              PresenceGuidebookTestStep(
                id: 6402,
                name: 'test_required_sources_messages_verification',
                testAgentId: messagesSourceReadableTestAgentId,
                trueDestinationTripDefinitionId: null,
                falseDestinationTripDefinitionId:
                    classifyMessagesSourceFailureTripId,
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6105,
            position: 4,
            id: determineContactsSourceReadinessTripId,
            name: 'required_sources_contacts_readiness',
            steps: <PresenceGuidebookStep>[
              PresenceGuidebookTestStep(
                id: 6501,
                name: 'test_required_sources_contacts_readiness',
                testAgentId: contactsSourceReadableTestAgentId,
                trueDestinationTripDefinitionId:
                    determineMessagesSourceHistorySufficiencyTripId,
                falseDestinationTripDefinitionId: null,
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6106,
            position: 5,
            id: guideUnavailableContactsSourceTripId,
            name: 'required_sources_contacts_remediation',
            steps: const <PresenceGuidebookStep>[
              PresenceGuidebookTellStep(
                id: 6601,
                name: 'explain_required_sources_contacts_unavailable',
                text:
                    'Your Messages history is available, but I couldn’t find or '
                    'read the local Contacts information MessageLens needs.',
              ),
              PresenceGuidebookTellStep(
                id: 6602,
                name: 'guide_required_sources_contacts_retry',
                text:
                    'Open Contacts and confirm the people you expect are present '
                    'on this Mac. If sync or privacy settings recently changed, '
                    'allow them to settle, then continue and I’ll check again.',
              ),
              PresenceGuidebookFixedDestinationStep(
                id: 6603,
                name: 'retry_required_sources_contacts_readiness',
                destinationTripDefinitionId:
                    determineContactsSourceReadinessTripId,
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6108,
            position: 6,
            id: determineMessagesSourceHistorySufficiencyTripId,
            name: 'determine_messages_source_history_sufficiency',
            steps: <PresenceGuidebookStep>[
              PresenceGuidebookTestStep(
                id: 6801,
                name: 'test_messages_source_history_sufficiency',
                testAgentId: messagesSourceHistorySufficientTestAgentId,
                trueDestinationTripDefinitionId:
                    confirmRequiredSourcesReadableTripId,
                falseDestinationTripDefinitionId:
                    guideSparseMessagesSourceHistoryTripId,
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6109,
            position: 7,
            id: guideSparseMessagesSourceHistoryTripId,
            name: 'guide_sparse_or_unsynced_messages_source',
            steps: <PresenceGuidebookStep>[
              const PresenceGuidebookTellStep(
                id: 6901,
                name: 'explain_sparse_messages_source_history',
                text:
                    'MessageLens found very little Messages history stored '
                    'locally on this Mac.',
              ),
              const PresenceGuidebookTellStep(
                id: 6902,
                name: 'guide_sparse_messages_source_history_choice',
                text:
                    'Messages history may still be synchronizing. You can allow '
                    'more time and re-check, or continue with the local history '
                    'currently available.',
              ),
              PresenceGuidebookChoiceStep(
                id: 6903,
                name: 'choose_sparse_messages_source_history_action',
                options: <ChoiceOption>[
                  ChoiceOption(
                    value: ChoiceValue('recheck'),
                    label: 'Re-check',
                    destinationTripDefinitionId:
                        determineMessagesSourceHistorySufficiencyTripId,
                  ),
                  ChoiceOption(
                    value: ChoiceValue('import_anyway'),
                    label: 'Import Anyway',
                    destinationTripDefinitionId:
                        confirmRequiredSourcesReadableTripId,
                  ),
                ],
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6110,
            position: 8,
            id: classifyMessagesSourceFailureTripId,
            name: 'classify_messages_source_failure',
            steps: <PresenceGuidebookStep>[
              PresenceGuidebookTestStep(
                id: 7001,
                name: 'test_messages_source_access_denied',
                testAgentId: messagesSourceAccessDeniedTestAgentId,
                trueDestinationTripDefinitionId:
                    guideUnreadableMessagesSourceTripId,
                falseDestinationTripDefinitionId:
                    guideUnavailableMessagesSourceTripId,
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6111,
            position: 9,
            id: guideUnavailableMessagesSourceTripId,
            name: 'guide_unavailable_messages_source',
            steps: const <PresenceGuidebookStep>[
              PresenceGuidebookTellStep(
                id: 7101,
                name: 'explain_unavailable_messages_source',
                text:
                    'MessageLens can’t currently use your Messages data. If '
                    'Messages or its local data changed recently, allow it to '
                    'settle, then continue and I’ll check again.',
              ),
              PresenceGuidebookFixedDestinationStep(
                id: 7102,
                name: 'retry_messages_source_readiness',
                destinationTripDefinitionId:
                    determineInitialMessagesSourceReadinessTripId,
              ),
            ],
          ),
          _occurrence(
            occurrenceId: 6107,
            position: 10,
            id: confirmRequiredSourcesReadableTripId,
            name: 'required_sources_confirmation',
            steps: const <PresenceGuidebookStep>[
              PresenceGuidebookTellStep(
                id: 6701,
                name: 'confirm_required_sources_readable',
                text:
                    'MessageLens can read the local Messages and Contacts '
                    'information it needs.',
              ),
            ],
          ),
        ],
      ),
    ],
  );
  const PresenceGuidebookCatalogValidator().validate(catalog);
  return catalog;
}

PresenceGuidebookTripOccurrence _occurrence({
  required int occurrenceId,
  required int position,
  required TripDefinitionId id,
  required String name,
  required List<PresenceGuidebookStep> steps,
}) {
  return PresenceGuidebookTripOccurrence(
    occurrenceId: occurrenceId,
    position: position,
    trip: PresenceGuidebookTrip(id: id, name: name, steps: steps),
  );
}
