import '../../presence/application/current_presence_guidebook_catalog.dart';
import '../../presence/application/presence_guidebook_runtime_materializer.dart';
import '../../presence/domain/entities/schedule_definition.dart';
import '../../presence/domain/services/fda_settings_opening_authority.dart';
import '../../presence/domain/services/test_agent_resolver.dart';

// Transitional materialization adapter for existing callers and tests.
//
// Authored Schedule geometry is owned by the Presence guidebook catalog.
export '../../presence/application/current_presence_guidebook_catalog.dart'
    show
        classifyMessagesSourceFailureTripId,
        confirmRequiredSourcesReadableTripId,
        contactsSourceReadableTestAgentId,
        determineContactsSourceReadinessTripId,
        determineInitialMessagesSourceReadinessTripId,
        determineMessagesSourceHistorySufficiencyTripId,
        guideSparseMessagesSourceHistoryTripId,
        guideUnavailableContactsSourceTripId,
        guideUnavailableMessagesSourceTripId,
        guideUnreadableMessagesSourceTripId,
        introduceMessageLensTripId,
        messagesSourceAccessDeniedTestAgentId,
        messagesSourceHistorySufficientTestAgentId,
        messagesSourceReadableTestAgentId,
        requiredSourcesReadinessScheduleId,
        verifyMessagesSourceReadinessTripId;

/// Materializes today's pure catalog through the existing runtime boundary.
///
/// Runtime installation remains `installOrExtendDefinition` until guidebook
/// lifecycle replacement is implemented in a later slice.
ScheduleDefinition buildRequiredSourcesReadinessDefinition({
  required TestAgentResolver testAgentResolver,
  required FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority,
}) {
  final catalog = currentPresenceGuidebookCatalog();
  return materializePresenceGuidebookSchedule(
    schedule: catalog.scheduleById(requiredSourcesReadinessScheduleId),
    testAgentResolver: testAgentResolver,
    fdaSettingsOpeningAuthority: fdaSettingsOpeningAuthority,
  );
}
