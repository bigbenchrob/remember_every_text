# Next Real Onboarding Concern Plan

## Status

Planning only. This document derives the next Presence experiment from the
current production onboarding implementation. It does not change production
startup, onboarding, persistence, or data.

## 1. Current Production Sequence After Messages Readability

`onboardingEnvironmentReportProvider` gathers the facts, then
`_OnboardingEnvironmentEvaluator` selects one blocker by precedence.
`OnboardingGate` converts the resulting environment state into gate status,
and the Environment Readiness feature presents the active blocker and its
available actions.

After the protected Messages SQLite read has succeeded, the current production
sequence is:

```text
Messages source readable
    -> defensively probe that chat.db still exists and is readable
    -> resolve and verify a viable local Address Book database
    -> count local Messages source rows
    -> surface simulated or persisted pipeline failures when applicable
    -> assess source-scoped import and conversation-graph readiness
    -> ready to import, retry, or enter the normal application
```

The detailed blocker precedence is:

1. `messagesDatabaseMissing` if the Messages file disappears or becomes
   unavailable between the operational readiness read and the report probe;
2. `addressBookUnavailable` if no viable local Address Book database can be
   resolved and read;
3. `sourceDataSparseOrUnsynced` if `chat.db.message` contains no more than ten
   rows;
4. simulated graph-projection failure, then simulated import failure, in
   development diagnostics;
5. an incomplete derived-data state that qualifies for automatic recovery;
6. a populated import ledger with an unready conversation graph;
7. a relevant persisted graph-projection failure, then a relevant persisted
   import failure;
8. missing source-scoped import database;
9. missing conversation graph;
10. empty source-scoped import database;
11. empty conversation graph;
12. no blocker: either the app is ready or it is ready for the user to start
    import.

The successful SQLite readiness probe already establishes that `chat.db`
existed and was queryable moments earlier. The additional file probe remains a
defensive current-state check. The first independent source concern after
Messages readability is therefore Address Book availability.

Current remediation follows the selected blocker:

- a missing or sparse Messages source shows local Messages/sync guidance and a
  `Re-check` action;
- unavailable Address Book data shows Contacts guidance and `Re-check`;
- initial import readiness offers `Import My Messages`;
- import or graph failure offers retry and diagnostic-report actions;
- complete graph readiness removes the onboarding gate.

## 2. Immediate Next Blocker

The immediate next blocker is:

> Can MessageLens discover and read a viable local Address Book database?

Production classifies failure as
`OnboardingBlockerKind.addressBookUnavailable`, maps it to the Contacts
Database readiness surface, and keeps `OnboardingGate` in
`awaitingUserAction`.

The production implementation currently treats this as a hard blocker. Some
existing UI wording says Contacts data *improves* context, which sounds
optional. That wording and the hard gate express different product claims.
This plan follows the implemented hard-gate behavior; making Contacts optional
would require a separate production and product decision.

## 3. Plain-English User Journey

MessageLens needs to establish that local Contacts information can be found
and read. Production currently requires that fact before allowing initial
import to proceed.

If Contacts is already available:

- MessageLens performs the check without introducing Address Book file names,
  database terminology, or troubleshooting copy;
- the user sees no Contacts-specific interruption;
- Presence proceeds quietly to the next established concern or, for this
  bounded experiment, to confirmation that both required sources are ready.

If Contacts is unavailable:

- MessageLens explains that Messages history is readable but local Contacts
  information could not be found or read;
- it asks the user to open Contacts, confirm that the expected contacts are
  present on this Mac, and allow local sync or privacy changes to settle;
- it offers a retry through the ordinary Trip route.

There is no current specialized Settings destination or automatic repair.
The user may be able to fix the condition by restoring local Contacts data or
waiting for sync, but MessageLens cannot guarantee that remediation. Restart
is not required. Restart is safe, and retry must perform a fresh discovery and
read rather than reuse a persisted readiness Boolean.

## 4. Existing Production Fact Source

The production fact originates from this chain:

```text
onboardingEnvironmentReportProvider
    -> futureGetFolderAggregateProvider
    -> AddressBookFolderRepository.getFinalFolderAggregate()
    -> AddressBookFolderPathsFinder
    -> ~/Library/Application Support/AddressBook/Sources/<UUID>/
    -> AddressBook-v22.abcddb candidates
```

`AddressBookFolderRepository` rejects candidates that cannot be opened and
queried. For each viable candidate it reads `ZABCDRECORD` summary facts and
constructs an `AddressBookFolderAggregate`. The onboarding evaluator selects
the aggregate's most recent path and performs its ordinary file probe. A
resolution failure, unreadable candidate set, absent selected file, or
unreadable selected file becomes `addressBookUnavailable`.

The Presence client should adapt this existing repository behavior. It should
not hard-code an Address Book path, scan directories itself, or consume the
whole onboarding environment report. Each retry should call the repository
again so discovery and readability are current.

## 5. Proposed Schedule Extension

The next Schedule revision should preserve the existing Messages readiness
and remediation flow, append a Contacts readiness test and remediation loop,
and finish with one combined source-readiness confirmation.

Proposed topology:

```text
introduce MessageLens
    -> determine initial Messages readability
        readable -> determine Contacts readability
        unreadable -> guide Full Disk Access

guide Full Disk Access
    -> verify Messages readability
        readable -> determine Contacts readability
        unreadable -> guide Full Disk Access

determine Contacts readability
    available -> confirm required sources readable
    unavailable -> guide unavailable Contacts source

guide unavailable Contacts source
    -> determine Contacts readability

confirm required sources readable
    -> complete
```

This revision requires a new Schedule identity and new definition/occurrence
identities. Existing definitions and run history must remain immutable.

### Reassessment of `confirm_messages_source_readable`

The Messages-only confirmation should not remain as an intervening Trip.
While it was a useful terminal presentation when Messages readability was the
entire experiment, it has no independent decision, obligation, or restart
value once another source check follows immediately.

After a successful Messages test, checkpointing the Contacts test Trip already
records the meaningful transition. An extra confirmation would require a user
action between an established fact and the next quiet check. The revised
Schedule should instead end this slice with
`confirm_required_sources_readable`, which truthfully confirms both Messages
and Contacts readiness.

This is not removal for Trip-count reduction. The semantic checkpoint moves
from "Messages is readable" to "begin the next required source check," and the
final confirmation now communicates the complete result established by this
bounded Schedule.

## 6. Trip-by-Trip Composition

### Introduce source readiness

**Purpose:** Orient the user to the source-readiness work.

**Ordered Steps:** Existing two `TellStep` definitions.

**Terminal Step:** Second `TellStep`.

**Result:** `null`.

**Default next:** Determine initial Messages source readiness.

**Alternate destination:** None.

**Restart suitability:** Restart begins the introduction again. No external
fact or accepted decision is lost.

### Determine initial Messages source readiness

**Purpose:** Perform the existing truthful Messages SQLite read.

**Ordered Steps:** Existing terminal `FdaTestStep`.

**Terminal Step:** `FdaTestStep`.

**Result:** Contacts-test Trip identity when readable; `null` when unreadable.

**Default next:** Full Disk Access guidance.

**Alternate destination:** Determine Contacts source readiness.

**Restart suitability:** Restart reruns the current external fact if the Trip
had not checkpointed; otherwise it resumes at the selected destination.

### Guide unreadable Messages source

**Purpose:** Explain only the permission and Settings action now required.

**Ordered Steps:** Existing remediation `TellStep` definitions followed by the
existing `OpenFdaSettingsStep`.

**Terminal Step:** `OpenFdaSettingsStep`.

**Result:** `null`.

**Default next:** Verify Messages source readiness.

**Alternate destination:** None.

**Restart suitability:** The next durable checkpoint is verification, so a
restart after opening Settings resumes at verification Step 1.

### Verify Messages source readiness

**Purpose:** Reorient after return and test the protected source again.

**Ordered Steps:** Existing returning-user `TellStep`, then existing terminal
`FdaTestStep`.

**Terminal Step:** `FdaTestStep`.

**Result:** `null` when readable; Full Disk Access guidance Trip identity when
unreadable.

**Default next:** Determine Contacts source readiness.

**Alternate destination:** Full Disk Access guidance.

**Restart suitability:** This remains the FDA restart checkpoint. Restart
begins with "Welcome back" and performs a fresh test.

### Determine Contacts source readiness

**Purpose:** Discover and read the local Address Book source without presenting
technical detail when it is already available.

**Ordered Steps:** One new terminal `ContactsSourceReadinessStep`.

**Terminal Step:** `ContactsSourceReadinessStep`.

**Result:** Final confirmation Trip identity when available; `null` when
unavailable.

**Default next:** Contacts remediation.

**Alternate destination:** Confirm required sources readable.

**Restart suitability:** Restart reruns the test if no destination has been
checkpointed. No readiness answer is persisted.

### Guide unavailable Contacts source

**Purpose:** Explain the failed Contacts fact and the actions currently
available to the user.

**Ordered Steps:** One or two narrowly written `TellStep` definitions followed
by a terminal `FixedDestinationStep`.

**Terminal Step:** `FixedDestinationStep`.

**Result:** Determine Contacts source readiness Trip identity.

**Default next:** Not used.

**Alternate destination:** Determine Contacts source readiness.

**Restart suitability:** Restart repeats the guidance from Step 1. Completing
the Trip returns to a fresh Contacts test.

### Confirm required sources readable

**Purpose:** Confirm the combined fact established by this bounded experiment.

**Ordered Steps:** One `TellStep` stating that MessageLens can read the local
Messages and Contacts information it needs.

**Terminal Step:** `TellStep`.

**Result:** `null`.

**Default next:** Schedule completion for this experiment.

**Alternate destination:** None.

**Restart suitability:** Restart resumes the confirmation until it is
completed. A completed run remains complete until explicitly replaced.

## 7. Existing Steps Reused

- `TellStep` continues to own all user-facing orientation and remediation
  copy.
- `FdaTestStep` remains limited to truthful Messages source readability.
- `OpenFdaSettingsStep` remains limited to opening the Full Disk Access pane.
- `FixedDestinationStep` returns from Contacts guidance to the canonical
  Contacts test Trip.

No existing Step should be generalized or renamed for this slice.

## 8. New Step Types, If Any

One concrete subtype is earned:

```text
ContactsSourceReadinessStep
```

Its exact workflow job is:

> Ask whether MessageLens can currently discover and read the local Contacts
> source, then return the configured canonical destination for the available
> or unavailable result.

Its persisted definition data should contain only:

- `step_definition_id`;
- nullable available destination `TripDefinitionId`;
- nullable unavailable destination `TripDefinitionId`.

The Step depends on one narrow `ContactsSourceReadinessAuthority`. It asks for
one Boolean operational fact and converts that private result into one of its
configured `TripDefinitionId?` arms.

It does not know paths, Address Book schema, folder ranking, provider state,
sync mechanisms, remediation copy, Trip occurrence identities, or Schedule
navigation.

`FdaTestStep` must not be reused: Contacts availability is neither an FDA
switch check nor the protected Messages read represented by that Step.

## 9. Specialist/Authority Boundary

The dependency direction should be:

```text
ContactsSourceReadinessStep
    -> ContactsSourceReadinessAuthority
    -> development client adapter
    -> existing AddressBookFolderRepository
    -> existing path finder and read-only Address Book query
```

Responsibilities remain:

- the Step owns workflow meaning and its two route arms;
- the narrow authority owns only the current Boolean readiness question;
- Address Book infrastructure owns path discovery, candidate validation, and
  source queries;
- Trip remains ignorant of the Step subtype and private result;
- Scheduler remains ignorant of Contacts and simply checkpoints the terminal
  canonical destination;
- the repository persists and reconstructs the concrete subtype.

Presence must not import the Address Book feature. The disposable development
client supplies the adapter, as it already does for onboarding's FDA service.

## 10. Restart/Retry Semantics

No new restart mechanism is required.

- The Trip remains the sole durable checkpoint.
- A process exit during the Contacts test reconstructs that Trip at Step 1 and
  performs the fact check again.
- Entry into Contacts remediation checkpoints that Trip; restart repeats its
  guidance.
- The terminal fixed destination returns to the Contacts test Trip.
- Each return executes fresh repository discovery and source validation.
- No Contacts-readable Boolean, current-Step index, retry counter, or pending
  action is persisted.
- Execution trace records observations but does not recover state.

## 11. Copy Considerations

When Contacts is available, introduce no Contacts database terminology and no
remediation explanation.

When unavailable, the copy should use the user-facing term **Contacts**. The
internal `AddressBook-v22.abcddb`, `Sources/<UUID>`, and `ZABCDRECORD` details
do not help the user act and remain diagnostic facts.

The remediation should communicate only:

1. Messages history is available;
2. local Contacts information could not be found or read;
3. open Contacts and confirm the expected people are present on this Mac;
4. allow recent sync or privacy changes to settle;
5. continue to retry the check.

The copy must not promise that opening Contacts will repair the condition. The
current implementation cannot observe iCloud Contacts sync state or identify
one universal remedy.

The existing production wording also needs a later product decision: calling
Contacts merely helpful is inconsistent with blocking setup when Contacts is
unavailable.

## 12. Manual Test Matrix

| Scenario | Expected route and presentation |
| --- | --- |
| Messages readable, Contacts available | Contacts test passes silently; combined source confirmation appears |
| Messages unreadable, Contacts available | FDA guidance -> restart verification -> Contacts test -> combined confirmation |
| Messages readable, Contacts unavailable | Contacts test -> Contacts guidance; no FDA remediation appears |
| Contacts becomes available during guidance | Complete guidance -> fresh Contacts test -> combined confirmation |
| Contacts remains unavailable | Guidance and test Trips loop through ordinary canonical routing |
| Restart during Contacts guidance | Resume Contacts guidance at Step 1 |
| Restart after return to Contacts test | Resume test Trip at Step 1 and query the source again |
| Address Book path exists but SQLite query fails | Treat as unavailable and show the same bounded remediation |
| Multiple Address Book candidates exist | Existing repository selects from viable candidates; Presence learns only readiness |
| Completed run relaunched | Remain complete until explicit `Run Again` |
| `Run Again` | Create a new run at the introduction; preserve prior definitions, runs, and traces |

The experiment should also verify that the available path does not flash or
briefly render Contacts remediation copy.

## 13. What Can Be Implemented Without Changing Presence

The next slice can preserve:

- the single `ScheduleDefinition` model;
- the single runtime `Trip` class;
- terminal-Step `TripDefinitionId?` results;
- default-next and canonical-destination routing;
- `PresenceScheduler` behavior;
- Trip-boundary `ScheduleRun` checkpoints;
- restart reconstruction;
- append-only trace semantics;
- the development host's existing completion interaction.

The implementation would add one earned concrete Step subtype, its narrow
definition table and repository mapping, one authority contract, one
development adapter, a revised fixture with new identities, and focused tests.
Those are extensions through existing boundaries, not changes to routing or
runtime architecture.

## 14. What Would Require an Architectural Decision

The following are outside this slice and must not be inferred:

- allowing onboarding to continue without Contacts;
- distinguishing missing, unreadable, unsynced, privacy-blocked, and malformed
  Contacts sources as separate workflow results;
- adding a dedicated Contacts Settings or application-opening action;
- carrying diagnostic payloads through Step results;
- adding automatic polling or retry timing;
- integrating the Presence Schedule into production `OnboardingGate`;
- replacing the production Environment Readiness surface;
- deciding the next blocker after Contacts availability.

Most importantly, production currently treats Contacts as mandatory while its
presentation describes Contacts primarily as an enhancement. Resolving that
product contradiction is required before eventual production integration, but
it does not prevent the development Presence host from truthfully modeling the
current production sequence.

## Conclusion

Messages readability is proven. Production next checks whether it can discover
and read a viable local Address Book source. Presence can express that concern
with one narrow Contacts readiness test Trip, one remediation-and-retry Trip,
and one combined source confirmation Trip.

If Contacts is already available, the user proceeds quietly. If it is not, the
user receives only the guidance relevant to restoring local Contacts data and
then retries the same fresh factual check.

The next slice requires no change to `Trip`, `PresenceScheduler`, routing
semantics, or `ScheduleRun` checkpoint semantics.
