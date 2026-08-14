import '../../presence/domain/entities/choice_option.dart';
import '../../presence/domain/entities/choice_value.dart';
import '../../presence/domain/entities/schedule_definition.dart';
import '../../presence/domain/entities/step.dart';
import '../../presence/domain/entities/trip.dart';
import '../../presence/domain/entities/trip_definition_id.dart';
import '../../presence/domain/services/fda_settings_opening_authority.dart';
import '../../presence/domain/services/test_agent_resolver.dart';
import 'onboarding_test_agent_ids.dart';

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

ScheduleDefinition buildRequiredSourcesReadinessDefinition({
  required TestAgentResolver testAgentResolver,
  required FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority,
}) {
  final messagesSourceReadinessTestAgent = testAgentResolver.resolve(
    messagesSourceReadableTestAgentId,
  );
  final contactsSourceReadinessTestAgent = testAgentResolver.resolve(
    contactsSourceReadableTestAgentId,
  );
  final messagesSourceHistorySufficiencyTestAgent = testAgentResolver.resolve(
    messagesSourceHistorySufficientTestAgentId,
  );
  return ScheduleDefinition(
    id: requiredSourcesReadinessScheduleId,
    name: 'required_sources_readiness_onboarding_experiment',
    trips: <ScheduleTripDefinition>[
      ScheduleTripDefinition(
        occurrenceId: 6101,
        position: 0,
        trip: TripDefinition(
          id: introduceMessageLensTripId,
          name: 'required_sources_introduction',
          steps: const <Step>[
            TellStep(
              id: 6101,
              name: 'required_sources_welcome',
              text: 'Welcome to MessageLens.',
            ),
            TellStep(
              id: 6102,
              name: 'explain_required_sources_check',
              text:
                  'I’ll make sure I can read the local Messages and Contacts '
                  'information I need.',
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 6102,
        position: 1,
        trip: TripDefinition(
          id: determineInitialMessagesSourceReadinessTripId,
          name: 'required_sources_initial_messages_readiness',
          steps: <Step>[
            TestStep(
              id: 6201,
              name: 'test_required_sources_initial_messages_readiness',
              testAgentId: messagesSourceReadableTestAgentId,
              testAgent: messagesSourceReadinessTestAgent,
              trueDestinationTripDefinitionId:
                  determineContactsSourceReadinessTripId,
              falseDestinationTripDefinitionId: null,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 6103,
        position: 2,
        trip: TripDefinition(
          id: guideUnreadableMessagesSourceTripId,
          name: 'required_sources_messages_remediation',
          steps: <Step>[
            const TellStep(
              id: 6301,
              name: 'explain_required_sources_messages_permission',
              text:
                  'MessageLens needs permission to read your Messages and '
                  'Contacts data. On macOS, Apple calls this Full Disk Access.',
            ),
            const TellStep(
              id: 6302,
              name: 'explain_required_sources_full_disk_access_action',
              text:
                  'In Full Disk Access, add or enable MessageLens Development. '
                  'macOS may ask you to quit and reopen the app after you make '
                  'the change.',
            ),
            OpenFdaSettingsStep(
              id: 6303,
              name: 'open_full_disk_access_for_required_sources',
              settingsOpeningAuthority: fdaSettingsOpeningAuthority,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 6104,
        position: 3,
        trip: TripDefinition(
          id: verifyMessagesSourceReadinessTripId,
          name: 'required_sources_messages_verification',
          steps: <Step>[
            const TellStep(
              id: 6401,
              name: 'orient_required_sources_messages_verification',
              text:
                  'Welcome back. I’ll check whether MessageLens can now read '
                  'the protected Messages database.',
            ),
            TestStep(
              id: 6402,
              name: 'test_required_sources_messages_verification',
              testAgentId: messagesSourceReadableTestAgentId,
              testAgent: messagesSourceReadinessTestAgent,
              trueDestinationTripDefinitionId: null,
              falseDestinationTripDefinitionId:
                  guideUnreadableMessagesSourceTripId,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 6105,
        position: 4,
        trip: TripDefinition(
          id: determineContactsSourceReadinessTripId,
          name: 'required_sources_contacts_readiness',
          steps: <Step>[
            TestStep(
              id: 6501,
              name: 'test_required_sources_contacts_readiness',
              testAgentId: contactsSourceReadableTestAgentId,
              testAgent: contactsSourceReadinessTestAgent,
              trueDestinationTripDefinitionId:
                  determineMessagesSourceHistorySufficiencyTripId,
              falseDestinationTripDefinitionId: null,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 6106,
        position: 5,
        trip: TripDefinition(
          id: guideUnavailableContactsSourceTripId,
          name: 'required_sources_contacts_remediation',
          steps: const <Step>[
            TellStep(
              id: 6601,
              name: 'explain_required_sources_contacts_unavailable',
              text:
                  'Your Messages history is available, but I couldn’t find or '
                  'read the local Contacts information MessageLens needs.',
            ),
            TellStep(
              id: 6602,
              name: 'guide_required_sources_contacts_retry',
              text:
                  'Open Contacts and confirm the people you expect are present '
                  'on this Mac. If sync or privacy settings recently changed, '
                  'allow them to settle, then continue and I’ll check again.',
            ),
            FixedDestinationStep(
              id: 6603,
              name: 'retry_required_sources_contacts_readiness',
              destinationTripDefinitionId:
                  determineContactsSourceReadinessTripId,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 6108,
        position: 6,
        trip: TripDefinition(
          id: determineMessagesSourceHistorySufficiencyTripId,
          name: 'determine_messages_source_history_sufficiency',
          steps: <Step>[
            TestStep(
              id: 6801,
              name: 'test_messages_source_history_sufficiency',
              testAgentId: messagesSourceHistorySufficientTestAgentId,
              testAgent: messagesSourceHistorySufficiencyTestAgent,
              trueDestinationTripDefinitionId:
                  confirmRequiredSourcesReadableTripId,
              falseDestinationTripDefinitionId:
                  guideSparseMessagesSourceHistoryTripId,
            ),
          ],
        ),
      ),
      ScheduleTripDefinition(
        occurrenceId: 6109,
        position: 7,
        trip: TripDefinition(
          id: guideSparseMessagesSourceHistoryTripId,
          name: 'guide_sparse_or_unsynced_messages_source',
          steps: <Step>[
            const TellStep(
              id: 6901,
              name: 'explain_sparse_messages_source_history',
              text:
                  'MessageLens found very little Messages history stored '
                  'locally on this Mac.',
            ),
            const TellStep(
              id: 6902,
              name: 'guide_sparse_messages_source_history_choice',
              text:
                  'Messages history may still be synchronizing. You can allow '
                  'more time and re-check, or continue with the local history '
                  'currently available.',
            ),
            ChoiceStep(
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
      ),
      ScheduleTripDefinition(
        occurrenceId: 6107,
        position: 8,
        trip: TripDefinition(
          id: confirmRequiredSourcesReadableTripId,
          name: 'required_sources_confirmation',
          steps: const <Step>[
            TellStep(
              id: 6701,
              name: 'confirm_required_sources_readable',
              text:
                  'MessageLens can read the local Messages and Contacts '
                  'information it needs.',
            ),
          ],
        ),
      ),
    ],
  );
}
