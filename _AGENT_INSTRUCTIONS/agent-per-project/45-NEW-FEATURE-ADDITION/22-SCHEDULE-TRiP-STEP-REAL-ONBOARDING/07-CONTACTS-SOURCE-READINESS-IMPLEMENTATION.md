# Contacts Source Readiness Implementation

## Status

Implemented in the development-only Presence onboarding experiment. Production
`OnboardingGate` and the existing production onboarding flow are unchanged.

## Production Fact Reused

The experiment reuses the fact already established by
`AddressBookFolderRepository.getFinalFolderAggregate()`: whether MessageLens
can currently discover and read at least one viable local Contacts source.

The existing repository remains responsible for path discovery, candidate
validation, read-only SQLite access, and failure detail. Presence receives only
a Boolean readiness answer.

## New Step Subtype

`ContactsSourceReadinessStep` asks one
`ContactsSourceReadinessAuthority` for the current fact and returns one of two
configured canonical destinations:

- available destination;
- unavailable destination.

Either destination may be `null`, preserving the existing default-next route.
The Step is terminal and knows nothing about paths, Address Book schema,
remediation, occurrences, or Schedule navigation.

## Narrow Authority And Adapter

The permanent Presence subsystem owns only:

```text
ContactsSourceReadinessAuthority.canReadContactsSource() -> Future<bool>
```

Onboarding owns `ContactsSourceReadinessPresenceAdapter`. It delegates every
invocation to
`AddressBookFolderRepository.getFinalFolderAggregate()` and maps `Right` to
available and `Left` to unavailable.

No readiness Boolean is cached or persisted. Re-entering the Contacts test
causes a fresh repository discovery and read.

The development experiment remains the first client and supplies a disposable
source-selection seam. It does not own the real adapter or the onboarding
Schedule.

## Schema Change

`presence.db` advances from schema version 5 to 6. The new class table is:

```text
contacts_source_readiness_step_definitions
    step_definition_id
    available_destination_trip_definition_id nullable
    unavailable_destination_trip_definition_id nullable
```

The base `step_definitions.type` constraint now admits
`contacts_source_readiness`. Migration creates the new subtype table while
preserving existing definitions, Schedule runs, and append-only execution
trace history.

## Revised Schedule

The active experiment uses new durable identities: Schedule `6`, Trip
definitions `301` through `307`, and occurrence identities `6101` through
`6107`. Schedule 5 and all of its historical definitions and runs remain
untouched.

Trip and Step definition names are also persisted global identities in the
current schema. Schedule 6 therefore uses its own `required_sources_*`
diagnostic names rather than reusing names already owned by Schedule 5. This
allows both definitions to coexist without changing their IDs, routes, copy,
or execution behavior.

```text
required_sources_introduction
    -> required_sources_initial_messages_readiness

Messages readable
    -> required_sources_contacts_readiness

Messages unreadable
    -> required_sources_messages_remediation
    -> required_sources_messages_verification

verified Messages readable
    -> required_sources_contacts_readiness

Contacts available
    -> required_sources_confirmation
    -> complete

Contacts unavailable
    -> required_sources_contacts_remediation
    -> required_sources_contacts_readiness
```

The Contacts retry is ordinary Trip routing. There is no retry counter, loop
object, automatic polling, or current-Step persistence.

## Messages-Only Confirmation

The active Schedule does not include `confirm_messages_source_readable`.
Successful initial or post-FDA Messages verification checkpoints directly into
the Contacts test. The only final confirmation communicates the combined fact
established by this bounded experiment.

## User-Facing Copy

Unavailable Contacts guidance says:

> Your Messages history is available, but I couldn't find or read the local
> Contacts information MessageLens needs.

> Open Contacts and confirm the people you expect are present on this Mac. If
> sync or privacy settings recently changed, allow them to settle, then
> continue and I'll check again.

The final confirmation says:

> MessageLens can read the local Messages and Contacts information it needs.

The available path introduces no technical Contacts explanation. Internal file
names, source directories, and schema terminology remain outside presentation.

## Restart And Retry

- Restart during Contacts guidance resumes that Trip at Step 1.
- Completing guidance checkpoints the canonical Contacts test Trip.
- Restart at the Contacts test reconstructs that Trip at Step 1.
- Every test completion invokes the Address Book repository again.
- A completed Schedule remains complete until the development-only `Run Again`
  action creates a fresh run.

Trip, Scheduler, routing, checkpoint, and restart semantics did not change.

## Test Evidence

Focused coverage establishes:

- subtype persistence and reconstruction;
- coexistence with the globally unique Trip and Step names retained by
  Schedule 5;
- schema migration with definitions, active run, and trace preserved;
- explicit available and nullable/default unavailable route arms;
- fresh authority and repository invocation on each retry;
- unavailable remediation loops and later recovery;
- restart at guidance and test checkpoints;
- combined source confirmation and absence of the obsolete confirmation;
- generated Mermaid and live-map topology;
- observational trace behavior;
- unchanged generic Trip and Scheduler boundaries.

## Manual Test

The controlled unavailable/recovery procedure is now defined in
[`08-DISPOSABLE-CONTACTS-SOURCE-TEST-SEAM.md`](08-DISPOSABLE-CONTACTS-SOURCE-TEST-SEAM.md).
It exercises this Schedule without manipulating Apple's live Address Book
database.

Do not alter production data or production onboarding to perform this test.

## Unresolved Product Contradiction

Production currently treats Contacts availability as a hard onboarding blocker,
while some existing copy describes Contacts primarily as improving contextual
quality. This implementation follows current production behavior and keeps
Contacts required. It does not resolve whether that product policy is correct.

## Architecture Result

No Presence architecture changed. The implementation adds one earned concrete
Step subtype through the existing definition, repository, Trip, Scheduler,
route, checkpoint, trace, and development-client boundaries.

## Boundary Summary

**What Contacts infrastructure knows:** source locations, candidate discovery,
SQLite readability, ranking, and diagnostic failure details.

**What the Step knows:** one Boolean readiness fact and two configured canonical
destination arms.

**What the user sees:** no interruption when Contacts is available; bounded,
actionable Contacts guidance when it is unavailable.

**What Trip knows:** the terminal Step returned a possible
`TripDefinitionId?`.

**What Scheduler knows:** the Trip completed and its canonical result must be
checkpointed using the existing routing rules.
