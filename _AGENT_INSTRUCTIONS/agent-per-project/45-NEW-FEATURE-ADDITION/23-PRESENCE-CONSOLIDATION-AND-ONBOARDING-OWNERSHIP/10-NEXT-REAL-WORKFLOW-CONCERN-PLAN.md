---
tier: project
scope: presence-next-real-workflow-concern
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: code-audit
links:
  - 00-START-HERE.md
  - 09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
  - ../22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/07-CONTACTS-SOURCE-READINESS-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
  - ../../25-ONBOARDING-AND-ARCHIVE/20-environment-readiness.md
tests: []
---

# Next Real Workflow Concern Plan

## 1. Current Production Sequence After Required-Source Readiness

The current production sequence is derived from
`OnboardingEnvironmentReport`, `OnboardingGate`, and the onboarding overlay.
The order matters because the environment classifier gives earlier blockers
precedence over later ones.

```text
Messages source readable and Contacts source available
    |
    v
Count rows in the local Messages `message` table
    |
    +-- 0-10 rows
    |      -> sourceSparseOrUnsynced
    |      -> explain likely incomplete local history
    |      -> user may re-check after Messages/iCloud sync
    |      -> user may explicitly choose Import Anyway
    |
    +-- more than 10 rows, or count unavailable
           -> inspect import-ledger and graph state
                  |
                  +-- populated import + ready graph
                  |      -> normal application
                  |
                  +-- inconsistent derived state
                  |      -> automatic derived-data recovery
                  |
                  +-- recorded import/graph failure
                  |      -> retry and diagnostic presentation
                  |
                  +-- missing or empty derived data
                         -> Ready to Import
                         -> user chooses Import My Messages
                         -> source import and graph build
                         -> completion or failure
```

The production items after required-source readiness are:

| Order | Fact or operation | Current owner | Current specialist | Precedence and user response | Shape |
| --- | --- | --- | --- | --- | --- |
| 1 | Is the local Messages history plausibly populated? | Onboarding | `OnboardingDatabaseProbeReader.readTableCount()` over `chat.db.message` | Before import and graph concerns. Sparse history offers re-check or explicit import override. | Boolean assessment plus user decision on failure |
| 2 | Are derived import and graph stores already usable? | Onboarding interprets; DB and Conversation Graph essentials supply facts | `OnboardingDatabaseProbeReader` and `ConversationGraphReadiness` | Ready state enters the normal app; missing/empty state asks the user to import. | Factual classification and user decision |
| 3 | Did a prior import or graph projection fail? | Onboarding | `OnboardingFailureStore`, database probes, graph readiness | Failure states precede ordinary ready-to-import presentation and offer retry/reporting. | Failure reconciliation and user action |
| 4 | Is partially built derived state clearly inconsistent? | Onboarding recovery policy | `MessageDataResetService`, `ArchiveMutationCoordinator`, graph-build services | Automatic recovery may reset derived data before a retry. | Long-running operation |
| 5 | Build the initial imported ledger and conversation graph. | Onboarding coordinates; source import and Conversation Graph own work | `ConversationGraphBuildController` and its build orchestration | Runs only after user initiation; reports running, complete, or failed. | User decision followed by long-running operation |

Attachment archive evidence is present in the environment report, but current
classification does not make attachment archival the next onboarding blocker.
It is therefore not selected here.

## 2. Immediate Next Concern

The immediate next independent concern is:

> Does this Mac contain enough local Messages history to make the intended
> initial import plausible, or has the user knowingly accepted a genuinely
> small local archive?

Production currently treats a non-null count of ten or fewer rows in
`chat.db.message` as `sourceSparseOrUnsynced`. This follows source
accessibility and precedes import-ledger and graph readiness.

This concern is not another readability test. A readable database can still
contain little useful local history.

## 3. Plain-English User Journey

1. MessageLens has established that it can read Messages and Contacts.
2. It explains that it will check whether enough Messages history is actually
   present on this Mac.
3. If more than ten local message rows are present, MessageLens confirms that
   the local history is sufficient for the next stage.
4. If ten or fewer rows are present, MessageLens explains that Messages in
   iCloud or local account synchronization may not have finished.
5. The user may open Messages, confirm the expected Apple Account and history,
   wait for local synchronization, and ask MessageLens to test again.
6. If the small local archive is intentional, the user may explicitly choose
   to continue with it.

Answers to the concrete workflow questions:

- **What must be established?** Whether the local Messages history is
  plausibly populated, or deliberately accepted despite being small.
- **Why does it matter?** Importing an unexpectedly empty local archive would
  produce a technically valid but misleadingly incomplete MessageLens archive.
- **Satisfactory outcome:** A calm confirmation that the local history is
  ready for the next onboarding stage.
- **Unsatisfactory outcome:** Guidance to let Messages/iCloud synchronization
  complete, followed by a fresh test.
- **Does MessageLens perform work?** It performs only a read-only count for
  this concern.
- **Does a specialist perform work?** An Onboarding-owned Test Agent delegates
  the factual database read to a read-only specialist.
- **Is there a user decision?** Yes. Production permits either re-testing or
  knowingly importing the small archive anyway.
- **Can the world change externally?** Yes. Apple Messages may synchronize more
  local history while MessageLens is closed.
- **Is restart relevant?** Yes. A restart must repeat the current Trip's
  explanation and make a fresh factual test rather than preserve an old result.
- **Workflow boundary:** This remains Onboarding. No archive import has begun.

## 4. Current Implementation Owner

`lib/essentials/onboarding/` owns the meaning and policy today:

- `_OnboardingEnvironmentEvaluator` defines the sparse-history threshold and
  blocker precedence;
- `OnboardingEnvironmentState.sourceSparseOrUnsynced` and
  `OnboardingBlockerKind.sourceDataSparseOrUnsynced` describe the result;
- the onboarding overlay explains the condition and offers `Re-check
  Environment` or `Import Anyway`.

The concern should remain Onboarding-owned in the experiment. Presence must
not learn what a Messages row count means.

## 5. Current Factual/Operational Specialist

The current production fact is read through
`OnboardingDatabaseProbeReader.readTableCount()` and its read-only SQLite
implementation. It executes `COUNT(*)` against the `message` table and returns
an optional integer.

There is also a Conversation Graph specialist,
`ChatDbSourceProbeReader.readImportableMessageCount()`, but it counts only rows
with a non-empty `guid`. That is not the same fact as production's current
`COUNT(*)` policy. It must not be substituted silently merely because it is a
more specialized existing abstraction.

The proposed workflow adapter is an Onboarding-owned Boolean Test Agent with a
stable identity such as:

```text
TestAgentId
    onboarding.messages-source-history-sufficient

Onboarding Test Agent
    owns threshold interpretation

Read-only source specialist
    owns the SQLite fact read
```

The implementation pass must first settle whether to preserve the current
all-row count exactly or intentionally adopt the importable-row count. This is
a measurement-contract decision, not a Presence decision.

## 6. Is This Still Onboarding?

Yes.

The meaning of the concern is whether the source environment is ready enough
for the user to begin initial ingestion. No MessageLens archive mutation has
started. Onboarding owns both the warning policy and the user's informed
decision to proceed with an intentionally small source.

The workflow crosses into ingestion only after the later `Import My Messages`
decision starts the source import and graph build.

## 7. Required Step Shapes

The real workflow requires:

| Mechanical job | Step shape |
| --- | --- |
| Explain the check and its result | `TellStep` |
| Ask whether local history exceeds the accepted threshold | Existing generic Boolean `TestStep` |
| Return from guidance to a fresh assessment | Existing `FixedDestinationStep` or one destination of a user choice |
| Choose between re-checking and accepting a small archive | A narrow two-destination user-choice shape not currently present |

It does not require `OpenFdaSettingsStep`, a new operation shape, a
long-running work shape, polling, or progress persistence.

## 8. Generic TestStep Usage

The assessment fits the proven generic Test architecture exactly:

```text
TestStep
    -> opaque TestAgentId
    -> Onboarding binding
    -> Onboarding-owned TestAgent
    -> read-only row-count specialist
    -> Boolean result
    -> true/false Trip destination
```

Presence needs to know only the opaque Agent identity and two destinations.
It must not know the threshold, database path, table name, SQL, sync meaning,
or onboarding copy.

The truthful Boolean contract should be:

- `true`: the agreed count semantics produce more than ten messages;
- `false`: the agreed count semantics produce zero through ten messages;
- read failure: evaluation failure, not a fabricated Boolean result.

Production currently converts a failed count to `null` and does not classify
that as sparse. A Test Agent cannot truthfully turn “unknown” into either
Boolean. The implementation slice must explicitly reconcile that difference,
preferably by allowing the already-proven source-readability prerequisite and
the specialist's failure behavior to remain visible rather than treating
unknown as success.

## 9. Operation-Shaped Step Evidence

No operation-shaped Step appears in this concern.

Opening Apple Messages, checking the signed-in account, and waiting for iCloud
history are user or external-system actions. MessageLens does not command or
await a specialist operation. It simply tests the factual condition again when
the user is ready.

The later import and graph build are genuine long-running operations, but they
are not the immediate concern selected for this pass.

## 10. Comparison With OpenFdaSettingsStep

| Question | `OpenFdaSettingsStep` | Local-history sufficiency concern |
| --- | --- | --- |
| What does the Step know? | A settings-opening authority and completion of the open request | Only an opaque Test Agent identity and Boolean destinations |
| What does the specialist know? | How to open the macOS FDA settings surface | How to obtain the agreed source-history count; Onboarding knows the threshold meaning |
| What is returned? | `Future<void>` from the settings-opening operation | `Future<bool>` from the Test Agent |
| What constitutes completion? | The request to open settings completes | The factual read produces a Boolean answer |
| What constitutes failure? | The settings-opening operation throws/fails | The factual read or Agent evaluation throws/fails |
| Does completion route directly? | No specialized route result; normal Trip progression follows | Yes, the Boolean chooses the configured destination |
| Persisted configuration? | The specialized persisted subtype identifies the operation | Existing generic Test definition stores Agent ID and destinations |

These are not two instances of the same mechanical pattern. This concern adds
no evidence for generalizing `OpenFdaSettingsStep`.

## 11. Proposed Schedule Extension

Keep `confirm_required_sources_readable` as an independent Trip. It still has:

- useful meaning: both protected sources are accessible;
- checkpoint value: FDA and Contacts remediation need not replay after restart;
- a natural transition role: it separates “can read the sources” from “is the
  local Messages history sufficiently populated?”

Append the minimum new topology:

```text
confirm_required_sources_readable
    |
    v
determine_messages_source_history_sufficiency
    |
    +-- true  -> confirm_messages_source_history_accepted
    |
    +-- false -> guide_sparse_or_unsynced_messages_source
                       |
                       +-- Re-check -> determine_messages_source_history_sufficiency
                       |
                       +-- Import Anyway -> confirm_messages_source_history_accepted
```

The final confirmation means the source history is accepted for the next
stage, either because it is plausibly populated or because the user knowingly
accepted the small archive. It must not falsely claim that a sparse source
became large.

No numeric Trip or Step IDs are selected in this planning pass. An
implementation must allocate stable, non-conflicting persisted identities
after inspecting the current ranges.

## 12. Trip-by-Trip Composition

### Determine Messages Source History Sufficiency

- **Purpose:** Introduce and perform a fresh source-history assessment.
- **Ordered Steps:**
  1. `TellStep`: explain that MessageLens will check whether local Messages
     history appears sufficiently populated.
  2. `TestStep`: evaluate the Onboarding-owned history-sufficiency Agent.
- **Terminal Step:** `TestStep`.
- **Result semantics:** `true` means sufficient; `false` means sparse or
  likely unsynced.
- **Default next:** Sparse-history guidance, using the false/default route in
  the same style as the current Schedule where appropriate.
- **Explicit alternate:** Sufficient-history confirmation on `true`.
- **Restart suitability:** Strong. Restart repeats the orientation and obtains
  a new reading from the externally changeable source.

### Guide Sparse Or Unsynced Messages Source

- **Purpose:** Explain why the source may be incomplete and present the two
  truthful user choices already present in production.
- **Ordered Steps:**
  1. `TellStep`: explain that only a very small local history was found.
  2. `TellStep`: advise opening Messages, checking the Apple Account and local
     history, and waiting for synchronization if appropriate.
  3. **Required user-choice Step:** choose either `Re-check` or `Import Anyway`.
- **Terminal Step:** The required two-destination user-choice shape.
- **Result semantics:** One choice requests a fresh factual assessment; the
  other records informed acceptance of the small local source.
- **Default next:** No hidden default should silently choose on the user's
  behalf.
- **Explicit alternates:** Re-check routes to assessment; Import Anyway routes
  to accepted-history confirmation.
- **Restart suitability:** Strong. Restart repeats the warning and decision;
  neither choice should be inferred from a previously displayed screen.

### Confirm Messages Source History Accepted

- **Purpose:** Mark a meaningful checkpoint before later import-readiness work.
- **Ordered Steps:** One `TellStep` confirming that MessageLens is ready to use
  the local history selected for the next stage.
- **Terminal Step:** `TellStep`.
- **Result semantics:** Normal progression only.
- **Default next:** Schedule completion for this bounded experiment. A later
  planning pass may connect it to import-state readiness.
- **Explicit alternates:** None.
- **Restart suitability:** Strong. It is a truthful checkpoint whether reached
  through sufficient history or informed override.

## 13. Restart/Checkpoint Implications

The current Trip-granular checkpoint model is sufficient:

- restarting during assessment repeats its explanation and performs a fresh
  test;
- restarting during guidance repeats the warning and asks the user again;
- no stale Boolean result is persisted as environmental truth;
- external Messages synchronization may change the next result;
- reaching the accepted-history confirmation prevents replay of completed FDA,
  Contacts, and source-history remediation Trips.

Current-Step persistence is neither needed nor justified.

## 14. Long-Running Work/Progress Ownership, If Relevant

There is no long-running MessageLens operation in the selected concern.
Waiting for Apple Messages or iCloud synchronization is external waiting, not
an operation whose progress Presence can own or poll.

Later, initial import and graph construction will require distinct states for
start, running, complete, and failed. Current production assigns durable work
and recovery truth to Onboarding, archive-mutation coordination, source import,
and Conversation Graph services. Presence should eventually sequence and
present that specialist-owned durable operation; it should not absorb its
progress state. That later concern is outside this plan.

## 15. Manual Test Possibilities

The bounded slice can be tested without changing production data:

- bind a fake Test Agent returning `true` and verify the sufficient route;
- bind a fake Test Agent returning `false` and verify the guidance route;
- change the fake result from `false` to `true`, re-check, and verify the new
  route;
- restart in assessment, guidance, and confirmation Trips and verify
  Trip-granular replay/checkpoint behavior;
- use temporary SQLite fixtures containing exactly 10 and 11 `message` rows to
  protect the threshold boundary;
- use the existing development `simulateSparseSourceHistory` facility only as
  comparative evidence for current production presentation;
- verify the informed override path once a user-choice shape exists.

No test should truncate, edit, or replace the real `chat.db`.

## 16. What Can Be Implemented With Current Presence

Current Presence can already express:

- all explanatory and confirmation Tells;
- the Boolean source-history test through generic `TestStep`;
- the sufficient-history route;
- the sparse-history route;
- a single deterministic retry route through `FixedDestinationStep`;
- Trip-granular restart and checkpoint behavior.

It cannot faithfully express both production choices after a sparse result.
Using only a fixed destination would remove `Import Anyway`; automatically
continuing would remove informed consent; using unrelated buttons outside the
Step grammar would bypass the Schedule. Each would misrepresent the real
workflow.

## 17. What Would Require A New Architectural Decision

One concrete mechanical requirement is now exposed:

> Present two explicit user choices and route the Trip according to the user's
> selected destination.

This is a user-choice shape, not an operation shape and not an `ActionStep`.
Before the complete production-equivalent Schedule extension can be
implemented, a separate bounded design pass must decide how such choices are
defined, rendered, completed, and persisted without introducing payload bags
or a general interaction framework.

Two smaller contracts also require explicit implementation decisions:

1. whether sufficiency continues to count every `message` row or adopts the
   existing importable-row definition;
2. how an unavailable count remains an evaluation failure rather than being
   coerced to `true` or `false`.

Neither question requires a Presence schema change by itself. The
user-choice shape may require persisted grammar, but that decision must be made
in its own reviewed pass.

## 18. Recommended Next Implementation Slice

Do not extend the live Schedule yet.

The next implementation slice should first establish the behavior-preserving,
Onboarding-owned source-history sufficiency Test Agent:

1. settle and document the count semantics against current production;
2. add one stable Onboarding Agent ID and concrete Test Agent;
3. bind it through the existing Onboarding Test Agent contribution;
4. add focused 10-row, 11-row, failure, binding, and dependency-boundary tests;
5. make no Schedule, schema, production-gate, or presentation change.

After that slice is verified, perform a separate narrow design pass for the
now-proven two-destination user-choice requirement. Only then should the three
Trips above be added to the development Schedule.

## Explicit Answers

- **What is the next real concern?** Whether the local Messages history is
  sufficiently populated, or knowingly accepted despite being small.
- **Who owns its meaning?** Onboarding.
- **What does Presence need to know?** An opaque Test Agent ID, Boolean
  destinations, ordinary Tell content, and eventually the destinations chosen
  by one explicit user-choice Step. It needs no Messages, SQL, threshold, sync,
  or import knowledge.
- **Did this concern produce a second genuine operation-shaped Step?** No.
- **Has ActionStep now earned a design pass?** No. The new evidence supports a
  narrowly bounded user-choice design question, not a generic action
  abstraction.
